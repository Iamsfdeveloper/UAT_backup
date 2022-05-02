public class HA_UnReservedBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC){
        
      //String query = 'SELECT Id,Name,Sponsoree_Is_Reserved__c,Sponsoree_Reserved_Until__c  FROM Contact WHERE Sponsoree_Reserved_Until__c <= LAST_MONTH AND Sponsorship_Status__c !=\'Sponsored \'';  
      String query ='SELECT Id,Name,Sponsoree_Is_Reserved__c,Sponsoree_Reserved_Until__c FROM Contact WHERE Sponsoree_Reserved_Until__c <= LAST_MONTH AND Sponsorship_Status__c !=\'Sponsored\' AND Is_Active__c = true AND RecordType.Name = \'Orphan\'';
      return Database.getQueryLocator(query);
   }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {

   		List<Contact> lstContacts = (List<Contact>) scope; 
        
        for (Contact objContact : lstContacts) {
            
            objContact.Sponsoree_Is_Reserved__c = false;
            objContact.Sponsoree_Reserved_Until__c = null;
        }
        
        update lstContacts;
 
    }
    
   	public void finish(Database.BatchableContext BC) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('Human Appeal');
        mail.setSubject('Batch Processing Reserved Orphans');
        mail.setPlainTextBody('Batch Process has completed');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
       
   	
    }
}