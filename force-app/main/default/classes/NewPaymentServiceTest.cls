/**
* @File Name          : NewPaymentServiceTest.cls
* @Description        :
* @Author             : agentgill
* @Group              :
* @Last Modified By   : agentgill
* @Last Modified On   : 07-10-2020
* @Modification Log   :
* Ver       Date            Author      		    Modification
* 1.0    6/22/2020   agentgill     Initial Version
**/
@isTest
public with sharing class NewPaymentServiceTest {
    public static final Integer RESPONSE_SUCCESS = 202;
    public static final String RESPONSE_BODY = '{ "internalPaymentDescription":"XXX", "apiKey":"testapikey", "incomeUserName":"HUAPB", "paymentGateway":"Stripe" }'; // TODO: Confirm once we hit SP endpoint
    public static final String REQUEST_BODY = '{ "internalPaymentDescription":"XXX" }'; // TODO: Confirm once we hit SP endpoint
    
    @TestSetup
    static void makeData() {
        String RecordTypeId = Schema.SObjectType.npe01__OppPayment__c.getRecordTypeInfosByDeveloperName().get('Card_Payment').getRecordTypeId();
        HA_Payment_Schedule__c TenNights = (HA_Payment_Schedule__c)TestFactory.createSObject(new HA_Payment_Schedule__c(Schedule__c = '10',Name='Single',Code__c='10N',Frequency__c='Daily'), 'TestFactoryDefaults.PaymentSchedulesDefaults', true);
        HA_Payment_Schedule__c ThirtyNights = (HA_Payment_Schedule__c)TestFactory.createSObject(new HA_Payment_Schedule__c(Schedule__c='30',Name='Single',Code__c='30N',Frequency__c='Daily'), 'TestFactoryDefaults.PaymentSchedulesDefaults', true);
        List<npsp__Trigger_Handler__c> handlers = npsp.TDTM_Config_API.getCachedRecords();
        for (npsp__Trigger_Handler__c th : handlers) {
            if (th.npsp__Object__c == 'Opportunity') {
                th.npsp__Active__c = false;
            }
        }
        List<Contact> contacts = (List<Contact>) TestFactory.createSObjectList(
            new Contact(),
            1,
            true
        );
        
        List<npe03__Recurring_Donation__c> rds = new List<npe03__Recurring_Donation__c>();
        List<npe01__OppPayment__c> tenNightsSchedule = new List<npe01__OppPayment__c>();
        for (Contact c : [
            SELECT Id, AccountId
            FROM Contact
            WHERE Id IN :contacts
        ]) {
            
            Opportunity opp = new Opportunity();
            opp.Name = 'testOpp';
            opp.Amount = 5;
            opp.StageName = 'Awaiting Payment Details';
            opp.CloseDate = Date.Today();
            opp.AccountId = c.AccountId;
            opp.Regional_Office_code__c='UK';
            opp.Skip_Process_Automation__c =true;  
            insert opp;

            
            Opportunity TenNightsOpp = new Opportunity();
            TenNightsOpp.Name = 'testOpp';
            TenNightsOpp.Amount = 10;
            TenNightsOpp.StageName = 'Setup Completed';
            TenNightsOpp.CloseDate = Date.Today();
            TenNightsOpp.npsp__Primary_Contact__c = c.Id;
            TenNightsOpp.Payment_Schedule__c = TenNights.Id;
            TenNightsOpp.AccountId = c.AccountId;
            TenNightsOpp.Regional_Office_code__c='UK';
            TenNightsOpp.Skip_Process_Automation__c =true;  
            insert TenNightsOpp;
            
            Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(Payment_Method_Id__c = 'pm_1EUmyr2x6R10KRrhlYS3l97f',Payment_Method_Type__c='card',Opportunity__c = opp.Id, Contact__c = c.Id, Payment_Status__c = 'Created', Transaction_Type__c = 'Sale',Gateway_Customer_Reference__c='cus_IXaICGcDMa0FK9');
            insert cardPayment;
            Income_Card_Payment__c TenNightcardPayment = new Income_Card_Payment__c(Payment_Method_Type__c='card',Opportunity__c = TenNightsOpp.Id, Contact__c = c.Id, Payment_Status__c = 'Created', Transaction_Type__c = 'Sale',Gateway_Customer_Reference__c='cus_IXaICGcDMa0FK9');
            insert TenNightcardPayment;
            TenNightcardPayment.Payment_Method_Id__c = 'pm_1EUmyr2x6R10KRrhlYS3l97e';
            TenNightcardPayment.Payment_Status__c = 'Successful';
			update TenNightcardPayment;
            
            for(Integer i=0;i<Integer.valueOf(TenNights.Schedule__c);i++){
                npe01__OppPayment__c payment = new npe01__OppPayment__c();
				payment.RecordTypeId = RecordTypeId;
                payment.npe01__Opportunity__c  = TenNightsOpp.Id;
                payment.Card_Details__c = TenNightcardPayment.id;
                payment.npe01__Payment_Amount__c = 1;
                payment.npe01__Payment_Date__c = System.today();
				payment.Payment_Status__c = 'pending';
				payment.Payment_Reference__c = HA_Utility.generateGUID();
				tenNightsSchedule.add(payment);
            }
           
            Income_Card_Payment_History__c cardPaymentHistory = new Income_Card_Payment_History__c(Income_Card_Payment__c = cardPayment.Id, Payment_Status__c = 'Successful', Transaction_Type__c = 'Sale', Transaction_Date__c = Date.Today() + 5);
            insert cardPaymentHistory;
            npe03__Recurring_Donation__c rd = (npe03__Recurring_Donation__c) TestFactory.createSObject(
                new npe03__Recurring_Donation__c(
                    npe03__Contact__c = c.Id,
                    npe03__Amount__c = 100,
                    npsp__StartDate__c = Date.today(),
                    npe03__Date_Established__c = Date.today(),
                    npsp__PaymentMethod__c = 'Card Payment',
                    npsp__Day_of_Month__c = String.valueOf(Date.today().day()),
                    Card_Payment_Detail__c=cardPayment.Id,
                    Regional_Office_code__c ='UK',
                    Opportunity__c = opp.Id
                ),
                'TestFactoryDefaults.RDDefaults'
            );
            rds.add(rd);
        /*Oppwa Test*/
            
             Income_Card_Payment__c OppwacardPayment = new Income_Card_Payment__c(Payment_Method_Id__c = '8ac7a4a1801b4c8b01801cc7a9a76979',payment_vendor__c='Oppwa',Payment_Method_Type__c='card',Opportunity__c = opp.Id, Contact__c = c.Id, Payment_Status__c = 'Successful', Transaction_Type__c = 'Sale');
            insert OppwacardPayment;
             npe03__Recurring_Donation__c rd2 = (npe03__Recurring_Donation__c) TestFactory.createSObject(
                new npe03__Recurring_Donation__c(
                    npe03__Contact__c = c.Id,
                    npe03__Amount__c = 100,
                    npsp__StartDate__c = Date.today(),
                    npe03__Date_Established__c = Date.today(),
                    npsp__PaymentMethod__c = 'Card Payment',
                    npsp__Day_of_Month__c = String.valueOf(Date.today().day()),
                    Card_Payment_Detail__c=OppwacardPayment.Id,
                    Regional_Office_code__c ='UK',
                    Opportunity__c = opp.Id
                ),
                'TestFactoryDefaults.RDDefaults'
            );
            rds.add(rd2);
             Opportunity oppwaTenNightsOpp = new Opportunity();
            oppwaTenNightsOpp.Name = 'testOpp';
            oppwaTenNightsOpp.Amount = 10;
            oppwaTenNightsOpp.Description='Oppwa';
            oppwaTenNightsOpp.Payment_Method__c='Oppwa';
            oppwaTenNightsOpp.StageName = 'Setup Completed';
            oppwaTenNightsOpp.CloseDate = Date.Today();
            oppwaTenNightsOpp.npsp__Primary_Contact__c = c.Id;
            oppwaTenNightsOpp.Payment_Schedule__c = TenNights.Id;
            oppwaTenNightsOpp.AccountId = c.AccountId;
            oppwaTenNightsOpp.Regional_Office_code__c='UK';  
            insert oppwaTenNightsOpp;
            for(Integer i=0;i<Integer.valueOf(TenNights.Schedule__c);i++){
                npe01__OppPayment__c payment = new npe01__OppPayment__c();
                payment.RecordTypeId = RecordTypeId;
                payment.npe01__Opportunity__c  = TenNightsOpp.Id;
                payment.Card_Details__c = OppwacardPayment.id;
                payment.npe01__Payment_Amount__c = 1;
                payment.npe01__Payment_Date__c = System.today();
                payment.Payment_Status__c = 'pending';
                payment.Payment_Reference__c = HA_Utility.generateGUID();
                tenNightsSchedule.add(payment);
            }
        /*SEPA Test Data */
            Opportunity oppSEPA =(Opportunity)TestFactory.CreatesObject(new Opportunity());
            oppSEPA.AccountId = c.AccountId;
            oppSEPA.Regional_Office_code__c='FR';
			oppSEPA.Donation_Type__c='RD';
            insert oppSEPA;
            Income_Card_Payment__c cardSepaPayment = new Income_Card_Payment__c(Payment_Method_Id__c = 'pm_1KXRbCBqqDaI4pY6fQsKe1Il ',Payment_Method_Type__c='sepa_debit',Opportunity__c = oppSEPA.Id, Contact__c = c.Id, Payment_Status__c = 'Created', Transaction_Type__c = 'Sale',Gateway_Customer_Reference__c='cus_LDr1lhYWIBvrBM ');
            insert cardSepaPayment;	
            npe03__Recurring_Donation__c rd1 = (npe03__Recurring_Donation__c) TestFactory.createSObject(
                new npe03__Recurring_Donation__c(
                    npe03__Contact__c = c.Id,
                    npe03__Amount__c = 100,
                    npsp__StartDate__c = Date.today(),
                    npe03__Date_Established__c = Date.today(),
                    npsp__PaymentMethod__c = 'SEPA',
                    npsp__Day_of_Month__c = String.valueOf(Date.today().day()),
                    Card_Payment_Detail__c=cardSepaPayment.Id,
                    Regional_Office_code__c ='FR',
                    Opportunity__c = oppSEPA.Id,Donation_Type__c='RD'
                ),
                'TestFactoryDefaults.RDDefaults'
            );
            rds.add(rd1);
        
     } 
        insert rds;
         insert tenNightsSchedule;
    }
    
    /**
* @description Test Request Payment Method
* @author agentgill | 6/22/2020
* @return void
**/
    @isTest
    private static void testRequestPayment() {
        StaticResource jsonResponse = [
            SELECT Id, Body
            FROM StaticResource
            WHERE Name = :'NewPaymentServiceTest'
            LIMIT 1
        ];
        // Inject Callout Mock
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            RESPONSE_SUCCESS,
            jsonResponse.Body.toString()
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        
        List<Opportunity> testOpps = [SELECT Id, Name FROM Opportunity];
        System.debug('>>> testOpps ' + testOpps);
        
        Opportunity oppTest = [
            SELECT npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Vendor__c,
            npe03__Recurring_Donation__r.Opportunity__c,npe03__Recurring_Donation__r.Regional_Code__c,npe03__Recurring_Donation__r.Regional_Office_Code__c,
            Id, Amount, CurrencyIsoCode,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Transaction_Source__c,
            npe03__Recurring_Donation__r.Card_Payment_Detail__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c,npsp__Primary_contact__c
            FROM Opportunity
            WHERE
            npe03__Recurring_Donation__r.npsp__PaymentMethod__c = 'Card Payment'
            AND CloseDate = TODAY
            AND npe03__Recurring_Donation__r.npsp__Status__c = 'Active'
            AND StageName = 'Pledged'
            ORDER BY Id limit 1
        ];
        
        System.debug('>>> oppTest ' + oppTest);
        
        Sobject sObj = (Sobject) oppTest;
        
        Test.startTest();
        NewPaymentService paymentService = new NewPaymentService();
        paymentService.requestPayment(sObj, 'TESTGUID');
        oppTest.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c = 'pm_1EUmyr2x6R10KRrhlYS3l97f';
        paymentService.requestPayment(HA_Utility.generateGUID(), oppTest);
        Test.stopTest();
        // TODO: Add Valid Test
        System.assertEquals(
            7,
            [SELECT COUNT() FROM Opportunity],
            'Something went wrong'
        );
    }
    @isTest
    private static void testRequestPaymentWithPaymentId() {
        String RESPONSE ='{ "id": "pi_3KTme0GItx6TnYh40vmpFXLT", "object": "payment_intent", "last_payment_error": null, "livemode": false, "next_action": null, "status": "succeeded", "amount": 15000, "amount_capturable": 0, "amount_received": 15000, "application": null, "application_fee_amount": null, "automatic_payment_methods": null, "canceled_at": null, "cancellation_reason": null, "capture_method": "automatic", "charges": { "object": "list", "data": [ { "id": "ch_3KTme0GItx6TnYh40NZczYFT", "object": "charge", "amount": 15000, "amount_captured": 15000, "amount_refunded": 0, "application": null, "application_fee": null, "application_fee_amount": null, "balance_transaction": "txn_3KTme0GItx6TnYh40c2DlyVb", "billing_details": { "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": "42424", "state": null }, "email": "iamsfdeveloper+12@gmail.com", "name": "Arshadulla Shariff", "phone": null }, "calculated_statement_descriptor": "HUMAN APPEAL", "captured": true, "created": 1645014612, "currency": "gbp", "customer": "cus_LA6rsEI3hgaqLR", "description": null, "destination": null, "dispute": null, "disputed": false, "failure_code": null, "failure_message": null, "fraud_details": { }, "invoice": null, "livemode": false, "metadata": { "Address Line 1: ": "32 New Way Road", "CartId": "430cfa36-f125-4e54-bcd7-1a8e834d0c75", "Country": "GBR", "Email: ": "iamsfdeveloper+12@gmail.com", "GiftAid": "True", "Line: 1": "Winter Emergency Fund - 70.000000000", "Line: 2": "Emergency Fund - Yemen - 80.000000000", "MarketingEmail": "False", "MarketingSMS": "False", "Name: ": "Arshadulla Shariff", "PostCode": "LE5 5UA", "Town": "Leicester", "website_payments": "v4" }, "on_behalf_of": null, "order": null, "outcome": { "network_status": "approved_by_network", "reason": null, "risk_level": "normal", "risk_score": 13, "seller_message": "Payment complete.", "type": "authorized" }, "paid": true, "payment_intent": "pi_3KTme0GItx6TnYh40vmpFXLT", "payment_method": "pm_1KTme7GItx6TnYh48JaWGvuW", "payment_method_details": { "card": { "brand": "visa", "checks": { "address_line1_check": null, "address_postal_code_check": "pass", "cvc_check": "pass" }, "country": "US", "exp_month": 4, "exp_year": 2024, "fingerprint": "qmmvbl4smAt9CiyM", "funding": "credit", "installments": null, "last4": "4242", "moto": null, "network": "visa", "three_d_secure": null, "wallet": null }, "type": "card" }, "receipt_email": null, "receipt_number": null, "receipt_url": "https://pay.stripe.com/receipts/acct_1FWLGKGItx6TnYh4/ch_3KTme0GItx6TnYh40NZczYFT/rcpt_LA6rYPZauJONKR13AVzS0qTrQrmkklO", "refunded": false, "refunds": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/charges/ch_3KTme0GItx6TnYh40NZczYFT/refunds" }, "review": null, "shipping": null, "source": null, "source_transfer": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "succeeded", "transfer_data": null, "transfer_group": null } ], "has_more": false, "total_count": 1, "url": "/v1/charges?payment_intent=pi_3KTme0GItx6TnYh40vmpFXLT" }, "client_secret": "pi_3KTme0GItx6TnYh40vmpFXLT_secret_9O0PacaHd0MzsyiVjkuO8exfZ", "confirmation_method": "automatic", "created": 1645014604, "currency": "gbp", "customer": "cus_LA6rsEI3hgaqLR", "description": null, "invoice": null, "metadata": { "Address Line 1: ": "32 New Way Road", "Address Line 2: ": "", "CartId": "430cfa36-f125-4e54-bcd7-1a8e834d0c75", "Country": "GBR", "Email: ": "iamsfdeveloper+12@gmail.com", "GiftAid": "True", "Line: 1": "Winter Emergency Fund - 70.000000000", "Line: 2": "Emergency Fund - Yemen - 80.000000000", "MarketingEmail": "False", "MarketingSMS": "False", "Name: ": "Arshadulla Shariff", "PostCode": "LE5 5UA", "Town": "Leicester", "website_payments": "v4" }, "on_behalf_of": null, "payment_method": "pm_1KTme7GItx6TnYh48JaWGvuW", "payment_method_options": { "card": { "installments": null, "network": null, "request_three_d_secure": "automatic" } }, "payment_method_types": [ "card" ], "processing": null, "receipt_email": null, "review": null, "setup_future_usage": "off_session", "shipping": null, "source": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "transfer_data": null, "transfer_group": null }';
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            200,
            RESPONSE
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        
        List<Opportunity> testOpps = [SELECT Id, Name FROM Opportunity];
        System.debug('>>> testOpps ' + testOpps);
        
        Opportunity oppTest = [
            SELECT npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Vendor__c,
            npe03__Recurring_Donation__r.Opportunity__c,npe03__Recurring_Donation__r.Regional_Code__c,npe03__Recurring_Donation__r.Regional_Office_Code__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c,
            Id, Amount, CurrencyIsoCode,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Transaction_Source__c,
            npe03__Recurring_Donation__r.Card_Payment_Detail__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c,npsp__Primary_contact__c
            FROM Opportunity
            WHERE
            npe03__Recurring_Donation__r.npsp__PaymentMethod__c = 'Card Payment'
            AND CloseDate = TODAY
            AND npe03__Recurring_Donation__r.npsp__Status__c = 'Active'
            AND StageName = 'Pledged'
            ORDER BY Id limit 1
        ];
        
        System.debug('>>> oppTest ' + oppTest);
        
        Sobject sObj = (Sobject) oppTest;
        
        Test.startTest();
        NewPaymentService paymentService = new NewPaymentService();
        oppTest.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c = 'pm_1EUmyr2x6R10KRrhlYS3l97f';
        paymentService.requestPayment(HA_Utility.generateGUID(), oppTest);
        Test.stopTest();
        // TODO: Add Valid Test
        System.assertEquals(
            7,
            [SELECT COUNT() FROM Opportunity],
            'Something went wrong'
        );
    }
    /**
* @description Test Callout
* @author agentgill | 6/22/2020
* @return void
**/
    @isTest
    private static void testCallout() {
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            RESPONSE_SUCCESS,
            RESPONSE_BODY
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        Test.startTest();
        HTTPResponse resCallout = NewPaymentService.makeCallout();
        System.assertEquals(
            RESPONSE_SUCCESS,
            resCallout.getStatusCode(),
            'Response code should be ' + RESPONSE_SUCCESS
        );
        System.assertEquals(
            RESPONSE_BODY,
            resCallout.getBody(),
            'Response body should be:- ' + RESPONSE_BODY
        );
        Test.stopTest();
    }
    @isTest
    private static void testMyNightBatchPositive() {
        String RESPONSEE='{ "id": "pi_3KTyyaGItx6TnYh40Z0vXcU4", "object": "payment_intent", "last_payment_error": null, "livemode": false, "next_action": null, "status": "succeeded", "amount": 571, "amount_capturable": 0, "amount_received": 571, "application": null, "application_fee_amount": null, "automatic_payment_methods": null, "canceled_at": null, "cancellation_reason": null, "capture_method": "automatic", "charges": { "object": "list", "data": [ { "id": "ch_3KTyyaGItx6TnYh40Y8OsB73", "object": "charge", "amount": 571, "amount_captured": 571, "amount_refunded": 0, "application": null, "application_fee": null, "application_fee_amount": null, "balance_transaction": "txn_3KTyyaGItx6TnYh406Zr8HLw", "billing_details": { "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": "42424", "state": null }, "email": "iamsfdeveloper+12@gmail.com", "name": "Arshadulla Shariff", "phone": null }, "calculated_statement_descriptor": "HUMAN APPEAL", "captured": true, "created": 1645062008, "currency": "gbp", "customer": "cus_LAJ2UBhUekGFBG", "description": null, "destination": null, "dispute": null, "disputed": false, "failure_code": null, "failure_message": null, "fraud_details": { }, "invoice": null, "livemode": false, "metadata": { "donationid": "0060C0000091VCSQA2", "cartid": "ad33eb0a-122b-48d6-2044-a71b17a3af6c", "paymentId": "a010C000003z4b9QAA" }, "on_behalf_of": null, "order": null, "outcome": { "network_status": "approved_by_network", "reason": null, "risk_level": "normal", "risk_score": 43, "seller_message": "Payment complete.", "type": "authorized" }, "paid": true, "payment_intent": "pi_3KTyyaGItx6TnYh40Z0vXcU4", "payment_method": "pm_1KTyQeGItx6TnYh4j9mcU0LN", "payment_method_details": { "card": { "brand": "visa", "checks": { "address_line1_check": null, "address_postal_code_check": "pass", "cvc_check": null }, "country": "US", "exp_month": 4, "exp_year": 2024, "fingerprint": "qmmvbl4smAt9CiyM", "funding": "credit", "installments": null, "last4": "4242", "moto": null, "network": "visa", "three_d_secure": null, "wallet": null }, "type": "card" }, "receipt_email": null, "receipt_number": null, "receipt_url": "https://pay.stripe.com/receipts/acct_1FWLGKGItx6TnYh4/ch_3KTyyaGItx6TnYh40Y8OsB73/rcpt_LAJbeqVgqBmpWiS7ZBXzlZxBTVGmLEb", "refunded": false, "refunds": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/charges/ch_3KTyyaGItx6TnYh40Y8OsB73/refunds" }, "review": null, "shipping": null, "source": null, "source_transfer": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "succeeded", "transfer_data": null, "transfer_group": null } ], "has_more": false, "total_count": 1, "url": "/v1/charges?payment_intent=pi_3KTyyaGItx6TnYh40Z0vXcU4" }, "client_secret": "pi_3KTyyaGItx6TnYh40Z0vXcU4_secret_iP0I76tVMHTOjSfgy7azPTWig", "confirmation_method": "automatic", "created": 1645062008, "currency": "gbp", "customer": "cus_LAJ2UBhUekGFBG", "description": null, "invoice": null, "metadata": { "donationid": "0060C0000091VCSQA2", "cartid": "ad33eb0a-122b-48d6-2044-a71b17a3af6c", "paymentId": "a010C000003z4b9QAA" }, "on_behalf_of": null, "payment_method": "pm_1KTyQeGItx6TnYh4j9mcU0LN", "payment_method_options": { "card": { "installments": null, "network": null, "request_three_d_secure": "automatic" } }, "payment_method_types": [ "card" ], "processing": null, "receipt_email": null, "review": null, "setup_future_usage": null, "shipping": null, "source": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "transfer_data": null, "transfer_group": null }';
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            200,
            RESPONSEE
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        Test.startTest();
        String Id = [Select Id From Opportunity Where StageName = 'Setup Completed' limit 1]?.Id;
        NewRecurringDonationService myBatch = new NewRecurringDonationService();
        myBatch.collectionType='Nightly';
        myBatch.Query ='SELECT Id,Payment_Reference__c,Card_Details__r.Payment_Vendor__c,Card_Details__c,npe01__Payment_Amount__c,currencyIsoCode,Card_Details__r.Payment_method_Type__c,Card_Details__r.Gateway_Customer_Reference__c,Card_Details__r.Payment_Method_Id__c,npe01__Payment_Date__c,npe01__Paid__c,npe01__Opportunity__c,npe01__Opportunity__r.Regional_Office_Code__c,npsp__Gateway_Payment_ID__c,Gateway_Customer_Reference__c FROM npe01__OppPayment__c WHERE npe01__Opportunity__c =\''+Id+'\' AND npe01__Paid__c =False AND npe01__Opportunity__r.IsClosed = false AND npe01__Opportunity__r.DonationCode__c IN (\'10N\',\'30N\') AND Card_Details__c != null AND RecordType.DeveloperName=\'Card_Payment\' AND Payment_Status__c =\'pending\' AND npe01__Opportunity__r.StageName =\'Setup Completed\' AND Card_Details__r.Payment_Vendor__c=\'Stripe\'';
        
        Database.executeBatch(myBatch);
        Test.stopTest();
        
        System.assertEquals(
            'Setup Completed',
            [SELECT Id, StageName FROM Opportunity Where StageName ='Setup Completed' LIMIT 1]
            .StageName,
            'Something went wrong'
        );
    }
    @isTest
    private static void testMyNightBatchPositive_1() {
        String RESPONSEE='{ "id": "pi_3KTyyaGItx6TnYh40Z0vXcU4", "object": "payment_intent", "last_payment_error": null, "livemode": false, "next_action": null, "status": "succeeded", "amount": 571, "amount_capturable": 0, "amount_received": 571, "application": null, "application_fee_amount": null, "automatic_payment_methods": null, "canceled_at": null, "cancellation_reason": null, "capture_method": "automatic", "charges": { "object": "list", "data": [ { "id": "ch_3KTyyaGItx6TnYh40Y8OsB73", "object": "charge", "amount": 571, "amount_captured": 571, "amount_refunded": 0, "application": null, "application_fee": null, "application_fee_amount": null, "balance_transaction": "txn_3KTyyaGItx6TnYh406Zr8HLw", "billing_details": { "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": "42424", "state": null }, "email": "iamsfdeveloper+12@gmail.com", "name": "Arshadulla Shariff", "phone": null }, "calculated_statement_descriptor": "HUMAN APPEAL", "captured": true, "created": 1645062008, "currency": "gbp", "customer": "cus_LAJ2UBhUekGFBG", "description": null, "destination": null, "dispute": null, "disputed": false, "failure_code": null, "failure_message": null, "fraud_details": { }, "invoice": null, "livemode": false, "metadata": { "donationid": "0060C0000091VCSQA2", "cartid": "ad33eb0a-122b-48d6-2044-a71b17a3af6c", "paymentId": "a010C000003z4b9QAA" }, "on_behalf_of": null, "order": null, "outcome": { "network_status": "approved_by_network", "reason": null, "risk_level": "normal", "risk_score": 43, "seller_message": "Payment complete.", "type": "authorized" }, "paid": true, "payment_intent": "pi_3KTyyaGItx6TnYh40Z0vXcU4", "payment_method": "pm_1KTyQeGItx6TnYh4j9mcU0LN", "payment_method_details": { "card": { "brand": "visa", "checks": { "address_line1_check": null, "address_postal_code_check": "pass", "cvc_check": null }, "country": "US", "exp_month": 4, "exp_year": 2024, "fingerprint": "qmmvbl4smAt9CiyM", "funding": "credit", "installments": null, "last4": "4242", "moto": null, "network": "visa", "three_d_secure": null, "wallet": null }, "type": "card" }, "receipt_email": null, "receipt_number": null, "receipt_url": "https://pay.stripe.com/receipts/acct_1FWLGKGItx6TnYh4/ch_3KTyyaGItx6TnYh40Y8OsB73/rcpt_LAJbeqVgqBmpWiS7ZBXzlZxBTVGmLEb", "refunded": false, "refunds": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/charges/ch_3KTyyaGItx6TnYh40Y8OsB73/refunds" }, "review": null, "shipping": null, "source": null, "source_transfer": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "succeeded", "transfer_data": null, "transfer_group": null } ], "has_more": false, "total_count": 1, "url": "/v1/charges?payment_intent=pi_3KTyyaGItx6TnYh40Z0vXcU4" }, "client_secret": "pi_3KTyyaGItx6TnYh40Z0vXcU4_secret_iP0I76tVMHTOjSfgy7azPTWig", "confirmation_method": "automatic", "created": 1645062008, "currency": "gbp", "customer": "cus_LAJ2UBhUekGFBG", "description": null, "invoice": null, "metadata": { "donationid": "0060C0000091VCSQA2", "cartid": "ad33eb0a-122b-48d6-2044-a71b17a3af6c", "paymentId": "a010C000003z4b9QAA" }, "on_behalf_of": null, "payment_method": "pm_1KTyQeGItx6TnYh4j9mcU0LN", "payment_method_options": { "card": { "installments": null, "network": null, "request_three_d_secure": "automatic" } }, "payment_method_types": [ "card" ], "processing": null, "receipt_email": null, "review": null, "setup_future_usage": null, "shipping": null, "source": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "transfer_data": null, "transfer_group": null }';
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            200,
            RESPONSEE
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        Test.startTest();
        String Id = [Select Id From Opportunity Where StageName = 'Setup Completed' limit 1]?.Id;
        NewRecurringDonationService myBatch = new NewRecurringDonationService();
        myBatch.collectionType='Nightly';
        Database.executeBatch(myBatch);
        Test.stopTest();
        
        System.assertEquals(
            'Setup Completed',
            [SELECT Id, StageName FROM Opportunity Where StageName ='Setup Completed' LIMIT 1]
            .StageName,
            'Something went wrong'
        );
    }
@isTest
    private static void testMyNightBatchNegative_1() {
        String RESPONSEE=' { "error": { "charge": "ch_3KU0E9GItx6TnYh40FDTIGwd", "code": "card_declined", "decline_code": "insufficient_funds", "doc_url": "https://stripe.com/docs/error-codes/card-declined", "message": "Your card has insufficient funds.", "payment_intent": { "id": "pi_3KU0E9GItx6TnYh401vcjBNz", "object": "payment_intent", "amount": 1333, "amount_capturable": 0, "amount_received": 0, "application": null, "application_fee_amount": null, "automatic_payment_methods": null, "canceled_at": null, "cancellation_reason": null, "capture_method": "automatic", "charges": { "object": "list", "data": [ { "id": "ch_3KU0E9GItx6TnYh40FDTIGwd", "object": "charge", "amount": 1333, "amount_captured": 0, "amount_refunded": 0, "application": null, "application_fee": null, "application_fee_amount": null, "balance_transaction": null, "billing_details": { "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": null, "state": null }, "email": null, "name": "Arshadulla Shariff", "phone": null }, "calculated_statement_descriptor": "HUMAN APPEAL", "captured": false, "created": 1645066818, "currency": "gbp", "customer": "cus_LAKr3WkXYePs25", "description": null, "destination": null, "dispute": null, "disputed": false, "failure_code": "card_declined", "failure_message": "Your card has insufficient funds.", "fraud_details": { }, "invoice": null, "livemode": false, "metadata": { "donationid": "0060C0000091jiRQAQ", "cardid": "cb4ac87e-df47-cb57-5586-e5d90e2bdb8e", "paymentId": "a010C000003z4htQAA" }, "on_behalf_of": null, "order": null, "outcome": { "network_status": "declined_by_network", "reason": "insufficient_funds", "risk_level": "normal", "risk_score": 58, "seller_message": "The bank returned the decline code `insufficient_funds`.", "type": "issuer_declined" }, "paid": false, "payment_intent": "pi_3KU0E9GItx6TnYh401vcjBNz", "payment_method": "pm_1KU0CJGItx6TnYh4v2LoRrDS", "payment_method_details": { "card": { "brand": "visa", "checks": { "address_line1_check": null, "address_postal_code_check": null, "cvc_check": "pass" }, "country": "GB", "exp_month": 12, "exp_year": 2033, "fingerprint": "WQMpKM9LHizdQgpe", "funding": "credit", "installments": null, "last4": "3178", "moto": null, "network": "visa", "three_d_secure": null, "wallet": null }, "type": "card" }, "receipt_email": null, "receipt_number": null, "receipt_url": null, "refunded": false, "refunds": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/charges/ch_3KU0E9GItx6TnYh40FDTIGwd/refunds" }, "review": null, "shipping": null, "source": null, "source_transfer": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "failed", "transfer_data": null, "transfer_group": null } ], "has_more": false, "total_count": 1, "url": "/v1/charges?payment_intent=pi_3KU0E9GItx6TnYh401vcjBNz" }, "client_secret": "pi_3KU0E9GItx6TnYh401vcjBNz_secret_5DWEkcmcMKrO7eldwn4Gyzwr1", "confirmation_method": "automatic", "created": 1645066817, "currency": "gbp", "customer": "cus_LAKr3WkXYePs25", "description": null, "invoice": null, "last_payment_error": { "charge": "ch_3KU0E9GItx6TnYh40FDTIGwd", "code": "card_declined", "decline_code": "insufficient_funds", "doc_url": "https://stripe.com/docs/error-codes/card-declined", "message": "Your card has insufficient funds.", "payment_method": { "id": "pm_1KU0CJGItx6TnYh4v2LoRrDS", "object": "payment_method", "billing_details": { "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": null, "state": null }, "email": null, "name": "Arshadulla Shariff", "phone": null }, "card": { "brand": "visa", "checks": { "address_line1_check": null, "address_postal_code_check": null, "cvc_check": "pass" }, "country": "GB", "exp_month": 12, "exp_year": 2033, "fingerprint": "WQMpKM9LHizdQgpe", "funding": "credit", "generated_from": null, "last4": "3178", "networks": { "available": [ "visa" ], "preferred": null }, "three_d_secure_usage": { "supported": true }, "wallet": null }, "created": 1645066703, "customer": "cus_LAKr3WkXYePs25", "livemode": false, "metadata": { }, "type": "card" }, "type": "card_error" }, "livemode": false, "metadata": { "donationid": "0060C0000091jiRQAQ", "cardid": "cb4ac87e-df47-cb57-5586-e5d90e2bdb8e", "paymentId": "a010C000003z4htQAA" }, "next_action": null, "on_behalf_of": null, "payment_method": null, "payment_method_options": { "card": { "installments": null, "network": null, "request_three_d_secure": "automatic" } }, "payment_method_types": [ "card" ], "processing": null, "receipt_email": null, "review": null, "setup_future_usage": null, "shipping": null, "source": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "requires_payment_method", "transfer_data": null, "transfer_group": null }, "payment_method": { "id": "pm_1KU0CJGItx6TnYh4v2LoRrDS", "object": "payment_method", "billing_details": { "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": null, "state": null }, "email": null, "name": "Arshadulla Shariff", "phone": null }, "card": { "brand": "visa", "checks": { "address_line1_check": null, "address_postal_code_check": null, "cvc_check": "pass" }, "country": "GB", "exp_month": 12, "exp_year": 2033, "fingerprint": "WQMpKM9LHizdQgpe", "funding": "credit", "generated_from": null, "last4": "3178", "networks": { "available": [ "visa" ], "preferred": null }, "three_d_secure_usage": { "supported": true }, "wallet": null }, "created": 1645066703, "customer": "cus_LAKr3WkXYePs25", "livemode": false, "metadata": { }, "type": "card" }, "type": "card_error" } }';
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            404,
            RESPONSEE
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        Test.startTest();
        NewRecurringDonationService myBatch = new NewRecurringDonationService();
        myBatch.collectionType='Nightly';
        Database.executeBatch(myBatch);
        Test.stopTest();
    }
@isTest
    private static void testMyNightBatchPositive_2() {
        String RESPONSEE='{ "id": "pi_3KTyyaGItx6TnYh40Z0vXcU4", "object": "payment_intent", "last_payment_error": null, "livemode": false, "next_action": null, "status": "succeeded", "amount": 571, "amount_capturable": 0, "amount_received": 571, "application": null, "application_fee_amount": null, "automatic_payment_methods": null, "canceled_at": null, "cancellation_reason": null, "capture_method": "automatic", "charges": { "object": "list", "data": [ { "id": "ch_3KTyyaGItx6TnYh40Y8OsB73", "object": "charge", "amount": 571, "amount_captured": 571, "amount_refunded": 0, "application": null, "application_fee": null, "application_fee_amount": null, "balance_transaction": "txn_3KTyyaGItx6TnYh406Zr8HLw", "billing_details": { "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": "42424", "state": null }, "email": "iamsfdeveloper+12@gmail.com", "name": "Arshadulla Shariff", "phone": null }, "calculated_statement_descriptor": "HUMAN APPEAL", "captured": true, "created": 1645062008, "currency": "gbp", "customer": "cus_LAJ2UBhUekGFBG", "description": null, "destination": null, "dispute": null, "disputed": false, "failure_code": null, "failure_message": null, "fraud_details": { }, "invoice": null, "livemode": false, "metadata": { "donationid": "0060C0000091VCSQA2", "cardid": "ad33eb0a-122b-48d6-2044-a71b17a3af6c", "paymentId": "a010C000003z4b9QAA" }, "on_behalf_of": null, "order": null, "outcome": { "network_status": "approved_by_network", "reason": null, "risk_level": "normal", "risk_score": 43, "seller_message": "Payment complete.", "type": "authorized" }, "paid": true, "payment_intent": "pi_3KTyyaGItx6TnYh40Z0vXcU4", "payment_method": "pm_1KTyQeGItx6TnYh4j9mcU0LN", "payment_method_details": { "card": { "brand": "visa", "checks": { "address_line1_check": null, "address_postal_code_check": "pass", "cvc_check": null }, "country": "US", "exp_month": 4, "exp_year": 2024, "fingerprint": "qmmvbl4smAt9CiyM", "funding": "credit", "installments": null, "last4": "4242", "moto": null, "network": "visa", "three_d_secure": null, "wallet": null }, "type": "card" }, "receipt_email": null, "receipt_number": null, "receipt_url": "https://pay.stripe.com/receipts/acct_1FWLGKGItx6TnYh4/ch_3KTyyaGItx6TnYh40Y8OsB73/rcpt_LAJbeqVgqBmpWiS7ZBXzlZxBTVGmLEb", "refunded": false, "refunds": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/charges/ch_3KTyyaGItx6TnYh40Y8OsB73/refunds" }, "review": null, "shipping": null, "source": null, "source_transfer": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "succeeded", "transfer_data": null, "transfer_group": null } ], "has_more": false, "total_count": 1, "url": "/v1/charges?payment_intent=pi_3KTyyaGItx6TnYh40Z0vXcU4" }, "client_secret": "pi_3KTyyaGItx6TnYh40Z0vXcU4_secret_iP0I76tVMHTOjSfgy7azPTWig", "confirmation_method": "automatic", "created": 1645062008, "currency": "gbp", "customer": "cus_LAJ2UBhUekGFBG", "description": null, "invoice": null, "metadata": { "donationid": "0060C0000091VCSQA2", "cardid": "ad33eb0a-122b-48d6-2044-a71b17a3af6c", "paymentId": "a010C000003z4b9QAA" }, "on_behalf_of": null, "payment_method": "pm_1KTyQeGItx6TnYh4j9mcU0LN", "payment_method_options": { "card": { "installments": null, "network": null, "request_three_d_secure": "automatic" } }, "payment_method_types": [ "card" ], "processing": null, "receipt_email": null, "review": null, "setup_future_usage": null, "shipping": null, "source": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "transfer_data": null, "transfer_group": null }';
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            200,
            RESPONSEE
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        Test.startTest();
        npe01__OppPayment__c payment = new npe01__OppPayment__c(npe01__Payment_Amount__c = 1);
        payment.npe01__Opportunity__r = new Opportunity(Regional_Office_Code__c = 'UK');
        payment.Card_Details__r = new Income_Card_Payment__c(Gateway_Customer_Reference__c = 'cus_LAKr3WkXYePs25',Payment_Method_Type__c = 'card');
        payment.npe01__Opportunity__c = [Select Id From Opportunity limit 1]?.Id;
        NewPaymentService ps = new NewPaymentService();
        HTTPResponse res = ps.requestNightPayment(HA_Utility.generateGUID(), payment);
        Test.stopTest();
    }
@isTest
    private static void testRequestCustomerPM() {
        String RESPONSE ='{ "id": "cus_LAJvdF40xe343zqF", "object": "customer", "address": { "city": "Leicester", "country": "United Kingdom", "line1": "6 23 Avenue", "line2": null, "postal_code": "SKD 6RT", "state": null }, "balance": 0, "created": 1645063177, "currency": null, "default_source": null, "delinquent": false, "description": null, "discount": null, "email": "test@gmail.com", "invoice_prefix": "56C2FFE4", "invoice_settings": { "custom_fields": null, "default_payment_method": "pm_1KTzHeGItx6TnYh4jpVcdV343E", "footer": null }, "livemode": true, "metadata": { }, "name": "Aamenah Karim", "next_invoice_sequence": 1, "phone": null, "preferred_locales": [ ], "shipping": { "address": { "city": "Leicester", "country": "United Kingdom", "line1": "6 Sutton Avenue", "line2": null, "postal_code": "LE4 6RT", "state": null }, "name": "Aamenah Karim", "phone": null }, "sources": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_LAJvdF40xeGzqF/sources" }, "subscriptions": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_LAJvdF40xeGzqF/subscriptions" }, "tax_exempt": "none", "tax_ids": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_LAJvdF40xeGzqF/tax_ids" } }';
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            200,
            RESPONSE
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
    	 Test.startTest();
        NewPaymentService ps = new NewPaymentService();
        HTTPResponse res = ps.requestCustomerInformation('cus_LAJvdF40xe343zqF','UK');
		Test.stopTest();
    }
    
    @isTest
    private static void testSEPACollectionPositive_1() {
         String RESPONSEE='{ "id": "pi_3KXri7BqqDaI4pY60Od6GVco", "object": "payment_intent", "last_payment_error": null, "livemode": false, "next_action": null, "status": "processing", "amount": 1200, "amount_capturable": 0, "amount_received": 0, "application": null, "application_fee_amount": null, "automatic_payment_methods": null, "canceled_at": null, "cancellation_reason": null, "capture_method": "automatic", "charges": { "object": "list", "data": [ { "id": "py_3KXri7BqqDaI4pY60bk7jJZe", "object": "charge", "amount": 1200, "amount_captured": 1200, "amount_refunded": 0, "application": null, "application_fee": null, "application_fee_amount": null, "balance_transaction": null, "billing_details": { "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": null, "state": null }, "email": "iamsfdeveloper+12@gmail.com", "name": "Arshadulla Shariff", "phone": null }, "calculated_statement_descriptor": null, "captured": true, "created": 1645987391, "currency": "eur", "customer": "cus_LDr1lhYWIBvrBM", "description": null, "destination": null, "dispute": null, "disputed": false, "failure_code": null, "failure_message": null, "fraud_details": { }, "invoice": null, "livemode": false, "metadata": { "donationid": "0060C000009C4aiQAC", "cardid": "pi_3KXRnmBqqDaI4pY605DYoJaY", "donorid": "0030C00000Q7EGKQA3" }, "on_behalf_of": null, "order": null, "outcome": { "network_status": "approved_by_network", "reason": null, "risk_level": "not_assessed", "seller_message": "Payment complete.", "type": "authorized" }, "paid": false, "payment_intent": "pi_3KXri7BqqDaI4pY60Od6GVco", "payment_method": "pm_1KXRbCBqqDaI4pY6fQsKe1Il", "payment_method_details": { "sepa_debit": { "bank_code": "19043", "branch_code": null, "country": "AT", "fingerprint": "VwuKPpGgC9ZRvbal", "last4": "3201", "mandate": "mandate_1KXRbDBqqDaI4pY6TCrvB45f" }, "type": "sepa_debit" }, "receipt_email": null, "receipt_number": null, "receipt_url": null, "refunded": false, "refunds": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/charges/py_3KXri7BqqDaI4pY60bk7jJZe/refunds" }, "review": null, "shipping": null, "source": null, "source_transfer": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "pending", "transfer_data": null, "transfer_group": null } ], "has_more": false, "total_count": 1, "url": "/v1/charges?payment_intent=pi_3KXri7BqqDaI4pY60Od6GVco" }, "client_secret": "pi_3KXri7BqqDaI4pY60Od6GVco_secret_uCqaBUg1m9s9SYQo5XSIcxjzG", "confirmation_method": "automatic", "created": 1645987391, "currency": "eur", "customer": "cus_LDr1lhYWIBvrBM", "description": null, "invoice": null, "metadata": { "donationid": "0060C000009C4aiQAC", "cardid": "pi_3KXRnmBqqDaI4pY605DYoJaY", "donorid": "0030C00000Q7EGKQA3" }, "on_behalf_of": null, "payment_method": "pm_1KXRbCBqqDaI4pY6fQsKe1Il", "payment_method_options": { "sepa_debit": { } }, "payment_method_types": [ "sepa_debit" ], "processing": null, "receipt_email": null, "review": null, "setup_future_usage": null, "shipping": null, "source": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "transfer_data": null, "transfer_group": null }';
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            200,
            RESPONSEE
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        
        Test.startTest();
        String Query = 'SELECT Id, Guid__c,Amount,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Vendor__c,Transaction_Id__c,npe03__Recurring_Donation__r.Regional_Office_Code__c,npe03__Recurring_Donation__r.Regional_Code__c,npsp__Primary_Contact__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c,'+
            +'CurrencyIsoCode,npe03__Recurring_Donation__r.Card_Payment_Detail__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c  FROM Opportunity  '+
            +'WHERE npe03__Recurring_Donation__r.npsp__PaymentMethod__c = \'SEPA\'  ORDER BY Id ';

        NewRecurringDonationService myBatch = new NewRecurringDonationService();
		myBatch.query = Query;
        Database.executeBatch(myBatch); 
        System.debug('testSEPACollectionPositive_1 '+Database.query('Select Id,Name,StageName,npe03__Recurring_Donation__r.npsp__PaymentMethod__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c From Opportunity WHERE npe03__Recurring_Donation__r.npsp__PaymentMethod__c = \'SEPA\''));
        Test.stopTest();
    }
    @isTest
    private static void testSEPACollectionPositive_2() {
        String RESPONSEE1='{"id": "pi_3KXri7BqqDaI4pY60Od6GVco", "object": "payment_intent", "last_payment_error": null, "livemode": false, "next_action": null, "status": "succeeded", "amount": 1200, "amount_capturable": 0, "amount_received": 1200, "application": null, "application_fee_amount": null, "automatic_payment_methods": null, "canceled_at": null, "cancellation_reason": null, "capture_method": "automatic", "charges": { "object": "list", "data": [ { "id": "py_3KXri7BqqDaI4pY60bk7jJZe", "object": "charge", "amount": 1200, "amount_captured": 1200, "amount_refunded": 0, "application": null, "application_fee": null, "application_fee_amount": null, "balance_transaction": "txn_3KXri7BqqDaI4pY603Uq9VZm", "billing_details": { "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": null, "state": null }, "email": "iamsfdeveloper+12@gmail.com", "name": "Arshadulla Shariff", "phone": null }, "calculated_statement_descriptor": null, "captured": true, "created": 1645987391, "currency": "eur", "customer": "cus_LDr1lhYWIBvrBM", "description": null, "destination": null, "dispute": null, "disputed": false, "failure_code": null, "failure_message": null, "fraud_details": { }, "invoice": null, "livemode": false, "metadata": { "donationid": "0060C000009C4aiQAC", "cartid": "pi_3KXRnmBqqDaI4pY605DYoJaY", "donorid": "0030C00000Q7EGKQA3" }, "on_behalf_of": null, "order": null, "outcome": { "network_status": "approved_by_network", "reason": null, "risk_level": "not_assessed", "seller_message": "Payment complete.", "type": "authorized" }, "paid": true, "payment_intent": "pi_3KXri7BqqDaI4pY60Od6GVco", "payment_method": "pm_1KXRbCBqqDaI4pY6fQsKe1Il", "payment_method_details": { "sepa_debit": { "bank_code": "19043", "branch_code": null, "country": "AT", "fingerprint": "VwuKPpGgC9ZRvbal", "last4": "3201", "mandate": "mandate_1KXRbDBqqDaI4pY6TCrvB45f" }, "type": "sepa_debit" }, "receipt_email": null, "receipt_number": null, "receipt_url": "https://pay.stripe.com/receipts/acct_1I6DCWBqqDaI4pY6/py_3KXri7BqqDaI4pY60bk7jJZe/rcpt_LEKMCJttZjZqAxEtJ6fQJROdJYcPwmu", "refunded": false, "refunds": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/charges/py_3KXri7BqqDaI4pY60bk7jJZe/refunds" }, "review": null, "shipping": null, "source": null, "source_transfer": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "succeeded", "transfer_data": null, "transfer_group": null } ], "has_more": false, "total_count": 1, "url": "/v1/charges?payment_intent=pi_3KXri7BqqDaI4pY60Od6GVco" }, "client_secret": "pi_3KXri7BqqDaI4pY60Od6GVco_secret_uCqaBUg1m9s9SYQo5XSIcxjzG", "confirmation_method": "automatic", "created": 1645987391, "currency": "eur", "customer": "cus_LDr1lhYWIBvrBM", "description": null, "invoice": null, "metadata": { "donationid": "0060C000009C4aiQAC", "cartid": "pi_3KXRnmBqqDaI4pY605DYoJaY", "donorid": "0030C00000Q7EGKQA3" }, "on_behalf_of": null, "payment_method": "pm_1KXRbCBqqDaI4pY6fQsKe1Il", "payment_method_options": { "sepa_debit": { } }, "payment_method_types": [ "sepa_debit" ], "processing": null, "receipt_email": null, "review": null, "setup_future_usage": null, "shipping": null, "source": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "transfer_data": null, "transfer_group": null }';
        HTTPCalloutServiceMock serviceMock1 = new HTTPCalloutServiceMock(
            200,
            RESPONSEE1
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock1);
        Test.startTest();
       	String Query2 =  'SELECT Id, Guid__c,Amount,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Vendor__c,Transaction_Id__c,npe03__Recurring_Donation__r.Regional_Office_Code__c,npe03__Recurring_Donation__r.Regional_Code__c,npsp__Primary_Contact__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c,'+
            +'CurrencyIsoCode,npe03__Recurring_Donation__r.Card_Payment_Detail__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c  FROM Opportunity  '+
            +'WHERE npe03__Recurring_Donation__r.npsp__PaymentMethod__c = \'SEPA\' AND npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c=\'sepa_debit\' AND  npe03__Recurring_Donation__r.npsp__Status__c = \'Active\'AND npe03__Recurring_Donation__r.Donation_type__c IN (\'RD\',\'RDA\',\'EMI\') '+
            +'AND npe03__Recurring_Donation__r.Card_Payment_Detail__c != null and npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c != null AND Amount >0.00 ORDER BY Id ';
        Opportunity opp = Database.query('Select Id,Name,StageName,npe03__Recurring_Donation__r.npsp__PaymentMethod__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c From Opportunity WHERE npe03__Recurring_Donation__r.npsp__PaymentMethod__c = \'SEPA\' limit 1');
		opp.Transaction_Id__c = 'pi_3KXri7BqqDaI4pY60Od6GVco';
		Update opp;
        NewRecurringDonationService myBatch1 = new NewRecurringDonationService();
        myBatch1.query = Query2;
        myBatch1.collectionType='SEPACollection';
        Database.executeBatch(myBatch1);
        System.debug('testSEPACollectionPositive_2 '+Database.query('Select Id,Name,StageName,npe03__Recurring_Donation__r.npsp__PaymentMethod__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c From Opportunity WHERE StageName !=\'Pledged\''));
        Test.stopTest();
    }
    @isTest
    private static void testSEPACollectionPositive_3() {
        String RESPONSEE1='{"id": "pi_3KXri7BqqDaI4pY60Od6GVco", "object": "payment_intent", "last_payment_error": null, "livemode": false, "next_action": null, "status": "succeeded", "amount": 1200, "amount_capturable": 0, "amount_received": 1200, "application": null, "application_fee_amount": null, "automatic_payment_methods": null, "canceled_at": null, "cancellation_reason": null, "capture_method": "automatic", "charges": { "object": "list", "data": [ { "id": "py_3KXri7BqqDaI4pY60bk7jJZe", "object": "charge", "amount": 1200, "amount_captured": 1200, "amount_refunded": 0, "application": null, "application_fee": null, "application_fee_amount": null, "balance_transaction": "txn_3KXri7BqqDaI4pY603Uq9VZm", "billing_details": { "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": null, "state": null }, "email": "iamsfdeveloper+12@gmail.com", "name": "Arshadulla Shariff", "phone": null }, "calculated_statement_descriptor": null, "captured": true, "created": 1645987391, "currency": "eur", "customer": "cus_LDr1lhYWIBvrBM", "description": null, "destination": null, "dispute": null, "disputed": false, "failure_code": null, "failure_message": null, "fraud_details": { }, "invoice": null, "livemode": false, "metadata": { "donationid": "0060C000009C4aiQAC", "cardid": "pi_3KXRnmBqqDaI4pY605DYoJaY", "donorid": "0030C00000Q7EGKQA3" }, "on_behalf_of": null, "order": null, "outcome": { "network_status": "approved_by_network", "reason": null, "risk_level": "not_assessed", "seller_message": "Payment complete.", "type": "authorized" }, "paid": true, "payment_intent": "pi_3KXri7BqqDaI4pY60Od6GVco", "payment_method": "pm_1KXRbCBqqDaI4pY6fQsKe1Il", "payment_method_details": { "sepa_debit": { "bank_code": "19043", "branch_code": null, "country": "AT", "fingerprint": "VwuKPpGgC9ZRvbal", "last4": "3201", "mandate": "mandate_1KXRbDBqqDaI4pY6TCrvB45f" }, "type": "sepa_debit" }, "receipt_email": null, "receipt_number": null, "receipt_url": "https://pay.stripe.com/receipts/acct_1I6DCWBqqDaI4pY6/py_3KXri7BqqDaI4pY60bk7jJZe/rcpt_LEKMCJttZjZqAxEtJ6fQJROdJYcPwmu", "refunded": false, "refunds": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/charges/py_3KXri7BqqDaI4pY60bk7jJZe/refunds" }, "review": null, "shipping": null, "source": null, "source_transfer": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "succeeded", "transfer_data": null, "transfer_group": null } ], "has_more": false, "total_count": 1, "url": "/v1/charges?payment_intent=pi_3KXri7BqqDaI4pY60Od6GVco" }, "client_secret": "pi_3KXri7BqqDaI4pY60Od6GVco_secret_uCqaBUg1m9s9SYQo5XSIcxjzG", "confirmation_method": "automatic", "created": 1645987391, "currency": "eur", "customer": "cus_LDr1lhYWIBvrBM", "description": null, "invoice": null, "metadata": { "donationid": "0060C000009C4aiQAC", "cardid": "pi_3KXRnmBqqDaI4pY605DYoJaY", "donorid": "0030C00000Q7EGKQA3" }, "on_behalf_of": null, "payment_method": "pm_1KXRbCBqqDaI4pY6fQsKe1Il", "payment_method_options": { "sepa_debit": { } }, "payment_method_types": [ "sepa_debit" ], "processing": null, "receipt_email": null, "review": null, "setup_future_usage": null, "shipping": null, "source": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "transfer_data": null, "transfer_group": null }';
        HTTPCalloutServiceMock serviceMock1 = new HTTPCalloutServiceMock(
            200,
            RESPONSEE1
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock1);
        Test.startTest();
       	String Query2 =  'SELECT Id, Guid__c,Amount,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Vendor__c,Transaction_Id__c,npe03__Recurring_Donation__r.Regional_Office_Code__c,npe03__Recurring_Donation__r.Regional_Code__c,npsp__Primary_Contact__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c,'+
            +'CurrencyIsoCode,npe03__Recurring_Donation__r.Card_Payment_Detail__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c  FROM Opportunity  '+
            +'WHERE npe03__Recurring_Donation__r.npsp__PaymentMethod__c = \'SEPA\' AND npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c=\'sepa_debit\' AND  npe03__Recurring_Donation__r.npsp__Status__c = \'Active\' AND StageName != \'Pledged\' AND npe03__Recurring_Donation__r.Donation_type__c IN (\'RD\',\'RDA\',\'EMI\') '+
            +'AND npe03__Recurring_Donation__r.Card_Payment_Detail__c != null and npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c != null AND Amount >0.00 ORDER BY Id ';
		
        System.debug('testSEPACollectionPositive_3 BF '+Database.query('Select Id,Name,StageName,npe03__Recurring_Donation__r.npsp__PaymentMethod__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c From Opportunity WHERE StageName !=\'Pledged\''));
        NewRecurringDonationService myBatch1 = new NewRecurringDonationService();
        myBatch1.query = Query2;
        myBatch1.collectionType='SEPACollection';
        Database.executeBatch(myBatch1);
        System.debug('testSEPACollectionPositive_3 AF '+Database.query('Select Id,Name,StageName,npe03__Recurring_Donation__r.npsp__PaymentMethod__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c From Opportunity WHERE StageName !=\'Pledged\''));
        Test.stopTest();
    }
     @isTest
    private static void testOppwaCollectionPositive_1() {
         String RESPONSEE='{ "id": "8ac7a4a1801b4c8b01801cd9f84b11cc", "paymentType": "PA", "amount": "20.00", "currency": "GBP", "descriptor": "8091.0775.7059 humanappeal-org-uk - 3DV2 ", "result": { "code": "000.100.110", "description": "Request successfully processed in Merchant in Integrator Test Mode" }, "risk": { "score": "0" }, "buildNumber": "0e531a0327bd64cc117eabe6a098c851b0c69050@2022-04-11 07:05:27 +0000", "timestamp": "2022-04-12 08:18:08+0000", "ndc": "8ac7a4c77ef7c6d9017efcd2b36c1225_4e81ad1b056d43c19ed7e417f23d3e2b", "standingInstruction": { "source": "MIT", "type": "UNSCHEDULED", "mode": "REPEATED" } }';
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            200,
            RESPONSEE
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        
        Test.startTest();
        String Query = 'SELECT Id, guid__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Vendor__c,Amount,npe03__Recurring_Donation__r.Regional_Office_Code__c,npe03__Recurring_Donation__r.Regional_Code__c,npsp__Primary_Contact__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Transaction_Source__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c,CurrencyIsoCode,npe03__Recurring_Donation__r.Card_Payment_Detail__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c '+
                +' FROM Opportunity  WHERE npe03__Recurring_Donation__r.npsp__PaymentMethod__c = \'Card Payment\' And npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Vendor__c=\'Oppwa\' ORDER BY Id ';

        NewRecurringDonationService myBatch = new NewRecurringDonationService();
		myBatch.query = Query;
        Database.executeBatch(myBatch); 
        
        Test.stopTest();
    } 
    @isTest
    private static void testOppwaCollectionPositive_2() {
         String RESPONSEE='{ "id": "8ac7a4a1801b4c8b01801cd9f84b11cc", "paymentType": "PA", "amount": "20.00", "currency": "GBP", "descriptor": "8091.0775.7059 humanappeal-org-uk - 3DV2 ", "result": { "code": "000.100.110", "description": "Request successfully processed in Merchant in Integrator Test Mode" }, "risk": { "score": "0" }, "buildNumber": "0e531a0327bd64cc117eabe6a098c851b0c69050@2022-04-11 07:05:27 +0000", "timestamp": "2022-04-12 08:18:08+0000", "ndc": "8ac7a4c77ef7c6d9017efcd2b36c1225_4e81ad1b056d43c19ed7e417f23d3e2b", "standingInstruction": { "source": "MIT", "type": "UNSCHEDULED", "mode": "REPEATED" } }';
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            200,
            RESPONSEE
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        
        Test.startTest();
        String Id= [Select Id From Opportunity WHERE Payment_Method__c='Oppwa' AND StageName = 'Setup Completed' limit 1 ]?.Id;
         NewRecurringDonationService myBatch = new NewRecurringDonationService();
        myBatch.collectionType='Nightly';
        myBatch.Query ='SELECT Id,Payment_Reference__c,Card_Details__c,Card_Details__r.Payment_Vendor__c,npe01__Payment_Amount__c,currencyIsoCode,Card_Details__r.Payment_method_Type__c,Card_Details__r.Gateway_Customer_Reference__c,Card_Details__r.Payment_Method_Id__c,npe01__Payment_Date__c,npe01__Paid__c,npe01__Opportunity__c,npe01__Opportunity__r.Regional_Office_Code__c,npsp__Gateway_Payment_ID__c,Gateway_Customer_Reference__c FROM npe01__OppPayment__c WHERE npe01__Opportunity__c =\''+Id+'\' AND npe01__Paid__c =False AND npe01__Opportunity__r.IsClosed = false AND npe01__Opportunity__r.DonationCode__c IN (\'10N\',\'30N\') AND Card_Details__c != null AND RecordType.DeveloperName=\'Card_Payment\' AND Payment_Status__c =\'pending\' AND npe01__Opportunity__r.StageName =\'Setup Completed\'';
        
        Database.executeBatch(myBatch); 
        
        Test.stopTest();
    } 
}