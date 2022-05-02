@isTest
public class LaunchOrphanVisitForm_Test {
        
    @isTest static void testfetchOrphanVisitsWithOrphan() {
        Date dueDate = Date.today();
        List<Orphan_Visit__c> listOrphanVisits = new List<Orphan_Visit__c>();
        Integer countVisits;
        test.startTest();
        Contact orphanContact = (Contact) TestFactory.createSObject(
            new Contact(LastName='test',RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Orphan').getRecordTypeId()),
            true
        );
        Orphan_Visit__c orphanVisit = (Orphan_Visit__c)TestFactory.createSObject(
            new Orphan_Visit__c(Orphan__c=orphanContact.Id,Comments__c='test',Status__c='In Progress',Due_Date__c=dueDate),
            true
        );
        listOrphanVisits = LaunchOrphanVisitForm.fetchOrphanVisits(orphanContact.Id);
        listOrphanVisits = LaunchOrphanVisitForm.fetchOrphanVisitsbySearch('test', orphanContact.Id);
        countVisits = LaunchOrphanVisitForm.countOrphanVisitsbySearch('test', orphanContact.Id);
        test.stopTest();
    }
    
    @isTest static void testfetchOrphanVisitsWithoutOrphan() {
        Date dueDate = Date.today();
        List<Orphan_Visit__c> listOrphanVisits = new List<Orphan_Visit__c>();
        Integer countVisits;
        test.startTest();
        Contact orphanContact = (Contact) TestFactory.createSObject(
            new Contact(RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Orphan').getRecordTypeId()),
            true
        );
        Orphan_Visit__c orphanVisit = (Orphan_Visit__c)TestFactory.createSObject(
            new Orphan_Visit__c(Orphan__c=orphanContact.Id,Comments__c='test',Status__c='In Progress',Due_Date__c=dueDate),
            true
        );
        listOrphanVisits = LaunchOrphanVisitForm.fetchOrphanVisits(null);
        listOrphanVisits = LaunchOrphanVisitForm.fetchOrphanVisitsbySearch('test', null);
        countVisits = LaunchOrphanVisitForm.countOrphanVisitsbySearch(null, null);
        test.stopTest();
    }
}