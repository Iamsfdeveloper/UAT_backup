@isTest
public with sharing class HA_UnReservedBatch_Test {
    
    public static Date reservedDate = Date.newInstance(2022, 01, 20);
    @TestSetup
    static void makeData() {
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
        Boolean isNpspTriggerDisabled = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>());
        
         List<Contact> orphanContacts = (List<Contact>) TestFactory.createSObjectList(
            new Contact(RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Orphan').getRecordTypeId(),Is_Active__c=true,Sponsorship_Status__c='Unsponsored',Sponsoree_Reserved_Until__c=reservedDate),
            1,
            true
        );
    }
    
    @isTest
    Static void unit_1(){
        Test.startTest(); 
            HA_UnReservedBatch myBatch = new HA_UnReservedBatch();
            Database.executeBatch(myBatch,1);
        Test.stopTest();
    
    }

}