/**
 * @File Name          : PaymentEventTriggerHandler.cls
 * @Description        :
 * @Author             : agentgill
 * @Group              :
 * @Last Modified By   : agentgill
 * @Last Modified On   : 07-05-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    12/06/2020   agentgill     Initial Version
 **/
public with sharing class PaymentEventTriggerHandler extends TriggerHandler {
    @testVisible
    private static List<Payment_Event__e> cardPaymentEvents = new List<Payment_Event__e>();
    @testVisible
    private static List<Payment_Event__e> directDebitEvents = new List<Payment_Event__e>();
    @testVisible
    private static List<Payment_Event__e> unknownEvents = new List<Payment_Event__e>();

    /**
     * @description
     * @author agentgill | 07-05-2020
     **/
    public override void afterInsert() {
        for (Payment_Event__e pe : (List<Payment_Event__e>) Trigger.new) {
            System.debug('!!! Payment Event recieved...');
            switch on pe.Payment_Type__c {
                when 'Card Payment' {
                    cardPaymentEvents.add(pe);
                }
                when 'Direct Debit' {
                    directDebitEvents.add(pe);
                }
                when else {
                    unknownEvents.add(pe);
                }
            }
        }

        if (!cardPaymentEvents.isEmpty()) {
            PaymentEventCardPaymentHandler.processCardPaymentEvent(
                cardPaymentEvents
            );
        }

        if (!directDebitEvents.isEmpty()) {
            System.debug('!!! Processing Direct Debit...');
            PaymentEventDirectDebitHandler.processDirectDebitEvent(
                directDebitEvents
            );
        }
    }
}