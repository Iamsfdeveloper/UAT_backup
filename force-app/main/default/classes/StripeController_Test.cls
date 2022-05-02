@isTest
public class StripeController_Test {
    @testSetup
   static void makeData(){
       List<HA_Payment_Schedule__c> paymentScheduleList = new List<HA_Payment_Schedule__c>{(HA_Payment_Schedule__c)TestFactory.createSObject(new HA_Payment_Schedule__c(Code__c='RD'),'TestFactoryDefaults.PaymentSchedulesDefaults'),(HA_Payment_Schedule__c)TestFactory.createSObject(new HA_Payment_Schedule__c(Code__c='SD'),'TestFactoryDefaults.PaymentSchedulesDefaults')};
        insert paymentScheduleList;
        System.debug(JSON.serialize(paymentScheduleList[0]));
        List<npsp__General_Accounting_Unit__c> items = (List<npsp__General_Accounting_Unit__c>)TestFactory.createSObjectList(new npsp__General_Accounting_Unit__c(Regional_Office_code__c='All'),1,'TestFactoryDefaults.GeneralAccountUnitsDefaults');
        insert items;
        Payment_Schedule_Allocation__c PSA1 = new Payment_Schedule_Allocation__c(General_Accounting_Unit__c= items[0].Id,Payment_Schedule__c = paymentScheduleList[0].Id);
        insert PSA1;
        Payment_Schedule_Allocation__c  PSA2 = new Payment_Schedule_Allocation__c(General_Accounting_Unit__c= items[0].Id,Payment_Schedule__c = paymentScheduleList[1].Id);
        insert PSA2;
        List<Contact> contactList = (List<Contact>) TestFactory.createSObjectList(
            new Contact(Email='test@humanappeal.org.uk',RecordTypeId = (String)Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Donor').getRecordTypeId()),
            1,
            true
        );
        contactlist[0].Gift_Aid_Status__c='Yes';
        update contactlist;
       insert new Gift_Aid_Declaration__c(Donor__c=contactlist[0].Id,Gift_Aid_Status__c ='Yes',Gift_Aid_Start_Date__c=System.today());
       List<Opportunity> opplist=(List<Opportunity>) TestFactory.createSObjectList(
           new Opportunity(guid__c=HA_Utility.generateGUID(), npsp__primary_Contact__c=contactlist[0].Id,Donation_type__c='RD',Payment_Schedule__c=paymentScheduleList[0].Id,Amount=100),
           2,
           true
       );
        List<npsp__Allocation__c> allocationList =( List<npsp__Allocation__c>)TestFactory.createSObjectList(
            new npsp__Allocation__c(npsp__General_Accounting_Unit__c =items[0].Id,npsp__Opportunity__c =opplist[0].Id,npsp__Amount__c=100),
            1,'TestFactoryDefaults.ItemAllocationDefaults',true
        ); 
        
    }
    testmethod static void unit_1(){
        String RESPONSEE='{ "id": "cus_LYSddy6vAr3B1u", "object": "customer", "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": "LE5 5UA", "state": null }, "balance": 0, "created": 1650630950, "currency": null, "default_source": null, "delinquent": false, "description": null, "discount": null, "email": "iamsfdeveloper+12@gmail.com", "invoice_prefix": "D14B2673", "invoice_settings": { "custom_fields": null, "default_payment_method": null, "footer": null }, "livemode": false, "metadata": { "contactid": "0030C00000QMQgKQAX" }, "name": "Arshadulla Shariff", "next_invoice_sequence": 1, "phone": null, "preferred_locales": [ ], "shipping": null, "sources": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_LYSddy6vAr3B1u/sources" }, "subscriptions": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_LYSddy6vAr3B1u/subscriptions" }, "tax_exempt": "none", "tax_ids": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/customers/cus_LYSddy6vAr3B1u/tax_ids" }, "tax_info": null, "tax_info_verification": null, "test_clock": null }';
		 HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            200,
            RESPONSEE
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        Opportunity opp = [Select Id,currencyISOCode From Opportunity Limit 1];
        Test.startTest();
        pageReference stripePage = Page.StripeComponent;
        Test.setCurrentPage(stripePage);
        stripePage.getParameters().put('id',opp.Id);
        StripeController stripeInstance = new StripeController();
        stripeInstance.getCustomer();
        stripeInstance.getSingle();
        stripeInstance.getbuttonLabel();
        stripeInstance.getpublishableKey();
        stripeInstance.getPaymentConfig();
        StripeController.getCurrencySymbolFromIso(opp.currencyISOCode);
        Test.stopTest();
    }
    testmethod static void unit_2(){
        String RESPONSEE='{ "id": "pi_3KrTaJGItx6TnYh40knkd00a", "object": "payment_intent", "last_payment_error": null, "livemode": false, "next_action": null, "status": "succeeded", "amount": 5000, "amount_capturable": 0, "amount_details": { "tip": { "amount": null } }, "amount_received": 5000, "application": null, "application_fee_amount": null, "automatic_payment_methods": null, "canceled_at": null, "cancellation_reason": null, "capture_method": "automatic", "charges": { "object": "list", "data": [ { "id": "ch_3KrTaJGItx6TnYh40DF7p2wa", "object": "charge", "amount": 5000, "amount_captured": 5000, "amount_refunded": 0, "application": null, "application_fee": null, "application_fee_amount": null, "balance_transaction": "txn_3KrTaJGItx6TnYh40lbd9PKr", "billing_details": { "address": { "city": "Sutton+Coldfield", "country": "GB", "line1": "47+Denholm+Road%0D%0AThe+Royal+Town+of+Sutton+Coldfield", "line2": "never", "postal_code": "B73+6PN", "state": "never" }, "email": "ateek.mahmood@humanappeal.org.uk", "name": "Ateek+Internal+Test+Mahmood+Internal+Test", "phone": "never" }, "calculated_statement_descriptor": "HUMAN APPEAL", "captured": true, "created": 1650661212, "currency": "gbp", "customer": "cus_LYXAvIbNBuGxa0", "description": null, "destination": null, "dispute": null, "disputed": false, "failure_balance_transaction": null, "failure_code": null, "failure_message": null, "fraud_details": { }, "invoice": null, "livemode": false, "metadata": { "donationid": "0060C000009nzK6QAI", "cartid": "125e3117-8450-4918-5f1e-c48dc0852051", "paymentid": "a010C000004IoUWQA0" }, "on_behalf_of": null, "order": null, "outcome": { "network_status": "approved_by_network", "reason": null, "risk_level": "normal", "risk_score": 28, "seller_message": "Payment complete.", "type": "authorized" }, "paid": true, "payment_intent": "pi_3KrTaJGItx6TnYh40knkd00a", "payment_method": "pm_1KrQ6SGItx6TnYh4JZhcrfUf", "payment_method_details": { "card": { "brand": "visa", "checks": { "address_line1_check": "pass", "address_postal_code_check": "pass", "cvc_check": null }, "country": "US", "exp_month": 4, "exp_year": 2024, "fingerprint": "qmmvbl4smAt9CiyM", "funding": "credit", "installments": null, "last4": "4242", "mandate": null, "moto": null, "network": "visa", "three_d_secure": null, "wallet": null }, "type": "card" }, "receipt_email": null, "receipt_number": null, "receipt_url": "https://pay.stripe.com/receipts/acct_1FWLGKGItx6TnYh4/ch_3KrTaJGItx6TnYh40DF7p2wa/rcpt_LYalwGUSkp96IjEp7DhHza2x7HfNGZ9", "refunded": false, "refunds": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/charges/ch_3KrTaJGItx6TnYh40DF7p2wa/refunds" }, "review": null, "shipping": null, "source": null, "source_transfer": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "succeeded", "transfer_data": null, "transfer_group": null } ], "has_more": false, "total_count": 1, "url": "/v1/charges?payment_intent=pi_3KrTaJGItx6TnYh40knkd00a" }, "client_secret": "pi_3KrTaJGItx6TnYh40knkd00a_secret_rxA8VguDWuICXmKRm5BWT1SqS", "confirmation_method": "automatic", "created": 1650661211, "currency": "gbp", "customer": "cus_LYXAvIbNBuGxa0", "description": null, "invoice": null, "metadata": { "donationid": "0060C000009nzK6QAI", "cartid": "125e3117-8450-4918-5f1e-c48dc0852051", "paymentid": "a010C000004IoUWQA0" }, "on_behalf_of": null, "payment_method": "pm_1KrQ6SGItx6TnYh4JZhcrfUf", "payment_method_options": { "card": { "installments": null, "mandate_options": null, "network": null, "request_three_d_secure": "automatic" } }, "payment_method_types": [ "card" ], "processing": null, "receipt_email": null, "review": null, "setup_future_usage": null, "shipping": null, "source": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "transfer_data": null, "transfer_group": null }';
		 HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            200,
            RESPONSEE
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        Opportunity opp = [Select Id,currencyISOCode From Opportunity Limit 1];
        contact con = [SELECT Id,Gateway_Customer_Id__c FROM contact WHERE Email ='test@humanappeal.org.uk' limit 1];
        con.Gateway_Customer_Id__c='cus_LYSddy6vAr3B1u';
        update con;
        Test.startTest();
        pageReference stripePage = Page.StripeComponent;
        Test.setCurrentPage(stripePage);
        stripePage.getParameters().put('id',opp.Id);
        StripeController stripeInstance = new StripeController();
        stripeInstance.getCustomer();
       	Map<String,Object> retVal= StripeController.getDonationDetails(opp.Id);
        Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(payment_Reference__c='InternalWizard',Gateway_Customer_Reference__c='cus_L9pBaWHpg3gMYk',First_Payment_Taken__c=true,First_Payment_Amount__c=100,order_ID__c='pi_3KrNcNGItx6TnYh40JKc0AFW',Payment_Method_Id__c='pm_1KrNf3GItx6TnYh4Yvowfb8G', Authorisation_Date__c =SYSTEM.now(),RecordTypeId=Schema.SObjectType.Income_Card_Payment__c.getRecordTypeInfosByDeveloperName().get('Card_Payment').getRecordTypeId(),payment_Vendor__c='Stripe',Payment_Method_Type__c ='card',Opportunity__c = opp.Id, Contact__c = con.Id, Payment_Status__c = 'succeeded', Transaction_Type__c = 'Authorised');
        
        npe01__OppPayment__c paymentObject = new npe01__OppPayment__c();
        paymentObject.npe01__Opportunity__c =opp.Id;
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
        StripeController.savePaymentDetails(JSON.serialize(cardPayment),JSON.serialize(paymentObject));
        
        StripeController.getCurrencySymbolFromIso(opp.currencyISOCode);
        Test.stopTest();
    }
    testMethod static void unit_3(){
        String Response = '{ "id": "seti_1KtBH1GItx6TnYh4hgXk7p8c", "object": "setup_intent", "application": null, "cancellation_reason": null, "client_secret": "seti_1KtBH1GItx6TnYh4hgXk7p8c_secret_LaLyWBAIOEoVDw66ZuDY149GfK4CQrn", "created": 1651067479, "customer": "cus_LZzsC0HRtbQXyh", "description": null, "last_setup_error": null, "latest_attempt": "setatt_1KtBHXGItx6TnYh4Nqq5rXgQ", "livemode": false, "mandate": null, "metadata": { "donationid": "0060C000009qmH0QAI", "cartid": "b2d6de4e-495b-1c34-00c0-973d06b8fa211", "donorid": "0030C00000QMQgKQAX", "internalwizard": "true" }, "next_action": null, "on_behalf_of": null, "payment_method": "pm_1KtBHPGItx6TnYh4ejBaNYhs", "payment_method_options": { "card": { "mandate_options": null, "request_three_d_secure": "automatic" } }, "payment_method_types": [ "card" ], "single_use_mandate": null, "status": "succeeded", "usage": "off_session" }';
    	HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            200,
            Response
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        Test.startTest();
        StripeController.confirmPaymentDetails(true,'pm_1KtBHPGItx6TnYh4ejBaNYhs', 'seti_1KtBH1GItx6TnYh4hgXk7p8c', 'UK');
        StripeController.confirmPaymentDetails(false,'pm_1KtBHPGItx6TnYh4ejBaNYhs', 'seti_1KtBH1GItx6TnYh4hgXk7p8c', 'UK');
        Test.stopTest();
    }
}