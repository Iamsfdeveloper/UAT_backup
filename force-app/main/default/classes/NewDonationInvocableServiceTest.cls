/**
 * @File Name          : NewDonationInvocableServiceTest.cls
 * @Description        :
 * @Author             : agentgill
 * @Group              :
 * @Last Modified By   : agentgill
 * @Last Modified On   : 4/4/2020, 4:49:56 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    3/10/2020   agentgill     Initial Version
 *
 *
 **/
@isTest
public with sharing class NewDonationInvocableServiceTest {
    @TestSetup
    static void makeData() {
         Profile p = [select id 
                            from 
                            Profile 
                            where Name ='System Administrator'];
        User webisteUser = new User(Department= 'Systems & Developement',Alias = 'user1',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='Europe/London', ProfileId=p.Id,Email='test@test.com',username='test@humanAppeal.org.uk.user1',lastname='user1',FirstName='Test');
        insert webisteUser;
        
        System.runAs(webisteUser){
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Website_Donations'];
            insert new PermissionSetAssignment(AssigneeId = webisteUser.id, PermissionSetId = ps.Id);
            npsp__General_Accounting_Unit__c testProduct = new npsp__General_Accounting_Unit__c(
                Name = 'Aqiqa',
                Donation_Item_Code__c = 'WIFU'
            );
            insert testProduct;
            insert new CollaborationGroup(Name='Integration_Users_Test', CollaborationType ='Private');
            
        }
    }

    /**
     * @description Test New Donation (Happy Path)
     * @author agentgill | 4/4/2020
     * @return void
     **/
    @isTest
    private static void testNewDonation() {
       User webisteUser = [Select Id From user Where username='test@humanAppeal.org.uk.user1'];
        System.runAs(webisteUser){
        StaticResource sr = [
            SELECT Id, Body
            FROM StaticResource
            WHERE Name = :'TestJSON'
            LIMIT 1
        ];
        String jsonBody = sr.Body.toString();

        NewDonationDataType dt = (NewDonationDataType) System.JSON.deserialize(
            jsonBody,
            NewDonationDataType.class
        );

        System.assert(dt != null, 'JSON not desrialized correctly');

        List<NewDonationInvocableService.Requests> requests = new List<NewDonationInvocableService.Requests>();
        NewDonationInvocableService.Requests request = new NewDonationInvocableService.Requests();

        List<NewDonationDataType> newDonation = new List<NewDonationDataType>();
        newDonation.add(dt);

        request.newDonation = newDonation;
        requests.add(request);

        List<NewDonationInvocableService.Results> results = new List<NewDonationInvocableService.Results>();
        NewDonationInvocableService.Results result = new NewDonationInvocableService.Results();

        Test.startTest();
        results = NewDonationInvocableService.newDonation(requests);
        Test.stopTest();

        //System.assertEquals(null, results[0].errors, 'Error generated');
        System.assertNotEquals(
            null,
            results[0].outputCollection,
            'Error generated'
        );

        System.AssertEquals(
            1,
            results.size(),
            'Something went wrong, no output'
        );

        System.assertEquals(
            'System Generated',
            [SELECT Name FROM Opportunity LIMIT 1]
            .NAME,
            'Name not correct'
        );
        }
    }
    @isTest
    private static void testNewDonation_positive() {
        insert new contact(Lastname='testOprhan',Sponsoree_ID__c='DefaultOrphan',RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Orphan').getRecordTypeId(),MailingCity='Test',MailingStreet='Test',MailingCountry='Test',MailingState='Test');
        User webisteUser = [Select Id From user Where username='test@humanAppeal.org.uk.user1'];
        System.runAs(webisteUser){
        StaticResource sr = [
            SELECT Id, Body
            FROM StaticResource
            WHERE Name = :'TestJSON_5'
            LIMIT 1
        ];
        String jsonBody = sr.Body.toString();

        NewDonationDataType dt = (NewDonationDataType) System.JSON.deserialize(
            jsonBody,
            NewDonationDataType.class
        );

        System.assert(dt != null, 'JSON not desrialized correctly');

        List<NewDonationInvocableService.Requests> requests = new List<NewDonationInvocableService.Requests>();
        NewDonationInvocableService.Requests request = new NewDonationInvocableService.Requests();

        List<NewDonationDataType> newDonation = new List<NewDonationDataType>();
        newDonation.add(dt);

        request.newDonation = newDonation;
        requests.add(request);

        List<NewDonationInvocableService.Results> results = new List<NewDonationInvocableService.Results>();
        NewDonationInvocableService.Results result = new NewDonationInvocableService.Results();

        Test.startTest();
        results = NewDonationInvocableService.newDonation(requests);
        Test.stopTest();

        //System.assertEquals(null, results[0].errors, 'Error generated');
        System.assertNotEquals(
            null,
            results[0].outputCollection,
            'Error generated'
        );

        System.AssertEquals(
            1,
            results.size(),
            'Something went wrong, no output'
        );

        System.assertEquals(
            'System Generated',
            [SELECT Name FROM Opportunity LIMIT 1]
            .NAME,
            'Name not correct'
        );
        }
    }
    /**
     * @description Test New Donation Negative Path
     * @author agentgill | 4/4/2020
     * @return void
     **/
    @isTest
    private static void testNewDonationNegative() {
        User webisteUser = [Select Id From user Where username='test@humanAppeal.org.uk.user1'];
        System.runAs(webisteUser){
        StaticResource sr = [
            SELECT Id, Body
            FROM StaticResource
            WHERE Name = :'TestJSON_2'
            LIMIT 1
        ];
        String jsonBody = sr.Body.toString();

        NewDonationDataType dx = (NewDonationDataType) System.JSON.deserialize(
            jsonBody,
            NewDonationDataType.class
        );

        System.assert(dx != null, 'JSON not desrialized correctly');

        List<NewDonationInvocableService.Requests> requests = new List<NewDonationInvocableService.Requests>();
        NewDonationInvocableService.Requests request = new NewDonationInvocableService.Requests();

        List<NewDonationDataType> newDonation = new List<NewDonationDataType>();
        newDonation.add(dx);

        request.newDonation = newDonation;
        requests.add(request);

        List<NewDonationInvocableService.Results> results = new List<NewDonationInvocableService.Results>();
        NewDonationInvocableService.Results result = new NewDonationInvocableService.Results();

        Test.startTest();
        results = NewDonationInvocableService.newDonation(requests);
        Test.stopTest();
        System.debug('>>> results testNewDonationNegative ' + results);

        System.assertEquals(
            null, results[0].errors,
            'Error generated not expected'
        );
    }
    }
}