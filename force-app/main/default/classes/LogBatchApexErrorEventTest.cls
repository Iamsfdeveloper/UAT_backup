/**
 * @description       :
 * @author            : agentgill
 * @group             :
 * @last modified on  : 07-11-2020
 * @last modified by  : agentgill
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   07-11-2020   agentgill   Initial Version
 **/
@isTest
public with sharing class LogBatchApexErrorEventTest {
    @isTest
    private static void testBatchApexErrorEvent() {
        try {
            Test.startTest();
            NewRecurringDonationService tb = new NewRecurringDonationService();
            Database.executeBatch(tb);
            Test.getEventBus().deliver();
            Test.stopTest();
        } catch (System.MathException e) {
        }
        Test.getEventBus().deliver();
    }
}