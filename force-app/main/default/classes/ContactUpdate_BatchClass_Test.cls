/**
* @description       : 
* @author            : Iamsfdeveloper
* @group             : 
* @last modified on  : 12-15-2021
* @last modified by  : Iamsfdeveloper
**/
@isTest
public with sharing class ContactUpdate_BatchClass_Test {
    @TestSetup
    static void makeData(){
        List<Contact> testData = (list<Contact>)TestFactory.createSObjectList(new Contact(MailingPostalCode = 'sk82bl',MailingState='Test'),15,true);
        
    }
    @IsTest
    static void unit1(){
        
        Test.startTest();
        ContactUpdate_BatchClass batchable = new ContactUpdate_BatchClass('SELECT Id,MailingStreet,MailingCountry,MailingCity,MailingState,MailingPostalCode From Contact',HA_Utility.generateGUID());
        Database.executeBatch(batchable);
        Test.stopTest();
        
    }
}