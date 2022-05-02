@isTest
public with sharing class TriggerHandler_CardPaymentHistoryTest
{
    public static final Integer RESPONSE_SUCCESS = 200;
    
    public static final String RESPONSE_BODY = '{ "id": "cus_L9pBaWHpg3gMYk", "object": "customer", "address": { "city": "Leicester", "country": "GBR", "line1": "32 New Way Road", "line2": "32 New Way Road", "postal_code": "LE5 5UA", "state": "Leicestershire" }, "balance": 0, "created": 1644948820, "currency": null, "default_source": null, "delinquent": false, "description": null, "discount": null, "email": "iamsfdeveloper+12@gmail.com", "invoice_prefix": "73BC0A63", "invoice_settings": { "custom_fields": null, "default_payment_method":"pm_1EUmyr2x6R10KRrhlYS3l97f", "footer": null }, "livemode": false, "metadata": { }, "name": "Arshadulla Shariff", "next_invoice_sequence": 1, "phone": null, "preferred_locales": [ ], "shipping": null, "sources": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_L9pBaWHpg3gMYk/sources" }, "subscriptions": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_L9pBaWHpg3gMYk/subscriptions" }, "tax_exempt": "none", "tax_ids": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_L9pBaWHpg3gMYk/tax_ids" }, "tax_info": null, "tax_info_verification": null }';
    @testSetup
    private static void setupTestConfig(){
        TriggerSettings__c triggersettings = new TriggerSettings__c();
        triggersettings.Card_Payment_History_Trigger__c = true;
        triggersettings.Card_Payment_Trigger__c = true;
        triggersettings.Payment_Schedule_Trigger__c = false;
        insert triggersettings;
    }

    @isTest static void testPaymentScheduleSetToFailed() {
        Contact member =(Contact)TestFactory.createSObject(new Contact(),true);

        Opportunity opp = (Opportunity)TestFactory.createSObject(new Opportunity());
        opp.Name = 'testOpp';
        opp.npsp__Primary_Contact__c = member.Id;
		opp.Type='Donation';
        opp.Amount = 5;
        opp.StageName = 'test';
        opp.CloseDate = Date.Today();
        insert opp;
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            RESPONSE_SUCCESS,
            RESPONSE_BODY
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        Test.startTest();

        npe03__Recurring_Donation__c rd = (npe03__Recurring_Donation__c) TestFactory.createSObject(
                new npe03__Recurring_Donation__c(
                    npe03__Contact__c = member.Id,
                    npe03__Amount__c = 100,
                    npsp__StartDate__c = Date.today(),
                    npsp__PaymentMethod__c = 'Card Payment',
                    npe03__Date_Established__c = Date.today(),
                    npsp__Day_of_Month__c = String.valueOf(Date.today().day())
                ),
                'TestFactoryDefaults.RDDefaults'
            );
        insert rd;

        Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(Opportunity__c = opp.Id, Recurring_Donation__c = rd.Id, Contact__c = member.Id, Payment_Status__c = 'Created', Transaction_Type__c = 'Sale', Internal_Payment_Description__c=opp.Id);
        insert cardPayment;
		cardPayment.Gateway_Customer_Reference__c='cus_L9pBaWHpg3gMYk';
		update cardPayment;
        cardPayment.Payment_Status__c = 'Failed';
        update cardPayment;

        Income_Card_Payment_History__c cardPaymentHistory = new Income_Card_Payment_History__c(Income_Card_Payment__c = cardPayment.Id, Payment_Status__c = 'Failed', Transaction_Type__c = 'Sale', Transaction_Date__c = Date.Today() + 5);
        insert cardPaymentHistory;  

        Test.stopTest();
    }

    @isTest static void testPaymentScheduleSetToSuccess() {
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
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            RESPONSE_SUCCESS,
            RESPONSE_BODY
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
       // setupTestConfig();

        Contact member =(Contact)TestFactory.createSObject(new Contact(),true);

        npsp__General_Accounting_Unit__c item = new npsp__General_Accounting_Unit__c(npsp__Active__c=true,Donation_item_code__c='WFIU');
        insert item;
		Test.startTest();
        Opportunity opp = (Opportunity)TestFactory.createSObject(new Opportunity());
        opp.Name = 'testOpp';
        opp.Amount = 5;
        opp.Type='Payment Plan - Source';
		opp.Donation_Type__c = 'RD';
		opp.Effective_Date__c = Date.Today()+1;
        opp.StageName = 'Awaiting Payment Details';
        opp.CloseDate = Date.Today();
        opp.npsp__Primary_Contact__c = member.Id;
        insert opp;

		npsp__Allocation__c itemAllocation = new npsp__Allocation__c(npsp__General_Accounting_Unit__c =item.Id ,npsp__Amount__c=5,npsp__Opportunity__c=opp.Id);
        insert itemAllocation;

       
        
       
        
        Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(Gateway_Customer_Reference__c='cus_L9pBaWHpg3gMYk',Opportunity__c = opp.Id, Contact__c = member.Id, Payment_Status__c = 'Created', Transaction_Type__c = 'Sale');
        insert cardPayment;

        cardPayment.Internal_Payment_Description__c=opp.Id;
        cardPayment.Payment_Status__c = 'Successful';
        update cardPayment;

        Income_Card_Payment_History__c cardPaymentHistory = new Income_Card_Payment_History__c(Amount__c=0,Income_Card_Payment__c = cardPayment.Id, Payment_Status__c = 'Successful', Transaction_Type__c = 'Authenticate', Transaction_Date__c = Date.Today() + 5);
        insert cardPaymentHistory;  

        Test.stopTest();
    }

    @isTest static void testNormalPaymentToSuccess() {
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

        List<Contact> contacts = (List<Contact>) TestFactory.createSObjectList(
            new Contact(Email = 'test@test.com'),
            1,
            true
        );

        npsp__General_Accounting_Unit__c item = new npsp__General_Accounting_Unit__c(npsp__Active__c=true,Donation_item_code__c='WFIU');
        insert item;

        Contact member = [SELECT Id, AccountId FROM Contact];

        HA_Payment_Schedule__c paymentSchedule = new HA_Payment_Schedule__c(
            Name = 'Single Donation',                 
            Code__c = 'RD',                              
            Start_Date__c = Date.parse('30/11/2020'),  
            End_Date__c = Date.parse('30/11/2099'),    
            Frequency__c = 'Monthly',                    
            Processing_Time__c = 'AM',
            Payment_Methods__c = 'Credit/Debit Card'                  
          );
        insert paymentSchedule;

       Opportunity opp = (Opportunity)TestFactory.createSObject(new Opportunity());
        opp.Name = 'testOpp';
        opp.Amount = 5;
        opp.StageName = 'Awaiting Payment Details';
        opp.CloseDate = Date.Today();
        opp.Type = 'Payment Plan - Source';
        opp.npsp__Primary_Contact__c = member.Id;
        opp.ContactId = member.Id;
        opp.Payment_Schedule__c = paymentSchedule.Id;
        opp.Recurring_Type__c = 'Open';
        opp.Number_of_Installments__c = 12;
        opp.Donation_Type__c = 'RD';
		Opp.Regional_Office_Code__c = 'UK';
        insert opp;

        npsp__Allocation__c itemAllocation = new npsp__Allocation__c(npsp__General_Accounting_Unit__c =item.Id ,npsp__Amount__c=5,npsp__Opportunity__c=opp.Id);
        insert itemAllocation;   

        Test.startTest();        
        Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(Opportunity__c = opp.Id, Contact__c = contacts[0].Id, Payment_Status__c = 'Created', Transaction_Type__c = 'Sale');
        insert cardPayment;

        /* try { */
            cardPayment.Internal_Payment_Description__c=opp.Id;
            cardPayment.Payment_Status__c = 'Successful';
            update cardPayment;

            Income_Card_Payment_History__c cardPaymentHistory = new Income_Card_Payment_History__c(Amount__c =0,Income_Card_Payment__c = cardPayment.Id, Payment_Status__c = 'Successful', Transaction_Type__c = 'Sale', Transaction_Date__c = Date.Today() + 5);
            insert cardPaymentHistory;  
       /*  } catch (Exception) {
            
        }    */     

        Test.stopTest();
    }
}