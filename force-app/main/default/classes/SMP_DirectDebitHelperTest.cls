@isTest
public with sharing class SMP_DirectDebitHelperTest
{
   // Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
    //Boolean isNpspTriggerDisabled = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>());        
    @testSetup
    static void makeData(){
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
        Boolean isNpspTriggerDisabled = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>()); 
    }
    private static List<Income_Debit_History__c> createTestHistories()
    {

        List<Income_Debit_History__c> testHistories = new List<Income_Debit_History__c>();
        
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'New Instruction', DD_Stage__c = 'Submitted', DD_Code__c = 'ADDACS-01'));
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'New Instruction', DD_Stage__c = 'Successful', DD_Code__c = 'ADDACS-02'));
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'New Instruction', DD_Stage__c = 'Failed', DD_Code__c = 'ADDACS-03'));

        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'First Collection', DD_Stage__c = 'Submitted', DD_Code__c = 'ARRUD-01'));        
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'First Collection', DD_Stage__c = 'Successful', DD_Code__c = 'ARRUD-02'));
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'First Collection', DD_Stage__c = 'Failed', DD_Code__c = 'ARRUD-03'));

        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'Ongoing Collection', DD_Stage__c = 'Successful', DD_Code__c = 'ARRUD-01'));

        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'Final Collection', DD_Stage__c = 'Submitted', DD_Code__c = 'ARRUD-02'));
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'First Represent', DD_Stage__c = 'Submitted', DD_Code__c = 'ARRUD-03'));
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'Second Represent', DD_Stage__c = 'Submitted', DD_Code__c = 'ARRUD-01'));
        testHistories.add(new Income_Debit_History__c(DD_Status__c = 'Third Represent', DD_Stage__c = 'Submitted', DD_Code__c = 'ARRUD-02'));

        return testHistories;
    }

    @isTest static void testGetParentDirectDebitsFromHistories() {
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
        Boolean isNpspTriggerDisabled = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>()); 
        Test.startTest();
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
				Opportunity__c = opp.Id,
                npsp__StartDate__c = Date.today(),
                npsp__PaymentMethod__c = 'Direct Debit',
                npe03__Date_Established__c = Date.today(),
                npsp__Day_of_Month__c = String.valueOf(Date.today().day())
            ),
            'TestFactoryDefaults.RDDefaults'
        );
        insert rd;

        Income_Direct_Debit__c testDirectDebit = new Income_Direct_Debit__c(Opportunity__c = opp.Id, Recurring_Donation__c = rd.Id, Contact__c = member.Id, DD_Bank_Account_Number__c = '00000000', DD_Bank_Sort_Code__c = '000000');
        insert testDirectDebit;

        Income_Debit_History__c testDirectDebitHistory = new Income_Debit_History__c(Income_Direct_Debit__c = testDirectDebit.Id);
        insert testDirectDebitHistory;

        Map<Id, Income_Direct_Debit__c> returnedDirectDebits = SMP_DirectDebitHelper.getParentDirectDebitsFromHistories(new List<Income_Debit_History__c>{testDirectDebitHistory});
		
        System.assertEquals(1, returnedDirectDebits.Size());
        Test.stopTest();
    }

    @isTest static void testGetNewInstructions() {
        Test.startTest();
        List<Income_Debit_History__c> testHistories = createTestHistories();

        List<Income_Debit_History__c> returnedHistories = SMP_DirectDebitHelper.getNewInstructions(testHistories);

        System.assertEquals(3, returnedHistories.Size());    
        Test.stopTest();
    }

    @isTest static void testGetNewInstructionsByStage() {
        Test.startTest();
        List<Income_Debit_History__c> testHistories = createTestHistories();

        List<Income_Debit_History__c> returnedHistories = SMP_DirectDebitHelper.getNewInstructionsByStage(testHistories, null, 'Submitted');

        System.assertEquals(1, returnedHistories.Size());
        System.assertEquals('Submitted', returnedHistories[0].DD_Stage__c);

        returnedHistories = SMP_DirectDebitHelper.getNewInstructionsByStage(testHistories, null, 'Successful');
        System.assertEquals(1, returnedHistories.Size());
        System.assertEquals('Successful', returnedHistories[0].DD_Stage__c);
        Test.stopTest();
    }

    @isTest static void testGetCollections() {
        Test.startTest();
        List<Income_Debit_History__c> testHistories = createTestHistories();

        List<Income_Debit_History__c> returnedHistories = SMP_DirectDebitHelper.getCollections(testHistories);

        System.assertEquals(8, returnedHistories.Size());
        Test.stopTest();
    }

    @isTest static void testGetCollectionsByStage() {
        Test.startTest();
        List<Income_Debit_History__c> testHistories = createTestHistories();

        List<Income_Debit_History__c> returnedHistories = SMP_DirectDebitHelper.getCollectionsByStage(testHistories, null, 'Failed');

        System.assertEquals(1, returnedHistories.Size());
        System.assertEquals('Failed', returnedHistories[0].DD_Stage__c);

        returnedHistories = SMP_DirectDebitHelper.getCollectionsByStage(testHistories, null, 'Successful');
        System.assertEquals(2, returnedHistories.Size());
        System.assertEquals('Successful', returnedHistories[0].DD_Stage__c);
        System.assertEquals('Successful', returnedHistories[1].DD_Stage__c);
        System.assertEquals('First Collection', returnedHistories[0].DD_Status__c);
        System.assertEquals('Ongoing Collection', returnedHistories[1].DD_Status__c);
        Test.stopTest();
    }

    @isTest static void testGetHistoriesByReasonCode() {
        Test.startTest();
        List<Income_Debit_History__c> testHistories = createTestHistories();

        List<Income_Debit_History__c> returnedHistories = SMP_DirectDebitHelper.getHistoriesByReasonCode(testHistories, null, new Set<String>{'ADDACS-02'});

        System.assertEquals(1, returnedHistories.Size());
        System.assertEquals('ADDACS-02', returnedHistories[0].DD_Code__c);
        Test.stopTest();
    }
}