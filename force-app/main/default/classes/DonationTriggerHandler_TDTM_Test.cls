/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 07-21-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   07-20-2021   Iamsfdeveloper   Initial Version
**/
@isTest
public with sharing class DonationTriggerHandler_TDTM_Test {
    @testSetup
    static void createData(){
    
        List<HA_Payment_Schedule__c> paymentScheduleList = (List<HA_Payment_Schedule__c>)TestFactory.createSObjectList(new HA_Payment_Schedule__c(),2,'TestFactoryDefaults.PaymentSchedulesDefaults');
        insert paymentScheduleList;
        System.debug(JSON.serialize(paymentScheduleList[0]));
        List<npsp__General_Accounting_Unit__c> items = (List<npsp__General_Accounting_Unit__c>)TestFactory.createSObjectList(new npsp__General_Accounting_Unit__c(),1,'TestFactoryDefaults.GeneralAccountUnitsDefaults');
        insert items;
        Payment_Schedule_Allocation__c PSA1 = new Payment_Schedule_Allocation__c(General_Accounting_Unit__c= items[0].Id,Payment_Schedule__c = paymentScheduleList[0].Id);
        insert PSA1;
        Payment_Schedule_Allocation__c  PSA2 = new Payment_Schedule_Allocation__c(General_Accounting_Unit__c= items[0].Id,Payment_Schedule__c = paymentScheduleList[1].Id);
        insert PSA2;
        List<Contact> contactList = (List<Contact>) TestFactory.createSObjectList(
            new Contact(),
            1,
            true
        );
        
        
        
    } 
   @IsTest
   static void unit(){

    List<npsp__Trigger_Handler__c> listHandlers = npsp.TDTM_Config_API.getCachedRecords();

    npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
    th.Name = 'DonationTriggerHandler_TDTM';
    th.npsp__Class__c = 'DonationTriggerHandler_TDTM';
    th.npsp__Object__c = 'Opportunity';
    th.npsp__Trigger_Action__c = 'AfterUpdate';
    th.npsp__Active__c = true;
    th.npsp__Load_Order__c = 5;
    th.npsp__Asynchronous__c = false;
    listHandlers.add(th);

    Test.startTest();
       
    List<npsp__General_Accounting_Unit__c> items = [Select Id,Name  FROM npsp__General_Accounting_Unit__c Where Name like 'Test Item%'];
    
    List<Campaign> campaignList=(List<Campaign>) TestFactory.createSObjectList(
        new Campaign(Regional_Office_Code__c = 'UK'),
       2,
        true
    );
    /*Campaign Allocation Item*/
    npsp__Allocation__c itemAllocation1 = (npsp__Allocation__c)TestFactory.createSObject(new npsp__Allocation__c(),'TestFactoryDefaults.ItemAllocationDefaults',false);
    itemAllocation1.npsp__General_Accounting_Unit__c = items[0].Id;
    itemAllocation1.npsp__Campaign__c = campaignList[0].Id;
    itemAllocation1.npsp__percent__c=50;
    insert itemAllocation1;
    List<Contact> contactList = [Select Id,Name FROM Contact Where MailingPostalCode = 'SK8 2BL'];
    List<Opportunity> opplist=(List<Opportunity>) TestFactory.createSObjectList(
        new Opportunity(),
       2,
        false
    );

    for(Opportunity opp:opplist){
        opp.CampaignId = campaignList[0].Id;
        opp.Amount=100;
        opp.Donation_Type__c ='SD';
        opp.npsp__Primary_Contact__c = contactList[0].Id;
    }
    insert opplist;
    for(Opportunity opp:opplist){
            opp.CurrencyISOCode='USD';
            opp.Amount=200;
        	opp.StageName='Paid';
        }
    update opplist;
      
       Test.stopTest();
       
   } 
}