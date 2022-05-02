@isTest
public class CheckoutController_Test
{    
    public static Opportunity opp;
    public static Opportunity opp2;
    public static npsp__General_Accounting_Unit__c unit;
    public static npsp__General_Accounting_Unit__c unit2;
    public static Contact contact;
    public static npsp__Allocation__c allocation;
    public static npsp__Allocation__c allocation2;
    public static HA_Payment_Schedule__c paymentSchedule;
    public static HA_Payment_Schedule__c paymentSchedule2;

    @isTest static void testCheckoutRouter() 
    {
       
        createObjectDDandCardFramework();
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
		
        Income_Direct_Debit__c testDD = new Income_Direct_Debit__c(Opportunity__c = opp.Id, Recurring_Donation__c = rd.Id, Contact__c = contact.Id, DD_Bank_Account_Number__c = '12345678', DD_Bank_Sort_Code__c = '112233');
        insert testDD;

        CheckoutRouterController cont = new CheckoutRouterController();
        ApexPages.currentpage().getparameters().put('id', testDD.Id);
        cont.redirect();

        ApexPages.currentpage().getparameters().put('res', 's');
        cont.redirect();

        ApexPages.currentpage().getparameters().put('res', 'f');
        cont.redirect();
        Test.stopTest();
    }
    @isTest static void testControllerMixedOpportunity() 
    {
        createObjectDDandCardFramework();
        CheckoutController controller =  new CheckoutController();
        System.assertNotEquals(0, controller.stepNo);
    }
    @isTest static void testControllerBlankTest() 
    {
        CheckoutController controller =  new CheckoutController();
        System.assertEquals(0, controller.stepNo);
    }
    @isTest static void testControllerOneOpportunity() 
    {
        createObjectFramework();
        CheckoutController controller =  new CheckoutController();
        System.assertEquals(opp.Id, controller.wrapperList[0].opp.Id);
        System.assertEquals(paymentSchedule.Name, controller.wrapperList[0].opp.Payment_Schedule__r.Name);
        System.assertEquals('DD', controller.wrapperList[0].FinalPaymenttype);
    }
    @isTest static void testControllerMultipleOpportunity() 
    {
        createMultipleObjectFramework();
        CheckoutController controller =  new CheckoutController();

        System.assertEquals(2, controller.wrapperList.size());
    }
    @isTest static void testWhichPaymentToTakeOneOpportunity() 
    {
        createObjectFramework();
        CheckoutController controller =  new CheckoutController();
        
        controller.whichPaymentToTake();
        System.assertEquals(true, controller.isDirectDebit);
        System.assertEquals(false, controller.isCardPayment);
    }
    @isTest static void testWhichPaymentToTakeMultipleOpportunity() 
    {
        createMultipleObjectFramework();
        CheckoutController controller =  new CheckoutController();
        
        controller.whichPaymentToTake();
        System.assertEquals(true, controller.isDirectDebit);
        System.assertEquals(true, controller.isCardPayment);
    }
    @isTest static void testNextActionOneOpportunity() 
    {
        createObjectFramework();
        CheckoutController controller =  new CheckoutController();
        
        controller.nextAction();
        System.assertEquals(2, controller.stepNo);
        System.assertEquals('checkout-steps__item--active', controller.currentHeaderStyle2);
        System.assertEquals(1, controller.directDebitsopps.size());
    }
    @isTest static void testSaveDirectDebit() 
    {
        createMultipleObjectFramework();
        CheckoutController controller =  new CheckoutController();

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

        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c(Opportunity__c = opp.Id, Recurring_Donation__c = rd.Id, Contact__c = contact.Id, DD_Bank_Account_Number__c = '00000000', DD_Bank_Sort_Code__c = '000000');

        List<Income_Direct_Debit__c> DDs = new List<Income_Direct_Debit__c>();
        DDs.add(testDirectDebit);
        controller.ddToCreate = DDs;

        controller.saveDirectDebit();

        System.assertNotEquals(null, controller.ddToCreate[0].Id);
        System.assertNotEquals(0, controller.stepNo);
        Test.stopTest();
    }
    @isTest static void testCheckDirectDebits() 
    {
        createMultipleObjectFramework();
        CheckoutController controller =  new CheckoutController();

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

        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c(Opportunity__c = opp.Id, Recurring_Donation__c = rd.Id, Contact__c = contact.Id, DD_Bank_Account_Number__c = '00000000', DD_Bank_Sort_Code__c = '000000');
        insert testDirectDebit;

        List<Income_Direct_Debit__c> testDDs = new List<Income_Direct_Debit__c>();
        testDDs.add(testDirectDebit);
        controller.ddToCreate = testDDs;

        System.assertEquals(true, controller.checkDirectDebits());
        Test.stopTest();
    }
    @isTest static void testNextActionMultipleOpportunity() 
    {
        createMultipleObjectFramework();
        CheckoutController controller =  new CheckoutController();
        
        controller.nextAction();
        System.assertEquals(2, controller.stepNo);
        System.assertEquals('checkout-steps__item--active', controller.currentHeaderStyle2);
        System.assertEquals(1, controller.oppsToDisplay.size());
        System.assertEquals(1, controller.directDebitsopps.size());
        System.assertNotEquals(null, controller.cardPaymentUrl);
    }
    @isTest static void testValidateBankDetails() 
    {
        createObjectFramework();

        String responseBody = '{"ProcessMessageResult":{"AccountCodeOK":true,"AccountNumber":"11104102","BankAddress1":"P.O. Box 8888","BankAddress2":"Nationwide Hse","BankAddress3":"Pipers Way","BankAddress4":"","BankAddressPostCode":"SN38 1NW","BankAddressTown":"Swindon L","BankName":"NATIONWIDE BUILDING SOCIETY","BranchTitle":"FlexAccount (NGC)","CreditsAllowedOK":false,"DirectDebitInstructionOK":true,"DirectDebitsOK":true,"Error":"","SortCode":"074456","SortCodeOK":true,"Telephone":"0800 302011"}}';        
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        CheckoutController controller =  new CheckoutController();
        controller.directDebit.DD_Bank_Account_Name__c = 'Test';
        controller.directDebit.DD_Bank_Sort_Code__c = '074456';
        controller.directDebit.DD_Bank_Account_Number__c = '11104102';

        Test.startTest();
        controller.ddCheck = true;
        controller.validateBankDetails();
        Test.stopTest();

        System.assertEquals(true, controller.directDebit.DD_Account_Number_OK__c);
        System.assertEquals(true, controller.directDebit.DD_Sort_Code_OK__c);
        System.assertEquals(true, controller.directDebit.DD_OK__c);
    }
    private static void setupTestConfig()
    {
        String responseBody = '{"ProcessListNewDDFirstCollectionDateResult":[{"Error":"","FirstCollectionDate":"2019-01-06"}]}';        
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
    }
    @isTest static void testMoveBetweenPages() 
    {
        createObjectFramework();
        CheckoutController controller = new CheckoutController();

        controller.nextAction();
        controller.stepNo = 2;

        controller.nextAction();
        controller.stepNo = 3;
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

        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c(Opportunity__c = opp.Id, Recurring_Donation__c = rd.Id, Contact__c = contact.Id, DD_Bank_Account_Number__c = '00000000', DD_Bank_Sort_Code__c = '000000');
        insert testDirectDebit;

        List<Income_Direct_Debit__c> DDs = new List<Income_Direct_Debit__c>();
        DDs.add(testDirectDebit);
        controller.ddToCreate = DDs;

        controller.nextAction();
        Test.stopTest();
    }
    @isTest static void testSetupDirectDebit() 
    {
        createObjectFramework();

        SMP_DDServiceNextCollectionModel model = new SMP_DDServiceNextCollectionModel();
        String responseBody = '{"ProcessNewDDFirstCollectionDateResult":{"FirstCollectionDate":"2017-11-05","Error":""}}';
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        CheckoutController controller = new CheckoutController();
        Test.startTest();
        controller.wrapperList[0].FinalPaymenttype = 'DD';
        controller.collectDDRecords();        
        controller.setupDirectDebit();

        Test.stopTest();

        System.assertEquals(1, controller.ddToCreate.size());
    }
 
    private static void createObjectDDandCardFramework()
    {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'HH_Account' AND SObjectType = 'Account'].Id;
        insert acc;

        contact = new Contact();
        contact.Firstname = 'Name1';
        contact.Lastname = 'Name2';
        contact.Email = 'test@test.com';
        contact.MailingStreet = 'test';
        contact.MailingCity = 'test';
        contact.MailingPostalCode = 'test';
        contact.MailingState = 'test';  
        contact.MailingCountry = 'UK';
        contact.AccountId = acc.Id;
        insert contact;

        HA_Payment_Schedule__c schedule = new HA_Payment_Schedule__c();
        schedule.Frequency__c = 'Monthly';
        schedule.Payment_Methods__c = 'Direct Debit;Credit/Debit Card';
        insert schedule;

        opp = new Opportunity();
        opp.Name = 'Test OPP';
        opp.CloseDate = Date.Today();
        opp.StageName = 'Prospecting';
        opp.Amount= 2;
        opp.CurrencyIsoCode = 'GBP';    
        opp.npsp__Primary_Contact__c = contact.Id;
        opp.Payment_Schedule__c = schedule.Id;
        opp.AccountId = acc.Id;
        opp.Type = 'Payment Plan - Source';

        insert opp;

        Test.setCurrentPageReference(new PageReference('Checkout.page'));
        
        System.currentPageReference().getParameters().put('oppId', opp.Id);
        
        unit = new npsp__General_Accounting_Unit__c();
        unit.Name = 'Test Unit';
        unit.CurrencyIsoCode = 'GBP';
        insert unit;

        allocation = new npsp__Allocation__c();
        allocation.npsp__Opportunity__c = opp.Id;
        allocation.npsp__Amount__c = 1;
        allocation.CurrencyIsoCode = 'GBP';
        allocation.npsp__General_Accounting_Unit__c = unit.Id;
        insert allocation;

        Payment_Schedule_Allocation__c scheduleAllocation = new Payment_Schedule_Allocation__c(General_Accounting_Unit__c = unit.Id,
                                                                                                Payment_Schedule__c = schedule.Id);
        insert scheduleAllocation;

        unit = new npsp__General_Accounting_Unit__c();
        unit.Name = 'Test Unit';
        unit.CurrencyIsoCode = 'GBP';
        insert unit;

        allocation = new npsp__Allocation__c();
        allocation.npsp__Opportunity__c = opp.Id;
        allocation.npsp__Amount__c = 1;
        allocation.CurrencyIsoCode = 'GBP';
        allocation.npsp__General_Accounting_Unit__c = unit.Id;
        insert allocation;

        scheduleAllocation = new Payment_Schedule_Allocation__c(General_Accounting_Unit__c = unit.Id,
                                                                Payment_Schedule__c = schedule.Id);
        insert scheduleAllocation;
    }
    private static void createObjectFramework()
    {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'HH_Account' AND SObjectType = 'Account'].Id;
        insert acc;

        contact = new Contact();
        contact.Firstname = 'Name1';
        contact.Lastname = 'Name2';
        contact.Email = 'test2@test.com';
        contact.MailingStreet = 'test';
        contact.MailingCity = 'test';
        contact.MailingPostalCode = 'test';
        contact.MailingState = 'test';  
        contact.MailingCountry = 'UK';
        contact.AccountId = acc.Id;
        insert contact;

        paymentSchedule = new HA_Payment_Schedule__c(
            Name = 'Monthly Donation',
            Code__c = 'RD',
            Start_Date__c = Date.parse('30/11/2020'),
            End_Date__c = Date.parse('30/11/2099'),
            Frequency__c = 'Monthly',
            Processing_Time__c = 'AM',
            Payment_Methods__c = 'Direct Debit',
            Type__c = 'Recurring'
          );
        insert paymentSchedule;


        opp = new Opportunity();
        opp.Name = 'Test OPP';
        opp.CloseDate = Date.Today();
        opp.StageName = 'Prospecting';
        opp.Amount= 1;
        opp.CurrencyIsoCode = 'GBP';    
        opp.npsp__Primary_Contact__c = contact.Id;
        opp.Payment_Schedule__c = paymentSchedule.Id;
        opp.AccountId = acc.Id;
        opp.Type = 'Payment Plan - Source';
        insert opp;

        Test.setCurrentPageReference(new PageReference('Checkout.page'));
        
        System.currentPageReference().getParameters().put('oppId', opp.Id);
        
        unit = new npsp__General_Accounting_Unit__c();
        unit.Name = 'Test Unit';
        unit.CurrencyIsoCode = 'GBP';
        insert unit;

        allocation = new npsp__Allocation__c();
        allocation.npsp__Opportunity__c = opp.Id;
        allocation.npsp__Amount__c = 1;
        allocation.CurrencyIsoCode = 'GBP';
        allocation.npsp__General_Accounting_Unit__c = unit.Id;
        insert allocation;

        Payment_Schedule_Allocation__c scheduleAllocation = new Payment_Schedule_Allocation__c(General_Accounting_Unit__c = unit.Id,
                                                                                                Payment_Schedule__c = paymentSchedule.Id);
        insert scheduleAllocation;
    }
    private static void createMultipleObjectFramework()
    { 
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'HH_Account' AND SObjectType = 'Account'].Id;
        insert acc;

        contact = new Contact();
        contact.Firstname = 'Name1';
        contact.Lastname = 'Name2';
        contact.Email = 'test@test2.com';
        contact.MailingStreet = 'test';
        contact.MailingCity = 'test';
        contact.MailingPostalCode = 'test';
        contact.MailingState = 'test';  
        contact.MailingCountry = 'UK';
        contact.AccountId = acc.Id;
        insert contact;

        paymentSchedule = new HA_Payment_Schedule__c(
            Name = 'Monthly Donation',                 
            Code__c = 'RD',                              
            Start_Date__c = Date.parse('30/11/2020'),  
            End_Date__c = Date.parse('30/11/2099'),    
            Frequency__c = 'Monthly',                    
            Processing_Time__c = 'AM',
            Payment_Methods__c = 'Credit/Debit Card',
            Type__c = 'Recurring'
          );
        insert paymentSchedule;

        opp = new Opportunity();
        opp.Name = 'Test OPP';
        opp.CloseDate = Date.Today();
        opp.StageName = 'Prospecting';
        opp.Amount= 1;
        opp.CurrencyIsoCode = 'GBP';    
        opp.npsp__Primary_Contact__c = contact.Id;
        opp.Payment_Schedule__c = paymentSchedule.Id;
        opp.AccountId = acc.Id;
        opp.Website_Code__c = 'UK';
        opp.Type = 'Payment Plan - Source';
        insert opp;

        paymentSchedule2 = new HA_Payment_Schedule__c(
            Name = 'Monthly Donation',                 
            Code__c = 'RD',                              
            Start_Date__c = Date.parse('30/11/2020'),  
            End_Date__c = Date.parse('30/11/2099'),    
            Frequency__c = 'Monthly',                    
            Processing_Time__c = 'AM',
            Payment_Methods__c = 'Direct Debit',
            Type__c = 'Recurring'
          );
        insert paymentSchedule2;

        opp2 = new Opportunity();
        opp2.Name = 'Test OPP';
        opp2.CloseDate = Date.Today();
        opp2.StageName = 'Prospecting';
        opp2.Amount= 1;
        opp2.CurrencyIsoCode = 'GBP';    
        opp2.npsp__Primary_Contact__c = contact.Id;
        opp2.Payment_Schedule__c = paymentSchedule2.Id;
        opp2.AccountId = acc.Id;
        opp.Type = 'Payment Plan - Source';
        insert opp2;

        Test.setCurrentPageReference(new PageReference('Checkout.page'));
        
        System.currentPageReference().getParameters().put('oppId', opp.Id+','+opp2.Id);
        
        unit = new npsp__General_Accounting_Unit__c();
        unit.Name = 'Test Unit';
        unit.CurrencyIsoCode = 'GBP';
        insert unit;

        allocation = new npsp__Allocation__c();
        allocation.npsp__Opportunity__c = opp.Id;
        allocation.npsp__Amount__c = 1;
        allocation.CurrencyIsoCode = 'GBP';
        allocation.npsp__General_Accounting_Unit__c = unit.Id;
        insert allocation;

        Payment_Schedule_Allocation__c scheduleAllocation = new Payment_Schedule_Allocation__c(General_Accounting_Unit__c = unit.Id,
                                                                                                Payment_Schedule__c = paymentSchedule.Id);
        insert scheduleAllocation;

        unit2 = new npsp__General_Accounting_Unit__c();
        unit2.Name = 'Test Unit';
        unit2.CurrencyIsoCode = 'GBP';
        insert unit2;

        allocation2 = new npsp__Allocation__c();
        allocation2.npsp__Opportunity__c = opp2.Id;
        allocation2.npsp__Amount__c = 1;
        allocation2.CurrencyIsoCode = 'GBP';
        allocation2.npsp__General_Accounting_Unit__c = unit2.Id;
        insert allocation2;

        scheduleAllocation = new Payment_Schedule_Allocation__c(General_Accounting_Unit__c = unit.Id,
                                                                Payment_Schedule__c = paymentSchedule2.Id);
        insert scheduleAllocation;
    }   
}