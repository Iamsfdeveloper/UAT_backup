/**
 * @description       : Update Opportunity and Payment records based on Direct Debit Status from smarter pay
 * @author            : Kalpesh.Thakur@HumanAppeal.co.uk
 * @group             : 
 * @last modified on  : 03-10-2022
 * @last modified by  : Kalpesh.Thakur@HumanAppeal.co.uk
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   03-10-2022   Kalpesh.Thakur@HumanAppeal.co.uk   Initial Version
**/
global class HA_DirectDebitStatusUpdate_TDTM extends npsp.TDTM_Runnable  {

    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                             List<SObject> oldlist,
                                             npsp.TDTM_Runnable.Action triggerAction,
                                             Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
       	List<Income_Debit_History__c> newIDHList = (List<Income_Debit_History__c>) newlist;
        
                                                 
		List<Payment_Event__e> paymentEvents = new List<Payment_Event__e>();
        
        Set<Id> setSubmittedIds = new Set<Id>();   
        Set<Id> setSubmittedDDIds = new Set<Id>(); 
        Set<Id> setSuccessFailedIds = new Set<Id>();    
                                                 
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {

            List<Income_Debit_History__c > oldIDHList = (List<Income_Debit_History__c >) oldlist;
            Map<Id,Income_Debit_History__c > oldIDHMap = new Map<Id,Income_Debit_History__c >(oldIDHList);
            
            for (Income_Debit_History__c objIDH : newIDHList) {
                
                System.debug('**Status**'+objIDH);
                
                String strStatus = objIDH.DD_Status__c;
                
                if (strStatus != null && strStatus.contains('Collection') && objIDH.DD_Stage__c != oldIDHMap.get(objIDH.Id).DD_Stage__c && (objIDH.DD_Stage__c == 'Failed' || objIDH.DD_Stage__c == 'Successful')) {
                    
                    setSuccessFailedIds.add(objIDH.Id);
                }
            }
            
            if (!setSuccessFailedIds.isEmpty()) {

                Map<Id,Income_Debit_History__c> mapOppDD = new Map<Id,Income_Debit_History__c>();
                
                for (Income_Debit_History__c objIDH : [SELECT Id,Income_Direct_Debit__c,Income_Direct_Debit__r.Opportunity__c,Amount__c,DD_Collection_Date__c,Income_Direct_Debit__r.Opportunity__r.npsp__Primary_Contact__c,
                                                              DD_Stage__c,DD_Status__c,DD_Failed_Description__c
                                                        FROM Income_Debit_History__c WHERE Id=:setSuccessFailedIds]) {
        
                    mapOppDD.put(objIDH.Income_Direct_Debit__r.Opportunity__c,objIDH);
                }
                
                List<Opportunity> lstOppUpdate = new List<Opportunity>();
                List<npe01__OppPayment__c> lstPayInsert = new List<npe01__OppPayment__c>();
                
                for(npe03__Recurring_Donation__c objRecDon : [SELECT Id, Opportunity__c, (SELECT Id,Amount,StageName,CloseDate,CurrencyIsoCode FROM npe03__Donations__r WHERE StageName = 'Pledged' AND CloseDate = THIS_MONTH LIMIT 1) 
                                                              FROM npe03__Recurring_Donation__c  WHERE Opportunity__c =:mapOppDD.keyset() AND npsp__PaymentMethod__c = 'Direct Debit' AND npsp__Status__c = 'Active']) {
                    System.debug('****:--'+objRecDon.npe03__Donations__r);
                     if (objRecDon.npe03__Donations__r != null && !objRecDon.npe03__Donations__r.isEmpty() && mapOppDD.containsKey(objRecDon.Opportunity__c) && mapOppDD.get(objRecDon.Opportunity__c).DD_Stage__c == 'Successful') {
                        
                        Opportunity objOpp = objRecDon.npe03__Donations__r[0];
                        objOpp.Payment_Details__c = 'Payment Taken';
                        lstOppUpdate.add(objOpp);
                        
                        npe01__OppPayment__c payment = new npe01__OppPayment__c();
                        payment.npe01__Opportunity__c = objOpp.Id;
                        payment.Income_Debit_History__c = mapOppDD.get(objRecDon.Opportunity__c).Id;
                        payment.npe01__Payment_Date__c = objOpp.CloseDate;
                        payment.npe01__Payment_Amount__c = mapOppDD.get(objRecDon.Opportunity__c).Amount__c;
                        payment.npe01__Payment_Method__c = 'Direct Debit';
                        payment.Contact__c = mapOppDD.get(objRecDon.Opportunity__c).Income_Direct_Debit__r.Opportunity__r.npsp__Primary_Contact__c;
                        payment.Status__c = 'RD'; 
                        payment.CurrencyIsoCode = objOpp.CurrencyIsoCode;
                        payment.npe01__Paid__c = true;            
                        payment.npsp__Type__c = 'Sale';
                        lstPayInsert.add(payment);
                    }
                    else if (objRecDon.npe03__Donations__r != null && !objRecDon.npe03__Donations__r.isEmpty()&& mapOppDD.containsKey(objRecDon.Opportunity__c) && mapOppDD.get(objRecDon.Opportunity__c).DD_Stage__c == 'Failed') {
                        
                        Opportunity objOpp = objRecDon.npe03__Donations__r[0];
                        objOpp.StageName = 'Payment Failed';
                        objOpp.Payment_Details__c = mapOppDD.get(objRecDon.Opportunity__c).DD_Failed_Description__c;
                        lstOppUpdate.add(objOpp);
                    }
                }
                
                try {
                    
                    update lstOppUpdate;
                    insert lstPayInsert;
                }
                catch (Exception ex) {
                    
                    System.debug('>>> exception ' + ex);
                    Recurring_Donation_Batch_Errors__c errorlog = HA_Logger.CreateErrorLog('Error While Updating Opp and Inserting Payments','HA_DirectDebitStatusUpdate_TDTM.Submitted',ex.getMessage()+'_'+ex.getStackTraceString());
                    insert errorlog;
                }
            }
        }
        

                                                 
      
      return dmlWrapper;
    }
    
    
}