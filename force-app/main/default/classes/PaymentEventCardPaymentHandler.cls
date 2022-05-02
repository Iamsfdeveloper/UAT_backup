/**
 * @description       : Process Card Payment Events
 * @author            : agentgill
 * @group             :
 * @last modified on  : 07-05-2020
 * @last modified by  : agentgill
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   07-05-2020   agentgill   Initial Version
 **/
public with sharing class PaymentEventCardPaymentHandler {
    private static Map<String, String> guidPaymentStatus = new Map<String, String>();
    private static Map<String, String> guidPaymentDetails = new Map<String, String>();

    /**
     * @description Process Card Payment Events
     * @author agentgill | 07-05-2020
     * @param paymentEvents
     **/
    public static void processCardPaymentEvent(
        List<Payment_Event__e> paymentEvents
    ) {
        Set<String> guidSet = new Set<String>();

        for (Payment_Event__e pe : paymentEvents) {
            guidSet.add(pe.Internal_Payment_Description__c);
            guidPaymentDetails.put(
                pe.Internal_Payment_Description__c,
                pe.Payment_Details__c
            );
            guidPaymentStatus.put(
                pe.Internal_Payment_Description__c,
                pe.Opportunity_Stage__c
            );           
        }

        List<Opportunity> opps = getOpportunties(guidSet);
        if (!opps.isEmpty()) {
            updateOpportunies(opps);            
        }
    }

    /**
     * @description Get Opportunities based on GUID
     * @author agentgill | 07-05-2020
     * @param guidSet
     * @return List<Opportunity>
     **/
    private static List<Opportunity> getOpportunties(Set<String> guidSet) {
        return (List<Opportunity>) [
            SELECT Id, StageName, GUID__c, npsp__Primary_Contact__c 
            FROM Opportunity
            WHERE Id IN :guidSet
        ];
    }
    

    /**
     * @description Update Opportunities
     * @author agentgill | 07-05-2020
     * @param opps
     * @param stageName
     * @param paymentDetails
     **/
    private static void updateOpportunies(List<Opportunity> opps) {
        for (Opportunity o : opps) {
            o.StageName = guidPaymentStatus.get(o.Id);
            o.Payment_Details__c = guidPaymentDetails.get(o.Id);
        }
        try {
            update opps;
        } catch (Exception ex) {
            System.debug('>>> exception ' + ex);
        }
    }
}