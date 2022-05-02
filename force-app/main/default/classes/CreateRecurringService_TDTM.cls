global class CreateRecurringService_TDTM extends npsp.TDTM_Runnable  {
    private static final string PP_TYPE = 'Payment Plan - Source';
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                             List<SObject> oldlist,
                                             npsp.TDTM_Runnable.Action triggerAction,
                                             Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
                                                 
          if(triggerAction == npsp.TDTM_Runnable.Action.AfterInsert){
              Map<Id,Opportunity> newOppMap = new Map<Id,Opportunity>((List<Opportunity>)newlist);
              List<npe01__OppPayment__c> paymentsToInsert = new List<npe01__OppPayment__c>();
              Id cardPaymentRecordTypeId = Schema.sObjectType.npe01__OppPayment__c.getRecordTypeInfosByDeveloperName().get('Card_Payment').getRecordTypeId();
                                                     //Identifying First Donation 
            Set<Id> rdIds = new Set<Id>();
            For(Opportunity opp:[Select Id,Amount,CurrencyIsoCode,ContactId,AccountId,npe03__Recurring_Donation__c,npe03__Recurring_Donation__r.Card_Payment_Detail__c,npe03__Recurring_Donation__r.npsp__StartDate__c,closeDate,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Order_ID__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Authorisation_Date__c  FROM Opportunity Where Id IN: newOppMap.keyset() AND npe03__Recurring_Donation__c != null AND npe03__Recurring_Donation__r.Card_Payment_Detail__c != null and  npe03__Recurring_Donation__r.Card_Payment_Detail__r.Transaction_Type__c ='Authorised' and npe03__Recurring_Donation__r.Card_Payment_Detail__r.First_Payment_Taken__c =true and Iswon= false and StageName='Pledged']){
                rdIds.add(opp.npe03__Recurring_Donation__c);
                if(opp.closeDate ==opp.npe03__Recurring_Donation__r.npsp__StartDate__c && opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Order_ID__c != null){
                    paymentsToInsert.add(new npe01__OppPayment__c(CurrencyIsoCode = opp.CurrencyIsoCode,npe01__Payment_Amount__c = opp.Amount,npsp__Type__c='Sale',Transaction_Type__c= 'Sale',RecordTypeId=cardPaymentRecordTypeId,
                                                                  npe01__Payment_Date__c =opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Authorisation_Date__c.date(), Order_ID__c = opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Order_ID__c,Contact__c =opp.ContactId, npe01__Paid__c =true,npe01__Payment_Method__c = 'Card Payment',npe01__Opportunity__c = opp.Id));
                }
            }
            System.debug('First Opportunity paymentsToInsert===>'+paymentsToInsert);
            
            if(paymentsToInsert.size()>0){
                
                dmlWrapper.objectsToInsert.addAll((List<SObject>)paymentsToInsert); //upsert paymentsToInsert;
            }
                                                 }       	                                          
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id,Opportunity> newOppMap = new Map<Id,Opportunity>((List<Opportunity>)newlist);
            Map<Id,Opportunity> oldOppMap = new Map<Id,Opportunity>((List<Opportunity>)oldlist); 
            
            
            set<Id> wonOppIds = new set<Id>();
            List<Opportunity> newOppList = newOppMap.values();   
            for(Integer i=0;i<newOppList.size();i++){
                System.debug('newOppList==>'+newOppList[i]);
                //Get Won Donations of Type Payment Plan SourceCre
                if(newOppList[i].isWon && !OldOppMap.get(newOppList[i].Id).isWon && newOppList[i].Type== PP_TYPE && newOppList[i].npe03__Recurring_Donation__c == Null && (newOppList[i].Donation_Type__c == 'EMI' || newOppList[i].Donation_Type__c == 'RD' || newOppList[i].Donation_Type__c == 'RDA'))
                     wonOppIds.add(newOppList[i].Id); 
            }
            
        //Create Recurring Donations for Payment PlanSource   
		if(wonOppIds.size()>0 && [SELECT Count() From npe03__Recurring_Donation__c Where Opportunity__c IN: wonOppIds]==0)
        	CreateRecurringDonations.CreateRD(wonOppIds);
            
        }else if(triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate){
            List<Opportunity> oppToUpdate = new List<Opportunity>();  
            for(Opportunity opp:(List<Opportunity>)newlist){
                if(opp.guid__c ==null){
                    opp.guid__c = HA_Utility.generateGUID();
                   
                }
            }
        }                                         
      
      return dmlWrapper;
    }
}