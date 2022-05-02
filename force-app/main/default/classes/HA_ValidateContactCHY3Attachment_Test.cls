/**
 * @description       : Test Class for HA_ValidateContactCHY3Attachment_TDTM Class
 * @author            : Kalpesh.Thakur@HumanAppeal.co.uk
 * @group             : 
 * @last modified on  : 07-22-2021
 * @last modified by  : Kalpesh.Thakur@HumanAppeal.co.uk
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   07-22-2021   Kalpesh.Thakur@HumanAppeal.co.uk   Initial Version
**/
@isTest
public with sharing class HA_ValidateContactCHY3Attachment_Test {

    @isTest
   static void validateContactCHY3AttachmentTest() {

    List<npsp__Trigger_Handler__c> listHandlers = npsp.TDTM_Config_API.getCachedRecords();

    npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
    th.Name = 'ValidateContactCHY3Attachment';
    th.npsp__Class__c = 'HA_ValidateContactCHY3Attachment_TDTM';
    th.npsp__Object__c = 'Contact';
    th.npsp__Trigger_Action__c = 'BeforeUpdate';
    th.npsp__Active__c = true;
    th.npsp__Load_Order__c = 1;
    th.npsp__Asynchronous__c = false;
    listHandlers.add(th);

    List<Contact> contactList = (List<Contact>) TestFactory.createSObjectList(
        new Contact(),
        1,
        true
    );

    Contact objCon = [SELECT Id,CHY3_Form_Received__c,CHY3_Expiry_Date__c,CHY3_Form_Sent__c,CHY3_Qualified_Donor__c,CHY3_Receive_Date__c,CHY3_Send_Date__c FROM Contact LIMIT 1];

    objCon.CHY3_Form_Sent__c = true;
    objCon.CHY3_Send_Date__c = Date.today()-1;
    objCon.CHY3_Receive_Date__c = Date.today();
    objCon.CHY3_Expiry_Date__c = Date.today();
    objCon.CHY3_Form_Received__c = true;

    Boolean errorOccured = false;

    Test.startTest();
    try {

        update objCon;
    }
    catch(DmlException ex) {
        errorOccured = true ;
        System.assertEquals(Label.HA_Request_to_attach_CHY3_Form,ex.getDmlMessage(0));
    }

    System.assertEquals(true, errorOccured);

    Test.stopTest();
   }
    
   @isTest
   static void validateContactCHY3AttachmentTest_withAtt() {

    List<npsp__Trigger_Handler__c> listHandlers = npsp.TDTM_Config_API.getCachedRecords();

    npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
    th.Name = 'ValidateContactCHY3Attachment';
    th.npsp__Class__c = 'HA_ValidateContactCHY3Attachment_TDTM';
    th.npsp__Object__c = 'Contact';
    th.npsp__Trigger_Action__c = 'BeforeUpdate';
    th.npsp__Active__c = true;
    th.npsp__Load_Order__c = 1;
    th.npsp__Asynchronous__c = false;
    listHandlers.add(th);

    List<Contact> contactList = (List<Contact>) TestFactory.createSObjectList(
        new Contact(),
        1,
        true
    );

    Contact objCon = [SELECT Id,CHY3_Form_Received__c,CHY3_Expiry_Date__c,CHY3_Form_Sent__c,CHY3_Qualified_Donor__c,CHY3_Receive_Date__c,CHY3_Send_Date__c FROM Contact LIMIT 1];
       
    Blob bodyBlob=Blob.valueOf('Unit Test Body to be insert in test class'); 
            
       ContentVersion contentVersion_1 = new ContentVersion(
           Title='test', 
           PathOnClient ='test.jpg',
           VersionData = bodyBlob, 
           origin = 'H'
       );
       insert contentVersion_1;
       
       ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                          FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
       
       ContentDocumentLink contentlink = new ContentDocumentLink();
       contentlink.LinkedEntityId = objCon.id;
       contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
       contentlink.ShareType = 'V';
       insert contentlink;  

    objCon.CHY3_Form_Sent__c = true;
    objCon.CHY3_Send_Date__c = Date.today()-1;
    objCon.CHY3_Receive_Date__c = Date.today();
    objCon.CHY3_Expiry_Date__c = Date.today();
    objCon.CHY3_Form_Received__c = true;

    Boolean errorOccured = false;

    Test.startTest();
    try {

        update objCon;
    }
    catch(DmlException ex) {
        errorOccured = true ;
        System.assertEquals(Label.HA_Request_to_attach_CHY3_Form,ex.getDmlMessage(0));
    }

    System.assertEquals(true, errorOccured);

    Test.stopTest();
   }
}