@isTest
public class SetupPaymentWizardControllerTest {
    
    @testsetup
    static void setupTestConfig(){
        SmarterPay_Direct_Debit_Settings__c config = new SmarterPay_Direct_Debit_Settings__c(Bank_Account_Checker_Endpoint__c = 'www.test.com',
                                                                                             User_Id__c = '123456');
        insert config;
        
        SmarterPay_Payment_Config__c paymentConfig = new SmarterPay_Payment_Config__c();
        paymentConfig.APIKey__c = '123456';
        paymentConfig.SmarterPay_User_Name__c = 'test';
        
        paymentConfig.Standard_MOTO__c = '/MOTO';
        paymentConfig.Standard_Ecommerce__c = '/Ecommerce';
        paymentConfig.Standard_Repeat__c = '/Repeat';
        paymentConfig.Standard_Refund__c = '/Refund';
        paymentConfig.Standard_Deferred_Capture_MOTO__c = '/DeferredCaptureMOTO';
        paymentConfig.Standard_Deferred_Capture_Ecommerce__c = '/DeferredCaptureEcommerce';
        paymentConfig.Standard_Deferred_Release__c = '/DeferredRelease'; 
        paymentConfig.Standard_Authenticate_Capture_MOTO__c = '/AuthenticateCaptureMOTO'; 
        paymentConfig.Standard_Authenticate_Capture_Ecommerce__c = '/AuthenticateCaptureEcommerce'; 
        paymentConfig.Standard_Authenticate_Release__c = '/AuthenticateRelease';
        
        insert paymentConfig;
        
        TriggerSettings__c triggersettings = new TriggerSettings__c();
        triggersettings.Card_Payment_History_Trigger__c = true;
        triggersettings.Card_Payment_Trigger__c = true;
        triggersettings.Payment_Schedule_Trigger__c = false;
        insert triggersettings;
        createObjectFramework();
    }
    
    private static void createObjectFramework()
    {
        contact contact = new Contact();
        contact.Firstname = 'Name1';
        contact.Lastname = 'Name2';
        contact.Email = 'test@test.com';
        contact.MailingStreet = 'test';
        contact.MailingCity = 'test';
        contact.MailingPostalCode = 'test';
        contact.MailingState = 'test';  
        contact.MailingCountry = 'UK';
        
        insert contact;
        
        HA_Payment_Schedule__c schedule = new HA_Payment_Schedule__c();
        schedule.Frequency__c = 'Monthly';
        schedule.Payment_Methods__c = 'Credit/Debit Card';
        insert schedule;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test OPP';
        opp.CloseDate = Date.Today();
        opp.StageName = 'Prospecting';
        opp.Amount= 1;
        opp.CurrencyIsoCode = 'GBP';    
        opp.npsp__Primary_Contact__c = contact.Id;
        opp.Payment_Schedule__c = schedule.Id;
        opp.Regional_office_Code__c = 'UK';
        
        insert opp;
        
        npsp__General_Accounting_Unit__c  unit = new npsp__General_Accounting_Unit__c();
        unit.Name = 'Test Unit';
        unit.CurrencyIsoCode = 'GBP';
        insert unit;
        
        Payment_Schedule_Allocation__c scheduleAllocation = new Payment_Schedule_Allocation__c(General_Accounting_Unit__c = unit.Id,
                                                                                               Payment_Schedule__c = schedule.Id);
        insert scheduleAllocation;
        
        npsp__Allocation__c guaAllication = new npsp__Allocation__c();
        guaAllication.npsp__Opportunity__c = opp.Id;
        guaAllication.npsp__Amount__c = 1;
        guaAllication.CurrencyIsoCode = 'GBP';
        guaAllication.npsp__General_Accounting_Unit__c = unit.Id;
        insert guaAllication;
    }
    @isTest static void testGetOpportunity() {
        
        Opportunity opp = [Select Id,Regional_Office_Code__c From Opportunity limit 1];
        Test.startTest();
        SetupPaymentWizardController.CheckoutWrapper response = SetupPaymentWizardController.getOpportunity(opp.Id);
        Test.stopTest();
        System.assertEquals(opp.Id, response.theOpportunity.Id);
        System.assert(String.isBlank(response.error) == true);
    }
    
    @isTest static void testValidateBankDetails() {
        
        setupBankFinderMock();
        
        Income_Direct_Debit__c directDebit = new Income_Direct_Debit__c(DD_Bank_Sort_Code__c = '074456', DD_Bank_Account_Number__c = '11104102');
        
        Test.startTest();
        SetupPaymentWizardController.modulusCheckDirectDebit(directDebit);
        Test.stopTest();
    }
    
    @isTest static void testSaveDirectDebit() {
        
        System.debug('#### testSaveDirectDebit');
        
        setupPaymentScheduleMock();
        Opportunity opp = [Select Id,Regional_Office_Code__c From Opportunity limit 1];
        Contact contact = [Select Id FROM Contact limit 1];
        npsp__General_Accounting_Unit__c  unit = [SElECT Id,Name From  npsp__General_Accounting_Unit__c where Name = 'Test Unit' limit 1];
        System.debug('#### contact: ' + contact);
        System.debug('#### opp: ' + opp);
        Test.startTest();
        npe03__Recurring_Donation__c rd = (npe03__Recurring_Donation__c) TestFactory.createSObject(
            new npe03__Recurring_Donation__c(
                npe03__Contact__c = contact.Id,
                npe03__Amount__c = 100,
                npsp__StartDate__c = Date.today(),
                npsp__PaymentMethod__c = 'Direct Debit',
                npe03__Date_Established__c = Date.today(),
                npsp__Day_of_Month__c = String.valueOf(Date.today().day())
            ),
            'TestFactoryDefaults.RDDefaults'
        );
        insert rd;
        
        Income_Direct_Debit__c directDebit = new Income_Direct_Debit__c(Contact__c = contact.Id, Recurring_Donation__c = rd.Id, Opportunity__c = opp.Id, 
                                                                        DD_Bank_Sort_Code__c = '074456', DD_Bank_Account_Number__c = '11104102');
        
        
        SetupPaymentWizardController.saveDirectDebit(directDebit);
        Test.stopTest();
    }
    @isTest static void testCreatePaymentRecord()  {        
        Opportunity opp = [Select Id,Regional_Office_Code__c From Opportunity limit 1];
        Contact contact = [Select Id FROM Contact limit 1];
        Id response = SetupPaymentWizardController.createPaymentRecord(opp.Id, contact.Id, 'Cash', '2');
        
        System.assert(response != null);
    }
    
    @isTest static void testGenerateCardPaymentLink() {
        Opportunity opp =  [Select CurrencyIsoCode,Id,Regional_Office_Code__c,npsp__Primary_Contact__r.FirstName,npsp__Primary_Contact__r.LastName,npsp__Primary_Contact__r.Mailingstate,npsp__Primary_Contact__r.Email,npsp__Primary_Contact__r.MailingCountry,npsp__Primary_Contact__r.MailingPostalCode,npsp__Primary_Contact__r.MailingCity,npsp__Primary_Contact__r.MailingStreet From Opportunity limit 1];
        
        String url = SetupPaymentWizardController.generateCardPaymentLink(opp, 5, true, 'test');
        
        System.assert(String.isNotBlank(url) == true);
    } 
    @isTest static void testGeneratepollForCardPaymentSuccess() {
        Opportunity opp =  [Select CurrencyIsoCode,Id,Regional_Office_Code__c,npsp__Primary_Contact__r.FirstName,npsp__Primary_Contact__r.LastName,npsp__Primary_Contact__r.Mailingstate,npsp__Primary_Contact__r.Email,npsp__Primary_Contact__r.MailingCountry,npsp__Primary_Contact__r.MailingPostalCode,npsp__Primary_Contact__r.MailingCity,npsp__Primary_Contact__r.MailingStreet From Opportunity limit 1];
        
        String url = SetupPaymentWizardController.pollForCardPaymentSuccess(opp.Id,'test');
        
    } 
    
    private static void setupBankFinderMock()
    {
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, '{"ProcessMessageResult":{"BankName":"COUTTS & CO","BranchTitle":"STRAND","SortCodeOK":true,"DirectDebitsOK":true,"AccountCodeOK":true,"BankAddress1":"Test1","BankAddress2":"Test2","BankAddress3":"Test3","BankAddress4":"Test4" }}');
        Test.setMock(HttpCalloutMock.class, fakeResponse);
    }
    
    private static void setupPaymentScheduleMock()
    {
        String responseBody = '{"ProcessListNewDDFirstCollectionDateResult":[{"Error":"","FirstCollectionDate":"2019-01-06"}]}';        
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
    }
    
    
}