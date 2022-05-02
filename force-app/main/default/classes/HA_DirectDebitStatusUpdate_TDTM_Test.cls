/**
* @description       : Test Class for HA_DirectDebitStatusUpdate_TDTM Class
* @author            : Kalpesh.Thakur@HumanAppeal.co.uk
* @group             : 
* @last modified on  : 03-14-2021
* @last modified by  : Kalpesh.Thakur@HumanAppeal.co.uk
* Modifications Log 
* Ver   Date         Author                             Modification
* 1.0   03-14-2021   Kalpesh.Thakur@HumanAppeal.co.uk   Initial Version
**/
@isTest
public class HA_DirectDebitStatusUpdate_TDTM_Test {
     @TestSetup
    static void makeData() {
        TriggerSettings__c triggersettings = new TriggerSettings__c();
        triggersettings.Direct_Debit_History_Trigger__c = true;
        triggersettings.Payment_Schedule_Trigger__c = false;
        triggersettings.Direct_Debit_Trigger__c = true;
        insert triggersettings;
    }
    
    
    @isTest
    static void validateDirectDebitStatusFailedTest() {
        
        List<npsp__Trigger_Handler__c> listHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Direct Debit Status Update';
        th.npsp__Class__c = 'HA_DirectDebitStatusUpdate_TDTM';
        th.npsp__Object__c = 'Income_Debit_History__c';
        th.npsp__Trigger_Action__c = 'AfterUpdate;';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        listHandlers.add(th);
        /**Recurring Donation Trigger handler**/	
        
        npsp__Trigger_Handler__c RD_th = new npsp__Trigger_Handler__c(
            Name = 'CreateRecurringService_TDTM',
            npsp__Class__c = 'CreateRecurringService_TDTM',
            npsp__Object__c = 'Opportunity',
            npsp__Trigger_Action__c = 'AfterUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 5,
            npsp__Asynchronous__c = false);
        listHandlers.add(RD_th);
        
        
        Campaign websiteCamp = new Campaign(Name='Website-UK-Test',Source__c ='Website (appeal / product landing page)',Department__c='Comms',Country__c='United Kingdom',Status='Planned',IsActive=true);
        insert websiteCamp;
        
        List<Contact> contactList = (List<Contact>) TestFactory.createSObjectList(
            new Contact(),
            1,
            true
        );
        
        List<HA_Payment_Schedule__c> paymentScheduleList = (List<HA_Payment_Schedule__c>)TestFactory.createSObjectList(new HA_Payment_Schedule__c(),1,'TestFactoryDefaults.PaymentSchedulesDefaults');
        insert paymentScheduleList;
        paymentScheduleList[0].Frequency__c = 'Monthly';
        update paymentScheduleList;
        
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        
        Id recordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test Opp';
        objOpp.AccountId=objAcc.Id;
        objOpp.RecordTypeId=recordTypeIdOpportunity;
        objOpp.StageName='Awaiting Payment Details';
        objOpp.Amount=50.00;
        objOpp.Probability=100;
        objOpp.CloseDate=Date.Today()-1;
        objOpp.Type='Payment Plan - Source';
        objOpp.CampaignId=websiteCamp.Id;
        objOpp.ContactId=contactList[0].Id;
        objOpp.npe01__Contact_Id_for_Role__c=contactList[0].Id;
        objOpp.npsp__Primary_Contact__c=contactList[0].Id;
        objOpp.Donation_Type__c='RD';
        objOpp.Transaction_Id__c='81f1ed98-3a87-4a83-b9a4-755ca5530e4b-0';
        objOpp.Medium__c='Online';
        objOpp.GUID__c='4a8d4f87-b9fb-2072-1074-57c4563fdb61';
        objOpp.Recurring_Type__c='Open';
        objOpp.Payment_Schedule__c = paymentScheduleList[0].Id;
        objOpp.Website_Code__c='UK';
        objOpp.Donation_Amount_Excluding_SR__c=50.00;
        objOpp.Payment_Method__c='Direct Debit';
        objOpp.Regional_Office_Code__c='UK';
        insert objOpp; 
        
        npsp__General_Accounting_Unit__c objGAU = new npsp__General_Accounting_Unit__c(Name='foo',npsp__Active__c=true);
        insert objGAU;
        
        npsp__Allocation__c objAllo = new npsp__Allocation__c();
        objAllo.npsp__Amount__c=50.00;
        objAllo.npsp__General_Accounting_Unit__c=objGAU.Id;
        objAllo.npsp__Opportunity__c=objOpp.Id;
        objAllo.npsp__Percent__c=100.000000;
        objAllo.Stipulation_Type__c='XX';
        objAllo.Quantity__c=1;
        insert objAllo;
        
        Income_Direct_Debit__c objIDD = new Income_Direct_Debit__c();
        objIDD.Contact__c=contactList[0].Id;
        objIDD.DD_Account_Number_OK__c=true;
        objIDD.DD_Bank_Account_Name__c='Testing';
        objIDD.DD_Bank_Account_Number__c='55779911';
        objIDD.DD_Bank_City__c='Leicester';
        objIDD.DD_Bank_Name__c='BARCLAYS BANK PLC';
        objIDD.DD_Bank_Phone__c='0345 7345345';
        objIDD.DD_Bank_Postcode__c='LE87 2BB';
        objIDD.DD_Bank_Sort_Code__c='200000';
        objIDD.DD_Branch_Name__c='1 CHURCHILL  PLACE';
        objIDD.DD_Collection_Day__c='1';
        objIDD.DD_Collection_Period__c='Monthly';
        objIDD.DD_Collection_Reference__c='Donation';
        objIDD.DD_Collection_Stretch__c='1';
        objIDD.DD_Collection_Type__c='Fixed';
        objIDD.DD_End_Date__c=Date.today()+600;
        objIDD.DD_First_Collection_Amount__c=50.00;
        objIDD.DD_First_Collection_Date__c=Date.today();
        objIDD.DD_Last_Collection_Failed__c=false;
        objIDD.DD_Next_Collection_Date__c=Date.today();
        objIDD.DD_OK__c=true;
        objIDD.DD_Ongoing_Collection_Amount__c=50.00;
        objIDD.DD_Single_Account_Holder__c=false;
        objIDD.DD_Sort_Code_OK__c=true;
        objIDD.DD_Start_Date__c=Date.today();
        objIDD.DD_Status__c='New Instruction';
        objIDD.Opportunity__c=objOpp.Id;
        insert objIDD;
        npe03__Recurring_Donation__c recurringDonation = [select Id From npe03__Recurring_Donation__c WHERE Opportunity__c=:objOpp.Id];	
		System.debug('recurringDonation '+recurringDonation);


        Opportunity objOpprec = new Opportunity();
        objOpprec.Name = 'Test Opp Recurring';
        objOpprec.StageName='Pledged';
        objOpprec.Amount=50.00;
        objOpprec.CloseDate=Date.Today()-1; 
        objOpprec.Type='Donation';
        objOpprec.npe03__Recurring_Donation__c = recurringDonation.Id;
        objOpprec.Regional_Office_Code__c='UK'; 
        insert objOpprec; 

        Test.startTest();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User userObj = new User(Alias = 'inteSP', Email='SPIntergation@testorg.com',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName,Department='IT');
        
        System.runAs(userObj) {
            
            Income_Debit_History__c objIDH = new Income_Debit_History__c();
            objIDH.Income_Direct_Debit__c=objIDD.Id;
            objIDH.Amount__c=50.00;
            objIDH.DD_Collection_Date__c=Date.today();
            objIDH.DD_Failed__c=false;
            objIDH.DD_Stage__c='Submitted';
            objIDH.DD_Status__c='Ongoing Collection';
            insert objIDH;
            
            objIDH.DD_Stage__c = 'Failed';
            update objIDH;

            Opportunity objOppFailed = [SELECT Id,StageName FROM Opportunity WHERE Id =:objOpprec.Id];
            System.assertEquals('Payment Failed', objOppFailed.StageName);
            
              /*  
            List<npe01__OppPayment__c> lstPayment = [SELECT Id,npe01__Payment_Method__c,npe01__Paid__c FROM npe01__OppPayment__c WHERE npe01__Payment_Method__c= 'Direct Debit' AND npe01__Opportunity__c =:objOpprec.Id];
            System.debug('***lstPayment*:--'+lstPayment);
            List<npe01__OppPayment__c> lstPaymentFailed = [SELECT Id,npe01__Paid__c FROM npe01__OppPayment__c WHERE npe01__Payment_Method__c= 'Direct Debit' AND npe01__Opportunity__c =:objOpprec.Id];
            System.assertEquals(false, lstPaymentFailed[0].npe01__Paid__c);*/
			
            
        }
        Test.stopTest();            
        
    }
    
    @isTest
    static void validateDirectDebitStatusSuccessTest() {
        
        List<npsp__Trigger_Handler__c> listHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'Direct Debit Status Update';
        th.npsp__Class__c = 'HA_DirectDebitStatusUpdate_TDTM';
        th.npsp__Object__c = 'Income_Debit_History__c';
        th.npsp__Trigger_Action__c = 'AfterUpdate;';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        listHandlers.add(th);
        /**Recurring Donation Trigger handler**/	
        
        npsp__Trigger_Handler__c RD_th = new npsp__Trigger_Handler__c(
            Name = 'CreateRecurringService_TDTM',
            npsp__Class__c = 'CreateRecurringService_TDTM',
            npsp__Object__c = 'Opportunity',
            npsp__Trigger_Action__c = 'AfterUpdate',
            npsp__Active__c = true,
            npsp__Load_Order__c = 5,
            npsp__Asynchronous__c = false);
        listHandlers.add(RD_th);
        
        
        Campaign websiteCamp = new Campaign(Name='Website-UK-Test',Source__c ='Website (appeal / product landing page)',Department__c='Comms',Country__c='United Kingdom',Status='Planned',IsActive=true);
        insert websiteCamp;
        
        List<Contact> contactList = (List<Contact>) TestFactory.createSObjectList(
            new Contact(),
            1,
            true
        );
        
        List<HA_Payment_Schedule__c> paymentScheduleList = (List<HA_Payment_Schedule__c>)TestFactory.createSObjectList(new HA_Payment_Schedule__c(),1,'TestFactoryDefaults.PaymentSchedulesDefaults');
        insert paymentScheduleList;
        paymentScheduleList[0].Frequency__c = 'Monthly';
        update paymentScheduleList;
        
        Account objAcc = [SELECT Id FROM Account LIMIT 1];
        
        Id recordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
        
        Opportunity objOpp = new Opportunity();
        objOpp.Name = 'Test Opp';
        objOpp.AccountId=objAcc.Id;
        objOpp.RecordTypeId=recordTypeIdOpportunity;
        objOpp.StageName='Awaiting Payment Details';
        objOpp.Amount=50.00;
        objOpp.Probability=100;
        objOpp.CloseDate=Date.Today()-1;
        objOpp.Type='Payment Plan - Source';
        objOpp.CampaignId=websiteCamp.Id;
        objOpp.ContactId=contactList[0].Id;
        objOpp.npe01__Contact_Id_for_Role__c=contactList[0].Id;
        objOpp.npsp__Primary_Contact__c=contactList[0].Id;
        objOpp.Donation_Type__c='RD';
        objOpp.Transaction_Id__c='81f1ed98-3a87-4a83-b9a4-755ca5530e4b-0';
        objOpp.Medium__c='Online';
        objOpp.GUID__c='4a8d4f87-b9fb-2072-1074-57c4563fdb61';
        objOpp.Recurring_Type__c='Open';
        objOpp.Payment_Schedule__c = paymentScheduleList[0].Id;
        objOpp.Website_Code__c='UK';
        objOpp.Donation_Amount_Excluding_SR__c=50.00;
        objOpp.Payment_Method__c='Direct Debit';
        objOpp.Regional_Office_Code__c='UK';
        insert objOpp; 
        
        npsp__General_Accounting_Unit__c objGAU = new npsp__General_Accounting_Unit__c(Name='foo',npsp__Active__c=true);
        insert objGAU;
        
        npsp__Allocation__c objAllo = new npsp__Allocation__c();
        objAllo.npsp__Amount__c=50.00;
        objAllo.npsp__General_Accounting_Unit__c=objGAU.Id;
        objAllo.npsp__Opportunity__c=objOpp.Id;
        objAllo.npsp__Percent__c=100.000000;
        objAllo.Stipulation_Type__c='XX';
        objAllo.Quantity__c=1;
        insert objAllo;
        
        Income_Direct_Debit__c objIDD = new Income_Direct_Debit__c();
        objIDD.Contact__c=contactList[0].Id;
        objIDD.DD_Account_Number_OK__c=true;
        objIDD.DD_Bank_Account_Name__c='Testing';
        objIDD.DD_Bank_Account_Number__c='55779911';
        objIDD.DD_Bank_City__c='Leicester';
        objIDD.DD_Bank_Name__c='BARCLAYS BANK PLC';
        objIDD.DD_Bank_Phone__c='0345 7345345';
        objIDD.DD_Bank_Postcode__c='LE87 2BB';
        objIDD.DD_Bank_Sort_Code__c='200000';
        objIDD.DD_Branch_Name__c='1 CHURCHILL  PLACE';
        objIDD.DD_Collection_Day__c='1';
        objIDD.DD_Collection_Period__c='Monthly';
        objIDD.DD_Collection_Reference__c='Donation';
        objIDD.DD_Collection_Stretch__c='1';
        objIDD.DD_Collection_Type__c='Fixed';
        objIDD.DD_End_Date__c=Date.today()+600;
        objIDD.DD_First_Collection_Amount__c=50.00;
        objIDD.DD_First_Collection_Date__c=Date.today();
        objIDD.DD_Last_Collection_Failed__c=false;
        objIDD.DD_Next_Collection_Date__c=Date.today();
        objIDD.DD_OK__c=true;
        objIDD.DD_Ongoing_Collection_Amount__c=50.00;
        objIDD.DD_Single_Account_Holder__c=false;
        objIDD.DD_Sort_Code_OK__c=true;
        objIDD.DD_Start_Date__c=Date.today();
        objIDD.DD_Status__c='New Instruction';
        objIDD.Opportunity__c=objOpp.Id;
        insert objIDD;
        npe03__Recurring_Donation__c recurringDonation = [select Id From npe03__Recurring_Donation__c WHERE Opportunity__c=:objOpp.Id];	
		System.debug('recurringDonation '+recurringDonation);


        Opportunity objOpprec = new Opportunity();
        objOpprec.Name = 'Test Opp Recurring';
        objOpprec.StageName='Pledged';
        objOpprec.Amount=50.00;
        objOpprec.CloseDate=Date.Today()-1; 
        objOpprec.Type='Donation';
        objOpprec.npe03__Recurring_Donation__c = recurringDonation.Id;
        objOpprec.Regional_Office_Code__c='UK'; 
        insert objOpprec; 

        Test.startTest();
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User userObj = new User(Alias = 'inteSP', Email='SPIntergation@testorg.com',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName,Department='IT');
        
        System.runAs(userObj) {
            
            Income_Debit_History__c objIDH = new Income_Debit_History__c();
            objIDH.Income_Direct_Debit__c=objIDD.Id;
            objIDH.Amount__c=50.00;
            objIDH.DD_Collection_Date__c=Date.today();
            objIDH.DD_Failed__c=false;
            objIDH.DD_Stage__c='Submitted';
            objIDH.DD_Status__c='Ongoing Collection';
            insert objIDH;
            
            objIDH.DD_Stage__c = 'Successful';
            update objIDH;

            List<npe01__OppPayment__c> lstPaymentFailed = [SELECT Id,npe01__Paid__c FROM npe01__OppPayment__c WHERE npe01__Payment_Method__c= 'Direct Debit' AND npe01__Opportunity__c =:objOpprec.Id];
            System.assertEquals(true, lstPaymentFailed[0].npe01__Paid__c);
			
            
        }
        Test.stopTest();            
        
    }
}