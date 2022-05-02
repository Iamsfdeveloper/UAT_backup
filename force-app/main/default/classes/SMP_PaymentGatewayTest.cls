@isTest
private class SMP_PaymentGatewayTest {

    private static Opportunity opportunity;
    private static Contact contact;
    private static Income_Card_Payment__c cardPayment;
    private static Income_Card_Payment_History__c cardPaymentHistory;

    @isTest
    private static void setupTestData()
    {
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

        insert paymentConfig;
    }

    @isTest static void testGenerateMOTOCardPaymentURL() {
        setupTestData();

        SMP_PaymentGateway.Payment Payment = new SMP_PaymentGateway.Payment();

        String sagePayURL = SMP_PaymentGateway.generateCardPaymentURL(Payment, SMP_PaymentGateway.Gateway.SAGEPAYPI, SMP_PaymentGateway.PaymentType.MOTO);
        String globalPaymentsPayURL = SMP_PaymentGateway.generateCardPaymentURL(Payment, SMP_PaymentGateway.Gateway.GLOBALPAYMENTS, SMP_PaymentGateway.PaymentType.MOTO);
        String stripePayURL = SMP_PaymentGateway.generateCardPaymentURL(Payment, SMP_PaymentGateway.Gateway.STRIPE, SMP_PaymentGateway.PaymentType.MOTO);

        System.assert(sagePayURL.contains('/MOTO'));
        System.assert(globalPaymentsPayURL.contains('/MOTO'));
        System.assert(stripePayURL.contains('/MOTO'));
    }

    @isTest static void testGenerateECommerceCardPaymentURL() {
        setupTestData();

        SMP_PaymentGateway.Payment Payment = new SMP_PaymentGateway.Payment();
        
        String sagePayURL = SMP_PaymentGateway.generateCardPaymentURL(Payment, SMP_PaymentGateway.Gateway.SAGEPAYPI, SMP_PaymentGateway.PaymentType.Ecommerce);
        String globalPaymentsPayURL = SMP_PaymentGateway.generateCardPaymentURL(Payment, SMP_PaymentGateway.Gateway.GLOBALPAYMENTS, SMP_PaymentGateway.PaymentType.Ecommerce);
        String stripePayURL = SMP_PaymentGateway.generateCardPaymentURL(Payment, SMP_PaymentGateway.Gateway.STRIPE, SMP_PaymentGateway.PaymentType.Ecommerce);

        System.assert(sagePayURL.contains('/Ecommerce'));
        System.assert(globalPaymentsPayURL.contains('/Ecommerce'));
        System.assert(stripePayURL.contains('/Ecommerce'));
    }

    @isTest static void testGenerateDeferredUrl() {
        setupTestData();

        SMP_PaymentGateway.Payment Payment = new SMP_PaymentGateway.Payment();
        
        String sagePayURL = SMP_PaymentGateway.generateCardPaymentURL(Payment, SMP_PaymentGateway.Gateway.SAGEPAYPI, SMP_PaymentGateway.PaymentType.DeferredMOTO);
        String stripePayURL = SMP_PaymentGateway.generateCardPaymentURL(Payment,SMP_PaymentGateway.Gateway.STRIPE, SMP_PaymentGateway.PaymentType.DeferredEcommerce);

        System.assert(sagePayURL.contains('/DeferredCaptureMOTO'));
        System.assert(stripePayURL.contains('/DeferredCaptureEcommerce'));
    }

    @isTest static void testDoRepeatPayment() {
        setupTestData();

        String responseBody = '{"ProcessListNewDDFirstCollectionDateResult":[{"Error":"","FirstCollectionDate":"2019-01-06"}]}';        
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        SMP_PaymentGateway.RepeatPayment repeatPayment = new SMP_PaymentGateway.RepeatPayment();

        Test.startTest();
        SMP_PaymentGateway.doRepeatPayment(SMP_PaymentGateway.Gateway.STRIPE, repeatPayment);
        Test.stopTest();
    }

    @isTest static void testDoRefund() {
        setupTestData();

        String responseBody = '{"ProcessListNewDDFirstCollectionDateResult":[{"Error":"","FirstCollectionDate":"2019-01-06"}]}';        
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        
        SMP_PaymentGateway.Refund Refund = new SMP_PaymentGateway.Refund();

        Test.startTest();
        SMP_PaymentGateway.doRefund(SMP_PaymentGateway.Gateway.STRIPE, Refund);
        Test.stopTest();
    }

    @isTest static void testDoDeferredRelease() {
        setupTestData();

        String responseBody = '{"ProcessListNewDDFirstCollectionDateResult":[{"Error":"","FirstCollectionDate":"2019-01-06"}]}';        
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        SMP_PaymentGateway.DeferredRelease release = new SMP_PaymentGateway.DeferredRelease();

        Test.startTest();
        SMP_PaymentGateway.doDeferredRelease(SMP_PaymentGateway.Gateway.STRIPE, release);
        Test.stopTest();
    }

    @isTest static void testDoAuthenticateAuthoriseRelease() {
        setupTestData();

        String responseBody = '{"ProcessListNewDDFirstCollectionDateResult":[{"Error":"","FirstCollectionDate":"2019-01-06"}]}';        
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        SMP_PaymentGateway.AuthenticateAuthoriseRelease authorise = new SMP_PaymentGateway.AuthenticateAuthoriseRelease();

        Test.startTest();
        SMP_PaymentGateway.doAuthenticateAuthoriseRelease(SMP_PaymentGateway.Gateway.STRIPE, authorise);
        Test.stopTest();
    }

    @isTest static void testGetGatewayEnumByPaymentVendor() {
        SMP_PaymentGateway.Gateway response = SMP_PaymentGateway.getGatewayEnumByPaymentVendor('Globalpay');
        System.assertEquals(SMP_PaymentGateway.Gateway.GLOBALPAYMENTS, response);
        response = SMP_PaymentGateway.getGatewayEnumByPaymentVendor('SagePayPi');
        System.assertEquals(SMP_PaymentGateway.Gateway.SAGEPAYPI, response);
        response = SMP_PaymentGateway.getGatewayEnumByPaymentVendor('Stripe');
        System.assertEquals(SMP_PaymentGateway.Gateway.STRIPE, response);

        response = SMP_PaymentGateway.getGatewayEnumByPaymentVendor('');
        System.assertEquals(null, response);
    }

    @isTest static void testGetNextRepeatPaymentDate_Monthly() {
        Date response = SMP_PaymentGateway.getNextRepeatPaymentDate('1', 'Monthly', '1', Date.Today(), null);
        System.assertEquals(Date.Today().addMonths(1).toStartOfMonth(), response);
    }

    @isTest static void testGetNextRepeatPaymentDate_Weekly() {
        Date response = SMP_PaymentGateway.getNextRepeatPaymentDate('1', 'Weekly', '1', Date.Today(), null);
        System.assertEquals(Date.Today().addDays(7), response);
    }

    @isTest static void testGetNextRepeatPaymentDate_Daily() {
        Date response = SMP_PaymentGateway.getNextRepeatPaymentDate('1', 'Daily', '1', Date.Today(), null);
        System.assertEquals(Date.Today().addDays(1), response);

        response = SMP_PaymentGateway.getNextRepeatPaymentDate('3', 'Daily', '1', Date.Today(), null);
        System.assertEquals(Date.Today().addDays(3), response);
    }
}