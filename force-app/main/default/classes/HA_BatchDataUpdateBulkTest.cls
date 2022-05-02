@isTest
public with sharing class HA_BatchDataUpdateBulkTest {

    @isTest
    static void batchDataUpdateBulkTest() {
        
        List<Contact> contactList = (List<Contact>) TestFactory.createSObjectList(
        new Contact(),
        1,
        true
        );

        contactList[0].Regional_Office_Code__c = 'UK';
        
        update contactList;

        List<Opportunity> oppList = (List<Opportunity>) TestFactory.createSObjectList(
        new Opportunity(),
        1,
        true
        );

        oppList[0].npsp__Primary_Contact__c = contactList[0].Id;

        update oppList;

        Test.startTest();
        HA_BatchDataUpdateBulk batch = new HA_BatchDataUpdateBulk();
        Database.executeBatch(batch);
        Test.stopTest();
    
    }
}