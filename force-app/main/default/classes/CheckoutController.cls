public without sharing class CheckoutController {
   
    public Integer stepNo {get; set;}
    public Income_Direct_Debit__c directDebit {get; set;}

    public Boolean ddValidated {get; set;}
    public List<Opportunity> oppValidList {get; set;}
    public List<opportunityCheckoutWrapper> oppsToDisplay {get; set;}

    public Boolean ddCheck {get; set;}
    public Boolean isRecurringPayment {get; set;}

    public String todaysDateFormatted {get; set;}

    public String currentHeaderStyle1 {get; set;}
    public String currentHeaderStyle2 {get; set;}
    public String currentHeaderStyle3 {get; set;}

    public Boolean isCardPayment {get; set;}
    public Boolean isDirectDebit {get; set;}

    public String cardPaymentUrl {get; set;}

    public Decimal amountToTake {get; set;}

    public Integer cardStage {get; set;}

    public List<opportunityCheckoutWrapper> directDebitsopps {get; set;}

    public List<opportunityCheckoutWrapper> wrapperList {get; set;}

    public List<Income_Direct_Debit__c> ddToCreate {get; set;}

    public CheckoutController()
    {        
        currentHeaderStyle1 = 'checkout-steps__item--active';

        cardStage = 2;

        stepNo = 1;
        ddCheck = false;

        directDebit = new Income_Direct_Debit__c();

        todaysDateFormatted = Date.today().format();

        isCardPayment = false;
        isDirectDebit = false;

        isRecurringPayment = false;

        oppValidList = new List<Opportunity>();

        // directDebit = new Income_Direct_Debit__c();              
        String oppIds = apexpages.currentpage().getparameters().get('oppId');
        List<String> oppIdsList;
        try 
        {         
            oppIdsList = oppIds.split(',');
        } 
        catch (Exception e) 
        {
            stepNo = 0;
            return;
        }

        System.debug('#### oppIds' + oppIds);

        List<Opportunity> oppResult = [SELECT Id, Name,Website_Code__c,Payment_Schedule__r.Name, Payment_Schedule__r.Start_Date__c, Payment_Schedule__r.End_Date__c,Payment_Schedule__r.Frequency__c, Payment_Schedule__r.Payment_Methods__c, npsp__Primary_Contact__c, Amount, AccountId, CurrencyIsoCode, 
                                            npsp__Primary_Contact__r.Name, npsp__Primary_Contact__r.Firstname, npsp__Primary_Contact__r.LastName, npsp__Primary_Contact__r.Phone, 
                                            npsp__Primary_Contact__r.Email, npsp__Primary_Contact__r.MailingStreet, npsp__Primary_Contact__r.MailingCity, 
                                            npsp__Primary_Contact__r.MailingState, npsp__Primary_Contact__r.MailingCountry, npsp__Primary_Contact__r.MailingPostalCode,  
                                            (SELECT Id, npsp__Amount__c, npsp__Opportunity__c, npsp__General_Accounting_Unit__r.Name  
                                            FROM npsp__Allocations__r order by npsp__General_Accounting_Unit__r.Name DESC),
                                            (SELECT Id, Schedule_Date__c, Amount__c, Opportunity__c, Status__c FROM Payment_Schedules__r WHERE Schedule_Date__c >= :Date.today() AND Status__c = 'Outstanding' order by Schedule_Date__c ASC) 
                                        FROM Opportunity WHERE Id IN :oppIdsList AND StageName != 'Paid']; 
        
        System.debug('#### oppResult' + oppResult);    

        if(oppResult.size() == 0)
        {
            stepNo = 0;
            System.debug('#### NO valid opportunity');
            return;
        }
        
        wrapperList = new List<opportunityCheckoutWrapper>();

        for (Opportunity opp : oppResult) 
        {
            if(opp.npsp__Allocations__r == null || opp.npsp__Allocations__r.Size() == 0)
            {
                stepNo = 0;
                System.debug('#### NO GUA');
                return;
            }
            if(opp.npsp__Primary_Contact__c == null)
            {
                stepNo = 0;
                System.debug('#### no primary Contact ');
    
                return;
            }
        }

        // Get Translations If Required
        String language = apexpages.currentpage().getparameters().get('language');
        List<Translation__c> translations = new List<Translation__c>();

        if(String.isNotBlank(language))
        {
            language = language.toUpperCase();
            Set<Id> GAUIds = new Set<Id>();
            Set<Id> paymentScheduleIds = new Set<Id>();

            for (Opportunity opp : oppResult)
            {
                paymentScheduleIds.add(opp.Payment_Schedule__c);

                for(npsp__Allocation__c product : opp.npsp__Allocations__r)
                {
                    GAUIds.add(product.npsp__General_Accounting_Unit__c);
                }
            }

            translations = [SELECT Id, Translated_Text__c, Item__c, Payment_Schedule__c 
            FROM Translation__c 
            WHERE Language__c = :language 
                AND (Item__c IN :GAUIds OR Payment_Schedule__c IN :paymentScheduleIds)];
        }

        for (Opportunity opp : oppResult)
        {
            System.debug('#### opp.npsp__Primary_Contact__r' + opp.npsp__Primary_Contact__r);

            opportunityCheckoutWrapper wrapper = new opportunityCheckoutWrapper();
            wrapper.opp = opp;            
            wrapper.productNames = new List<String>();
            wrapper.amount = opp.Amount;
            wrapper.staticPaymentTypes = new List<SelectOption>();

            wrapper.name = opp.Payment_Schedule__r.Name;

            if(String.isNotBlank(language))
            {
                for(Translation__c t : translations)
                {
                    if(t.Payment_Schedule__c == opp.Payment_Schedule__c)
                    {
                        wrapper.name = t.Translated_Text__c;
                    }
                }
            }

            if(opp.Payment_Schedule__r.Payment_Methods__c.contains('Direct Debit')
                && language != 'ES')
            {
                wrapper.staticPaymentTypes.add(new SelectOption('DD', System.Label.Payment_Option_Direct_Debit));
                wrapper.FinalPaymenttype = 'DD';
            }

            if(opp.Payment_Schedule__r.Payment_Methods__c.contains('Credit/Debit Card'))
            {
                wrapper.CardPaymentEnabled = true;
                wrapper.staticPaymentTypes.add(new SelectOption('CP', System.Label.Payment_Option_Card));

                if(wrapper.FinalPaymenttype != 'DD')
                {
                    wrapper.FinalPaymenttype = 'CP';
                }
            }

            for(npsp__Allocation__c product : opp.npsp__Allocations__r)
            {                
                System.debug('####  product' + product);    
                
                Boolean foundTranslation = false;

                if(String.isNotBlank(language))
                {
                    for(Translation__c t : translations)
                    {
                        if(t.Item__c == product.npsp__General_Accounting_Unit__c)
                        {
                            wrapper.productNames.add(t.Translated_Text__c);
                            foundTranslation = true;
                        }
                    }
                }

                if(foundTranslation == false)
                {
                    wrapper.productNames.add(product.npsp__General_Accounting_Unit__r.Name);
                }
            }

            if(wrapper.productNames.size() > 0)
            {
                wrapperList.add(wrapper);
            }

            System.debug('#### wrapper' + wrapper);   
        }
        
        if (wrapperList.size() == 0) 
        {
            stepNo = 0;
            System.debug('#### no valid opps for the wrapper');    
        }
        else if(wrapperList.Size() == 1 && wrapperList[0].staticPaymentTypes.Size() == 1)
        {
            nextAction();
        }

        System.debug('#### wrapperList' + wrapperList);
    }

    public void whichPaymentToTake()
    {
        isDirectDebit = false;
        isCardPayment = false;
        
        for (opportunityCheckoutWrapper wrapper : wrapperList) 
        {
            if(wrapper.FinalPaymenttype == 'DD')
            {
                isDirectDebit = true;
            }
            else if(wrapper.FinalPaymenttype == 'CP')
            {
                isCardPayment = true;
            }
        }
    }
    public void back()
    {        
        stepNo--;
    }
    public Pagereference nextAction()
    {              
        if(stepNo == 1)
        {
            whichPaymentToTake();

            if(isCardPayment && isDirectDebit)
            {
                cardStage = 3;
            }

            if(isCardPayment)
            {
                runCardPayment();
                
                stepNo = 4;
                currentHeaderStyle1 = '';
                currentHeaderStyle2 = '';
                currentHeaderStyle3 = 'checkout-steps__item--active';
            }
            if (isDirectDebit) 
            {
                collectDDRecords();
                stepNo = 2;
                currentHeaderStyle1 = '';
                currentHeaderStyle2 = 'checkout-steps__item--active';
                currentHeaderStyle3 = '';
                system.debug('#### currentHeaderStyle1 ' + currentHeaderStyle1);
                system.debug('#### currentHeaderStyle2 ' + currentHeaderStyle2);
                system.debug('#### currentHeaderStyle3 ' + currentHeaderStyle3);

            }
            return null;
        }
        if(stepNo == 2)
        {
            validateBankDetails();
            System.debug('####  stepNo' + stepNo);    

            if (directDebit.DD_Account_Number_OK__c == true && directDebit.DD_Sort_Code_OK__c == true && directDebit.DD_OK__c == true && ddCheck == true) 
            {
                stepNo = 3;
            }
            

            return null;
        }
        if(stepNo == 3)
        {
            currentHeaderStyle1 = '';
            currentHeaderStyle2 = '';
            currentHeaderStyle3 = 'checkout-steps__item--active';

            saveDirectDebit();
            if(isCardPayment)
            {
                runCardPayment();
                stepNo = 4;
                
            }
            else 
            {
                if(checkDirectDebits())
                {   
                    // Success
                    System.debug('#### DD Success');

                    Id ddId = ddToCreate[0].Id;

                    Pagereference pageRef = Page.CheckoutRouter;
                    pageRef.getParameters().put('res', 's');
                    pageRef.getParameters().put('id', ddId);
                    pageref.setRedirect(true);

                    return pageref;   
                }
                else 
                {
                    Pagereference pageRef = Page.CheckoutRouter;
                    pageRef.getParameters().put('res', 'f');
                    pageref.setRedirect(true);

                    return pageref;  
                }
                
                
            }
        }
        return null;        
    }
    public Boolean checkDirectDebits()
    {
       for (Income_Direct_Debit__c DD : ddToCreate) 
       {
           if(DD.Id == null)
           {
            return false;
           }
       } 
       return true;
    }

    public void setupDirectDebit()
    {
        
        ddToCreate = new List<Income_Direct_Debit__c>();
        try{
            System.debug('#### directDebitsopps: ' + directDebitsopps);

            for (opportunityCheckoutWrapper wrapper : directDebitsopps) 
            {
                
                SMP_DDServiceHandler.SingleCollectionDateWrapper collectionDateWrapper = new SMP_DDServiceHandler.SingleCollectionDateWrapper();
                collectionDateWrapper.CollectionDay = '1';
                collectionDateWrapper.StartDate = String.valueOf(wrapper.opp.Payment_Schedule__r.Start_Date__c);
                collectionDateWrapper.CollectionPeriod = wrapper.opp.Payment_Schedule__r.Frequency__c ;
                collectionDateWrapper.NumberOfDaysToWaitFromNewInstruction = '5';
                System.debug('#### collectionDateWrapper: ' + collectionDateWrapper);

                SMP_DDServiceNextCollectionModel firstCollection = SMP_DDServiceHandler.getNextCollectionDate(collectionDateWrapper);

                System.debug('#### firstCollection: ' + firstCollection);

                String[] splitDate = firstCollection.ProcessNewDDFirstCollectionDateResult.FirstCollectionDate.split('-');
                

                Date firstCollectionDate = Date.parse(splitDate[2] +'/'+ splitDate[1] +'/'+ splitDate[0]);
                System.debug('#### firstCollectionDate: ' + firstCollectionDate);
                
                Income_Direct_Debit__c dd = new Income_Direct_Debit__c();
                dd.Opportunity__c = wrapper.opp.Id;
                dd.Account__c = wrapper.opp.AccountId;
                dd.Contact__c = wrapper.opp.npsp__Primary_Contact__c;

                dd.DD_Start_Date__c = wrapper.opp.Payment_Schedule__r.Start_Date__c;
                dd.DD_End_Date__c = wrapper.opp.Payment_Schedule__r.End_Date__c;
                dd.DD_First_Collection_Date__c = firstCollectionDate;
                dd.DD_Next_Collection_Date__c = firstCollectionDate;
                dd.DD_First_Collection_Amount__c = wrapper.opp.Amount;
                dd.DD_Ongoing_Collection_Amount__c = wrapper.opp.Amount;
                dd.DD_Bank_Sort_Code__c = directDebit.DD_Bank_Sort_Code__c;
                dd.DD_Bank_Account_Number__c = directDebit.DD_Bank_Account_Number__c;
                dd.DD_Bank_Account_Name__c = directDebit.DD_Bank_Account_Name__c;
                dd.DD_Sort_Code_OK__c = directDebit.DD_Sort_Code_OK__c;
                dd.DD_Account_Number_OK__c = directDebit.DD_Sort_Code_OK__c;
                dd.DD_OK__c = directDebit.DD_OK__c;

                dd.DD_Collection_Day__c = '1';
                dd.DD_Collection_Period__c =  'Monthly';
                if(wrapper.opp.Payment_Schedule__r.Frequency__c == 'Annually')
                {
                    dd.DD_Collection_Stretch__c = '12';

                }
                else 
                {
                    dd.DD_Collection_Stretch__c = '1';   
                }
                

                ddToCreate.add(dd);
                System.debug('#### dd: ' + dd);

            }
        }
        catch(Exception ex)
        {
            System.debug('#### Exception creating direct debit: ' + ex.getMessage());
            stepNo = 0; 
        }
    }

    public void collectDDRecords()
    {
        directDebitsopps = new List<opportunityCheckoutWrapper>(); 

        for (opportunityCheckoutWrapper wrapper : wrapperList) 
        {
            if(wrapper.FinalPaymenttype == 'DD')
            {
                directDebitsopps.add(wrapper);
            } 
        }
        System.debug('#### directDebitsopps' + directDebitsopps);

    }
    
    public void validateBankDetails()
    {
        ddValidated = true;

        try
        {
            SMP_DDServiceBankAccountModel bankAccount = SMP_DDServiceHandler.getBankDetails(directDebit.DD_Bank_Sort_Code__c, directDebit.DD_Bank_Account_Number__c);
            System.debug('#### bankAccount' + bankAccount);

            if(bankAccount != null)
            {
                bankAccount.copyFieldsToDirectDebitRecord(directDebit);
            }
            System.debug('#### directDebit' + directDebit);

            if(directDebit.DD_Account_Number_OK__c == true && directDebit.DD_Sort_Code_OK__c == true && directDebit.DD_OK__c == true && ddCheck == true)
            {
                setupDirectDebit();
                
            }
            else 
            {
                directDebit.DD_Account_Number_OK__c = false;
                directDebit.DD_Sort_Code_OK__c = false;
                directDebit.DD_OK__c = false;
            }
           
            System.debug('#### stepNo' + stepNo);
        }
        catch (Exception e){} 
    }

    public void runCardPayment()
    {
        System.debug('#### runCardPayment');
        System.debug('#### stepNo: ' + stepNo);
        System.debug('#### wrapperList: ' + wrapperList);

        amountToTake = 0;
        Boolean singleCardPayment = false;
        Boolean recurringCardPayment = false;
        oppsToDisplay = new List<opportunityCheckoutWrapper>();
            

        for (opportunityCheckoutWrapper wrapper : wrapperList) 
        {
            System.debug('#### wrapper: ' + wrapper);
            System.debug('#### wrapper.FinalPaymenttype: ' + wrapper.FinalPaymenttype);
            System.debug('#### wrapper.Payment_Schedule__r.Frequency__c: ' + wrapper.opp.Payment_Schedule__r.Frequency__c);

            if(wrapper.FinalPaymenttype == 'CP')
            {
                oppsToDisplay.add(wrapper);

                if(wrapper.opp.Payment_Schedule__r.Frequency__c == 'Single')
                {
                    singleCardPayment = true;
                    amountToTake += wrapper.opp.Amount;
                }
                else 
                {
                    recurringCardPayment = true;
                }                    
            }
        }
        System.debug('#### wrapperList: ' + wrapperList);
        System.debug('#### oppsToPay: ' + wrapperList);
        System.debug('#### oppsToAuthOnly: ' + wrapperList);

        if(recurringCardPayment == true && singleCardPayment == false)
        {
            isRecurringPayment = true;
        }
        
        cardPaymentUrl = getCardPaymentLink(oppsToDisplay);
        
        System.debug('#### cardPaymentUrl: ' + cardPaymentUrl);
        System.debug('#### stepNo: ' + stepNo);
    }
    
    public void saveDirectDebit()
    {   
        System.debug('#### ddToCreate before: ' + ddToCreate);

        try 
        {
            insert ddToCreate;

        } catch (Exception e) {
            System.debug('####  Exception on DD insert: ' + e);

            stepNo = 0;

        }

        System.debug('####  ddToCreate after: ' + ddToCreate);
    }

    private String getCardPaymentLink(List<opportunityCheckoutWrapper> opps)
    {
        System.debug('#### getCardPaymentLink');
        System.debug('#### opps: ' + opps);

        String oppIds = '';
        String websiteCode = '';
        
        for(Integer i = 0; i < opps.Size(); i++)
        {
            oppIds += opps[i].opp.Id + ',';
            websiteCode = opps[i].opp.Website_Code__c;
        }

        oppIds = oppIds.removeEnd(',');

        System.debug('#### oppIds: ' + oppIds);

        SMP_PaymentGateway.Payment wrapper = new SMP_PaymentGateway.Payment();

        Payment_Country_Setting__mdt setting = [SELECT SmarterPay_User_Name__c, APIKey__c FROM Payment_Country_Setting__mdt WHERE DeveloperName = :websiteCode];
        
        wrapper.incomeusername = setting.SmarterPay_User_Name__c;
        wrapper.APIKey = setting.APIKey__c;

        wrapper.rpenabled = false;
        wrapper.customerFirstName = opps[0].opp.npsp__Primary_Contact__r.FirstName;
        wrapper.customerLastName = opps[0].opp.npsp__Primary_Contact__r.LastName;

        wrapper.billingAddressOne = opps[0].opp.npsp__Primary_Contact__r.MailingStreet;
        wrapper.billingAddressCity = opps[0].opp.npsp__Primary_Contact__r.MailingCity;
        wrapper.billingAddressState = opps[0].opp.npsp__Primary_Contact__r.MailingState;
        wrapper.billingAddressPostalCode = opps[0].opp.npsp__Primary_Contact__r.MailingPostalCode;
        wrapper.billingAddressCountry = opps[0].opp.npsp__Primary_Contact__r.MailingCountry;

        wrapper.shippingAddressOne = opps[0].opp.npsp__Primary_Contact__r.MailingStreet;
        wrapper.shippingAddressCity = opps[0].opp.npsp__Primary_Contact__r.MailingCity;
        wrapper.shippingAddressState = opps[0].opp.npsp__Primary_Contact__r.MailingState;
        wrapper.shippingAddressPostalCode = opps[0].opp.npsp__Primary_Contact__r.MailingPostalCode;
        wrapper.shippingAddressCountry = opps[0].opp.npsp__Primary_Contact__r.MailingCountry;

        wrapper.currencyCode = opps[0].opp.CurrencyIsoCode;
        wrapper.amount = amountToTake;

        wrapper.emailAddress = opps[0].opp.npsp__Primary_Contact__r.Email;

        wrapper.firstReferenceId = opps[0].opp.npsp__Primary_Contact__c;
        wrapper.firstReferenceObject = 'Contact__c';

        if(opps.Size() == 1)
        {
            wrapper.secondReferenceId = opps[0].opp.Id;
            wrapper.secondReferenceObject = 'Opportunity__c';
        }
        else 
        {
            wrapper.internalPaymentDescription = oppIds;
        }
        
        wrapper.customerPaymentReference = 'Donation';
        // wrapper.rpenabled = isRecurringPayment;
        
        System.debug('#### SMP_PaymentGateway.wrapper : ' + wrapper);

        if(isRecurringPayment)
        {
            return SMP_PaymentGateway.generateCardPaymentURL(wrapper, SMP_PaymentGateway.Gateway.STRIPE,SMP_PaymentGateway.PaymentType.AuthenticateAuthoriseEcommerce);
        }
        else
        {            
            return SMP_PaymentGateway.generateCardPaymentURL(wrapper, SMP_PaymentGateway.Gateway.STRIPE,SMP_PaymentGateway.PaymentType.Ecommerce);
        }         
    }
    public class opportunityCheckoutWrapper
    {
        public Opportunity opp {get; set;}
        public String name {get; set;}

        public Boolean CardPayment {get; set;}
        public Boolean CardPaymentEnabled {get; set;}

        public List<SelectOption> staticPaymentTypes {get; set;} 

        public Boolean DirectDebit {get; set;}
        public Boolean DirectDebitEnabled {get; set;}

        public String FinalPaymenttype {get; set;}

        public List<String> productNames {get; set;}

        public Boolean TakeMoney {get; set;}

        public Decimal amount {get; set;}
    }
}