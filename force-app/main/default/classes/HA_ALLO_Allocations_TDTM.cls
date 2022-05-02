global without sharing class HA_ALLO_Allocations_TDTM extends npsp.TDTM_Runnable {

    /** @description A map of allocation parent id to alloWrapper class; holds all relevant allocations data for this transaction. */
    public Map<Id,alloWrapper> mapWrapper = new Map<Id,alloWrapper>();
    /** @description Allocations settings */
    global npsp.TDTM_Runnable.DmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

    /** @description Allocations settings */
        public static npsp__Allocations_Settings__c settings= npsp.UTIL_CustomSettings_API.getAllocationsSettings();


    /** @description  Retrieve and cache the household settings first time this class is loaded only */
    public static final npo02__Households_Settings__c householdSettings = npsp.UTIL_CustomSettings_API.getHouseholdsSettings();
    public List<npsp__Allocation__c> listAlloForInsertAll;

    /*******************************************************************************************************
    * @description wrapper class to hold all allocation and opportunity information for a single parent:
    * Opportunity, Campaign, or Recurring Donation.
    */
    private class alloWrapper {
        boolean isPercentOnly = true;                                        //tracks whether all allocations are percentage based
        Decimal parentAmount = null;                                         //amount of this allocation's parent
        Decimal totalAmount = 0;                                             //holds total allocation amount
        Decimal totalPercent = 0;                                            //holds total percentage allocations
        List<npsp__Allocation__c> triggerList = new List<npsp__Allocation__c>();         //all allocations for this opportunity in the current trigger set
        List<npsp__Allocation__c> listAllo = new List<npsp__Allocation__c>();            //all non-default allocations for this parent object
        Map<Id, npsp__Allocation__c> defaultDupesById = new Map<Id, npsp__Allocation__c>();//duplicate default allocations, if any
        npsp__Allocation__c defaultAllo = null;                                    //the default allocation for this parent object
        boolean defaultInTrigger = false;                                    //is the default allocation in the current trigger set?
    }

    /*******************************************************************************************************
    * @description Trigger Handler on Opportunity and Allocation, dispatches to the correct method based on
    * object type.
    * @param listNew the list of contacts, accounts, or affiliations from trigger new.
    * @param listOld the list of contacts, accounts, or affiliations from trigger old.
    * @param triggerAction Which action triggered the current context. (Before or After; Insert, Update,
    * Delete, or Undelete.)
    * @param objResult The field describe object for the current trigger context.
    * @return dmlWrapper Objects that need to be inserted or updated after the processing of the trigger.
    ********************************************************************************************************/
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
        npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
		
        // dispatch to the correct handler
         if (objResult.getSObjectType() == Opportunity.sObjectType) {

            runOpportunityTriggerHandler(newlist, oldlist, triggerAction, objResult);
        } 
            return dmlWrapper;
    }

    /*******************************************************************************************************
    * @description Allocations trigger handler on Opportunity. Creates allocations as needed, by copying
    * from Campaign or Recurring Donation, and creating a default if enabled. Also updates existing
    * allocations if the opportunity amount or currency is changed.
    * @param listNew The list of opportunities from trigger new.
    * @param listOld The list of opportunities from trigger old.
    * @param triggerAction Which action triggered the current context. (Before or After; Insert, Update,
    * Delete, or Undelete.)
    * @param objResult The field describe object for Opportunity.
    * @return dmlWrapper Objects that need to be inserted or updated after the processing of the trigger.
    ********************************************************************************************************/
    private void runOpportunityTriggerHandler(List<SObject> newlist, List<SObject> oldlist,
        npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
		List<npsp__Trigger_Handler__c> handlers = npsp.TDTM_Config_API.getCachedRecords();
        Set<Id> oppRecordTypesToExclude = new Set<Id>();
        Set<String> oppTypesToExclude = new Set<String>();
        if (settings.npsp__Excluded_Opp_RecTypes__c!=null)
            oppRecordTypesToExclude = new Set<Id>((List<Id>)settings.npsp__Excluded_Opp_RecTypes__c.split(';'));
        if (settings.npsp__Excluded_Opp_Types__c!=null)
            oppTypesToExclude = new Set<String>(settings.npsp__Excluded_Opp_Types__c.split(';'));

        List<Opportunity> listOppsForProcessing = new List<Opportunity>();
        List<Opportunity> oppsWithNullOldAmount = new List<Opportunity>();
         Map<Id,Opportunity> oppList = new Map<Id,Opportunity>();
         Map<Id,Opportunity> newOppList = new Map<Id,Opportunity>((List<Opportunity>)newlist);
		System.debug('triggerAction==>'+triggerAction);
        if(triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate)
         oppList = new Map<Id,Opportunity>([Select Id,(Select Id From npsp__Allocations__r)  From Opportunity Where Id IN:newOppList.keySet()]);
        System.debug('oppList====>'+oppList);    
            for (integer i=0; i<newList.size(); i++) {
                Opportunity opp = (Opportunity) newlist[i];
                
                
                //skip excluded opp types and recordtypes
                if (oppRecordTypesToExclude.contains((Id)opp.get('RecordTypeId')) || oppTypesToExclude.contains(opp.Type))
                    continue;
                
                //INSERT case: Verify associated Campaign and Recurring Donations to auto create allocations
                if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
                    
                    //don't do anything on insert if we don't have an amount
                    if (opp.Amount == null) {
                        continue;
                        //if this new opportunity has a Campaign or RD, add to list for processing
                    } else 
                        if (opp.CampaignId != null || opp.npe03__Recurring_Donation__c != null)
                        listOppsForProcessing.add(opp);
                    //create a default allocation for the total amount, only if there's no possibility of other allocations from related objects
                    
                }
                
                //UPDATE case: if the opportunity amount changed, or the opp went to a closed/won stage: add to the list for processing
                if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {                
                    if(oppList != null && oppList.keySet().contains(opp.Id) && oppList.get(opp.Id).npsp__Allocations__r.size() ==0)
                        oppsWithNullOldAmount.add(opp);
                    Decimal oldAmount = (Decimal) oldlist[i].get('Amount');
                    if (oldAmount == null && opp.Amount != null ) {
                        oppsWithNullOldAmount.add(opp);
                        
                    } else if (opp.Amount != oldAmount ) {
                        listOppsForProcessing.add(opp);
                    }
                    
                    //if currency has changed, reset allocation currencies
                    if (UserInfo.isMultiCurrencyOrganization()) {
                        if (opp.get('CurrencyIsoCode') != oldlist[i].get('CurrencyIsoCode')) {
                            listOppsForProcessing.add(opp);
                        }
                    }
                }
            }
		
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
            fillMapWrapper(listOppsForProcessing);
            copyRecurringDonationCampaignAndPaymentAllocations(listOppsForProcessing);

        } else if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            System.debug('oppsWithNullOldAmount==>'+oppsWithNullOldAmount);
            List<Opportunity> opps = new List<Opportunity>(listOppsForProcessing);
            opps.addAll(oppsWithNullOldAmount);
            fillMapWrapper(opps);

            copyRecurringDonationCampaignAndPaymentAllocations(oppsWithNullOldAmount);
           // opportunityAmountCurrencyChange(listOppsForProcessing);
        }
    }

   
    /*******************************************************************************************************
    * @description Determines whether it is necessary to copy allocations from campaign, recurring donation
    * or opportunity and calls method to do so if required.
    * @param listSObjs A list of Opportunities or Payments.
    * @return void
    ********************************************************************************************************/
    private void copyRecurringDonationCampaignAndPaymentAllocations(List<SObject> listSObjs) {
        for (SObject sObj : listSObjs) {
            
            Boolean isPaymentRecord = sObj instanceof npe01__OppPayment__c;

            if (isPaymentRecord && mapWrapper.containsKey((Id)sObj.get('npe01__Opportunity__c'))) {
                copyRecurringDonationCampaignAndPaymentAllocations(sObj);

            } else if (!isPaymentRecord && sObj.get('npe03__Recurring_Donation__c') != null && mapWrapper.containsKey((Id)sObj.get('npe03__Recurring_Donation__c'))) {
                System.debug('sObj =====> '+JSON.serialize(sObj));
                copyRecurringDonationCampaignAndPaymentAllocations(sObj);

            } else if (!isPaymentRecord && sObj.get('CampaignId') != null && mapWrapper.containsKey((Id)sObj.get('CampaignId'))) {
                copyRecurringDonationCampaignAndPaymentAllocations(sObj);

            } 
        }
    }

    /*******************************************************************************************************
    * @description Creates allocations by copying from campaign or recurring donation allocations to Opps,
    * or from Opportunitys to Payments. Adjusts default allocation if enabled.
    * @param sObj Opportunity or Payment.
    * @return void This method modifies class variables and doesn't return anything.
    ********************************************************************************************************/
    private void copyRecurringDonationCampaignAndPaymentAllocations(SObject sObj) {
        alloWrapper wrap;
        Map<Id, npsp__Allocation__c> GAUtoAlloMapping = new Map<Id, npsp__Allocation__c>();
        Boolean isPaymentAllocation = false;

        
        //get wrapper for parent object, preferring recurring donation over campaign allocations if they exist
         if (sObj.get('npe03__Recurring_Donation__c') != null && mapWrapper.containsKey((Id)sObj.get('npe03__Recurring_Donation__c'))) {
            wrap = mapWrapper.get((Id) sObj.get('npe03__Recurring_Donation__c'));
        }

        else {
            wrap = mapWrapper.get((Id) sObj.get('CampaignId'));
        }

        List<npsp__Allocation__c> listAlloForInsert = new List<npsp__Allocation__c>();

        //add only allocations to active GAUs
        for (npsp__Allocation__c allo : wrap.listAllo.deepclone()) {

            // If it's a payment, don't filter out the active allocations.
            if (sObj instanceof npe01__OppPayment__c) {
                listAlloForInsert.add(allo);

            } else {
                if (allo.npsp__General_Accounting_Unit__r.npsp__Active__c) {
                    listAlloForInsert.add(allo);
                }
            }
        }

        Decimal amount = (Decimal)(sObj instanceof Opportunity ? sObj.get('Amount') : sObj.get('npe01__Payment_Amount__c'));
        Decimal remainder = amount;
		
        //reparent the cloned allocation to the opportunity
        for (npsp__Allocation__c allo : listAlloForInsert) {
            npsp__Allocation__c alloInMap;
            Boolean isPercentOnly = allo.npsp__Percent__c !=null && allo.npsp__Amount__c == null;

            if (isPaymentAllocation == true && GAUtoAlloMapping.containsKey(allo.npsp__General_Accounting_Unit__c)) {
                alloInMap = GAUtoAlloMapping.get(allo.npsp__General_Accounting_Unit__c);
            }

            allo.npsp__Opportunity__c = null;
            allo.npsp__Recurring_Donation__c = null;
            allo.npsp__Campaign__c = null;
            if (sObj instanceof Opportunity) {
                allo.npsp__Opportunity__c = sObj.Id;

            } else {
                allo.npsp__Payment__c = sObj.Id;
            }

            if (allo.npsp__Percent__c != null) {
                allo.npsp__Amount__c = (amount * allo.npsp__Percent__c * .01).setScale(2);//changes made on 20-09-21 amount to remainder// 21-09-21 - changes reversed
            }

            //Calculate proportional amount for non-percentage based Payment allocations
            if (sObj instanceof npe01__OppPayment__c && allo.npsp__Percent__c == null) {
                // Do not round the percent yet, we want the most accurate Amount value possible
                Decimal alloPercent = allo.npsp__Amount__c / wrap.parentAmount * 100;
                allo.npsp__Amount__c = (amount * alloPercent * .01).setScale(2);//changes made on 20-09-21 amount to remainder// 21-09-21 - changes reversed
                // Round the visible percentage value to 2 decimal places after the amount is calculated
                allo.npsp__Percent__c = alloPercent.setScale(2, System.RoundingMode.HALF_UP);
            }
			
		
            if (isPaymentAllocation == true && alloInMap != null) {
                alloInMap.npsp__Amount__c += allo.npsp__Amount__c;
                if (alloInMap.npsp__Percent__c != null && allo.npsp__Percent__c != null) {
                    // If both Payment Allocations have a percent set (which they should), maintain the total
                    alloInMap.npsp__Percent__c += allo.npsp__Percent__c;
                }
            }

            remainder -= allo.npsp__Amount__c;

            if (isPaymentAllocation == true) {
                if (alloInMap != null) {
                    GAUtoAlloMapping.put(alloInMap.npsp__General_Accounting_Unit__c, alloInMap);

                } else {
                    GAUtoAlloMapping.put(allo.npsp__General_Accounting_Unit__c, allo);
                }
            }
        }

        // Only update the list to insert to the consolidated list when it's a payment.
        if (isPaymentAllocation == true) {
            // Set the consolidated list as the list to insert
            listAlloForInsert = GAUtoAlloMapping.values();
        }

        //if our remainder is negative, only create percentage based allocations
        if ((amount >= 0 && remainder < 0)||(amount < 0 && remainder > 0)) {
            remainder = amount;

            //TODO: log error: not able to create allocations. chatter post?
            for (npsp__Allocation__c allo : listAlloForInsert) {
                if (allo.npsp__Percent__c!=null) {
                    dmlWrapper.objectsToInsert.add(allo);
                    remainder-=allo.npsp__Amount__c;
                }
            }

        
        }
            dmlWrapper.objectsToInsert.addAll((List<SObject>)listAlloForInsert);
        }
 
   

    //fills wrapper based on Opportunities with or without parent objects (Campaigns or Recurring donations)
    /*******************************************************************************************************
    * @description Fills the mapWrapper variable based on a list of opportunities.
    * @param listOpps A list of GAU Allocations.
    * @return void This method modifies class variables and doesn't return anything.
    ********************************************************************************************************/
    private void fillMapWrapper (List<SObject> parentList) {
        if (parentList == null || parentList.isEmpty()) {
            return;
        }

        Set<Id> setParentId = new Set<Id>();
        //create set of Campaign IDs, Recurring Donation Ids, and Opp Ids for query
        for (SObject parent : parentList) {
            if (parent instanceof Opportunity && parent.get('CampaignId') != null)
                setParentId.add((Id)parent.get('CampaignId'));
            if (parent instanceof Opportunity && parent.get('npe03__Recurring_Donation__c') != null)
                setParentId.add((Id)parent.get('npe03__Recurring_Donation__c'));
           // if (parent instanceof npe01__OppPayment__c && parent.get('npe01__Opportunity__c') != null)
           //     setParentId.add((Id)parent.get('npe01__Opportunity__c'));
            setParentId.add(parent.id);
        }
		System.debug('setParentId '+setParentId.toString());
        String alloQueryString = 'SELECT Id, npsp__Payment__c, npsp__Payment__r.npe01__Payment_Amount__c, npsp__Payment__r.npe01__Paid__c,Orphan__c,Stipulation_type__c,Quantity__c, ' +
        'npsp__Payment__r.npe01__Written_Off__c, npsp__Opportunity__c, npsp__Opportunity__r.Amount, npsp__Campaign__c, npsp__Recurring_Donation__c, ' +
            'npsp__Amount__c, npsp__Percent__c, npsp__General_Accounting_Unit__c, npsp__General_Accounting_Unit__r.npsp__Active__c';

        //query for multicurrency string if multicurrency org
        if (UserInfo.isMultiCurrencyOrganization()) {
            alloQueryString += ', CurrencyIsoCode';
        }
        alloQueryString += ' FROM npsp__Allocation__c WHERE (npsp__Payment__c IN :setParentId OR npsp__Opportunity__c IN :setParentId OR npsp__Campaign__c IN :setParentId OR npsp__Recurring_Donation__c IN :setParentId)';
        alloQueryString += ' AND npsp__General_Accounting_Unit__r.npsp__Active__c = TRUE';
		System.debug('alloQueryString '+alloQueryString+' '+database.query(alloQueryString));
        for (npsp__Allocation__c allo : database.query(alloQueryString)) {

            //create wrapper if it doesn't exist yet
            if (!mapWrapper.containsKey(getParentId(allo)))
                mapWrapper.put(getParentId(allo), new alloWrapper());

            alloWrapper wrap = mapWrapper.get(getParentId(allo));

            //add opportunity amount and allocation totals
            if (allo.npsp__Opportunity__c != null) {
                wrap.parentAmount = allo.npsp__Opportunity__r.Amount;
            }

            

           

            if (allo.npsp__Amount__c!=null)
                wrap.totalAmount += allo.npsp__Amount__c;

            //if any allocations don't have a percent, set flag to false
            if (allo.npsp__Percent__c == null)
                wrap.isPercentOnly = false;
            else if (allo.npsp__Percent__c != null)
                wrap.totalPercent += allo.npsp__Percent__c;

            wrap.listAllo.add(allo);

        }
    }

    /*******************************************************************************************************
    * @description Returns the id of a given allocation's parent object; Opportunity, Recurring Donation, or
    * Campaign.
    * @param allo A GAU Allocation.
    * @return id The id of this allocation's parent object.
    ********************************************************************************************************/
    public static Id getParentId (npsp__Allocation__c allo) {
        if (allo.npsp__Opportunity__c!=null)
            return allo.npsp__Opportunity__c;
        if (allo.npsp__Recurring_Donation__c!=null)
            return allo.npsp__Recurring_Donation__c;
        if (allo.npsp__Campaign__c!=null)
            return allo.npsp__Campaign__c;
        return null;
    }

   

}