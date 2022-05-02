@isTest
public with sharing class TriggerHandler_DirectDebitTest
{
    @TestSetup
    static void makeData() {
        TriggerSettings__c triggersettings = new TriggerSettings__c();
        triggersettings.Direct_Debit_History_Trigger__c = true;
        triggersettings.Payment_Schedule_Trigger__c = false;
        triggersettings.Direct_Debit_Trigger__c = true;
        insert triggersettings;
    }

    @isTest static void testPaymentScheduleConnected() {
        
        Contact member = new Contact();
        member.FirstName = 'testFirst';
        member.LastName = 'testLast';
        member.Email = 'test@test.com';
        member.MailingStreet = 'test';
        member.MailingCity = 'test';
        member.MailingPostalCode = 'test';
        member.MailingState = 'test';
        member.MailingCountry = 'UK';
        insert member;

        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
        opp.Amount = 5;
        opp.StageName = 'test';
        opp.CloseDate = Date.Today();
        opp.npsp__Primary_Contact__c = member.Id;
        insert opp;

        Test.startTest();

        npe03__Recurring_Donation__c rd = (npe03__Recurring_Donation__c) TestFactory.createSObject(
            new npe03__Recurring_Donation__c(
                npe03__Contact__c = member.Id,
                npe03__Amount__c = 100,
                npsp__StartDate__c = Date.today(),
                npsp__PaymentMethod__c = 'Direct Debit',
                npe03__Date_Established__c = Date.today(),
                npsp__Day_of_Month__c = String.valueOf(Date.today().day()),
                Opportunity__c = opp.Id
            ),
            'TestFactoryDefaults.RDDefaults'
        );
        insert rd;

        Income_Direct_Debit__c directDebit = new Income_Direct_Debit__c(Opportunity__c = opp.Id, Contact__c = member.Id, DD_Status__c = 'On Hold', DD_Bank_Account_Number__c = '00000000', DD_Bank_Sort_Code__c = '000000');
        insert directDebit;

        Test.stopTest();
    }
}