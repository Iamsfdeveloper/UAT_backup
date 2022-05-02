public with sharing class SMPRenewWizardController {

    @AuraEnabled
    public static npe03__Recurring_Donation__c getRecurringDonation(String donationId)
    {
        System.debug('#### getRecurringDonation ' + donationId);
        
        npe03__Recurring_Donation__c donation = [SELECT Id, OwnerId, Name, CurrencyIsoCode, CreatedById,Regional_Office_code__c, 
                                                    LastModifiedById, npe03__Amount__c, npe03__Contact__c, 
                                                    npe03__Date_Established__c, npe03__Donor_Name__c, 
                                                    npe03__Installment_Period__c, npe03__Installments__c, 
                                                    npe03__Last_Payment_Date__c, npe03__Next_Payment_Date__c, 
                                                    npe03__Organization__c, npe03__Paid_Amount__c, 
                                                    npe03__Recurring_Donation_Campaign__c, 
                                                    npe03__Total_Paid_Installments__c, npsp__Day_of_Month__c, 
                                                    npsp__CurrentYearValue__c, npsp__NextYearValue__c, 
                                                    npsp__CommitmentId__c, npsp__EndDate__c, Card_Payment_Detail__c, 
                                                    npsp__InstallmentFrequency__c, npsp__PaymentMethod__c, 
                                                    npsp__RecurringType__c, npsp__StartDate__c, npsp__Status__c, 
                                                    Direct_Debit_Detail__c, Opportunity__c,
                                                    npe03__Contact__r.FirstName, npe03__Contact__r.LastName,
                                                    npe03__Contact__r.MailingStreet, npe03__Contact__r.MailingCity,
                                                    npe03__Contact__r.MailingState, npe03__Contact__r.MailingPostalCode,
                                                    npe03__Contact__r.MailingCountry, npe03__Contact__r.Email
                                                    FROM npe03__Recurring_Donation__c WHERE Id = :donationId];
        
        System.debug('#### donation ' + donation);

        return donation;
    }
    @AuraEnabled
    public static Income_Direct_Debit__c saveDirectDebit(Income_Direct_Debit__c pDirectDebit, npe03__Recurring_Donation__c pDonation)
    {
        System.debug('#### saveDirectDebit');
        System.debug('#### pDirectDebit: ' + pDirectDebit);
        SMP_DDServiceHandler.SingleCollectionDateWrapper collectionDateWrapper = new SMP_DDServiceHandler.SingleCollectionDateWrapper();
        collectionDateWrapper.CollectionDay = '1';
        collectionDateWrapper.StartDate = String.valueOf(pDirectDebit.DD_Start_Date__c);
        collectionDateWrapper.CollectionPeriod = 'Monthly';
        collectionDateWrapper.NumberOfDaysToWaitFromNewInstruction = '5';
        SMP_DDServiceNextCollectionModel firstCollection = SMP_DDServiceHandler.getNextCollectionDate(collectionDateWrapper);

        pDirectDebit.DD_First_Collection_Date__c = (Test.isRunningTest())?System.today():Date.valueOf(firstCollection.ProcessNewDDFirstCollectionDateResult.FirstCollectionDate);
        pDirectDebit.DD_Next_Collection_Date__c = (Test.isRunningTest())?System.today():Date.valueOf(firstCollection.ProcessNewDDFirstCollectionDateResult.FirstCollectionDate);

        pDirectDebit.DD_Status__c = 'New Instruction';
        pDirectDebit.Recurring_Donation__c = pDonation.Id;
        pDirectDebit.Opportunity__c = pDonation.Opportunity__c;
        pDirectDebit.Contact__c = pDonation.npe03__Contact__c;
        pDirectDebit.DD_First_Collection_Amount__c = pDonation.npe03__Amount__c;

        insert pDirectDebit;    
        System.debug('#### pDirectDebit: ' + pDirectDebit);

        if(pDonation.Direct_Debit_Detail__c != null)
        {
            Income_Direct_Debit__c oldDirectDebit = [SELECT Id, DD_Status__c, DD_First_Collection_Amount__c FROM Income_Direct_Debit__c WHERE Id = :pDonation.Direct_Debit_Detail__c];
            oldDirectDebit.DD_Status__c = 'Cancelled';
            update oldDirectDebit;
            System.debug('#### oldDirectDebit: ' + oldDirectDebit);

        }

        pDonation.Direct_Debit_Detail__c = pDirectDebit.Id;
        update pDonation;
        System.debug('#### pDonation: ' + pDonation);

        return pDirectDebit;
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
    public static string getAuthPaymentURL(npe03__Recurring_Donation__c donation)
    {
        Payment_Country_Setting__mdt setting = [SELECT SmarterPay_User_Name__c, APIKey__c FROM Payment_Country_Setting__mdt WHERE DeveloperName = :donation.Regional_office_code__c];
        SMP_PaymentGateway.Payment wrapper = new SMP_PaymentGateway.Payment();
        wrapper.incomeusername = setting.SmarterPay_User_Name__c;
        wrapper.APIKey = setting.APIKey__c;
        wrapper.customerFirstName = donation.npe03__Contact__r.FirstName;
        wrapper.customerLastName = donation.npe03__Contact__r.LastName;
        wrapper.ownerId = UserInfo.getUserId();

        wrapper.billingAddressOne = donation.npe03__Contact__r.MailingStreet;
        wrapper.billingAddressCity = donation.npe03__Contact__r.MailingCity;
        wrapper.billingAddressState = donation.npe03__Contact__r.MailingState;
        wrapper.billingAddressPostalCode = donation.npe03__Contact__r.MailingPostalCode;
        wrapper.billingAddressCountry = donation.npe03__Contact__r.MailingCountry;

        wrapper.shippingAddressOne = donation.npe03__Contact__r.MailingStreet;
        wrapper.shippingAddressCity = donation.npe03__Contact__r.MailingCity;
        wrapper.shippingAddressState = donation.npe03__Contact__r.MailingState;
        wrapper.shippingAddressPostalCode = donation.npe03__Contact__r.MailingPostalCode;
        wrapper.shippingAddressCountry = donation.npe03__Contact__r.MailingCountry;
        wrapper.currencyCode = donation.CurrencyIsoCode;
        wrapper.amount = donation.npe03__Amount__c;

        wrapper.emailAddress = donation.npe03__Contact__r.Email;

        wrapper.firstReferenceId = donation.Id;
        wrapper.firstReferenceObject = 'Recurring_Donation__c';

        wrapper.secondReferenceId = donation.npe03__Contact__c;
        wrapper.secondReferenceObject = 'Contact__c';

        wrapper.internalPaymentDescription = donation.Id;
        wrapper.customerPaymentReference = 'Renewal';
        wrapper.rpenabled = false;        
        
        System.debug('#### wrapper: ' + wrapper);

     
        return SMP_PaymentGateway.generateCardPaymentURL(wrapper, SMP_PaymentGateway.Gateway.STRIPE, SMP_PaymentGateway.PaymentType.AuthenticateAuthoriseMOTO);
        
    }
}