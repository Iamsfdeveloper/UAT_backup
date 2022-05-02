global class ALLO_Allocations_Custom_TDTM extends npsp.TDTM_Runnable {

    /** @description A map of allocation parent id to alloWrapper class; holds all relevant allocations data for this transaction. */
    public Map<Id,alloWrapper> mapWrapper = new Map<Id,alloWrapper>();
    /** @description Allocations settings. */
    public npsp.TDTM_Runnable.DmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();

    /** @description Allocations settings. */
    public static npsp__Allocations_Settings__c settings = npsp__Allocations_Settings__c.getInstance();

    /** @description  Retrieve and cache the household settings the first time this class is loaded only */
    public static final npo02__Households_Settings__c householdSettings = npo02__Households_Settings__c.getInstance();

    /** @description The id of the default General Accounting Unit if default allocations are enabled */
    public static id idDefaultGAU {
        get {
            return settings.npsp__Default__c;
        }
        set;
    }

    /*******************************************************************************************************
    * @description wrapper class to hold all allocation and opportunity information for a single parent:
    * Opportunity, Campaign, or Recurring Donation.
    */
    private class alloWrapper {
        boolean isPercentOnly = true;                                        //tracks whether all allocations are percentage based
        Decimal parentAmount = null;                                         //amount of this allocation's parent
        Decimal totalAmount = 0;                                             //holds total allocation amount
        Decimal totalPercent = 0;                                            //holds total percentage allocations
        List<npsp__Allocation__c > triggerList = new List<npsp__Allocation__c >();         //all allocations for this opportunity in the current trigger set
        List<npsp__Allocation__c > listAllo = new List<npsp__Allocation__c >();            //all non-default allocations for this parent object
        Map<Id, npsp__Allocation__c > defaultDupesById = new Map<Id, npsp__Allocation__c >();//duplicate default allocations, if any
        npsp__Allocation__c  defaultAllo = null;                                    //the default allocation for this parent object
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

        //if default allocations are enabled, verify that we have an ID value for the default fund
        if (settings.npsp__Default_Allocations_Enabled__c && settings.npsp__Default__c == null) {
            SObject obj = newList.isEmpty() ? oldList[0] : newList[0];
            obj.addError(Label.npsp.alloDefaultGAUMissing);
        }

        // dispatch to the correct handler
        if (objResult.getSObjectType() == npsp__Allocation__c.sObjectType  &&
            (triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate)) {
			System.debug('befor trigger');
            runAllocationBeforeTriggerHandler(newlist, oldlist, triggerAction, objResult);
        } else if (objResult.getSObjectType() == npsp__Allocation__c.sObjectType  &&
            (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert || triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate || triggerAction == npsp.TDTM_Runnable.Action.AfterDelete)) {
			System.debug('after trigger');
            runAllocationAfterTriggerHandler(newlist, oldlist, triggerAction, objResult);
            //setting before to true for afterDelete case, to avoid running triggers on DML wrapper objects
        } 


        //npsp.TDTM_TriggerHandler.processDML(dmlWrapper);
        //dmlWrapper = null;

        return dmlWrapper;
    }


    /*******************************************************************************************************
    * @description Allocations before trigger handler on GAU Allocation. Validates allocation data per
    * object and per parent object to avoid badly created allocations, exceeding opportunity amount,
    * exceeding 100%, negative amounts or percents, etc.
    * In multicurrency orgs, also verifies currency matches the parent object's currency.
    * @param listNew The list of allocations from trigger new.
    * @param listOld The list of allocations from trigger old.
    * @param triggerAction Which action triggered the current context. (Before or After; Insert, Update,
    * Delete, or Undelete.)
    * @param objResult The field describe object for GAU Allocation.
    * @return dmlWrapper Objects that need to be inserted or updated after the processing of the trigger.
    ********************************************************************************************************/
    private void runAllocationBeforeTriggerHandler(List<SObject> newlist, List<SObject> oldlist,
        npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
		system.debug('befor trigger '+triggerAction);
        String  alloDefaultNotEnabledLabel = 'You must enable Default Allocations in order to allocate at the payment level.';    
        String alloPaymentNotEnabledLabel ='Payment-level Allocations aren\'t enabled for your organization. Try allocating at the Opportunity level instead.';    
        String alloSingleParentLabel = 'Ensure that this Allocation has only one parent object: Payment, Opportunity, Recurring Donation, or Campaign.';
        String alloSignMistmatchLabel = 'Negative Allocations are only allowed in negative donations and positive Allocations are not allowed in negative donations.';
        List<npsp__Allocation__c> triggerList = (List<npsp__Allocation__c>) newList;
        Boolean parentErrorDetected = false;

        for (integer i=0; i<triggerList.size(); i++) {
            npsp__Allocation__c allo = triggerlist[i];

            System.debug('****Allocation*****:--'+settings.npsp__Default_Allocations_Enabled__c );
            System.debug('****Payment*****:--'+settings.npsp__Payment_Allocations_Enabled__c );
            System.debug('****npsp__Payment__c*****:--'+allo.npsp__Payment__c );
            //throw error if allocating at the payment level but default allocation is not enabled
            if (!settings.npsp__Default_Allocations_Enabled__c && allo.npsp__Payment__c != null) {
                allo.addError(alloDefaultNotEnabledLabel);
                parentErrorDetected = true;
            }

            //throw error if payment allocations are disabled and Payment__c is not null
            if (settings.npsp__Payment_Allocations_Enabled__c != true && allo.npsp__Payment__c != null) {
                allo.addError(alloPaymentNotEnabledLabel);
                parentErrorDetected = true;
            }

            //if we don't have a parent, or have more than one parent, exception thrown
            //
            /*
            if (parentError(allo)) {
                allo.AddError(alloSingleParentLabel);
                parentErrorDetected = true;
            }
            */
            //neither an amount nor a percent is defined
            if (allo.npsp__Amount__c == null && allo.npsp__Percent__c == null) {
                allo.addError(Label.npsp.alloAmountOrPercent);
            }
            /*
            //negative amount (Payments excepted)
            if (allo.npsp__Amount__c != null && allo.npsp__Amount__c < 0 && allo.npsp__Payment__c == null) {
                allo.addError(Label.npsp.alloNegativeAmount);
            }*/
            //negative percent
            /*
            if (allo.npsp__Percent__c != null && allo.npsp__Percent__c < 0) {
                allo.addError(Label.npsp.alloNegativePercent);
            }*/
            //manually updated currency
            if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate &&
                    UserInfo.isMultiCurrencyOrganization() &&
                    allo.get('CurrencyIsoCode') != oldList[i].get('CurrencyIsoCode')) {
                allo.addError(Label.npsp.alloModifyCurrency);
            }

        }

        if (parentErrorDetected) {
            return;
        }

        fillMapWrapper(triggerList);
            System.debug('triggerList'+triggerList);

        //verify that we're not over the total amount, and that everything is equalized
        for (npsp__Allocation__c allo : triggerList) {

            alloWrapper wrap = mapWrapper.get(getParentId(allo));
			System.debug('wrap'+wrap);
            //if we exceed 100%
            if (wrap.totalPercent > 100) {
                allo.addError(Label.npsp.alloPercentExceed100);
            }

            //skip this check for Campaign and Recurring Donation allocations
            if (wrap.parentAmount==null) {
                continue;
            }

            //Verify that allocation and Payment amount sign match
            if ((allo.npsp__Amount__c >= 0 && wrap.parentAmount < 0)
                ||(allo.npsp__Amount__c < 0 && wrap.parentAmount >= 0)){
                //allo.addError(alloSignMistmatchLabel);
            }

            //verify the total allocations don't exceed the parent amount
            if ((wrap.totalAmount >= 0 && wrap.totalAmount > wrap.parentAmount)) {
               // ||(wrap.totalAmount < 0 && wrap.totalAmount < wrap.parentAmount)) {
                    system.debug('wrap.totalAmount'+wrap.totalAmount);
                    System.debug('wrap.parentAmount'+wrap.parentAmount);
                allo.addError(Label.npsp.alloTotalExceedsOppAmt);
            }

        }

        //if this org is multicurrency and this is an insert or update, set currency ISO code based on parent ISO code
        /*if ((triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert || triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate)
                && npsp.ALLO_Multicurrency_TDTM.isMultiCurrency()) {
            npsp.ALLO_Multicurrency_TDTM.updateAllocationCurrency(triggerList);
        }*/
        //TODO: don't let users change allocation currency manually
    }

    /*******************************************************************************************************
    * @description Allocations after trigger handler on GAU Allocation. When a recurring donation allocation
    * is modified, creates or modifies all allocations for open opportunities under that recurring
    * donations' schedule to match the recurring donation's allocations.
    * @param listNew The list of allocations from trigger new.
    * @param listOld The list of allocations from trigger old.
    * @param triggerAction Which action triggered the current context. (Before or After; Insert, Update,
    * Delete, or Undelete.)
    * @param objResult The field describe object for GAU Allocation.
    * @return dmlWrapper Objects that need to be inserted or updated after the processing of the trigger.
    ********************************************************************************************************/
    private void runAllocationAfterTriggerHandler(List<SObject> newlist, List<SObject> oldlist,
        npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        List<Opportunity> listOpps = new List<Opportunity>();
        List<npe01__OppPayment__c> listPmts = new List<npe01__OppPayment__c>();
        Set<Id> setRecDonId = new Set<Id>();
        Set<Id> setOppIds = new Set<Id>();
        Set<Id> setPmtIds = new Set<Id>();

        for (npsp__Allocation__c allo : triggerAction == npsp.TDTM_Runnable.Action.AfterDelete ? (List<npsp__Allocation__c>) oldList : (List<npsp__Allocation__c>) newList) {
            //if this allocation is for a recurring donation, save the Id for updating open opportunities under that RD schedule
            System.debug('triggerAction++ '+triggerAction);
            System.debug('all after '+allo);
            if (allo.npsp__Recurring_Donation__c != null)
                setRecDonId.add(allo.npsp__Recurring_Donation__c);
            //if this is an opportunity allocation and defaults are enabled, adjust/create/delete the default
            if (settings.npsp__Default_Allocations_Enabled__c && allo.npsp__Opportunity__c!=null)
                setOppIds.add(allo.npsp__Opportunity__c);

        }

        if (!setRecDonId.isEmpty() || !setOppIds.isEmpty()) {
            String oppQuery = 'SELECT Id, Amount, npe03__Recurring_Donation__c, CampaignId';
            if (UserInfo.isMultiCurrencyOrganization()) {
                oppQuery += ', CurrencyIsoCode';
            }
            oppQuery+=' FROM Opportunity WHERE (Opportunity.isClosed = FALSE AND npe03__Recurring_Donation__c IN :setRecDonId) OR Id IN :setOppIds';
            listOpps = database.query(oppQuery);
        }



        if (!listOpps.isEmpty()) {

            fillMapWrapper(listOpps);

            //if we have any opportunity allocations and default handling is enabled, adjust the opps' default allocation
            List<Opportunity> listRecDonOpps = new List<Opportunity>();
            if (!setOppIds.isEmpty()) {
                for (Opportunity opp : listOpps) {
                    //we have allocations for this opportunity
                    if (setOppIds.contains(opp.Id)) {
                        //this opp has allocations, check for default cases
                        if (mapWrapper.containsKey(opp.Id)) {
                            alloWrapper oppWrap = mapWrapper.get(opp.Id);
                            //adjust default allocation, and add to DML wrapper if needed
                            Decimal amountDifferential = opp.Amount - oppWrap.totalAmount;

                            //no remainder: delete default allocation
                            if (amountDifferential == 0 && oppWrap.defaultAllo!=null) {
                                dmlWrapper.objectsToDelete.add(oppWrap.defaultAllo);
                            } else if (amountDifferential > 0) {
                                //create a default allocation if we don't have one
                                if (oppWrap.defaultAllo == null) {
                                    oppWrap.defaultAllo = makeDefaultAllocation(opp);
                                    oppWrap.defaultAllo.npsp__Amount__c = amountDifferential;
                                    dmlWrapper.objectsToInsert.add(oppWrap.defaultAllo);
                                } else if (oppWrap.defaultAllo.npsp__Amount__c != amountDifferential) {
                                    oppWrap.defaultAllo.npsp__Amount__c = amountDifferential;
                                    dmlWrapper.objectsToUpdate.add(oppWrap.defaultAllo);
                                }
                            }
                            //delete duplicate default GAU allocations
                            if (!oppWrap.defaultDupesById.isEmpty()) {
                                dmlWrapper.objectsToDelete.addAll((List<SObject>)oppWrap.defaultDupesById.values());
                            }
                        //this opp has no allocations, just create the default
                        } else dmlWrapper.objectsToInsert.add(makeDefaultAllocation(opp));
                    //if this was a recurring donation allocation, add to list for processing
                    } else listRecDonOpps.add(opp);
                }
            //no opportunity default cases, just copy the list over
            } else {
                listRecDonOpps = listOpps;
            }
            //after insert/update/delete of Recurring Donation allocations: delete and recreate all open opportunities' allocations
            if (!listRecDonOpps.isEmpty()) {

                //first, delete all existing opp allocations
                for (Opportunity opp : listRecDonOpps) {
                    if (mapWrapper.containsKey(opp.Id)){
                        alloWrapper oppWrap = mapWrapper.get(opp.Id);
                        dmlWrapper.objectsToDelete.addAll((List<SObject>)oppWrap.listAllo);
                        if (settings.npsp__Default_Allocations_Enabled__c && oppWrap.defaultAllo != null) {
                            dmlWrapper.objectsToDelete.add(oppWrap.defaultAllo);
                        }
                    }
                }


                //then, recreate them based on the recurring donation
                copyRecurringDonationCampaignAndPaymentAllocations(listRecDonOpps);
            }
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
                copyRecurringDonationCampaignAndPaymentAllocations(sObj);

            } else if (settings.npsp__Default_Allocations_Enabled__c) {
                dmlWrapper.objectsToInsert.add(makeDefaultAllocation(sObj));
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

        //get wrapper for parent Payment.
        if (sObj instanceof npe01__OppPayment__c) {
            wrap = mapWrapper.get((Id)sObj.get('npe01__Opportunity__c'));
            isPaymentAllocation = true;
        }

        //get wrapper for parent object, preferring recurring donation over campaign allocations if they exist
        else if (sObj.get('npe03__Recurring_Donation__c') != null && mapWrapper.containsKey((Id)sObj.get('npe03__Recurring_Donation__c'))) {
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
                allo.npsp__Amount__c = (amount * allo.npsp__Percent__c * .01).setScale(2);
            }

            //Calculate proportional amount for non-percentage based Payment allocations
            if (sObj instanceof npe01__OppPayment__c && allo.npsp__Percent__c == null) {
                // Do not round the percent yet, we want the most accurate Amount value possible
               /* Decimal alloPercent = allo.npsp__Amount__c / wrap.parentAmount * 100;
                allo.npsp__Amount__c = (amount * alloPercent * .01).setScale(2);
                // Round the visible percentage value to 2 decimal places after the amount is calculated
                allo.npsp__Percent__c = alloPercent.setScale(2, System.RoundingMode.HALF_UP);*/
            }

            /*//if this is a multicurrency org, recalculate the amount and set the CurrencyIsoCode
            if (UserInfo.isMultiCurrencyOrganization()) {
                if (allo.npsp__Amount__c != null && !isPercentOnly) {
                    allo.npsp__Amount__c = UTIL_CurrencyConversion.convertAmountUsingStandardRates(
                            (String)allo.get('CurrencyIsoCode'),
                            (String)sObj.get('CurrencyIsoCode'),
                            allo.npsp__Amount__c
                    );
                }
                allo.put('CurrencyIsoCode', sObj.get('CurrencyIsoCode'));
            }*/

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

            if (settings.npsp__Default_Allocations_Enabled__c) {
                npsp__Allocation__c defaultAllo = makeDefaultAllocation(sObj); 
                defaultAllo.npsp__Amount__c = remainder;
                dmlWrapper.objectsToInsert.add(defaultAllo);
            }

        //create default allocation if needed
        } else if (settings.npsp__Default_Allocations_Enabled__c && ((amount >= 0 && remainder > 0)||(amount < 0 && remainder < 0))) {
            npsp__Allocation__c defaultAllo = makeDefaultAllocation(sObj);
            defaultAllo.npsp__Amount__c = remainder;
            dmlWrapper.objectsToInsert.add(defaultAllo);
            dmlWrapper.objectsToInsert.addAll((List<SObject>)listAlloForInsert);
        //add objects to DML wrapper in all other cases (no remainder, or positive remainder without default allocations enabled)
        } else {
            Boolean needsDefaultAllocation = isPaymentAllocation == true && listAlloForInsert.isEmpty() && amount == 0;
            if (needsDefaultAllocation) {
                npsp__Allocation__c defaultAllo = makeDefaultAllocation(sObj);
                defaultAllo.npsp__Amount__c = 0;
                listAlloForInsert.add(defaultAllo);
            }
            dmlWrapper.objectsToInsert.addAll((List<SObject>)listAlloForInsert);
        }
    }

    /*******************************************************************************************************
    * @description Fills the mapWrapper variable based on a list of allocations from the trigger set.
    * Updates current trigger set amounts to match percentages.
    * @param listOpps A list of GAU Allocations.
    * @return void This method modifies class variables and doesn't return anything.
    ********************************************************************************************************/
    public void fillMapWrapper (List<npsp__Allocation__c> alloList) {

        Set<Id> setParentId = new Set<Id>();
        Set<Id> setExistingAlloId = new Set<Id>();

        //build a list of related object Ids to fill wrapper with data
        for (npsp__Allocation__c allo : alloList) {
            setParentId.add(getParentId(allo));

            //create wrapper object and add to map
            if (!mapWrapper.containsKey(getParentId(allo))) {
                alloWrapper wrapper = new alloWrapper();
                mapWrapper.put(getParentId(allo), wrapper);
            }
        }

        //fill wrapper with current trigger set allocations
        for (npsp__Allocation__c allo : alloList) {
            alloWrapper wrap = mapWrapper.get(getParentId(allo));
            wrap.triggerList.add(allo);
			System.debug('allo '+allo);
            System.debug('allo recurring '+allo.npsp__Recurring_Donation__c);
            //Add any allocation with an id to be excluded from calculations in the query
            if (allo.Id != null)
                setExistingAlloId.add(allo.Id);
            if (settings.npsp__Default_Allocations_Enabled__c && allo.npsp__General_Accounting_Unit__c == idDefaultGAU) {
                if (allo.npsp__Percent__c != null && (allo.npsp__Opportunity__c != null || allo.npsp__Payment__c != null))
                    allo.addError(Label.npsp.alloDefaultNotPercent);
                if (wrap.defaultAllo == null)
                    wrap.defaultAllo = allo;
                else if (wrap.defaultAllo.Id != allo.Id) {
                    wrap.defaultDupesById.put(allo.Id, allo);
                }
                wrap.defaultInTrigger = true;
                continue;
            }

            if (allo.npsp__Amount__c!=null){
                wrap.totalAmount += allo.npsp__Amount__c;
				System.debug('wrap.totalAmount '+wrap.totalAmount);	
            	System.debug('allo.npsp__Amount__c '+allo.npsp__Amount__c);	
            }
                
            
            //if any allocations don't have a percent, set flag to false
            if (allo.npsp__Percent__c == null)
                wrap.isPercentOnly = false;
            else
                wrap.totalPercent += allo.npsp__Percent__c;
        }

        //fill wrapper with all allocations for this opportunity
        //getting payment and opportunity info here to avoid excess queries
        for (npsp__Allocation__c allo : [SELECT Id, npsp__Payment__c, npsp__Payment__r.npe01__Payment_Amount__c,  npsp__Payment__r.npe01__Paid__c, npsp__Payment__r.npe01__Written_Off__c, npsp__Opportunity__c, npsp__Opportunity__r.Amount, npsp__Amount__c, npsp__Percent__c, npsp__General_Accounting_Unit__c, npsp__Recurring_Donation__c, npsp__Campaign__c,Instruction__c FROM npsp__Allocation__c
                WHERE (npsp__Payment__c IN :setParentId OR npsp__Opportunity__c IN :setParentId OR npsp__Recurring_Donation__c IN :setParentId OR npsp__Campaign__c IN :setParentId OR Instruction__c IN :setParentId)
                AND Id NOT IN :setExistingAlloId]) {
			System.debug('allo count '+allo);
            alloWrapper wrap = mapWrapper.get(getParentId(allo));

            //add payment amount
            if (allo.npsp__Payment__c != null) {
                wrap.parentAmount = allo.npsp__Payment__r.npe01__Payment_Amount__c;
                system.debug('wrap.parentAmount '+wrap.parentAmount+' allo.npsp__Payment__r.npe01__Payment_Amount__c '+allo.npsp__Payment__r.npe01__Payment_Amount__c);
            }
            //add opportunity amount
            else if (allo.npsp__Opportunity__c != null) {
                wrap.parentAmount = allo.npsp__Opportunity__r.Amount;
	            system.debug('wrap.parentAmount '+wrap.parentAmount+' allo.npsp__Opportunity__r.Amount '+allo.npsp__Opportunity__r.Amount);
            }

            //save the default allocation.
            if (settings.npsp__Default_Allocations_Enabled__c && allo.npsp__General_Accounting_Unit__c == idDefaultGAU) {
                if (wrap.defaultAllo == null || wrap.defaultAllo.Id == allo.Id) {
                wrap.defaultAllo = allo;
                //keep the default allocation from listAllo
                }
                else {
                    wrap.defaultDupesById.put(allo.Id, allo);
                }
                continue;
            }

            /*if (allo.npsp__Amount__c!=null){
               // wrap.totalAmount += allo.npsp__Amount__c;
                System.debug('wrap.totalAmount 2 '+wrap.totalAmount);
            }*/
                

            //add this allocation to the list
            wrap.listAllo.add(allo);

            //if any allocations don't have a percent, set flag to false
            if (allo.npsp__Percent__c == null)
                wrap.isPercentOnly = false;
            else if (allo.npsp__Percent__c!=null)
                wrap.totalPercent += allo.npsp__Percent__c;
        }

        Set<Id> setOppIds = new Set<Id>();

        //if we arrive here without a parent amount for an opportunity/payment, we need another query for the parent info.
        for (npsp__Allocation__c allo : alloList) {
            alloWrapper wrap = mapWrapper.get(getParentId(allo));
            if (wrap.parentAmount == null && allo.npsp__Opportunity__c!=null)
                setOppIds.add(allo.npsp__Opportunity__c);

        }

        //we have opportunities we need to query for a parent amount
        if (!setOppIds.isEmpty()) {
            for (Opportunity opp : [SELECT Id, Amount FROM Opportunity WHERE Id IN :setOppIds]) {
                mapWrapper.get(opp.Id).parentAmount = opp.Amount;
            }
        }


        //verify the current trigger set has correct amounts based on the percentage chosen
        for (npsp__Allocation__c allo : alloList) {
            alloWrapper wrap = mapWrapper.get(getParentId(allo));
            if (allo.npsp__Percent__c!=null && wrap.parentAmount!=null) {
                //we don't have an amount yet, add it. we're only dealing with before triggers so we can just update the allocation
                if (allo.npsp__Amount__c==null) {
                    allo.npsp__Amount__c = (wrap.parentAmount * allo.npsp__Percent__c * .01).setScale(2);
                    wrap.totalAmount += allo.npsp__Amount__c;
                //we have an amount not equal to the percentage of the total, so update it and the total
                } else if (allo.npsp__Amount__c != (wrap.parentAmount * allo.npsp__Percent__c * .01).setScale(2)) {
                    //remove the previous amount, recalculate the amount, and add it back
                    wrap.totalAmount -= allo.npsp__Amount__c;
                    allo.npsp__Amount__c = (wrap.parentAmount * allo.npsp__Percent__c * .01).setScale(2);
                    wrap.totalAmount += allo.npsp__Amount__c;
                }
            }
        }
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
            if (parent instanceof npe01__OppPayment__c && parent.get('npe01__Opportunity__c') != null)
                setParentId.add((Id)parent.get('npe01__Opportunity__c'));
            setParentId.add(parent.id);
        }

        String alloQueryString = 'SELECT Id,Instruction__c, npsp__Payment__c, npsp__Payment__r.npe01__Payment_Amount__c, npsp__Payment__r.npe01__Paid__c, ' +
        'npsp__Payment__r.npe01__Written_Off__c, npsp__Opportunity__c, npsp__Opportunity__r.Amount, npsp__Campaign__c, npsp__Recurring_Donation__c, ' +
            'npsp__Amount__c, npsp__Percent__c, npsp__General_Accounting_Unit__c, npsp__General_Accounting_Unit__r.npsp__Active__c';

        //query for multicurrency string if multicurrency org
        if (UserInfo.isMultiCurrencyOrganization()) {
            alloQueryString += ', CurrencyIsoCode';
        }
        alloQueryString += ' FROM npsp__Allocation__c WHERE (npsp__Payment__c IN :setParentId OR npsp__Opportunity__c IN :setParentId OR npsp__Campaign__c IN :setParentId OR npsp__Recurring_Donation__c IN :setParentId)';
        //alloQueryString += ' AND General_Accounting_Unit__r.Active__c = TRUE';

        for (npsp__Allocation__c allo : database.query(alloQueryString)) {

            //create wrapper if it doesn't exist yet
            if (!mapWrapper.containsKey(getParentId(allo)))
                mapWrapper.put(getParentId(allo), new alloWrapper());

            alloWrapper wrap = mapWrapper.get(getParentId(allo));

            //add opportunity amount and allocation totals
            if (allo.npsp__Opportunity__c != null) {
                wrap.parentAmount = allo.npsp__Opportunity__r.Amount;
            }

            //add payment amount and allocation totals
            if (allo.npsp__Payment__c != null) {
                wrap.parentAmount = allo.npsp__Payment__r.npe01__Payment_Amount__c;
            }

            //save the default allocation.
            if (settings.npsp__Default_Allocations_Enabled__c && allo.npsp__General_Accounting_Unit__c == idDefaultGAU) {
                if (wrap.defaultAllo == null)
                    wrap.defaultAllo = allo;
                else if (wrap.defaultAllo.Id != allo.Id) {
                    wrap.defaultDupesById.put(allo.Id, allo);
                }
                continue;
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
        if (allo.npsp__Payment__c!=null)
            return allo.npsp__Payment__c;
        if (allo.npsp__Opportunity__c!=null)
            return allo.npsp__Opportunity__c;
        if (allo.npsp__Recurring_Donation__c!=null)
            return allo.npsp__Recurring_Donation__c;
        if (allo.npsp__Campaign__c!=null)
            return allo.npsp__Campaign__c;
        if (allo.Instruction__c!=null)
            return allo.Instruction__c;
        return null;
    }


    /*******************************************************************************************************
    * @description Creates a default allocation for the specified Opportunity/Payment.
    * @param parentSObj An Opportunity or Payment.
    * @return Allocation__c A default allocation for the amount of the Opportunity/Payment.
    ********************************************************************************************************/
    public static npsp__Allocation__c makeDefaultAllocation(SObject parentSObj) {

        npsp__Allocation__c defaultAllo = new npsp__Allocation__c(
            npsp__General_Accounting_Unit__c = idDefaultGAU
        );

        if (parentSObj instanceof npe01__OppPayment__c) {
            defaultAllo.npsp__Payment__c = parentSObj.Id;
            defaultAllo.npsp__Amount__c = (Decimal)parentSObj.get('npe01__Payment_Amount__c');
        }

        if (parentSObj instanceof Opportunity) {
            defaultAllo.npsp__Opportunity__c = parentSObj.Id;
            defaultAllo.npsp__Amount__c = (Decimal)parentSObj.get('Amount');
        }

        if (UserInfo.isMultiCurrencyOrganization()) {
            defaultAllo.put('CurrencyIsoCode', parentSObj.get('CurrencyIsoCode'));
        }

        return defaultAllo;
    }

}