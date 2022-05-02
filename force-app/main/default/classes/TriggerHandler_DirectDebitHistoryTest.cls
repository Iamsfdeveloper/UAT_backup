@isTest
public with sharing class TriggerHandler_DirectDebitHistoryTest
{
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
        TriggerSettings__c triggersettings = new TriggerSettings__c();
        triggersettings.Direct_Debit_History_Trigger__c = true;
        triggersettings.Payment_Schedule_Trigger__c = false;
        insert triggersettings;
        
        
        
    }
    
    
    @isTest static void testPaymentScheduleConnected() {
        List<npsp__Trigger_Handler__c> listHandlers = npsp.TDTM_Config_API.getCachedRecords();
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'CreateRecurringService_TDTM';
        th.npsp__Class__c = 'CreateRecurringService_TDTM';
        th.npsp__Object__c = 'Opportunity';
        th.npsp__Trigger_Action__c = 'AfterInsert,AfterUpdate';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 5;
        th.npsp__Asynchronous__c = false;
        listHandlers.add(th);
        Contact member = [Select Id From Contact Where Email like '%@humanappeal.org.uk.test' limit 1];
         List<npsp__General_Accounting_Unit__c> items = [Select Id,Name  FROM npsp__General_Accounting_Unit__c Where Name like 'Test Item%'];
        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
		opp.npsp__Primary_Contact__c = member.Id;
        opp.Amount = 5;
        opp.StageName = 'Awaiting Payment Details';
        opp.CloseDate = Date.Today();
        opp.Donation_Type__c ='RD';
        opp.Type= 'Payment Plan - Source';
        insert opp;
        npsp__Allocation__c itemAllocation1 = (npsp__Allocation__c)TestFactory.createSObject(new npsp__Allocation__c(),'TestFactoryDefaults.ItemAllocationDefaults',false);
        itemAllocation1.npsp__General_Accounting_Unit__c = items[0].Id;
        itemAllocation1.npsp__Amount__c=5;
        itemAllocation1.npsp__Opportunity__c = opp.Id;
        insert itemAllocation1;
        String responseBody = '{"ProcessNewDDFirstCollectionDateResult":{"FirstCollectionDate":"2022-02-18","Error":""}}';
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        Income_Direct_Debit__c directDebit = new Income_Direct_Debit__c(DD_Sort_Code_OK__c = true,DD_OK__c=true,DD_Account_Number_OK__c=true,DD_Collection_Day__c='1',DD_Collection_Period__c='Monthly',DD_Start_Date__c = System.today(),Opportunity__c = opp.Id, Contact__c = member.Id, DD_Status__c = 'New Instruction', DD_Bank_Account_Number__c = '00000000', DD_Bank_Sort_Code__c = '000000');
        insert directDebit;
        Payment_Schedule__c schedule = new Payment_Schedule__c(Opportunity__c = opp.Id, Status__c = 'Outstanding', Schedule_Date__c = Date.Today() + 5);
        insert schedule;
        
        Income_Debit_History__c directDebitHistory = new Income_Debit_History__c(Income_Direct_Debit__c = directDebit.Id, DD_Status__c = 'Ongoing Collection', DD_Collection_Date__c = Date.Today() + 5);
        insert directDebitHistory;
        Test.stopTest();
    }
    
    @isTest static void testPaymentScheduleSetToFailed() {
        
        
        Contact member = [Select Id From Contact Where Email like '%@humanappeal.org.uk.test' limit 1];
        
        Opportunity opp = new Opportunity();
        opp.npsp__Primary_Contact__c = member.Id;
        opp.Name = 'testOpp';
        opp.Amount = 5;
        opp.StageName = 'test';
        opp.CloseDate = Date.Today();
        insert opp;
        
        Income_Direct_Debit__c directDebit = new Income_Direct_Debit__c(Opportunity__c = opp.Id, Contact__c = member.Id, DD_Status__c = 'Ongoing Collection', DD_Bank_Account_Number__c = '00000000', DD_Bank_Sort_Code__c = '000000');
        insert directDebit;
        
        Payment_Schedule__c schedule = new Payment_Schedule__c(Opportunity__c = opp.Id, Status__c = 'Outstanding', Schedule_Date__c = Date.Today() + 5);
        insert schedule;
        
        Income_Debit_History__c directDebitHistory = new Income_Debit_History__c(Payment_Schedule__c = schedule.Id, 
                                                                                 Income_Direct_Debit__c = directDebit.Id, 
                                                                                 DD_Status__c = 'Ongoing Collection', 
                                                                                 DD_Collection_Date__c = Date.Today() + 5);
        insert directDebitHistory;
        
        directDebitHistory.DD_Stage__c = 'Failed';
        update directDebitHistory;      
        
    }
    
    @isTest static void testPaymentScheduleSetToSuccess() {
        Contact member = [Select Id From Contact Where Email like '%@humanappeal.org.uk.test' limit 1];
        
        Opportunity opp = new Opportunity();
		opp.npsp__Primary_Contact__c = member.Id;
        opp.Name = 'testOpp';
        opp.Amount = 5;
        opp.StageName = 'test';
        opp.CloseDate = Date.Today();
        insert opp;
        
        Income_Direct_Debit__c directDebit = new Income_Direct_Debit__c(Opportunity__c = opp.Id, Contact__c = member.Id, DD_Status__c = 'Ongoing Collection', DD_Bank_Account_Number__c = '00000000', DD_Bank_Sort_Code__c = '000000');
        insert directDebit;
        
        Payment_Schedule__c schedule = new Payment_Schedule__c(Opportunity__c = opp.Id,Status__c = 'Outstanding', Schedule_Date__c = Date.Today() + 5);
        insert schedule;
        
        Income_Debit_History__c directDebitHistory = new Income_Debit_History__c(Payment_Schedule__c = schedule.Id, 
                                                                                 Income_Direct_Debit__c = directDebit.Id, 
                                                                                 DD_Status__c = 'Ongoing Collection', 
                                                                                 DD_Collection_Date__c = Date.Today() + 5);
        insert directDebitHistory;
        
        directDebitHistory.DD_Stage__c = 'Successful';
        update directDebitHistory;      
    }
}