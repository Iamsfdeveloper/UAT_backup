@isTest
public with sharing class SMP_DDServiceHandlerTest
{
    @isTest
    private static void GetNextCollectionDate() {
        SMP_DDServiceNextCollectionModel model = new SMP_DDServiceNextCollectionModel();
        String responseBody = '{"ProcessNewDDFirstCollectionDateResult":{"FirstCollectionDate":"11/05/2017","Error":""}}';
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SMP_DDServiceNextCollectionModel response = SMP_DDServiceHandler.getNextCollectionDate('1', Date.Today(), 'Monthly', '5');
        Test.stopTest();
        System.assertEquals('11/05/2017', response.ProcessNewDDFirstCollectionDateResult.FirstCollectionDate);
    }
    @isTest
    private static void GetNextCollectionDateWrapper() {
        SMP_DDServiceNextCollectionModel model = new SMP_DDServiceNextCollectionModel();
        String responseBody = '{"ProcessNewDDFirstCollectionDateResult":{"FirstCollectionDate":"11/05/2017","Error":""}}';
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        SMP_DDServiceHandler.SingleCollectionDateWrapper collectionWrapper = new SMP_DDServiceHandler.SingleCollectionDateWrapper();
        collectionWrapper.CollectionDay = '1';
        collectionWrapper.StartDate = string.valueOf(Date.today());
        collectionWrapper.CollectionPeriod = 'Monthly';
        collectionWrapper.NumberOfDaysToWaitFromNewInstruction = '5';
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SMP_DDServiceNextCollectionModel response = SMP_DDServiceHandler.getNextCollectionDate(collectionWrapper);
        Test.stopTest();
        System.assertEquals('11/05/2017', response.ProcessNewDDFirstCollectionDateResult.FirstCollectionDate);
    }
    @isTest
    private static void GetNextCollectionDateList() {
        SMP_DDServiceNextCollectionModelList model = new SMP_DDServiceNextCollectionModelList();
        String responseBody = '{"ProcessListNewDDFirstCollectionDateResult":[{"Error":"","FirstCollectionDate":"11/05/2017"},{"Error":"","FirstCollectionDate":"11/05/2017"}]}';
        
        List<SMP_DDServiceHandler.ListCollectionDateWrapper> cdWrapperList = new List<SMP_DDServiceHandler.ListCollectionDateWrapper>();
        SMP_DDServiceHandler.ListCollectionDateWrapper cdWrapperObject1 = new SMP_DDServiceHandler.ListCollectionDateWrapper();
        cdWrapperObject1.sd = string.valueOf(Date.today());
        cdWrapperList.add(cdWrapperObject1);

        SMP_DDServiceHandler.ListCollectionDateWrapper cdWrapperObject2 = new SMP_DDServiceHandler.ListCollectionDateWrapper();
        cdWrapperObject2.sd = string.valueOf(Date.today().addMonths(1));
        cdWrapperList.add(cdWrapperObject2);
        SMP_DDServiceHandler.ListCollectionDateBaseWrapper cdWrapper = new SMP_DDServiceHandler.ListCollectionDateBaseWrapper(cdWrapperList, 'Monthly', '5', '1');

        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SMP_DDServiceNextCollectionModelList response = SMP_DDServiceHandler.getNextCollectionDate(cdWrapper);
        Test.stopTest();
        System.assertEquals('11/05/2017', response.ProcessListNewDDFirstCollectionDateResult[0].FirstCollectionDate);
    }
    @isTest
    private static void GetNextCollectionDate_ErrorInCallout() {
        String responseBody = '{"ProcessNewDDFirstCollectionDateResult":{"FirstCollectionDate":"11/05/2017","Error":""}}';
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(300, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SMP_DDServiceNextCollectionModel response = SMP_DDServiceHandler.getNextCollectionDate('1', Date.Today(), 'Monthly', '5');
        Test.stopTest();
        System.assertEquals('Error Calling SmarterPay Service. 300 null', response.ProcessNewDDFirstCollectionDateResult.Error);
    }
    @isTest
    private static void GetBankDetails() {
        SmarterPay_Direct_Debit_Settings__c config = new SmarterPay_Direct_Debit_Settings__c(Bank_Account_Checker_Endpoint__c = 'www.test.com',
                                                                                            User_Id__c = '123456');
        insert config;
        
        String responseBody = '{"ProcessMessageResult":{"BankName":"COUTTS & CO","BranchTitle":"STRAND","SortCodeOK":true,"DirectDebitsOK":true,"AccountCodeOK":true,"BankAddress1":"Test1","BankAddress2":"Test2","BankAddress3":"Test3","BankAddress4":"Test4" }}';
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.startTest();
        SMP_DDServiceBankAccountModel response = SMP_DDServiceHandler.getBankDetails('110011', '12345678');
        Test.stopTest();
        System.assertEquals('COUTTS & CO', response.ProcessMessageResult.BankName);
    }
    @isTest
    private static void testListParse() {
        String json = '{\"ProcessListNewDDFirstCollectionDateResult\":[{\"Error\":\"\",\"FirstCollectionDate\":\"2019-12-02\"},{\"Error\":\"\",\"FirstCollectionDate\":\"2020-01-02\"},{\"Error\":\"\",\"FirstCollectionDate\":\"2020-02-03\"},{\"Error\":\"\",\"FirstCollectionDate\":\"2020-03-02\"},{\"Error\":\"\",\"FirstCollectionDate\":\"2020-04-01\"},{\"Error\":\"\",\"FirstCollectionDate\":\"2020-05-01\"},{\"Error\":\"\",\"FirstCollectionDate\":\"2020-06-01\"},{\"Error\":\"\",\"FirstCollectionDate\":\"2020-07-01\"},{\"Error\":\"\",\"FirstCollectionDate\":\"2020-08-03\"},{\"Error\":\"\",\"FirstCollectionDate\":\"2020-09-01\"},{\"Error\":\"\",\"FirstCollectionDate\":\"2020-10-01\"},{\"Error\":\"\",\"FirstCollectionDate\":\"2020-11-02\"},{\"Error\":\"\",\"FirstCollectionDate\":\"2020-12-01\"},{\"Error\":\"\",\"FirstCollectionDate\":\"2021-01-01\"}]}';
        SMP_DDServiceNextCollectionModelList obj = SMP_DDServiceNextCollectionModelList.parse(json);
        System.assert(obj != null);
    }
}