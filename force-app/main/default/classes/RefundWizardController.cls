public with sharing class RefundWizardController {
    
  	@AuraEnabled
    public static List<OptionsWrap> getPickListValuesIntoList(String objectType, String selectedField){
        List<OptionsWrap> pickListValuesList = new List<OptionsWrap>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(new OptionsWrap(pickListVal.getValue(),pickListVal.getLabel()));
        }     
        
        System.debug('**pickListValuesList***'+pickListValuesList);
        return pickListValuesList;
        
    }
    
    public class OptionsWrap {

        @AuraEnabled public String value {get; set;}
        @AuraEnabled public String label {get; set;}
        
        public OptionsWrap(String strValue, String strLabel) {
            
            this.value = strValue;
            this.label = strLabel;
        }
    }
    
    

    @AuraEnabled
    public static DonationWrapper getDonationPayments(Id donationId) {

        DonationWrapper wrapper = new DonationWrapper();

        wrapper.donation = [SELECT Id, Name, Website_Code__c,Total_Donation_Amount__c,  CurrencyIsoCode, npsp__Primary_Contact__c, GUID__c,(SELECT id,Name ,npsp__General_Accounting_Unit__r.Id,npsp__General_Accounting_Unit__r.Name,npsp__Amount__c,npsp__Opportunity__c,Parent_Allocation__c	 FROM npsp__Allocations__r)  
                            FROM Opportunity 
                            WHERE Id = :donationId];

        wrapper.allocations = new List<AllocationWrapper>();
        Map<String,Decimal> mapAmount = new Map<String,Decimal>();
        
        for (npsp__Allocation__c objAllocation : wrapper.donation.npsp__Allocations__r) {
            
            String keyString = objAllocation.npsp__General_Accounting_Unit__r.Id+'-'+objAllocation.Parent_Allocation__c;
                
            if (objAllocation.Parent_Allocation__c == null) {
               
                keyString = objAllocation.npsp__General_Accounting_Unit__r.Id+'-'+objAllocation.Id;
            }
            
            if (mapAmount.containsKey(keyString)) {
                
                Decimal intialAmount = mapAmount.get(keyString);
                Decimal addedAmount = intialAmount +  objAllocation.npsp__Amount__c;
                mapAmount.put(keyString,addedAmount);
            }
            else {
                
               mapAmount.put(keyString,objAllocation.npsp__Amount__c); 
            }
        }  
        
        for (npsp__Allocation__c objAllocation : wrapper.donation.npsp__Allocations__r) {
            
            if (objAllocation.npsp__Amount__c > 0) {
                
                objAllocation.npsp__Amount__c  =  mapAmount.get(objAllocation.npsp__General_Accounting_Unit__r.Id+'-'+objAllocation.Id);
                wrapper.allocations.add(new AllocationWrapper(objAllocation,0.0));
            }         
        } 
        
        

        wrapper.refunds = new List<RefundWrapper>();

        List<npe01__OppPayment__c> payments = new List<npe01__OppPayment__c>();

        
        payments = [SELECT Id, Name, npe01__Opportunity__c,npe01__Opportunity__r.Total_Donation_Amount__c, npe01__Opportunity__r.Name, 
                    npe01__Opportunity__r.Total_Refund__c, npe01__Opportunity__r.npe01__Amount_Outstanding__c, npe01__Opportunity__r.npe01__Payments_Made__c,
                    npe01__Payment_Amount__c, npe01__Payment_Method__c, npe01__Payment_Date__c, 
                    Card_Payment_History__c, Card_Payment_History__r.Name, Card_Payment_History__r.Order_Id__c, Card_Payment_History__r.Income_Card_Payment__c  
                    FROM npe01__OppPayment__c 
                    WHERE (npe01__Opportunity__c = :donationId OR npe01__Opportunity__r.npe03__Recurring_Donation__r.Opportunity__c = :donationId)
                    AND npsp__Type__c != 'Refund' 
                    ORDER BY npe01__Payment_Date__c DESC];
        
        for(npe01__OppPayment__c payment : payments)
        {
            RefundWrapper refund = new RefundWrapper();
            refund.checked = false;
            refund.payment = payment;
            refund.refundAmount = payment.npe01__Opportunity__r.Total_Donation_Amount__c;
            refund.refundDate = date.today();
            refund.refundPaid = false;
            if(((payment.npe01__Opportunity__r.npe01__Amount_Outstanding__c + payment.npe01__Opportunity__r.npe01__Payments_Made__c) - (payment.npe01__Opportunity__r.Total_Refund__c * -1)) <= 0){
                refund.disabled = true;
            }else{
                refund.disabled = false;
            }
            wrapper.refunds.add(refund);
        }

        return wrapper;
    }

    @AuraEnabled
    public static ResponseWrapper insertRefunds(DonationWrapper donationWrapperIn,String transactionId,String refundReason,String giftAidPrecluded) {

        Savepoint sp;
        Boolean setSavePoint = false;

        try {

            ResponseWrapper paymentResponse = new ResponseWrapper();
            paymentResponse.hasError = false;
            List<npe01__OppPayment__c> refunds = new List<npe01__OppPayment__c>();
            Set<Id> refundHistories = new Set<Id>();
            
            if(donationWrapperIn.refundType == 'Card Payment')
            {
                Payment_Country_Setting__mdt setting = [SELECT SmarterPay_User_Name__c, APIKey__c FROM Payment_Country_Setting__mdt WHERE DeveloperName = :donationWrapperIn.donation.Website_Code__c];

                for(RefundWrapper wrapper : donationWrapperIn.refunds)
                {
                    SMP_PaymentGateway.Refund gatewayRefundWrapper = new SMP_PaymentGateway.Refund();
                    gatewayRefundWrapper.incomeusername = setting.SmarterPay_User_Name__c;
                    gatewayRefundWrapper.APIKey = setting.APIKey__c;
                    gatewayRefundWrapper.incomeCardPaymentId = wrapper.payment.Card_Payment_History__r.Income_Card_Payment__c;
                    gatewayRefundWrapper.amount = wrapper.refundAmount;
                    gatewayRefundWrapper.currencyCode = donationWrapperIn.donation.CurrencyIsoCode;
                    gatewayRefundWrapper.chargeId = wrapper.payment.Card_Payment_History__r.Order_Id__c;
                    gatewayRefundWrapper.customerPaymentReference = 'Refund';
                    gatewayRefundWrapper.internalPaymentDescription = donationWrapperIn.donation.GUID__c;

                    SMP_PaymentGateway.RefundResponse response = SMP_PaymentGateway.doRefund(SMP_PaymentGateway.Gateway.STRIPE, gatewayRefundWrapper);
                    System.debug('#### response: ' + response);
                    if(response.status == 'failed'){
                        System.debug('#### response error: ' + response.message);
                        paymentResponse.hasError = true;
                        paymentResponse.errorMessage = response.message;
                        throw new RefundException('Error :-'+response.message);
                    }
                    
                    refundHistories.add(response.data.incomeCardPaymentHistoryId);
                }
            }

            sp = Database.setSavepoint(); 
            setSavePoint = true;
            
            Map<String,Schema.RecordTypeInfo> mapRecordTypeInfo = Schema.SObjectType.npe01__OppPayment__c.getRecordTypeInfosByDeveloperName();
            Map<String,String> mapPaymentMethodRecordType = new Map<String,String>();
            mapPaymentMethodRecordType.put('Cash', 'Cash' );
            mapPaymentMethodRecordType.put('Cheque', 'Cheque');
            mapPaymentMethodRecordType.put('Card Payment', 'Card_Payment');
            mapPaymentMethodRecordType.put('Direct Debit', 'Card_Payment');
            mapPaymentMethodRecordType.put('Bank Transfer','Bank_Transfer');
            mapPaymentMethodRecordType.put('Facebook Giving','Online_Crowdfunding');
            mapPaymentMethodRecordType.put('JustGiving','Online_Crowdfunding');
            
            for(RefundWrapper wrapper : donationWrapperIn.refunds)
            {
                if(wrapper.checked == true)
                {
                    npe01__OppPayment__c refund = new npe01__OppPayment__c();
                    refund.npe01__Opportunity__c = wrapper.payment.npe01__Opportunity__c; 
                    refund.npe01__Payment_Amount__c = wrapper.refundAmount * -1;
                    refund.npe01__Payment_Method__c = donationWrapperIn.refundType;
                    refund.CurrencyIsoCode = donationWrapperIn.donation.CurrencyIsoCode;
                    refund.Contact__c = donationWrapperIn.donation.npsp__Primary_Contact__c;
                    refund.npsp__Type__c = 'Refund';
                    refund.npe01__Paid__c = wrapper.refundPaid;
                    refund.npe01__Payment_Date__c = wrapper.refundDate;
                    refund.Transaction_ID__c = transactionId;
                    refund.Reason_for_Refund__c = refundReason;
                    refund.Gift_Aid_Precluded__c = giftAidPrecluded;
                    refund.RecordTypeId = mapRecordTypeInfo.get(mapPaymentMethodRecordType.get(donationWrapperIn.refundType)).getRecordTypeId();
                    refunds.add(refund);
                }
            }
            
            insert refunds;

            List<npsp__Allocation__c> lstAllocationNeg = new List<npsp__Allocation__c>();
            
            for (AllocationWrapper wrapper : donationWrapperIn.allocations) {
                System.debug('****wrapper.refundAmount:--'+wrapper.refundAmount);
                if(wrapper.refundAmount >0){
                    System.debug('**wrapper.objAllocation**:--'+wrapper.objAllocation);
                    npsp__Allocation__c objAllocation = new npsp__Allocation__c();
                    objAllocation = wrapper.objAllocation.clone(false,false,false,false);
                    objAllocation.Parent_Allocation__c = wrapper.objAllocation.Id;
                    objAllocation.Id = null;
                    objAllocation.npsp__Amount__c = wrapper.refundAmount * -1;
                    lstAllocationNeg.add(objAllocation);
                    System.debug('**objAllocation**:--'+objAllocation);
                }
            }
			
            insert lstAllocationNeg;

            paymentResponse.paymentsList = [SELECT Id, Name, npe01__Opportunity__c, npe01__Opportunity__r.Name, npe01__Payment_Amount__c 
                    FROM npe01__OppPayment__c WHERE Id IN :refunds OR Card_Payment_History__c IN :refundHistories];

            return paymentResponse;
        }
        catch(Exception exp) {
            if (setSavePoint) {
                Database.rollback(sp);
            }
            System.debug('****:---'+exp.getMessage()+'****'+exp.getStackTraceString());
            throw new AuraHandledException('Error :-'+exp.getMessage());
        }
    }

    public with sharing class DonationWrapper
    {
        @AuraEnabled public Opportunity donation {get; set;}
        @AuraEnabled public List<RefundWrapper> refunds {get; set;}
        @AuraEnabled public String refundType {get; set;}
        @AuraEnabled public List<AllocationWrapper> allocations {get; set;}
        @AuraEnabled public List<String> refundReasonOptions {get;set;}
    }

    public with sharing class RefundWrapper
    {
        @AuraEnabled public Boolean disabled {get; set;}
        @AuraEnabled public Boolean checked {get; set;}
        @AuraEnabled public npe01__OppPayment__c payment {get; set;}
        @AuraEnabled public Decimal refundAmount {get; set;}
        @AuraEnabled public Date refundDate {get; set;}
        @AuraEnabled public Boolean refundPaid {get; set;}
    }

    public with sharing class ResponseWrapper
    {
        @AuraEnabled public List<npe01__OppPayment__c> paymentsList {get; set;}
        @AuraEnabled public Boolean hasError {get; set;}
        @AuraEnabled public string errorMessage {get; set;}
    }

    public class AllocationWrapper {

        @AuraEnabled public npsp__Allocation__c objAllocation {get; set;}
        @AuraEnabled public decimal refundAmount {get; set;}

        public AllocationWrapper() {
        }

        public AllocationWrapper(npsp__Allocation__c objAllocate, Decimal refund) {
            
            this.objAllocation = objAllocate;
            this.refundAmount = refund;
        }
    }
    
    public class RefundException extends Exception {}
}