@isTest
public with sharing class PaymentEventDirectDebitHandlerTest {
    @TestSetup
    static void makeData() {
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
        Boolean isNpspTriggerDisabled1 = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>());
        List<Contact> contacts = (List<Contact>) TestFactory.createSObjectList(
            new Contact(Email = 'salma_93@hotmail.co.uk',                                    
                        MobilePhone = '07740030241',                                      
                        npe01__WorkPhone__c = '07740030241',                         
                        MailingStreet = 'Test',
                        MailingCity = 'Test',
                        MailingCountry = 'Test',
                        MailingPostalCode = 'Test'),
            1,
            true
        );

        List<npe03__Recurring_Donation__c> rds = new List<npe03__Recurring_Donation__c>();

        for (Contact c : [
            SELECT Id, AccountId
            FROM Contact
            WHERE Id IN :contacts
        ]) {
            npe03__Recurring_Donation__c rd = (npe03__Recurring_Donation__c) TestFactory.createSObject(
                new npe03__Recurring_Donation__c(
                    npe03__Contact__c = c.Id,
                    npe03__Amount__c = 100,
                    npsp__StartDate__c = Date.today(),
                    npsp__PaymentMethod__c = 'Direct Debit',
                    npe03__Date_Established__c = Date.today(),
                    npsp__Day_of_Month__c = String.valueOf(Date.today().day())
                ),
                'TestFactoryDefaults.RDDefaults'
            );
            rds.add(rd);
        }

        insert rds;
       
    }

    /**
     * @description Test Successful Card Payment
     * @author agentgill | 07-05-2020
     **/
    @isTest
    private static void testSubmittedDirectDebitEvent() {
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
        Boolean isNpspTriggerDisabled1 = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>());
        Contact c = [SELECT Id FROM Contact];

        Opportunity sourceOpp = new Opportunity();
        sourceOpp.Name = 'Test OPP';
        sourceOpp.CloseDate = Date.Today();
        sourceOpp.StageName = 'Prospecting';
        sourceOpp.Amount= 1;
        sourceOpp.CurrencyIsoCode = 'GBP';    
        sourceOpp.npsp__Primary_Contact__c = c.Id;

        insert sourceOpp;

        Opportunity opp = [
            SELECT Id, Name, StageName, AccountId, GUID__c
            FROM Opportunity
            LIMIT 1
        ];

        Test.startTest();
		Callable npspApi1 = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
        Boolean isNpspTriggerDisabled = (Boolean)npspApi1.call('TDTM.DisableAllTriggers', new Map<String, Object>());
        opp.GUID__c = 'TESTGUID';
        opp.CloseDate = Date.Today().addDays(1);
        update opp;

        npe03__Recurring_Donation__c rd = [SELECT Id FROM npe03__Recurring_Donation__c][0];
        rd.Opportunity__c = sourceOpp.Id;
        update rd;        
		Opportunity childOpp = new Opportunity();
        childOpp.Name = 'Test OPP';
        childOpp.CloseDate = Date.Today();
        childOpp.StageName = 'Pledged';
        childOpp.Amount= 1;
        childOpp.CurrencyIsoCode = 'GBP';    
        childOpp.npsp__Primary_Contact__c = c.Id;
		childOpp.npe03__Recurring_Donation__c = rd.Id;
        insert childOpp;
        System.debug('!!! testOpp' + opp);
        Income_Direct_Debit__c dd = new Income_Direct_Debit__c(
            Opportunity__c = sourceOpp.Id, DD_Bank_Account_Number__c = '00000000', DD_Bank_Sort_Code__c = '000000', Recurring_Donation__c = rd.Id
        );
        insert dd;
        System.debug('!!! direct debit' + dd);

        Income_Debit_History__c ddh = new Income_Debit_History__c(
            Income_Direct_Debit__c = dd.Id,
            DD_Stage__c = 'Submitted',
            DD_Status__c = 'First Collection',
            Amount__c = 1,
            DD_Collection_Date__c = Date.Today()
        );

        insert ddh;

        ddh.DD_Stage__c = 'Failed';
        update ddh;

        Test.stopTest();
    }
}