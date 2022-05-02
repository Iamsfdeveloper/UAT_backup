@isTest
public class SMP_RepeatPaymentSchedulerTest {
    
    private static Opportunity opportunity;
    private static Contact contact;

    private static void setupConfig()
    {
        opportunity = new Opportunity();
        opportunity.Name = 'testOpp';
        opportunity.Amount = 5;
        opportunity.StageName = 'test';
        opportunity.CloseDate = Date.Today();
        insert opportunity;

        contact = new Contact();
        contact.FirstName = 'TestFirst';
        contact.LastName = 'TestLast';
        contact.Email = 'test@test.com';
        contact.MailingStreet = 'test';
        contact.MailingCity = 'test';
        contact.MailingPostalCode = 'test';
        contact.MailingState = 'test';  
        contact.MailingCountry = 'UK';
        insert contact;

        SmarterPay_Payment_Config__c paymentConfig = new SmarterPay_Payment_Config__c();
        paymentConfig.APIKey__c = '123456';
        paymentConfig.SmarterPay_User_Name__c = 'test';
        
        paymentConfig.Standard_MOTO__c = '/MOTO';
        paymentConfig.Standard_Ecommerce__c = '/Ecommerce';
        paymentConfig.Standard_Repeat__c = '/Repeat';
        paymentConfig.Standard_Refund__c = '/Refund';
        paymentConfig.Standard_Deferred_Capture_MOTO__c = '/DeferredCaptureMOTO';
        paymentConfig.Standard_Deferred_Capture_Ecommerce__c = '/DeferredCaptureEcommerce';
        paymentConfig.Standard_Deferred_Release__c = '/DeferredRelease'; 
        paymentConfig.Standard_Authenticate_Capture_MOTO__c = '/AuthenticateCaptureMOTO'; 
        paymentConfig.Standard_Authenticate_Capture_Ecommerce__c = '/AuthenticateCaptureEcommerce'; 
        paymentConfig.Standard_Authenticate_Release__c = '/AuthenticateRelease'; 

        paymentConfig.Manage_Repeat_Payment_Dates__c = false;

        insert paymentConfig;
    }  

    @isTest static void testRepeat_ManageNextPaymentDates() {
        setupConfig();

        /* Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(Opportunity__c = opportunity.Id, Contact__c = contact.Id, Transaction_Type__c = 'Sale', Payment_Vendor__c = 'Stripe', 
                                                                        Transaction_ID__c = '1234', Gateway_Customer_Reference__c = '1234', Payment_Status__c = 'Successful',
                                                                        RP_Stretch__c = '1', RP_Collection_Day__c = '1', RP_Start_Date__c = Date.Today(), RP_Next_Payment_Date__c = Date.Today(),
                                                                        RP_Frequency__c = 'Daily', RP_Enabled__c = true, RP_Description__c = 'test', RP_Amount__c = 5);
        insert cardPayment;

        String responseBody = '{"response":[{"status":"success","message":""}]}';        
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse); */
        
        Test.StartTest();
        SMP_RepeatPaymentScheduler sched = new SMP_RepeatPaymentScheduler();
        sched.execute(null);
        Test.StopTest();        
    }
}