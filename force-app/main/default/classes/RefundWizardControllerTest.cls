@isTest
public with sharing class RefundWizardControllerTest { 
    private static Opportunity testOpp;

    @isTest static void testGetDonationPayments() 
    {
        createTestData();
		Test.startTest();
        RefundWizardController.DonationWrapper wrapper = RefundWizardController.getDonationPayments(testOpp.Id);

        System.assertEquals(testOpp.Id, wrapper.donation.Id);
        Test.stopTest();
    }

    @isTest static void testCashRefund() 
    {
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
		Boolean isNpspTriggerDisabled = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>());
        createTestData();
        
        RefundWizardController.DonationWrapper wrapper = new RefundWizardController.DonationWrapper();
        wrapper.refundType = 'Cash';
        wrapper.refunds = new List<RefundWizardController.RefundWrapper>();

        RefundWizardController.RefundWrapper refundWrapper = new RefundWizardController.RefundWrapper(); 
        refundWrapper.checked = true;
        refundWrapper.refundPaid = true;
        refundWrapper.payment = new npe01__OppPayment__c(npe01__Opportunity__c = testOpp.Id, 
                                                        npe01__Payment_Amount__c = 6.00);
        refundWrapper.refundAmount = 6.00;
        wrapper.refunds.add(refundWrapper);
        
        npsp__Allocation__c objAllocation = [SELECT Id,npsp__Opportunity__c,npsp__Amount__c,npsp__General_Accounting_Unit__c FROM npsp__Allocation__c LIMIT 1];
        
        List<RefundWizardController.AllocationWrapper> lstAlloWrapper = new List<RefundWizardController.AllocationWrapper>{new RefundWizardController.AllocationWrapper(objAllocation,3.00)};
        lstAlloWrapper.add(new RefundWizardController.AllocationWrapper(objAllocation,3.00));
        wrapper.allocations = lstAlloWrapper;
		
        Test.startTest();
        RefundWizardController.ResponseWrapper refund = RefundWizardController.insertRefunds(wrapper,'testTransacId','Entered by Mistake','Yes'); 
        
        wrapper = RefundWizardController.getDonationPayments(testOpp.Id);

        System.assertEquals(1, refund.paymentsList.Size());
        Test.stopTest();
    }

    @isTest static void testCreditDebitCardRefund() 
    {	
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
		Boolean isNpspTriggerDisabled = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>());
        
        createTestData();

        Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(Opportunity__c = testOpp.Id);
        insert cardPayment;

        Income_Card_Payment_History__c cardPaymentHistory = new Income_Card_Payment_History__c(Amount__c = 10.00, Income_Card_Payment__c = cardPayment.Id);
        insert cardPaymentHistory;

        npe01__OppPayment__c payment = new npe01__OppPayment__c(Card_Payment_History__c = cardPaymentHistory.Id, 
                                                                npe01__Opportunity__c = testOpp.Id, 
                                                                npe01__Payment_Amount__c = 10.00);
        insert payment;

        SmarterPay_Payment_Config__c paymentConfig = new SmarterPay_Payment_Config__c();
        paymentConfig.APIKey__c = '123456';
        paymentConfig.SmarterPay_User_Name__c = 'test';        
        paymentConfig.Standard_Refund__c = '/Refund';
        insert paymentConfig;

        String responseBody = '{"status":"successful","message":"","data":{"incomeCardPaymentHistoryId":"a0x260000028tEhAAI"}}';        
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        RefundWizardController.DonationWrapper wrapper = new RefundWizardController.DonationWrapper();
        wrapper.refundType = 'Card Payment';
        wrapper.refunds = new List<RefundWizardController.RefundWrapper>();
        wrapper.donation = testOpp;

        RefundWizardController.RefundWrapper refundWrapper = new RefundWizardController.RefundWrapper();
        refundWrapper.checked = true;
        refundWrapper.payment = payment;
        refundWrapper.refundPaid = false;
        refundWrapper.refundAmount = 10.00;
        wrapper.refunds.add(refundWrapper);
        
        npsp__Allocation__c objAllocation = [SELECT Id,npsp__Opportunity__c,npsp__Amount__c,npsp__General_Accounting_Unit__c FROM npsp__Allocation__c LIMIT 1];
        
        List<RefundWizardController.AllocationWrapper> lstAlloWrapper = new List<RefundWizardController.AllocationWrapper>{new RefundWizardController.AllocationWrapper(objAllocation,6.0)};
        
        wrapper.allocations = lstAlloWrapper;

        Test.startTest();
        RefundWizardController.ResponseWrapper refund = RefundWizardController.insertRefunds(wrapper,'','Entered by Mistake','Yes');
        Test.stopTest();
    }

    private static void createTestData()
    {
        Contact contact = new Contact();
        contact.Firstname = 'Name1';
        contact.Lastname = 'Name2';
        contact.Email = 'test@test.com';
        contact.MailingStreet = 'test';
        contact.MailingCity = 'test';
        contact.MailingPostalCode = 'test';
        contact.MailingState = 'test';  
        contact.MailingCountry = 'UK';
        insert contact;

        testOpp = new Opportunity();
        testOpp.Name = 'Test OPP';
        testOpp.CloseDate = Date.Today();
        testOpp.StageName = 'Prospecting';
        testOpp.Amount = 6;
        testOpp.CurrencyIsoCode = 'GBP';    
        testOpp.npsp__Primary_Contact__c = contact.Id;
        testOpp.Website_Code__c = 'UK';
        insert testOpp;
        
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name='foo');
        insert gau;
        
        npsp__Allocation__c amountAllo = new npsp__Allocation__c(npsp__Opportunity__c=testOpp.id, npsp__Amount__c = 3, npsp__General_Accounting_Unit__c = gau.id);
        insert amountAllo;
        
        npsp__Allocation__c amountAllo1 = new npsp__Allocation__c(npsp__Opportunity__c=testOpp.id, npsp__Amount__c = 3, npsp__General_Accounting_Unit__c = gau.id);
        insert amountAllo1;
    }
    
    
    @isTest static void getPickListValuesIntoListTest() {
        
        List<RefundWizardController.OptionsWrap> options = RefundWizardController.getPickListValuesIntoList('npe01__OppPayment__c','Reason_for_Refund__c');
        
        System.assertNotEquals(0, options.size());
    }
    
    
    @isTest static void testCreditDebitCardRefundFailure() 
    {	
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
		Boolean isNpspTriggerDisabled = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>());
        
        createTestData();

        Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(Opportunity__c = testOpp.Id);
        insert cardPayment;

        Income_Card_Payment_History__c cardPaymentHistory = new Income_Card_Payment_History__c(Amount__c = 10.00, Income_Card_Payment__c = cardPayment.Id);
        insert cardPaymentHistory;

        npe01__OppPayment__c payment = new npe01__OppPayment__c(Card_Payment_History__c = cardPaymentHistory.Id, 
                                                                npe01__Opportunity__c = testOpp.Id, 
                                                                npe01__Payment_Amount__c = 10.00);
        insert payment;

        SmarterPay_Payment_Config__c paymentConfig = new SmarterPay_Payment_Config__c();
        paymentConfig.APIKey__c = '123456';
        paymentConfig.SmarterPay_User_Name__c = 'test';        
        paymentConfig.Standard_Refund__c = '/Refund';
        insert paymentConfig;

        String responseBody = '{"status":"failed","message":"Test Failure","data":{"incomeCardPaymentHistoryId":"a0x260000028tEhAAI"}}';        
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        RefundWizardController.DonationWrapper wrapper = new RefundWizardController.DonationWrapper();
        wrapper.refundType = 'Card Payment';
        wrapper.refunds = new List<RefundWizardController.RefundWrapper>();
        wrapper.donation = testOpp;

        RefundWizardController.RefundWrapper refundWrapper = new RefundWizardController.RefundWrapper();
        refundWrapper.checked = true;
        refundWrapper.payment = payment;
        refundWrapper.refundPaid = false;
        refundWrapper.refundAmount = 10.00;
        wrapper.refunds.add(refundWrapper);
        
        npsp__Allocation__c objAllocation = [SELECT Id,npsp__Opportunity__c,npsp__Amount__c,npsp__General_Accounting_Unit__c FROM npsp__Allocation__c LIMIT 1];
        
        List<RefundWizardController.AllocationWrapper> lstAlloWrapper = new List<RefundWizardController.AllocationWrapper>{new RefundWizardController.AllocationWrapper(objAllocation,6.0)};
        
        wrapper.allocations = lstAlloWrapper;

        Test.startTest();
        
        Boolean errorOccured = false;
        
        try {
            
            RefundWizardController.ResponseWrapper refund = RefundWizardController.insertRefunds(wrapper,'','Entered by Mistake','Yes');
        }
        catch(Exception Ex) {
          	errorOccured = true;
            System.assert(Ex.getMessage().contains('Script-thrown exception'));
        }
        
        System.assertEquals(true, errorOccured);
        Test.stopTest();
    }
    
}