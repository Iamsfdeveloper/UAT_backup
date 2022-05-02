@isTest
private class SMP_PaymentScheduleHelperTest {
    /* private static Opportunity opportunity;
    private static Contact contact;

    private static void setupConfig()
    {
        String responseBody = '{"ProcessListNewDDFirstCollectionDateResult":[{"Error":"","FirstCollectionDate":"2019-01-06"}]}';
        
        HttpRestCallOutMock fakeResponse = new HttpRestCallOutMock(200, responseBody);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        opportunity = new Opportunity();
        opportunity.Name = 'testOpp';
        opportunity.Amount = 5;
        opportunity.StageName = 'test';
        opportunity.CloseDate = Date.Today();
        insert opportunity;

        contact = new Contact();
        contact.FirstName = 'TestFirst';
        contact.LastName = 'TestLast';
        insert contact;
    }

    @isTest static void testCalculatePaymentSchedulesFuture_DirectDebit() {
        setupConfig();

        Income_Direct_Debit__c dd = new Income_Direct_Debit__c(Opportunity__c = opportunity.Id, DD_Status__c = 'New Instruction', 
                                                                DD_Collection_Period__c = 'Monthly', DD_Start_Date__c = Date.today(),
                                                                DD_Bank_Account_Number__c = '00000000', DD_Bank_Sort_Code__c = '000000');
        insert dd;

        Test.startTest();
        SMP_PaymentScheduleHelper.calculatePaymentSchedulesFuture(new Set<Id>{opportunity.Id});
        Test.stopTest();

        List<Payment_Schedule__c> schedules = [SELECT Id FROM Payment_Schedule__c WHERE Opportunity__c = :opportunity.Id];

        System.assertEquals(12, schedules.Size());
    }

    @isTest static void testCalculatePaymentSchedulesFuture_CardPayment() {
        setupConfig();

        Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(Opportunity__c = opportunity.Id, RP_Enabled__c = true, 
                                                                        RP_Frequency__c = 'Monthly', RP_Start_Date__c = Date.today(), 
                                                                        RP_Collection_Day__c = '1');
        insert cardPayment;

        Test.startTest();
        SMP_PaymentScheduleHelper.calculatePaymentSchedulesFuture(new Set<Id>{opportunity.Id});
        Test.stopTest();

        List<Payment_Schedule__c> schedules = [SELECT Id FROM Payment_Schedule__c WHERE Opportunity__c = :opportunity.Id];

        System.assertEquals(12, schedules.Size());
    }

    @isTest static void testCalculateDirectDebitPaymentSchedules_MonthlyNoEndDate() {
        setupConfig();

        Test.startTest();
        List<Payment_Schedule__c> schedules = SMP_PaymentScheduleHelper.calculateDirectDebitPaymentSchedules(opportunity, new List<npsp__Allocation__c>(), null, Date.today(), null);
        Test.stopTest();

        System.assertEquals(12, schedules.Size());
    }

    @isTest static void testCalculateDirectDebitPaymentSchedules_MonthlyWithEndDate() {
        setupConfig();

        Test.startTest();
        List<Payment_Schedule__c> schedules = SMP_PaymentScheduleHelper.calculateDirectDebitPaymentSchedules(opportunity, new List<npsp__Allocation__c>(), null, Date.today(), Date.today().addMonths(6));
        Test.stopTest();

        if(Date.today().day() > 12){
            System.assertEquals(5, schedules.Size());
        }
        else{
            System.assertEquals(6, schedules.Size());
        }
        
    }

    @isTest static void testCalculateCardPaymentPaymentSchedules_MonthlyNoEndDate() {
        setupConfig();

        Test.startTest();
        List<Payment_Schedule__c> schedules = SMP_PaymentScheduleHelper.calculateCardPaymentSchedules(opportunity, new List<npsp__Allocation__c>(), null, Date.today(), null, '1', 'Monthly');
        Test.stopTest();

        System.assertEquals(12, schedules.Size());
    }

    @isTest static void testCalculateCardPaymentPaymentSchedules_MonthlyWithEndDate() {
        setupConfig();

        Test.startTest();
        List<Payment_Schedule__c> schedules = SMP_PaymentScheduleHelper.calculateCardPaymentSchedules(opportunity, new List<npsp__Allocation__c>(), null, Date.today(), Date.today().addMonths(6), '1', 'Monthly');
        Test.stopTest();

        System.assertEquals(7, schedules.Size());
    }

    @isTest static void testCalculateCardPaymentPaymentSchedules_DailyNoEndDate() {
        setupConfig();

        Test.startTest();
        List<Payment_Schedule__c> schedules = SMP_PaymentScheduleHelper.calculateCardPaymentSchedules(opportunity, new List<npsp__Allocation__c>(), null, Date.today(), null, '1', 'Daily');
        Test.stopTest();

        System.assertEquals(12, schedules.Size());
    }

    @isTest static void testCalculateCardPaymentPaymentSchedules_DailyWithEndDate() {
        setupConfig();

        Test.startTest();
        List<Payment_Schedule__c> schedules = SMP_PaymentScheduleHelper.calculateCardPaymentSchedules(opportunity, new List<npsp__Allocation__c>(), null, Date.today(), Date.today().addDays(2), '1', 'Daily');
        Test.stopTest();

        System.assertEquals(3, schedules.Size());
    }

    @isTest static void testCheckRecurringPayment_WithDD() {
        setupConfig();

        List<Payment_Schedule__c> schedules = new List<Payment_Schedule__c>();
        schedules.add(new Payment_Schedule__c(Opportunity__c = opportunity.Id, Amount__c = 5, Schedule_Date__c = Date.today().addMonths(1), Status__c = 'Outstanding'));
        schedules.add(new Payment_Schedule__c(Opportunity__c = opportunity.Id, Amount__c = 10, Schedule_Date__c = Date.today().addMonths(2), Status__c = 'Outstanding'));
        insert schedules;

        Income_Direct_Debit__c dd = new Income_Direct_Debit__c(Opportunity__c = opportunity.Id, DD_Status__c = 'New Instruction', 
                                                                DD_Collection_Period__c = 'Monthly', DD_Start_Date__c = Date.today(),
                                                                DD_Bank_Account_Number__c = '00000000', DD_Bank_Sort_Code__c = '000000');
        insert dd;

        Test.startTest();
        SMP_PaymentScheduleHelper.checkRecurringPayment(new Set<Id>{opportunity.Id});
        Test.stopTest();

        dd = [SELECT Id, DD_First_Collection_Date__c, DD_First_Collection_Amount__c, DD_Ongoing_Collection_Amount__c, DD_Next_Collection_Date__c, Opportunity__c, DD_Status__c FROM Income_Direct_Debit__c WHERE Id = :dd.Id];
        
        System.assertEquals(schedules[0].Amount__c, dd.DD_First_Collection_Amount__c);
        System.assertEquals(schedules[0].Schedule_Date__c, dd.DD_First_Collection_Date__c);
        System.assertEquals(schedules[0].Amount__c, dd.DD_Ongoing_Collection_Amount__c);
        System.assertEquals(schedules[0].Schedule_Date__c, dd.DD_Next_Collection_Date__c);

        schedules[0].Status__c = 'Paid';
        update schedules;

        dd = SMP_PaymentScheduleHelper.checkDirectDebit(new List<Income_Direct_Debit__c>{dd})[0];

        System.assertEquals(schedules[1].Amount__c, dd.DD_First_Collection_Amount__c);
        System.assertEquals(schedules[1].Schedule_Date__c, dd.DD_First_Collection_Date__c);
        System.assertEquals(schedules[1].Amount__c, dd.DD_Ongoing_Collection_Amount__c);
        System.assertEquals(schedules[1].Schedule_Date__c, dd.DD_Next_Collection_Date__c);
    }

    @isTest static void testCheckRecurringPayment_WithCard() {
        setupConfig();

        List<Payment_Schedule__c> schedules = new List<Payment_Schedule__c>();
        schedules.add(new Payment_Schedule__c(Opportunity__c = opportunity.Id, Amount__c = 5, Schedule_Date__c = Date.today().addMonths(1), Status__c = 'Outstanding'));
        schedules.add(new Payment_Schedule__c(Opportunity__c = opportunity.Id, Amount__c = 10, Schedule_Date__c = Date.today().addMonths(2), Status__c = 'Outstanding'));
        insert schedules;

        Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(Opportunity__c = opportunity.Id, RP_Enabled__c = true, 
                                                                        RP_Frequency__c = 'Monthly', RP_Start_Date__c = Date.today(), 
                                                                        RP_Collection_Day__c = '1');
        insert cardPayment;

        SMP_PaymentScheduleHelper.checkRecurringPayment(new Set<Id>{opportunity.Id});

        cardPayment = [SELECT Id, RP_Amount__c, RP_Next_Payment_Date__c, RP_Enabled__c, Opportunity__c FROM Income_Card_Payment__c WHERE Id = :cardPayment.Id];

        System.assertEquals(schedules[0].Amount__c, cardPayment.RP_Amount__c);
        System.assertEquals(schedules[0].Schedule_Date__c, cardPayment.RP_Next_Payment_Date__c);

        schedules[0].Status__c = 'Paid';
        update schedules;

        cardPayment = SMP_PaymentScheduleHelper.checkRepeatCardPayment(new List<Income_Card_Payment__c>{cardPayment})[0];

        System.assertEquals(schedules[1].Amount__c, cardPayment.RP_Amount__c);
        System.assertEquals(schedules[1].Schedule_Date__c, cardPayment.RP_Next_Payment_Date__c);
    } */
}