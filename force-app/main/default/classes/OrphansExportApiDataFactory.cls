@isTest
public class OrphansExportApiDataFactory {
    public static List<Contact> createOrphans(Integer numOrphans) {
        List<Contact> orphans = new List<Contact>();
        
        for(Integer i=0;i<numOrphans;i++) {
            Contact c = new Contact(MailingCountry = 'United Kingdom',MailingStreet='Carrs Road',MailingCity='Manchester',MailingState='No State',
                					FirstName='TestOrphan' + i,
                					LastName = 'TestOrphan' + i,
                					Country__c = 'General',
                					RecordTypeId = Schema.SObjectType.contact.getRecordTypeInfosByDeveloperName().get('Orphan').getRecordTypeId()
                                   );
            orphans.add(c);
        }
        insert orphans;
  
        return orphans;
    }
}