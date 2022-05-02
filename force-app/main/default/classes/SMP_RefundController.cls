public with sharing class SMP_RefundController {    
    
    @AuraEnabled
    public static List<Income_Card_Payment_History__c> fetchIncomeCardPaymentHistory(Id incomeCardPaymentId)
    {
        return [SELECT Id, Name, Amount__c, Order_Id__c, Transaction_Type__c, Transaction_Date__c, CurrencyIsoCode  
                FROM Income_Card_Payment_History__c 
                WHERE Income_Card_Payment__c = :incomeCardPaymentId
                    AND (Transaction_Type__c = 'Sale' OR Transaction_Type__c = 'Authorised' OR Transaction_Type__c = 'Deferred Release') 
                    AND Payment_Status__c = 'Successful' order by Transaction_Date__c DESC];
    }

    @AuraEnabled
    public static Map<String, SMP_PaymentGateway.RefundResponse> executeRefundByHistory(Map<Id, Decimal> refundsByHistory)
    {
        System.debug('#### executeRefundByHistory');
        System.debug('#### refundsByHistory: ' + refundsByHistory);

        List<Income_Card_Payment_History__c> cardPayments = [SELECT Id, Name, Order_Id__c, Income_Card_Payment__c, Income_Card_Payment__r.Payment_Vendor__c, CurrencyIsoCode   
                                                            FROM Income_Card_Payment_History__c
                                                            WHERE Id =: refundsByHistory.keySet()];
        
        Map<String, SMP_PaymentGateway.RefundResponse> responseMap = new Map<String, SMP_PaymentGateway.RefundResponse>();

        for(Income_Card_Payment_History__c icph : cardPayments)
        {
            SMP_PaymentGateway.Gateway paymentGateway = SMP_PaymentGateway.getGatewayEnumByPaymentVendor(icph.Income_Card_Payment__r.Payment_Vendor__c);

            SMP_PaymentGateway.Refund refundWrapper = new SMP_PaymentGateway.Refund();
            refundWrapper.incomeCardPaymentId = icph.Income_Card_Payment__c;
            refundWrapper.amount = refundsByHistory.get(icph.Id);
            refundWrapper.currencyCode = icph.CurrencyIsoCode;

            if(paymentGateway == SMP_PaymentGateway.Gateway.SAGEPAYPI){
            }
            else if(paymentGateway == SMP_PaymentGateway.Gateway.GLOBALPAYMENTS){
            }
            else if(paymentGateway == SMP_PaymentGateway.Gateway.STRIPE){
                refundWrapper.chargeId = icph.Order_Id__c;
            }

            refundWrapper.customerPaymentReference = 'Refund';
            refundWrapper.internalPaymentDescription = 'Refund';

            SMP_PaymentGateway.RefundResponse response = SMP_PaymentGateway.doRefund(paymentGateway, refundWrapper);
            System.debug('#### response: '+response);
            responseMap.put(icph.Name, response);
        }
        
        System.debug('#### responseMap: '+responseMap);
        return responseMap;
    }
}