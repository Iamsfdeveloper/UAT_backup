global class SMP_RepeatPaymentSchedulerBatch implements Database.AllowsCallouts, Database.Batchable<sObject>
{
    global Boolean isMultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
    global List<Income_Card_Payment__c> failedCardPayments;

    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('#### SMP_RepeatPaymentSchedulerBatch Start');
        System.debug('#### isMultiCurrencyEnabled: ' + isMultiCurrencyEnabled);

        failedCardPayments = new List<Income_Card_Payment__c>();

        String query = 'SELECT Id, Name, Transaction_Type__c, Payment_Vendor__c, Transaction_ID__c, Gateway_Customer_Reference__c, ';
        query += 'RP_Stretch__c, RP_Collection_Day__c, RP_Start_Date__c, RP_Next_Payment_Date__c, RP_Frequency__c, RP_End_Date__c, RP_Enabled__c, RP_Description__c, RP_Amount__c';

        if(isMultiCurrencyEnabled){
            query += ', CurrencyIsoCode';
        }

        query += ' FROM Income_Card_Payment__c';
        query += ' WHERE RP_Enabled__c = TRUE AND RP_Next_Payment_Date__c = TODAY AND (RP_End_Date__c = null OR RP_End_Date__c >= TODAY) AND Payment_Vendor__c != null AND Payment_Status__c = \'Successful\'';
        query += ' AND (Transaction_Type__c = \'Sale\' OR Transaction_Type__c = \'Authenticate\'  OR Transaction_Type__c = \'Authorised\'  OR Transaction_Type__c = \'Deferred\' OR Transaction_Type__c = \'Deferred Released\')';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Income_Card_Payment__c> cardPayments)
    {    
        System.debug('#### SMP_RepeatPaymentSchedulerBatch execute');
        System.debug('#### cardPayments: ' + cardPayments);
        System.debug('#### isMultiCurrencyEnabled: ' + isMultiCurrencyEnabled);        

        if(failedCardPayments == null){
            failedCardPayments = new List<Income_Card_Payment__c>();
        }

        List<Income_Card_Payment__c> updatedCardPayments = new List<Income_Card_Payment__c>();

        for(Income_Card_Payment__c icp : cardPayments)
        {
            if(String.isNotBlank(icp.Payment_Vendor__c))
            {
                SMP_PaymentGateway.Gateway paymentGateway = SMP_PaymentGateway.getGatewayEnumByPaymentVendor(icp.Payment_Vendor__c);
                System.debug('#### paymentGateway: ' + paymentGateway);

                if(paymentGateway != null)
                {
                    if(icp.Transaction_Type__c == 'Sale' || icp.Transaction_Type__c == 'Authorised' || icp.Transaction_Type__c == 'Deferred Released')
                    {
                        // We do a normal repeat payment here.
                        System.debug('#### Process Repeat Payment');

                        SMP_PaymentGateway.RepeatPayment repeatWrapper = new SMP_PaymentGateway.RepeatPayment();
                        repeatWrapper.incomeCardPaymentId = icp.Id;
                        repeatWrapper.amount = icp.RP_Amount__c;

                        // if CurrencyIsoCode exists use that
                        repeatWrapper.currencyCode = isMultiCurrencyEnabled ? String.valueOf(icp.get('CurrencyIsoCode')) : UserInfo.getDefaultCurrency();
                        repeatWrapper.customerPaymentReference = 'test';
                        repeatWrapper.internalPaymentDescription = 'test';
                        
                        if(paymentGateway == SMP_PaymentGateway.Gateway.SAGEPAYPI){                            
                        }
                        else if(paymentGateway == SMP_PaymentGateway.Gateway.GLOBALPAYMENTS){

                        }
                        else if(paymentGateway == SMP_PaymentGateway.Gateway.STRIPE){
                            repeatWrapper.customerId = icp.Gateway_Customer_Reference__c;
                        }

                        SMP_PaymentGateway.RepeatPaymentResponse response = SMP_PaymentGateway.doRepeatPayment(paymentGateway, repeatWrapper);

                        System.debug('#### response: ' + response);

                        Boolean isSuccess = response != null && response.status == 'success' ? true : false;
                        updatedCardPayments.add(handleResponse(icp, isSuccess));
                    }
                    else if(icp.Transaction_Type__c == 'Authenticate')
                    {
                        // We do a authenticate/authorise release here.
                        System.debug('#### Process Authenticate Authorise');

                        SMP_PaymentGateway.AuthenticateAuthoriseRelease authoriseWrapper = new SMP_PaymentGateway.AuthenticateAuthoriseRelease();
                        authoriseWrapper.incomeCardPaymentId = icp.Id;
                        authoriseWrapper.amount = icp.RP_Amount__c;

                        // if CurrencyIsoCode exists use that
                        authoriseWrapper.currencyCode = isMultiCurrencyEnabled ? String.valueOf(icp.get('CurrencyIsoCode')) : UserInfo.getDefaultCurrency();
                        authoriseWrapper.customerPaymentReference = icp.RP_Description__c;
                        authoriseWrapper.internalPaymentDescription = 'test';
                        if(paymentGateway == SMP_PaymentGateway.Gateway.SAGEPAYPI){                            
                        }
                        else if(paymentGateway == SMP_PaymentGateway.Gateway.GLOBALPAYMENTS){

                        }
                        else if(paymentGateway == SMP_PaymentGateway.Gateway.STRIPE){
                            authoriseWrapper.customerId = icp.Gateway_Customer_Reference__c;
                        }

                        SMP_PaymentGateway.AuthenticateAuthoriseReleaseResponse response = SMP_PaymentGateway.doAuthenticateAuthoriseRelease(paymentGateway, authoriseWrapper);

                        System.debug('#### response: ' + response);

                        Boolean isSuccess = response != null && response.status == 'success' ? true : false;
                        updatedCardPayments.add(handleResponse(icp, isSuccess));
                    }
                    else if(icp.Transaction_Type__c == 'Deferred')
                    {
                        // We do a defer release here.
                        System.debug('#### Process Defer Release');

                        SMP_PaymentGateway.DeferredRelease releaseWrapper = new SMP_PaymentGateway.DeferredRelease();
                        releaseWrapper.incomeCardPaymentId = icp.Id;
                        releaseWrapper.amount = icp.RP_Amount__c;

                        // if CurrencyIsoCode exists use that
                        releaseWrapper.currencyCode = isMultiCurrencyEnabled ? String.valueOf(icp.get('CurrencyIsoCode')) : UserInfo.getDefaultCurrency();
                        releaseWrapper.customerPaymentReference = icp.RP_Description__c;
                        
                        if(paymentGateway == SMP_PaymentGateway.Gateway.SAGEPAYPI){                            
                        }
                        else if(paymentGateway == SMP_PaymentGateway.Gateway.GLOBALPAYMENTS){

                        }
                        else if(paymentGateway == SMP_PaymentGateway.Gateway.STRIPE){
                            releaseWrapper.customerId = icp.Gateway_Customer_Reference__c;
                        }

                        SMP_PaymentGateway.DeferredReleaseResponse response = SMP_PaymentGateway.doDeferredRelease(paymentGateway, releaseWrapper);

                        System.debug('#### response: ' + response);

                        Boolean isSuccess = response != null && response.status == 'success' ? true : false;
                        updatedCardPayments.add(handleResponse(icp, isSuccess));
                    }
                }                
            }            
        }

        update updatedCardPayments;
    }
    
    global void finish(Database.BatchableContext BC)
    {        
    }

    private Income_Card_Payment__c handleResponse(Income_Card_Payment__c cardPayment, Boolean isSuccess){

        System.debug('#### handleResponse');
        System.debug('#### cardPayment: ' + cardPayment);
        System.debug('#### isSuccess: ' + isSuccess);

        Income_Card_Payment__c newCardPayment = new Income_Card_Payment__c(Id = cardPayment.Id);

        if(isSuccess == true)
        {    
            // If management of dates is switched on, update the repeat payment date.
            if(SMP_PaymentGateway.paymentConfig.Manage_Repeat_Payment_Dates__c == true)
            {
                System.debug('#### Calculating Next Payment Date');
                
                newCardPayment.RP_Next_Payment_Date__c = SMP_PaymentGateway.getNextRepeatPaymentDate(cardPayment.RP_Stretch__c,
                                                                                                    cardPayment.RP_Frequency__c,
                                                                                                    cardPayment.RP_Collection_Day__c,
                                                                                                    cardPayment.RP_Next_Payment_Date__c,
                                                                                                    cardPayment.RP_End_Date__c);

                System.debug('#### Next Payment Date: ' + newCardPayment.RP_Next_Payment_Date__c);
            }        
        }
        else
        {     
            failedCardPayments.add(cardPayment); 
        } 
        
        return newCardPayment;
    }
}