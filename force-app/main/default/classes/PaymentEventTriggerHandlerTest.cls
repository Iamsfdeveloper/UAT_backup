/**
 * @description       :
 * @author            : agentgill
 * @group             :
 * @last modified on  : 07-11-2020
 * @last modified by  : agentgill
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   07-05-2020   agentgill   Initial Version
 **/
@isTest
public with sharing class PaymentEventTriggerHandlerTest {
    @isTest
    private static void testPublishPaymentEvent() {
        Test.startTest();
        Payment_Event__e event = new Payment_Event__e(
            Internal_Payment_Description__c = 'TestME'
        );
        EventBus.publish(event);
        Test.stopTest();
        System.assertEquals(
            1,
            PaymentEventTriggerHandler.unknownEvents.size(),
            'Something not right'
        );
    }
}