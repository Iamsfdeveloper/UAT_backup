/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 05-21-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   05-21-2021   Iamsfdeveloper   Initial Version
**/
@isTest
public with sharing class HA_BatchClass_Test {

    private static final string STAGE_PROCESSING_FAILED = 'Processing Failed';
    private static final string STAGE_PLEDGE = 'Pledge';

    @TestSetup
    static void makeData() {
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
        Boolean isNpspTriggerDisabled = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>());
         
        List<Contact> donorContacts = (List<Contact>) TestFactory.createSObjectList(
            new Contact(RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Donor').getRecordTypeId(),Regional_Office_Code__c='UK'),
            1,
            true
        );
        
        List<Contact> orphanContacts = (List<Contact>) TestFactory.createSObjectList(
            new Contact(RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Orphan').getRecordTypeId()),
            1,
            true
        );
        List<Opportunity> OpportunityList = (List<Opportunity>) TestFactory.createSObjectList(
            new Opportunity(Type='Payment Plan - Source',StageName = 'Paid' ,Donation_type__c ='RD',npsp__Primary_Contact__c =donorContacts[0].Id,Amount=100 ),
            1,
            true
        );
        List<npsp__General_Accounting_Unit__c> item = (List<npsp__General_Accounting_Unit__c>)TestFactory.createSObjectList(new npsp__General_Accounting_Unit__c(), 1, 'TestFactoryDefaults.GeneralAccountUnitsDefaults', true);
        
        List<npsp__Allocation__c> allocationList =( List<npsp__Allocation__c>)TestFactory.createSObjectList(
            new npsp__Allocation__c(npsp__General_Accounting_Unit__c =item[0].Id,npsp__Opportunity__c =OpportunityList[0].Id,npsp__Amount__c=100),
            1,'TestFactoryDefaults.ItemAllocationDefaults',true
        ); 
        List<npe03__Recurring_Donation__c> rdList =( List<npe03__Recurring_Donation__c>)TestFactory.createSObjectList(
            new npe03__Recurring_Donation__c(npsp__Status__c='Closed',Opportunity__c =OpportunityList[0].Id,npe03__Amount__c=100),
            1,'TestFactoryDefaults.RDDefaults',
            true
        ); 
       
        
    }
    @isTest
    Static void unit_1(){
        Test.setMock(HttpCalloutMock.class, new APXTConga4.MockHttpResponseGenerator());
        Test.startTest();

            HA_BatchClass myBatch = new HA_BatchClass();
            Database.executeBatch(myBatch,1);
        Test.stopTest();
    
    }
     @isTest
    Static void unit_2(){
        Test.setMock(HttpCalloutMock.class, new APXTConga4.MockHttpResponseGenerator());
        Test.startTest();
			
            HA_BatchClass myBatch = new HA_BatchClass();
            myBatch.query = 'Select Id,(Select Id,npsp__Opportunity__c,npsp__General_Accounting_Unit__c, npsp__Amount__c, Stipulation_Type__c, Receipt_Note__c, Country__c,Orphan__c From npsp__Allocations__r) From Opportunity Where CloseDate=today';
            myBatch.executeContext = 'CopyGAUAllocation';
            Database.executeBatch(myBatch,1);
			System.debug('Allocation==>'+Database.query('Select Id,npsp__Opportunity__c,npsp__Recurring_Donation__c,npsp__General_Accounting_Unit__c, npsp__Amount__c, Stipulation_Type__c, Receipt_Note__c, Country__c,Orphan__c From npsp__Allocation__c'));
        	System.debug('RD==>'+[Select Id,Name,Opportunity__c from npe03__Recurring_Donation__c]);
        	System.debug('RD Allocation'+[Select Count() From npsp__Allocation__c Where npsp__Recurring_Donation__c != null]);
        	//system.assertEquals(1, [Select Count() From npsp__Allocation__c Where npsp__Recurring_Donation__c != null]);
        Test.stopTest();
    
    }
    @isTest
    Static void unit_3(){
        Test.setMock(HttpCalloutMock.class, new APXTConga4.MockHttpResponseGenerator());
        Test.startTest();
			
            HA_BatchClass myBatch = new HA_BatchClass();
            myBatch.query = 'Select Id,Website_Code__c,Name,Type,StageName,Basket_Collection_Id__c,Medium__c, Recurring_Type__c,Source__c,Donation_Type__c,CurrencyIsoCode,CloseDate,npsp__Primary_Contact__c,Amount,campaignId,AccountId,(Select Id,CurrencyISOCode,npsp__Opportunity__c,npsp__General_Accounting_Unit__c, npsp__Amount__c, Stipulation_Type__c, Receipt_Note__c, Country__c,Orphan__c From npsp__Allocations__r) From Opportunity Where CloseDate=today';
            myBatch.executeContext = 'InsertRecurringDonation';
            Database.executeBatch(myBatch,1);
			System.debug('Allocation==>'+Database.query('Select Id,npsp__Opportunity__c,npsp__Recurring_Donation__c,npsp__General_Accounting_Unit__c, npsp__Amount__c, Stipulation_Type__c, Receipt_Note__c, Country__c,Orphan__c From npsp__Allocation__c'));
        	System.debug('RD==>'+[Select Id,Name,Opportunity__c from npe03__Recurring_Donation__c]);
        	System.debug('RD Allocation'+[Select Count() From npsp__Allocation__c Where npsp__Recurring_Donation__c != null]);
        	//system.assertEquals(1, [Select Count() From npsp__Allocation__c Where npsp__Recurring_Donation__c != null]);
        Test.stopTest();
    
    }
    @isTest
    Static void unit_4(){
        Test.startTest(); 
            HA_BatchClass myBatch = new HA_BatchClass();
            myBatch.query = 'Select Id,First_Sponsorship_Date__c from Contact where Contact_Type__c =\'ORPHAN\' AND Sponsorship_Status__c!=\'Unsponsored\'';
        	myBatch.dueDate = Date.today();
            myBatch.executeContext = 'CreateOrphanVisitRecord';
            Database.executeBatch(myBatch,1);
        Test.stopTest();
    
    }
    
    @isTest
    Static void unit_5(){
        Test.startTest(); 
            HA_BatchClass myBatch = new HA_BatchClass();
            myBatch.query = 'Select Id,npsp__Opportunity__c,npsp__Opportunity__r.Donor_Name__c,GAU_Name__c,npsp__General_Accounting_Unit__r.Name,npsp__General_Accounting_Unit__r.Donation_Item_Code__c,npsp__General_Accounting_Unit__c from npsp__Allocation__c where npsp__Opportunity__r.Donation_Type__c =\'SD\' AND npsp__General_Accounting_Unit__r.Product_Type__c=\'Qty-based (Special Request)\' AND npsp__General_Accounting_Unit__r.Skip_Special_Instruction__c=false AND npsp__Opportunity__r.StageName=\'Paid\'';
        	myBatch.dueDate = Date.today();
            //myBatch.executeContext = 'CreateTaskForSingleDonation';
            Database.executeBatch(myBatch,1);
        Test.stopTest();
    
    }
}