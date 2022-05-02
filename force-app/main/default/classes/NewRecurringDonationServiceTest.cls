/**
* @File Name          : NewRecurringDonationServiceTest.cls
* @Description        :
* @Author             : agentgill
* @Group              :
* @Last Modified By   : agentgill
* @Last Modified On   : 07-05-2020
* @Modification Log   :
* Ver       Date            Author      		    Modification
* 1.0    12/06/2020   agentgill     Initial Version
**/
@isTest
public  class NewRecurringDonationServiceTest {
    private static final string STAGE_PROCESSING_FAILED = 'Processing Failed';
    private static final string STAGE_PLEDGE = 'Pledge';
    
    @TestSetup
    static void makeData() {
        List<Contact> contacts = (List<Contact>) TestFactory.createSObjectList(
            new Contact(Gift_Aid_Status__c='Yes'),
            1,
            true
        );
        Opportunity opp = new Opportunity(npsp__Primary_Contact__c = contacts[0].Id);
        opp.Name = 'testOpp';
        opp.Amount = 100;
        opp.StageName = 'Pledge';
        opp.CloseDate = Date.Today();
		opp.Regional_Office_code__c='UK';
        insert opp;        
        List<npe03__Recurring_Donation__c> rds = new List<npe03__Recurring_Donation__c>();
         Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(Payment_Method_Id__c = 'pm_1EUmyr2x6R10KRrhlYS3l97f',Payment_Method_Type__c='card',Opportunity__c = opp.Id, Contact__c = opp.npsp__Primary_Contact__c, Payment_Status__c = 'Created', Transaction_Type__c = 'Sale',Gateway_Customer_Reference__c='cus_IXaICGcDMa0FK9');
            insert cardPayment;
        for (Contact c : [
            SELECT Id, AccountId
            FROM Contact
            WHERE MailingCountry= 'test@humanappeal.org.uk.test'
        ]) {
            npe03__Recurring_Donation__c rd = (npe03__Recurring_Donation__c) TestFactory.createSObject(
                new npe03__Recurring_Donation__c(
                    npe03__Contact__c = c.Id,
                    npe03__Amount__c = 100,
                    npsp__StartDate__c = Date.today(),
                    npe03__Date_Established__c = Date.today(),
                    npsp__PaymentMethod__c = 'Card Payment',
                    npsp__Day_of_Month__c = String.valueOf(Date.today().day()),
					card_Payment_detail__c =cardPayment.Id,
					Regional_Office_code__c='UK',
					Donation_type__c = 'RD'
                ),
                'TestFactoryDefaults.RDDefaults'
            );
            rds.add(rd);
        }
        for (Contact c : [
            SELECT Id, AccountId
            FROM Contact
            WHERE MailingCountry= 'test@humanappeal.org.uk.test'
        ]) {
            
            npe03__Recurring_Donation__c rd = (npe03__Recurring_Donation__c) TestFactory.createSObject(
                new npe03__Recurring_Donation__c(
                    Opportunity__c=opp.ID,
                    npe03__Contact__c = c.Id,
                    npe03__Amount__c = 100,
                    npsp__StartDate__c = Date.today(),
                    npe03__Date_Established__c = Date.today(),
                    npsp__PaymentMethod__c = 'Card Payment',
                    npsp__Day_of_Month__c = String.valueOf(Date.today().day()),
                    Regional_Office_code__c='UK',
					Donation_type__c = 'RD'	
                ),
                'TestFactoryDefaults.RDDefaults'
            );
            rds.add(rd);
        }
        insert rds;
    }
    @isTest
    private static void giftAidPositive() {
        Test.startTest();
        for (Contact c : [
            SELECT Id, AccountId
            FROM Contact
            WHERE MailingCountry= 'test@humanappeal.org.uk.test'
        ]) {
            Insert new Gift_Aid_Declaration__c(Active__c=true,Gift_Aid_Status__c='Yes',Gift_Aid_Effective_Date__c=System.Today(),Donor__c=c.Id,Gift_Aid_Source__c='Verbal',Gift_Aid_Start_Date__c=System.today());
        }
        Test.stopTest();
    }
    /**
* @description Positive Test
* @author agentgill | 12/06/2020
* @return void
**/
    @isTest
    private static void testMyBatchPositive() {
        String RESPONSEE='{ "id": "pi_3KTyyaGItx6TnYh40Z0vXcU4", "object": "payment_intent", "last_payment_error": null, "livemode": false, "next_action": null, "status": "succeeded", "amount": 571, "amount_capturable": 0, "amount_received": 571, "application": null, "application_fee_amount": null, "automatic_payment_methods": null, "canceled_at": null, "cancellation_reason": null, "capture_method": "automatic", "charges": { "object": "list", "data": [ { "id": "ch_3KTyyaGItx6TnYh40Y8OsB73", "object": "charge", "amount": 571, "amount_captured": 571, "amount_refunded": 0, "application": null, "application_fee": null, "application_fee_amount": null, "balance_transaction": "txn_3KTyyaGItx6TnYh406Zr8HLw", "billing_details": { "address": { "city": null, "country": null, "line1": null, "line2": null, "postal_code": "42424", "state": null }, "email": "iamsfdeveloper+12@gmail.com", "name": "Arshadulla Shariff", "phone": null }, "calculated_statement_descriptor": "HUMAN APPEAL", "captured": true, "created": 1645062008, "currency": "gbp", "customer": "cus_LAJ2UBhUekGFBG", "description": null, "destination": null, "dispute": null, "disputed": false, "failure_code": null, "failure_message": null, "fraud_details": { }, "invoice": null, "livemode": false, "metadata": { "donationid": "0060C0000091VCSQA2", "cardid": "ad33eb0a-122b-48d6-2044-a71b17a3af6c", "paymentId": "a010C000003z4b9QAA" }, "on_behalf_of": null, "order": null, "outcome": { "network_status": "approved_by_network", "reason": null, "risk_level": "normal", "risk_score": 43, "seller_message": "Payment complete.", "type": "authorized" }, "paid": true, "payment_intent": "pi_3KTyyaGItx6TnYh40Z0vXcU4", "payment_method": "pm_1KTyQeGItx6TnYh4j9mcU0LN", "payment_method_details": { "card": { "brand": "visa", "checks": { "address_line1_check": null, "address_postal_code_check": "pass", "cvc_check": null }, "country": "US", "exp_month": 4, "exp_year": 2024, "fingerprint": "qmmvbl4smAt9CiyM", "funding": "credit", "installments": null, "last4": "4242", "moto": null, "network": "visa", "three_d_secure": null, "wallet": null }, "type": "card" }, "receipt_email": null, "receipt_number": null, "receipt_url": "https://pay.stripe.com/receipts/acct_1FWLGKGItx6TnYh4/ch_3KTyyaGItx6TnYh40Y8OsB73/rcpt_LAJbeqVgqBmpWiS7ZBXzlZxBTVGmLEb", "refunded": false, "refunds": { "object": "list", "data": [ ], "has_more": false, "total_count": 0, "url": "/v1/charges/ch_3KTyyaGItx6TnYh40Y8OsB73/refunds" }, "review": null, "shipping": null, "source": null, "source_transfer": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "status": "succeeded", "transfer_data": null, "transfer_group": null } ], "has_more": false, "total_count": 1, "url": "/v1/charges?payment_intent=pi_3KTyyaGItx6TnYh40Z0vXcU4" }, "client_secret": "pi_3KTyyaGItx6TnYh40Z0vXcU4_secret_iP0I76tVMHTOjSfgy7azPTWig", "confirmation_method": "automatic", "created": 1645062008, "currency": "gbp", "customer": "cus_LAJ2UBhUekGFBG", "description": null, "invoice": null, "metadata": { "donationid": "0060C0000091VCSQA2", "cardid": "ad33eb0a-122b-48d6-2044-a71b17a3af6c", "paymentId": "a010C000003z4b9QAA" }, "on_behalf_of": null, "payment_method": "pm_1KTyQeGItx6TnYh4j9mcU0LN", "payment_method_options": { "card": { "installments": null, "network": null, "request_three_d_secure": "automatic" } }, "payment_method_types": [ "card" ], "processing": null, "receipt_email": null, "review": null, "setup_future_usage": null, "shipping": null, "source": null, "statement_descriptor": null, "statement_descriptor_suffix": null, "transfer_data": null, "transfer_group": null }';
        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            200,
            RESPONSEE
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        
        Test.startTest();
        
        NewRecurringDonationService myBatch = new NewRecurringDonationService();
        Database.executeBatch(myBatch);
        Test.stopTest();
        
        System.assertEquals(
            STAGE_PLEDGE,
            [SELECT Id, StageName FROM Opportunity LIMIT 1]
            .StageName,
            'Something went wrong'
        );
    }
   
}