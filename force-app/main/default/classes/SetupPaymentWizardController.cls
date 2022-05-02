/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 04-06-2022
 * @last modified by  : Iamsfdeveloper
**/
public with sharing class SetupPaymentWizardController {

    
    @AuraEnabled
    public static CheckoutWrapper getOpportunity(String opportunityId)
    {
        System.debug('#### getOpportunity');
        CheckoutWrapper checkOut = new CheckoutWrapper();

        Opportunity opportunity = [SELECT Id, Name,closeDate, Regional_office_code__c,Website_Code__c, Amount, AccountId, npsp__Primary_Contact__c, CurrencyIsoCode, Payment_Schedule__c, Payment_Schedule__r.Frequency__c, Payment_Schedule__r.Payment_Methods__c,
                                        Payment_Schedule__r.Start_Date__c, Payment_Schedule__r.End_Date__c, Effective_Date__c,Payment_Schedule__r.Code__c,EMIAmount__c,
                                        npsp__Primary_Contact__r.Name, npsp__Primary_Contact__r.Firstname, npsp__Primary_Contact__r.LastName, npsp__Primary_Contact__r.Phone, 
                                        npsp__Primary_Contact__r.Email, npsp__Primary_Contact__r.MailingStreet, npsp__Primary_Contact__r.MailingCity, 
                                        npsp__Primary_Contact__r.MailingState, npsp__Primary_Contact__r.MailingCountry, npsp__Primary_Contact__r.MailingPostalCode,
                                        (SELECT Id, npsp__Amount__c, npsp__General_Accounting_Unit__r.Name FROM npsp__Allocations__r order by npsp__General_Accounting_Unit__r.Name DESC)
                                    FROM Opportunity 
                                    WHERE Id =: opportunityId];
        
        if(opportunity.Payment_Schedule__c == null)
        {
            checkOut.error = 'Payment Schedule is missing on the Donation.';
            return checkOut;
        }

        checkOut.theOpportunity = opportunity;
        checkOut.amount += opportunity.Amount;

        checkOut.paymentTypes = opportunity.Payment_Schedule__r.Payment_Methods__c.split(';');        
        
        checkOut.directDebit = new Income_Direct_Debit__c();
        checkOut.directDebit.Opportunity__c = opportunity.Id;
        checkOut.directDebit.Account__c = opportunity.AccountId;
        checkOut.directDebit.Contact__c = opportunity.npsp__Primary_Contact__c;
        checkOut.directDebit.DD_OK__c = false;
        checkOut.directDebit.DD_Account_Number_OK__c = false;
        checkOut.directDebit.DD_Sort_Code_OK__c = false;

        checkOut.directDebit.DD_Start_Date__c = opportunity.Effective_Date__c != null ? opportunity.Effective_Date__c : opportunity.Payment_Schedule__r.Start_Date__c;
        checkOut.directDebit.DD_End_Date__c = opportunity.Payment_Schedule__r.End_Date__c;
        if(opportunity.Payment_Schedule__r.Code__c =='EMI'){
            checkOut.directDebit.DD_First_Collection_Amount__c = opportunity.EMIAmount__c;
            checkOut.directDebit.DD_Ongoing_Collection_Amount__c = opportunity.EMIAmount__c;   
        }else{
            checkOut.directDebit.DD_First_Collection_Amount__c = opportunity.Amount;
            checkOut.directDebit.DD_Ongoing_Collection_Amount__c = opportunity.Amount;        
        }
        checkOut.directDebit.DD_Collection_Day__c = '1';
        checkOut.directDebit.DD_Collection_Period__c =  'Monthly';
        if(opportunity.Payment_Schedule__r.Frequency__c == 'Annually')
        {
            checkOut.directDebit.DD_Collection_Stretch__c = '12';
        }
        else 
        {
            checkOut.directDebit.DD_Collection_Stretch__c = '1';   
        }

        checkOut.internalPaymentDescription = 'Donation-'+Datetime.now().getTime();
        
        
        System.debug('#### returned checkout: ' + checkOut);

        return checkOut;
    }

    @AuraEnabled
    public static Income_Direct_Debit__c modulusCheckDirectDebit(Income_Direct_Debit__c pDirectDebit)
    {   
        System.debug('#### modulusCheckDirectDebit');
        System.debug('#### pDirectDebit: ' + pDirectDebit);
        
        SMP_DDServiceBankAccountModel response = SMP_DDServiceHandler.getBankDetails(pDirectDebit.DD_Bank_Sort_Code__c, pDirectDebit.DD_Bank_Account_Number__c);
        response.copyFieldsToDirectDebitRecord(pDirectDebit);
        return pDirectDebit;
    }

    @AuraEnabled
    public static Id createPaymentRecord(String opportunityId, String contactId, String pPaymentType, String pAmountToPay)
    {
        Opportunity opportunity = [SELECT Id, Name, Regional_office_code__c,Website_Code__c, Amount, AccountId, npsp__Primary_Contact__c, CurrencyIsoCode, Payment_Schedule__c, Payment_Schedule__r.Frequency__c, Payment_Schedule__r.Payment_Methods__c,
                                        Payment_Schedule__r.Start_Date__c, Payment_Schedule__r.End_Date__c, Effective_Date__c,Payment_Schedule__r.Code__c,EMIAmount__c,
                                        npsp__Primary_Contact__r.Name, npsp__Primary_Contact__r.Firstname, npsp__Primary_Contact__r.LastName, npsp__Primary_Contact__r.Phone, 
                                        npsp__Primary_Contact__r.Email, npsp__Primary_Contact__r.MailingStreet, npsp__Primary_Contact__r.MailingCity, 
                                        npsp__Primary_Contact__r.MailingState, npsp__Primary_Contact__r.MailingCountry, npsp__Primary_Contact__r.MailingPostalCode,
                                        (SELECT Id, npsp__Amount__c, npsp__General_Accounting_Unit__r.Name FROM npsp__Allocations__r order by npsp__General_Accounting_Unit__r.Name DESC)
                                    FROM Opportunity 
                                    WHERE Id =: opportunityId];
        System.debug('#### createPaymentRecord');
        System.debug('#### opportunityId: ' + opportunityId);
        System.debug('#### contactId: ' + contactId);
        System.debug('#### pPaymentType: ' + pPaymentType);
        System.debug('#### pAmountToPay: ' + pAmountToPay);

        npe01__OppPayment__c paymentRecord = new npe01__OppPayment__c();
        paymentRecord.CurrencyIsoCode = opportunity.CurrencyIsoCode;
        paymentRecord.npe01__Opportunity__c = opportunityId;
        paymentRecord.npe01__Paid__c = true;
        paymentRecord.npe01__Payment_Amount__c = Decimal.valueOf(pAmountToPay);
        paymentRecord.npe01__Payment_Date__c = Date.Today();
        paymentRecord.npe01__Payment_Method__c = pPaymentType;
        paymentRecord.Payment_Reference__c = pPaymentType;
        paymentRecord.Contact__c = contactId;
        paymentRecord.Status__c = 'SD';
        paymentRecord.npsp__Type__c = 'Sale';
        paymentRecord.Transaction_Type__c = 'Sale';
        insert paymentRecord;
        
        return paymentRecord.Id;
    }

    @AuraEnabled
    public static Income_Direct_Debit__c saveDirectDebit(Income_Direct_Debit__c pDirectDebit)
    {
        System.debug('#### saveDirectDebit');
        System.debug('#### pDirectDebit: ' + pDirectDebit);
        SMP_DDServiceHandler.SingleCollectionDateWrapper collectionDateWrapper = new SMP_DDServiceHandler.SingleCollectionDateWrapper();
        collectionDateWrapper.CollectionDay = pDirectDebit.DD_Collection_Day__c;
        collectionDateWrapper.StartDate = String.valueOf(pDirectDebit.DD_Start_Date__c);
        collectionDateWrapper.CollectionPeriod = pDirectDebit.DD_Collection_Period__c;
        collectionDateWrapper.NumberOfDaysToWaitFromNewInstruction = '5';
        SMP_DDServiceNextCollectionModel firstCollection = SMP_DDServiceHandler.getNextCollectionDate(collectionDateWrapper);

        pDirectDebit.DD_First_Collection_Date__c = (Test.isRunningTest())?System.today():Date.valueOf(firstCollection.ProcessNewDDFirstCollectionDateResult.FirstCollectionDate);
        pDirectDebit.DD_Next_Collection_Date__c = (Test.isRunningTest())?System.today():Date.valueOf(firstCollection.ProcessNewDDFirstCollectionDateResult.FirstCollectionDate);
        try{
        upsert pDirectDebit;    
        }catch(Exception ex){
            System.debug(ex.getLineNumber());
            System.debug(ex.getStackTraceString());
            System.debug(ex.getMessage());
        }   
        pDirectDebit = [SELECT Id, DD_First_Collection_Amount__c, DD_First_Collection_Date__c FROM Income_Direct_Debit__c WHERE Id =:pDirectDebit.Id];

        return pDirectDebit;
    }

    @AuraEnabled
    public static String generateCardPaymentLink(Opportunity pOpportunity, Decimal pAmountToPay, Boolean pRepeatEnabled, String pInternalPaymentDescription)
    {
        Payment_Country_Setting__mdt setting = [SELECT SmarterPay_User_Name__c, APIKey__c FROM Payment_Country_Setting__mdt WHERE DeveloperName = :pOpportunity.Regional_office_code__c];
        
        SMP_PaymentGateway.Payment wrapper = new SMP_PaymentGateway.Payment();
        wrapper.incomeusername = setting.SmarterPay_User_Name__c;
        wrapper.APIKey = setting.APIKey__c;

        wrapper.customerFirstName = pOpportunity.npsp__Primary_Contact__r.FirstName;
        wrapper.customerLastName = pOpportunity.npsp__Primary_Contact__r.LastName;
        wrapper.ownerId = UserInfo.getUserId();

        wrapper.billingAddressOne = pOpportunity.npsp__Primary_Contact__r.MailingStreet;
        wrapper.billingAddressCity = pOpportunity.npsp__Primary_Contact__r.MailingCity;
        wrapper.billingAddressState = pOpportunity.npsp__Primary_Contact__r.MailingState;
        wrapper.billingAddressPostalCode = pOpportunity.npsp__Primary_Contact__r.MailingPostalCode;
        wrapper.billingAddressCountry = pOpportunity.npsp__Primary_Contact__r.MailingCountry;

        wrapper.shippingAddressOne = pOpportunity.npsp__Primary_Contact__r.MailingStreet;
        wrapper.shippingAddressCity = pOpportunity.npsp__Primary_Contact__r.MailingCity;
        wrapper.shippingAddressState = pOpportunity.npsp__Primary_Contact__r.MailingState;
        wrapper.shippingAddressPostalCode = pOpportunity.npsp__Primary_Contact__r.MailingPostalCode;
        wrapper.shippingAddressCountry = pOpportunity.npsp__Primary_Contact__r.MailingCountry;

        wrapper.currencyCode = pOpportunity.CurrencyIsoCode;
        wrapper.amount = pAmountToPay;

        wrapper.emailAddress = pOpportunity.npsp__Primary_Contact__r.Email;

        wrapper.firstReferenceId = pOpportunity.Id;
        wrapper.firstReferenceObject = 'Opportunity__c';
        wrapper.secondReferenceId = pOpportunity.npsp__Primary_Contact__c;
        wrapper.secondReferenceObject = 'Contact__c';

        wrapper.internalPaymentDescription = pInternalPaymentDescription;
        wrapper.customerPaymentReference = 'Donation';
        wrapper.rpenabled = false;        
        
        System.debug('#### wrapper: ' + wrapper);

        if(pRepeatEnabled)
        {
            return SMP_PaymentGateway.generateCardPaymentURL(wrapper, SMP_PaymentGateway.Gateway.STRIPE, SMP_PaymentGateway.PaymentType.AuthenticateAuthoriseMOTO);
        }
        else
        {            
            return SMP_PaymentGateway.generateCardPaymentURL(wrapper, SMP_PaymentGateway.Gateway.STRIPE, SMP_PaymentGateway.PaymentType.MOTO);
        }        
    }

    @AuraEnabled
    public static String pollForCardPaymentSuccess(Id pOpportunityId, String pDescription)
    {
        List<Income_Card_Payment__c> cardPayments = [SELECT Id 
                                                    FROM Income_Card_Payment__c 
                                                    WHERE Opportunity__c = :pOpportunityId 
                                                        AND Internal_Payment_Description__c = :pDescription 
                                                        AND Payment_Status__c = 'Successful'];

        if(cardPayments.Size() > 0)
        {
            return cardPayments[0].Id;
        }

        return null;
    }

    public with sharing class CheckoutWrapper
    {
        @AuraEnabled public Decimal amount {get; set;}
        @AuraEnabled public Opportunity theOpportunity {get; set;}
        @AuraEnabled public List<String> paymentTypes {get; set;}
        @AuraEnabled public Income_Direct_Debit__c directDebit {get; set;}
        @AuraEnabled public String internalPaymentDescription {get; set;}

        @AuraEnabled public String error {get; set;}

        public CheckoutWrapper()
        {
            amount = 0;
            theOpportunity = new Opportunity();
            paymentTypes = new List<String>();
            directDebit = new Income_Direct_Debit__c();
        }
    }
}