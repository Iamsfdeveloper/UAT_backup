@isTest
public with sharing class SMP_RefundControllerTest {
    @isTest static void testRefund() {
        SmarterPay_Payment_Config__c paymentConfig = new SmarterPay_Payment_Config__c();
        paymentConfig.APIKey__c = '123456';
        paymentConfig.SmarterPay_User_Name__c = 'test';
        
        paymentConfig.Standard_Refund__c = '/Refund';

        insert paymentConfig;

        String responseBody = '{"ProcessListNewDDFirstCollectionDateResult":[{"Error":"","FirstCollectionDate":"2019-01-06"}]}';        
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(Payment_Status__c = 'Created', Transaction_Type__c = 'Sale', Payment_Vendor__c = 'Stripe');
        insert cardPayment;        

        Income_Card_Payment_History__c cardPaymentHistory = new Income_Card_Payment_History__c(Income_Card_Payment__c = cardPayment.Id, Amount__c = 5, Payment_Status__c = 'Successful', Transaction_Type__c = 'Sale', Transaction_Date__c = Date.Today());
        insert cardPaymentHistory;  

        List<Income_Card_Payment_History__c> response = SMP_RefundController.fetchIncomeCardPaymentHistory(cardPayment.Id);

        Map<Id, Decimal> refundsByHistory = new Map<Id, Decimal>();
        refundsByHistory.put(cardPaymentHistory.Id, 5);

        Test.startTest();
        Map<String, SMP_PaymentGateway.RefundResponse> refundResponse = SMP_RefundController.executeRefundByHistory(refundsByHistory);
        Test.stopTest();
    }
}