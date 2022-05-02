@isTest
public class CreateRecurringService_TDTM_Test {
    
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
        th.Name = 'CreateRecurringService_TDTM';
        th.npsp__Class__c = 'CreateRecurringService_TDTM';
        th.npsp__Object__c = 'Opportunity';
        th.npsp__Trigger_Action__c = 'AfterInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 5;
        th.npsp__Asynchronous__c = false;
        listHandlers.add(th);
        
        Test.startTest();
        
        List<npsp__General_Accounting_Unit__c> items = [Select Id,Name  FROM npsp__General_Accounting_Unit__c Where Name like 'Test Item%'];
        
        List<Campaign> campaignList=(List<Campaign>) TestFactory.createSObjectList(
            new Campaign(),
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
            opp.Donation_Type__c ='RD';
            opp.Type = 'Payment Plan - Source';
            opp.npsp__Primary_Contact__c = contactList[0].Id;
        }
        insert opplist;
        Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(payment_Reference__c='InternalWizard',Gateway_Customer_Reference__c='cus_L9pBaWHpg3gMYk',First_Payment_Taken__c=true,First_Payment_Amount__c=100,order_ID__c='pi_3KrNcNGItx6TnYh40JKc0AFW',Payment_Method_Id__c='pm_1KrNf3GItx6TnYh4Yvowfb8G', Authorisation_Date__c =SYSTEM.now(),RecordTypeId=Schema.SObjectType.Income_Card_Payment__c.getRecordTypeInfosByDeveloperName().get('Card_Payment').getRecordTypeId(),payment_Vendor__c='Stripe',Payment_Method_Type__c ='card',Opportunity__c = opplist[0].Id, Contact__c = contactList[0].Id, Payment_Status__c = 'succeeded', Transaction_Type__c = 'Authorised');
        insert cardPayment;
        npe01__OppPayment__c paymentObject = new npe01__OppPayment__c();
        paymentObject.npe01__Opportunity__c =opplist[0].Id;
        paymentObject.RecordTypeId=Schema.SObjectType.npe01__OppPayment__c.getRecordTypeInfosByDeveloperName().get('Card_Payment').getRecordTypeId();
        paymentObject.npe01__Payment_Method__c = 'Card Payment';
        paymentObject.Payment_Status__c = 'succeeded';
        paymentObject.npe01__Payment_Date__c= System.Today();
        paymentObject.npsp__Gateway_Payment_ID__c ='pm_1KrNf3GItx6TnYh4Yvowfb8G';
        paymentObject.Order_ID__c ='pi_3KrNcNGItx6TnYh40JKc0AFW';
        paymentObject.Transaction_ID__c ='pi_3KrNcNGItx6TnYh40JKc0AFW';
        paymentObject.npe01__Payment_Amount__c = 0;
        paymentObject.npsp__Type__c='Setup';
        paymentObject.Transaction_Type__c ='Setup';
        paymentObject.Card_Details__c=cardPayment.Id;
        insert paymentObject;
        
        
        Test.stopTest();
        
    } 
    @IsTest
    static void unit_1(){
        
        List<npsp__Trigger_Handler__c> listHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'CreateRecurringService_TDTM';
        th.npsp__Class__c = 'CreateRecurringService_TDTM';
        th.npsp__Object__c = 'Opportunity';
        th.npsp__Trigger_Action__c = 'AfterUpdate,BeforeUpdate';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 5;
        th.npsp__Asynchronous__c = false;
        listHandlers.add(th);
        
        Test.startTest();
        
        List<npsp__General_Accounting_Unit__c> items = [Select Id,Name  FROM npsp__General_Accounting_Unit__c Where Name like 'Test Item%'];
        
        List<Campaign> campaignList=(List<Campaign>) TestFactory.createSObjectList(
            new Campaign(),
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
            opp.Donation_Type__c ='RD';
            opp.Type = 'Payment Plan - Source';
            opp.npsp__Primary_Contact__c = contactList[0].Id;
        }
        insert opplist;
        Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(payment_Reference__c='InternalWizard',Gateway_Customer_Reference__c='cus_L9pBaWHpg3gMYk',First_Payment_Taken__c=true,First_Payment_Amount__c=100,order_ID__c='pi_3KrNcNGItx6TnYh40JKc0AFW',Payment_Method_Id__c='pm_1KrNf3GItx6TnYh4Yvowfb8G', Authorisation_Date__c =SYSTEM.now(),RecordTypeId=Schema.SObjectType.Income_Card_Payment__c.getRecordTypeInfosByDeveloperName().get('Card_Payment').getRecordTypeId(),payment_Vendor__c='Stripe',Payment_Method_Type__c ='card',Opportunity__c = opplist[0].Id, Contact__c = contactList[0].Id, Payment_Status__c = 'succeeded', Transaction_Type__c = 'Authorised');
        insert cardPayment;
        npe01__OppPayment__c paymentObject = new npe01__OppPayment__c();
        paymentObject.npe01__Opportunity__c =opplist[0].Id;
        paymentObject.RecordTypeId=Schema.SObjectType.npe01__OppPayment__c.getRecordTypeInfosByDeveloperName().get('Card_Payment').getRecordTypeId();
        paymentObject.npe01__Payment_Method__c = 'Card Payment';
        paymentObject.Payment_Status__c = 'succeeded';
        paymentObject.npe01__Payment_Date__c= System.Today();
        paymentObject.npsp__Gateway_Payment_ID__c ='pm_1KrNf3GItx6TnYh4Yvowfb8G';
        paymentObject.Order_ID__c ='pi_3KrNcNGItx6TnYh40JKc0AFW';
        paymentObject.Transaction_ID__c ='pi_3KrNcNGItx6TnYh40JKc0AFW';
        paymentObject.npe01__Payment_Amount__c = 0;
        paymentObject.npsp__Type__c='Setup';
        paymentObject.Transaction_Type__c ='Setup';
        paymentObject.Card_Details__c=cardPayment.Id;
        insert paymentObject;
        
        
        Test.stopTest();
        
    } 
    
}