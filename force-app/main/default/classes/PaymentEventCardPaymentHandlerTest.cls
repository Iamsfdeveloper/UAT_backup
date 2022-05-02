/**
 * @description       : Apex Test for PaymentEventCardPaymentHandler
 * @author            : agentgill
 * @group             :
 * @last modified on  : 07-11-2020
 * @last modified by  : agentgill
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   07-05-2020   agentgill   Initial Version
 **/
@isTest
public with sharing class PaymentEventCardPaymentHandlerTest {
    @TestSetup
    static void makeData() {
        List<Contact> contacts = (List<Contact>) TestFactory.createSObjectList(
            new Contact(Email = 'test@test.com'),
            1,
            true
        );

        List<npe03__Recurring_Donation__c> rds = new List<npe03__Recurring_Donation__c>();

        for (Contact c : [
            SELECT Id, AccountId
            FROM Contact
            WHERE Id IN :contacts
        ]) {
            npe03__Recurring_Donation__c rd = (npe03__Recurring_Donation__c) TestFactory.createSObject(
                new npe03__Recurring_Donation__c(
                    npe03__Contact__c = c.Id,
                    npe03__Amount__c = 100,
                    npsp__StartDate__c = Date.today(),
                    npsp__PaymentMethod__c = 'Card Payment',
                    npe03__Date_Established__c = Date.today(),
                    npsp__Day_of_Month__c = String.valueOf(Date.today().day())
                ),
                'TestFactoryDefaults.RDDefaults'
            );
            rds.add(rd);
        }

        insert rds;

        TriggerSettings__c triggersettings = new TriggerSettings__c();
        triggersettings.Card_Payment_History_Trigger__c = true;
        triggersettings.Card_Payment_Trigger__c = true;
        triggersettings.Payment_Schedule_Trigger__c = false;
        insert triggersettings;
    }

    /**
     * @description Test Successful Card Payment
     * @author agentgill | 07-05-2020
     **/
    @isTest
    private static void testSuccessfulProcessCardPaymentEvent() {
        Opportunity opp = [
            SELECT Id, Name, StageName, AccountId, GUID__c
            FROM Opportunity
            LIMIT 1
        ];

        opp.GUID__c = 'TESTGUID';
        update opp;

        System.debug('!!! testOpp' + opp);
        Income_Card_Payment__c cp = new Income_Card_Payment__c(
            Opportunity__c = opp.Id,
            Payment_Status__c = 'Test',
            Transaction_Type__c = 'Authenticate',
            Gateway_Customer_Reference__c = 'Test',
            Payment_Method_Id__c='Test'
        );
        insert cp;
        System.debug('!!! cardPayment' + cp);

        Test.startTest();

        Income_Card_Payment_History__c cph = new Income_Card_Payment_History__c(
            Income_Card_Payment__c = cp.Id,
            Payment_Status__c = 'Successful',
            Payment_Status_Details__c = 'Successful payment',
            Internal_Payment_Description__c = opp.Id,
            Transaction_Type__c = 'Sale'
        );

        insert cph;

        Test.stopTest();

    }

    @isTest
    private static void testFailedProcessCardPaymentEvent() {
        Opportunity opp = [
            SELECT Id, Name, StageName, AccountId, GUID__c
            FROM Opportunity
            LIMIT 1
        ];

        opp.GUID__c = 'TESTGUID';
        update opp;

        System.debug('!!! testOpp' + opp);
        Income_Card_Payment__c cp = new Income_Card_Payment__c(
            Opportunity__c = opp.Id,
            Payment_Status__c = 'Test',
            Transaction_Type__c = 'Authenticate',
            Gateway_Customer_Reference__c = 'Test',
            Payment_Method_Id__c='Test'
        );
        insert cp;
        System.debug('!!! cardPayment' + cp);

        Test.startTest();

        Income_Card_Payment_History__c cph = new Income_Card_Payment_History__c(
            Income_Card_Payment__c = cp.Id,
            Payment_Status__c = 'Failed',
            Payment_Status_Details__c = 'Failed payment',
            Internal_Payment_Description__c = opp.Id,
            Transaction_Type__c = 'Sale'
        );

        insert cph;

        Test.stopTest();

        
    }
}