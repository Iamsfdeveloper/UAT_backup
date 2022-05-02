/**
* @description Tests for BankFinderController
*/
@isTest
private class SMP_BankFinderControllerTest
{    
  @testSetup
    static void makeData(){
         SmarterPay_Direct_Debit_Settings__c config = new SmarterPay_Direct_Debit_Settings__c(Bank_Account_Checker_Endpoint__c = 'www.test.com',
                                                                                             User_Id__c = '123456');
        insert config;
         Contact member = new Contact();
        member.FirstName = 'testFirst';
        member.LastName = 'testLast';
        member.Email = 'test@test.com';
        member.MailingStreet = 'test';
        member.MailingCity = 'test';
        member.MailingPostalCode = 'test';
        member.MailingState = 'test';  
        member.MailingCountry = 'UK';
        insert member;
        Opportunity opp = new Opportunity();
        opp.Name = 'Test OPP';
        opp.CloseDate = Date.Today();
        opp.StageName = 'Prospecting';
        opp.Amount= 1;
        opp.CurrencyIsoCode = 'GBP';    
        opp.npsp__Primary_Contact__c = member.Id;
        insert opp;
        
        npe03__Recurring_Donation__c rd = (npe03__Recurring_Donation__c) TestFactory.createSObject(
            new npe03__Recurring_Donation__c(
                npe03__Contact__c = member.Id,
                npe03__Amount__c = 100,
                npsp__StartDate__c = Date.today(),
                npsp__PaymentMethod__c = 'Direct Debit',
                npe03__Date_Established__c = Date.today(),
                npsp__Day_of_Month__c = String.valueOf(Date.today().day())
            ),
            'TestFactoryDefaults.RDDefaults'
        );
        //insert rd;
    }
    /**
* @description Sets the response from the Bank Validation Service.
*/
    private static void setFakeResponse(integer statusCode)
    {
        String sBodyText = '';
        
        if(statusCode == 200){
            sBodyText = '{"ProcessMessageResult":{"BankName":"COUTTS & CO","BranchTitle":"STRAND","SortCodeOK":true,"DirectDebitsOK":true,"AccountCodeOK":true,"BankAddress1":"Test1","BankAddress2":"Test2","BankAddress3":"Test3","BankAddress4":"Test4" }}';
        }
        else if (statusCode == 300){
            sBodyText = '{"ProcessMessageResult":{"BankName":"COUTTS & CO","BranchTitle":"STRAND","SortCodeOK":false,"DirectDebitsOK":false,"AccountCodeOK":false,"BankAddress1":"Test1","BankAddress2":"Test2","BankAddress3":"Test3","BankAddress4":"Test4"}}';
        }
        else if (statusCode == 400){
            sBodyText = '{"ProcessMessageResult":{"BankName":"COUTTS & CO","BranchTitle":"STRAND","SortCodeOK":true,"DirectDebitsOK":false,"AccountCodeOK":true,"BankAddress1":"Test1","BankAddress2":"Test2","BankAddress3":"Test3","BankAddress4":"Test4"}}';
        }
        
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, sBodyText);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
    } 
    
    @isTest static void TestStart_BankAccountValid()
    {       
        Contact member = [Select Id From Contact Where Email = 'test@test.com' limit 1];
        Opportunity opp = [SELECT Id From Opportunity WHERE npsp__Primary_Contact__c =:member.Id limit 1];
       
        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c();        
        testDirectDebit.DD_Bank_Account_Number__c = '18273645';
        testDirectDebit.DD_Bank_Sort_Code__c = '162534';     
        testDirectDebit.Opportunity__c = opp.Id;
        testDirectDebit.Contact__c = member.Id;   
        testDirectDebit.DD_First_Collection_Date__c = System.today();
        insert testDirectDebit;
        setFakeResponse(200); 
        Test.StartTest();
        SMP_BankFinderController controller = new SMP_BankFinderController(new ApexPages.StandardController(testDirectDebit));
         controller.start();
        Test.StopTest();
        
        System.assertEquals('STRAND', testDirectDebit.DD_Branch_Name__c);
        System.assertEquals('COUTTS & CO', testDirectDebit.DD_Bank_Name__c);
        System.assertEquals(true, testDirectDebit.DD_OK__c);
        System.assertEquals(true, testDirectDebit.DD_Sort_Code_OK__c);
        System.assertEquals(true, testDirectDebit.DD_Account_Number_OK__c);    
    }
    
    /**
* @description Checks that the correct values are updated for a valid bank account.
*/
    @isTest static void GetBankDetailsAndUpdate_BankAccountValid()
    {
        Contact member = [Select Id From Contact Where Email = 'test@test.com' limit 1];
        Opportunity opp = [SELECT Id From Opportunity WHERE npsp__Primary_Contact__c =:member.Id limit 1];
        
        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c();        
        testDirectDebit.DD_Bank_Account_Number__c = '18273645';
        testDirectDebit.DD_Bank_Sort_Code__c = '162534';   
        testDirectDebit.Opportunity__c = opp.Id;
        testDirectDebit.Contact__c = member.Id;
        testDirectDebit.DD_First_Collection_Date__c = System.today();
        insert testDirectDebit;
        
        setFakeResponse(200);
         Test.StartTest();
        
        SMP_BankFinderController controller = new SMP_BankFinderController(new ApexPages.StandardController(testDirectDebit));
        
        
        
        controller.getBankDetailsAndUpdate();
        Test.StopTest();
        
        testDirectDebit = [SELECT Id, DD_Account_Number_OK__c, DD_Sort_Code_OK__c, DD_OK__c, DD_Bank_Name__c, DD_Branch_Name__c 
                           FROM Income_Direct_Debit__c 
                           WHERE Id = :testDirectDebit.Id];
        
        System.assertEquals('STRAND', testDirectDebit.DD_Branch_Name__c);
        System.assertEquals('COUTTS & CO', testDirectDebit.DD_Bank_Name__c);
        System.assertEquals(true, testDirectDebit.DD_OK__c);
        System.assertEquals(true, testDirectDebit.DD_Sort_Code_OK__c);
        System.assertEquals(true, testDirectDebit.DD_Account_Number_OK__c);     
    } 
    
    /**
* @description Checks that the correct values are updated on an invalid bank account.
*/
    @isTest static void GetBankDetailsAndUpdate_BankAccountNotValid()
    {
        Contact member = [Select Id From Contact Where Email = 'test@test.com' limit 1];
        Opportunity opp = [SELECT Id From Opportunity WHERE npsp__Primary_Contact__c =:member.Id limit 1];
        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c();        
        testDirectDebit.DD_Bank_Account_Number__c = '18273645';
        testDirectDebit.DD_Bank_Sort_Code__c = '162534'; 
        testDirectDebit.Opportunity__c = opp.Id;
        testDirectDebit.Contact__c = member.Id;
        testDirectDebit.DD_First_Collection_Date__c = System.today();     
        insert testDirectDebit;

        setFakeResponse(400);
        Test.StartTest();
        
        
        SMP_BankFinderController controller = new SMP_BankFinderController(new ApexPages.StandardController(testDirectDebit));
        
        
        
        controller.getBankDetailsAndUpdate();
        Test.StopTest();
        
        testDirectDebit = [SELECT Id, DD_Account_Number_OK__c, DD_Sort_Code_OK__c, DD_OK__c, DD_Bank_Name__c, DD_Branch_Name__c 
                           FROM Income_Direct_Debit__c 
                           WHERE Id = :testDirectDebit.Id];
        
        System.assertEquals('STRAND', testDirectDebit.DD_Branch_Name__c);
        System.assertEquals('COUTTS & CO', testDirectDebit.DD_Bank_Name__c);
        System.assertEquals(false, testDirectDebit.DD_OK__c);
        System.assertEquals(true, testDirectDebit.DD_Sort_Code_OK__c);
        System.assertEquals(true, testDirectDebit.DD_Account_Number_OK__c);     
    }
    
    /**
* @description Checks that the correct values are updated for an account that is unable to use direct debits.
*/
    @isTest static void GetBankDetailsAndUpdate_DirectDebitsNotAllowed()
    {
       
       Contact member = [Select Id From Contact Where Email = 'test@test.com' limit 1];
        Opportunity opp = [SELECT Id From Opportunity WHERE npsp__Primary_Contact__c =:member.Id limit 1];
        
        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c();        
        testDirectDebit.DD_Bank_Account_Number__c = '18273645';
        testDirectDebit.DD_Bank_Sort_Code__c = '162534';  
        testDirectDebit.Opportunity__c = opp.Id;
        testDirectDebit.Contact__c = member.Id;
        testDirectDebit.DD_First_Collection_Date__c = System.today();
        insert testDirectDebit;
        
        setFakeResponse(300);
        Test.StartTest();
        
        SMP_BankFinderController controller = new SMP_BankFinderController(new ApexPages.StandardController(testDirectDebit));
   
        controller.getBankDetailsAndUpdate();
        Test.StopTest();
        
        testDirectDebit = [SELECT Id, DD_Account_Number_OK__c, DD_Sort_Code_OK__c, DD_OK__c, DD_Bank_Name__c, DD_Branch_Name__c 
                           FROM Income_Direct_Debit__c 
                           WHERE Id = :testDirectDebit.Id];
        
        System.assertEquals('STRAND', testDirectDebit.DD_Branch_Name__c);
        System.assertEquals('COUTTS & CO', testDirectDebit.DD_Bank_Name__c);
        System.assertEquals(false, testDirectDebit.DD_OK__c);
        System.assertEquals(false, testDirectDebit.DD_Sort_Code_OK__c);
        System.assertEquals(false, testDirectDebit.DD_Account_Number_OK__c);     
    }
    
    @isTest static void SaveDirectDebit_ErroneousData()
    {     
        Contact member = [Select Id From Contact Where Email = 'test@test.com' limit 1];
        Opportunity opp = [SELECT Id From Opportunity WHERE npsp__Primary_Contact__c =:member.Id limit 1];
        Test.StartTest();
        
        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c();        
        testDirectDebit.DD_Bank_Account_Number__c = '18273645';
        testDirectDebit.DD_Bank_Sort_Code__c = '162534';       
        testDirectDebit.Opportunity__c = opp.Id;
        testDirectDebit.Contact__c = member.Id;
        testDirectDebit.DD_First_Collection_Date__c = System.today();
        insert testDirectDebit;
        
        SMP_BankFinderController controller = new SMP_BankFinderController(new ApexPages.StandardController(testDirectDebit));
       
        try
        {
            controller.ddRecord.DD_Bank_Account_Number__c = null;
            controller.ddRecord.DD_Bank_Sort_Code__c = null;
            controller.getBankDetailsAndUpdate();
        }
        catch(Exception e)
        {
            System.assert(false, 'The test failed as there was an exception in the method.');
        } 
         Test.StopTest();
    }
}