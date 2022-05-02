/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 10-14-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   12-18-2020   Iamsfdeveloper   Initial Version
**/
@istest
public with sharing class HA_Utility_Test {
    @IsTest
    static void unit1_Positive(){
        List<HA_Payment_Schedule__c> paymentScheduleList = (List<HA_Payment_Schedule__c>)TestFactory.createSObjectList(new HA_Payment_Schedule__c(Is_Internal__c=true),2,'TestFactoryDefaults.PaymentSchedulesDefaults');
        insert paymentScheduleList;
        List<Contact> contactList = (List<Contact>) TestFactory.createSObjectList(
            new Contact(),
            1,
            true
        );
        ContentVersion contentVersion = new ContentVersion(
        Title = 'Penguins',
        Type__c='Profile Photo',
        PathOnClient = 'MyProfilePic.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );
        insert contentVersion; 
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = contactList[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        List<npsp__Trigger_Handler__c> listHandlers = npsp.TDTM_Config_API.getCachedRecords();
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'CampaignTriggerHandler_TDTM_Mutable';
        th.npsp__Class__c = 'CampaignTriggerHandler_TDTM_Mutable';
        th.npsp__Object__c = 'CampaignMember';
        th.npsp__Trigger_Action__c = 'AfterInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        listHandlers.add(th);
        Campaign OutboundCallingCampaign = new Campaign(Name='Test',Type='Outbound_Calling',Regional_Office_code__c = 'UK');
        insert OutboundCallingCampaign;
        CampaignMember newMember = 
        new CampaignMember(ContactId = contactList[0].id, status='To Call', campaignid = OutboundCallingCampaign.id);
        insert newMember;
        List<Call_List__c> currentCallList = [SELECT Id,OwnerId FROM Call_List__c WHERE CampaignId__c =: OutboundCallingCampaign.Id];
        
        Test.startTest();
        HA_Utility.getContactDetailsFromCallList(currentCallList[0].Id);
        HA_Utility.getProfilePhotoURL(contactList[0].id);
        HA_Utility.getPaymentSchedules();
        HA_Utility.getUserInfoRegionalCode();
        Test.stopTest();
        
    }
    @IsTest
    static void unit2(){
        /*AddressCallout*/
        Contact contactObject = (Contact) TestFactory.createSObject(new Contact(),true);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        HA_Utility.getProfilePhotoURL(contactObject.id);
        HA_Utility.getAddress('SK8 2Bl');
        Test.stopTest();
        
    }
    @isTest
    static void unit3(){
        /*AddressCallout*/
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_postcode());
        Test.startTest();
        HA_Utility.getAddress('L1 8JQ');
        Test.stopTest();
        
    }
    @isTest
    static void unit4(){
        Test.startTest();
        HA_selectOption HA1= new HA_selectOption();
        HA_selectOption HA2= new HA_selectOption('Test','Test','Test');
        HA_selectOption HA3= new HA_selectOption('Test','Test','Test',true);
        HA_selectOption HA4= new HA_selectOption('Test','Test',true);
        HA_selectOption HA5= new HA_selectOption('Test','Test');
        HA_Utility.generateGUID();
		HA_Utility.getUserInfoAccountId();
        HA_Utility.getUserInfoContactId();
        HA_Utility.getCountryISOCode('United Kingdom');
        Test.stopTest();
        
    }
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod());
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"Id":"GB|RM|B|22132622","Type":"Address","Text":"Human Appeal, Pennine House, Carrs Road","Highlight":";9-12,13-16","Description":"Cheadle, SK8 2BL"}]');
            res.setStatusCode(200);
            return res;
        }
    }
    public class MockHttpResponseGenerator_postcode implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod());
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"Id":"GB|RM|ENG|8JQ-L1","Type":"Postcode","Text":"L1 8JQ","Highlight":"0-2,3-6","Description":"Wall Street, Liverpool - 15 Addresses"}]');
            res.setStatusCode(200);
            return res;
        }
    }
}