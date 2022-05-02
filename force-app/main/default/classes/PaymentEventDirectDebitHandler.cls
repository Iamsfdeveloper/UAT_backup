/**
 * @description       : PaymentEventDirectDebitHandler
 * @author            : agentgill
 * @group             :
 * @last modified on  : 07-06-2020
 * @last modified by  : agentgill
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   07-05-2020   agentgill   Initial Version
 **/
public with sharing class PaymentEventDirectDebitHandler {
    private static Map<Id, Payment_Event__e> peMap = new Map<Id, Payment_Event__e>();
    private static Map<Id, Payment_Event__e> peFailedMap = new Map<Id, Payment_Event__e>();
    /**
     * @description Process Direct Debit Payment Events
     * @author agentgill | 07-05-2020
     * @param paymentEvents
     **/
    public static void processDirectDebitEvent(
        List<Payment_Event__e> paymentEvents
    ) {
        Set<Id> failedPaymentIds = new Set<Id>();

        for (Payment_Event__e pe : paymentEvents) {
            if(pe.Opportunity_Stage__c == 'Payment Failed') {
                peFailedMap.put(pe.Opportunity_Id__c, pe);
                failedPaymentIds.add(pe.Payment_Id__c);
            }
            else {
                peMap.put(pe.Opportunity_Id__c, pe);
            }            
        }

        List<npe03__Recurring_Donation__c> recurringDonations = getOpportunitiesByRecurringDonation(peMap.keySet());

        System.debug('!!! recurringDonations ' + recurringDonations);

        if (!recurringDonations.isEmpty()) {
            updateOpportunies(recurringDonations);
        }

        List<Opportunity> failedOpportunities = getFailedOpportunities(failedPaymentIds);

        System.debug('!!! failedOpportunities ' + failedOpportunities);

        if (!failedOpportunities.isEmpty()) {
            updateFailedOpportunies(failedOpportunities);
        }
    }

    /**
     * @description Get Opportunities by Recurring Donation based on Source Opportunity Id
     * @author agentgill | 07-05-2020
     * @param oppIds
     * @return List<npsp_Recurring_Donation__c>
     **/
    private static List<npe03__Recurring_Donation__c> getOpportunitiesByRecurringDonation(Set<Id> oppIds) {
        return (List<npe03__Recurring_Donation__c>) [
            SELECT Id, Opportunity__c,
                (SELECT Id,
                        Amount,
                        StageName,
                        CloseDate,
                        CurrencyIsoCode                        
                FROM npe03__Donations__r
                WHERE StageName = 'Pledged'
                order by CloseDate ASC limit 1) 
            FROM npe03__Recurring_Donation__c 
            WHERE Opportunity__c IN :oppIds
                AND npsp__PaymentMethod__c = 'Direct Debit'
                AND npsp__Status__c = 'Active'
        ];
    }

    private static List<Opportunity> getFailedOpportunities(Set<Id> historyIds) {
        return [SELECT Id, CloseDate, StageName, Payment_Details__c, npe03__Recurring_Donation__r.Opportunity__c,
                    (SELECT Id, npe01__Written_Off__c, npe01__Payment_Date__c, npe01__Paid__c FROM npe01__OppPayment__r WHERE Income_Debit_History__c IN :historyIds)
                FROM Opportunity 
                WHERE Id IN (SELECT npe01__Opportunity__c FROM npe01__OppPayment__c WHERE Income_Debit_History__c IN :historyIds)];    
    }

    /**
     * @description Update Opportunies
     * @author agentgill | 07-05-2020
     * @param opps
     **/
    private static void updateOpportunies(List<npe03__Recurring_Donation__c> recurringDonations) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<npe01__OppPayment__c> payments = new List<npe01__OppPayment__c> ();
        
        for(npe03__Recurring_Donation__c recurringDonation : recurringDonations)
        {
            if (peMap.containsKey(recurringDonation.Opportunity__c)) 
            {
                Payment_Event__e pe = (Payment_Event__e) peMap.get(recurringDonation.Opportunity__c);

                for (Opportunity opp : recurringDonation.npe03__Donations__r) 
                {  
                    //opp.StageName = pe.Opportunity_Stage__c;
                    opp.Payment_Details__c = pe.Payment_Details__c;
                    //opp.CloseDate = opp.CloseDate == null ? pe.Transaction_Date__c.Date().ToStartOfMonth() : opp.CloseDate;
                    //opp.CloseDate = opp.CloseDate;
                    oppsToUpdate.add(opp);

                    if(pe.Payment_Details__c == 'Payment Taken')
                    {
                        npe01__OppPayment__c payment = new npe01__OppPayment__c();
                        payment.npe01__Opportunity__c = opp.Id;
                        payment.Income_Debit_History__c = pe.Payment_Id__c;
                        payment.npe01__Payment_Date__c = opp.CloseDate;
                        payment.npe01__Payment_Amount__c = pe.Amount__c;
                        payment.npe01__Payment_Method__c = pe.Payment_Type__c;
                        payment.Contact__c = pe.Contact_Id__c;
                        payment.Status__c = 'RD'; 

                        payment.CurrencyIsoCode = opp.CurrencyIsoCode;
                        payment.npe01__Paid__c = true;            
                        payment.npsp__Type__c = 'Sale';

                        payments.add(payment);
                    }  
                }
            }
        }        

        try {
            update oppsToUpdate;
            insert payments;
        } catch (Exception ex) { 
            System.debug('>>> exception ' + ex);
			Recurring_Donation_Batch_Errors__c errorlog = HA_Logger.CreateErrorLog('Error While Updating and Inserting Payments'+payments,'PaymentEventDirectDebitHandler.updateOpportunies',ex.getMessage()+'_'+ex.getStackTraceString());
            insert errorlog;
        }
    }

    private static void updateFailedOpportunies(List<Opportunity> opps) {
        System.debug('#### updateFailedOpportunies');
        System.debug('#### opps: ' + opps);

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<npe01__OppPayment__c> payments = new List<npe01__OppPayment__c> ();
            
        for (Opportunity opp : opps) 
        {  
            if (peFailedMap.containsKey(opp.npe03__Recurring_Donation__r.Opportunity__c)) 
            {
                Payment_Event__e pe = (Payment_Event__e) peFailedMap.get(opp.npe03__Recurring_Donation__r.Opportunity__c);
                opp.StageName = pe.Opportunity_Stage__c;
                opp.Payment_Details__c = pe.Payment_Details__c;
                //opp.CloseDate = opp.CloseDate;
                oppsToUpdate.add(opp);

                for(npe01__OppPayment__c payment : opp.npe01__OppPayment__r)
                {
                    payment.npe01__Written_Off__c = true;
                    payment.npe01__Paid__c = false;
                    payment.npe01__Payment_Date__c = payment.npe01__Payment_Date__c;
                    payments.add(payment);
                }
            }
        } 

        System.debug('#### oppsToUpdate: ' + oppsToUpdate);
        
        try {
            update oppsToUpdate; 
            update payments;
        } catch (Exception ex) {
            System.debug('>>> exception ' + ex);
            Recurring_Donation_Batch_Errors__c errorlog = HA_Logger.CreateErrorLog('Error While Updating and Inserting Payments','PaymentEventDirectDebitHandler.updateFailedOpportunies',ex.getMessage()+'_'+ex.getStackTraceString());
            insert errorlog;
        }
    }
}