@isTest
public class HA_ValidateOrphanProfileActive_TDTM_Test {
	
   @isTest
   static void validateOrphanProfileActiveTest() {

    List<npsp__Trigger_Handler__c> listHandlers = npsp.TDTM_Config_API.getCachedRecords();

    npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
    th.Name = 'ValidateOrphanProfileActive_TDTM';
    th.npsp__Class__c = 'HA_ValidateOrphanProfileActive_TDTM';
    th.npsp__Object__c = 'Contact';
    th.npsp__Trigger_Action__c = 'BeforeUpdate;BeforeInsert';
    th.npsp__Active__c = true;
    th.npsp__Load_Order__c = 1;
    th.npsp__Asynchronous__c = false;
    listHandlers.add(th);
	
    Id recordTypeOrphanId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Orphan').getRecordTypeId();
    
    Boolean errorOccured = false;
    
    try {
        
        List<Contact> contactList = (List<Contact>) TestFactory.createSObjectList(
            new Contact(RecordTypeId = recordTypeOrphanId),
            1,
            true
        );
        
    }
    catch(DmlException ex) {
        errorOccured = true ;
        System.assertEquals(Label.HA_ErrorMessage_OrphanProfilePhotoRequired,ex.getDmlMessage(0));
    }
    
    System.assertEquals(true, errorOccured);   
    
       
    List<Contact> contactList = (List<Contact>) TestFactory.createSObjectList(
            new Contact(RecordTypeId = recordTypeOrphanId,Is_Active__c = false),
            1,
            true
        );   

    Contact objCon = [SELECT Id,CHY3_Form_Received__c,CHY3_Expiry_Date__c,CHY3_Form_Sent__c,CHY3_Qualified_Donor__c,CHY3_Receive_Date__c,CHY3_Send_Date__c,Is_Active__c FROM Contact LIMIT 1];
	
   	System.debug('****objCon:-'+objCon);
    
    objCon.Is_Active__c = true;

    errorOccured = false;

    Test.startTest();
    try {

        update objCon;
    }
    catch(DmlException ex) {
        errorOccured = true ;
        System.assertEquals(Label.HA_ErrorMessage_OrphanProfilePhotoRequired,ex.getDmlMessage(0));
    }

    System.assertEquals(true, errorOccured);

    Test.stopTest();
   }
}