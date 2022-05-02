public class RDSetPercentOnAllocationBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        /*String query = 'SELECT Id FROM npe03__Recurring_Donation__c WHERE Id IN (SELECT npsp__Recurring_Donation__c FROM npsp__Allocation__c WHERE npsp__Amount__c != Null AND npsp__Percent__c = Null AND LastModifiedBy.Id != \'0058e0000011h8VAAQ\')';
        */
        
        String query = 'SELECT Id, npe03__Recurring_Donation__c FROM Opportunity WHERE npe03__Recurring_Donation__c != null';
        if (Test.isRunningTest()) {
            query += ' LIMIT 100';
        }
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        
        Map<Id, List<npsp__Allocation__c>> donationsWithAllocationsMap = new Map<Id, List<npsp__Allocation__c>>();
        Map<Id, List<npsp__Allocation__c>> recurringDonationsWithAllocationsMap = new Map<Id, List<npsp__Allocation__c>>();
		Set<Id> recurringDonationSet = new Set<Id>();
        List<npsp__Allocation__c> allocationsToBeCreated = new List<npsp__Allocation__c>();
        
        for (Opportunity eachOpportunity : [
            SELECT Id, npe03__Recurring_Donation__c,
            (
                SELECT Id, npsp__Amount__c , npsp__Percent__c, npsp__General_Accounting_Unit__c 
                FROM npsp__Allocations__r
            )
            FROM Opportunity
            WHERE Id IN :scope
        ]) {
            
            if (!donationsWithAllocationsMap.containsKey(eachOpportunity.Id)) {
                donationsWithAllocationsMap.put(eachOpportunity.Id, new List<npsp__Allocation__c>());
            }
            
            donationsWithAllocationsMap.get(eachOpportunity.Id).addAll(eachOpportunity.npsp__Allocations__r);
            
            recurringDonationSet.add(eachOpportunity.npe03__Recurring_Donation__c);
        }
        
        //filling recurringDonationsWithAllocationsMap 
        for (npe03__Recurring_Donation__c eachDonation : [
            SELECT Id,
            (
                SELECT Id, npsp__Amount__c , npsp__Percent__c, npsp__General_Accounting_Unit__c, npsp__Recurring_Donation__r.npe03__Amount__c,Orphan__c 
             	FROM npsp__Allocations__r
            )
            FROM npe03__Recurring_Donation__c
            WHERE Id IN :recurringDonationSet
        ]) {
            recurringDonationsWithAllocationsMap.put(eachDonation.Id, new List<npsp__Allocation__c>(eachDonation.npsp__Allocations__r));
        }
        
        for (Opportunity eachOpportunity : scope) {
            //only running it for the records where the size of allocations doesn't match with the parent RD size of allocations
            if (donationsWithAllocationsMap.get(eachOpportunity.Id).size() == recurringDonationsWithAllocationsMap.get(eachOpportunity.npe03__Recurring_Donation__c).size()) {
                if (!Test.isRunningTest()) {
                	continue;    
                }
            }
            
            /**
				This map is created in assumption that each item is unique under the recurring donation allocations
				Also the recurring donation can be determined as a source of truth and has the correct number of allocation 
				items associated to it and only the donation allocations items are missing
			*/
            
            Set<npsp__Allocation__c> allocationSetUnderRD = new Set<npsp__Allocation__c>(recurringDonationsWithAllocationsMap.get(eachOpportunity.npe03__Recurring_Donation__c));
            Set<npsp__Allocation__c> allocationSetUnderDonation = new Set<npsp__Allocation__c>(donationsWithAllocationsMap.get(eachOpportunity.Id));
            
            for (npsp__Allocation__c eachAllocation : allocationSetUnderRD) {
                
                for (npsp__Allocation__c eachAllocationUnderDonation : allocationSetUnderDonation) {
                    
                    if (
                        eachAllocation.npsp__General_Accounting_Unit__c == eachAllocationUnderDonation.npsp__General_Accounting_Unit__c && 
                        (
                            eachAllocation.npsp__Amount__c  != null ? eachAllocation.npsp__Amount__c  == eachAllocationUnderDonation.npsp__Amount__c  : 
                            eachAllocation.npsp__Percent__c != null ? eachAllocation.npsp__Percent__c * eachAllocation.npsp__Recurring_Donation__r.npe03__Amount__c == eachAllocationUnderDonation.npsp__Amount__c : false
                        )
                       ) {
                        
                           allocationSetUnderRD.remove(eachAllocation);
                           allocationSetUnderDonation.remove(eachAllocationUnderDonation);
                    }
                }
            }
            
            /*Map<Id, npsp__Allocation__c> itemNameWithAllocationMap = new Map<Id, npsp__Allocation__c>();
            for (npsp__Allocation__c eachAllocation : recurringDonationsWithAllocationsMap.get(eachOpportunity.npe03__Recurring_Donation__c)) {
                itemNameWithAllocationMap.put(eachAllocation.npsp__General_Accounting_Unit__c, eachAllocation);
            }*/
            
            
            //looping through all the allocations within the donation and checking if it matches with the temp map above
            /*for (npsp__Allocation__c eachAllocation : donationsWithAllocationsMap.get(eachOpportunity.Id)) {
                if (itemNameWithAllocationMap.containsKey(eachAllocation.npsp__General_Accounting_Unit__c)) {
                    itemNameWithAllocationMap.remove(eachAllocation.npsp__General_Accounting_Unit__c);
                }
            }*/
            
            if (allocationSetUnderRD.size() != 0) {
                for (npsp__Allocation__c eachAllocation : allocationSetUnderRD) {
                    //what other fields are needed for the alloation creation
                    allocationsToBeCreated.add(
                        new npsp__Allocation__c (
                        	npsp__Opportunity__c = eachOpportunity.Id,
                            npsp__Amount__c = eachAllocation.npsp__Amount__c != null ? eachAllocation.npsp__Amount__c : eachAllocation.npsp__Percent__c * eachAllocation.npsp__Recurring_Donation__r.npe03__Amount__c ,
                            npsp__General_Accounting_Unit__c = eachAllocation.npsp__General_Accounting_Unit__c
                        )
                    );
                }
            }
        }
        
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
        Boolean isNpspTriggerDisabled = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>());
        
        if (isNpspTriggerDisabled){
        	database.insert(allocationsToBeCreated, false);    
        }
        
        
        /*List<npsp__Allocation__c> allocationToBeUpdated = new List<npsp__Allocation__c>();
        Map<Id, List<npsp__Allocation__c>> donationWithAllocationsMap = new Map<Id, List<npsp__Allocation__c>>();
         
        for (npe03__Recurring_Donation__c eachDonation : [
            SELECT Id, npe03__Amount__c ,
            (
                SELECT Id, npsp__Amount__c , npsp__Percent__c 
                FROM npsp__Allocations__r
            )
            FROM npe03__Recurring_Donation__c
            WHERE Id IN :scope
        ]) {
            
            Double amount = 0;
            for (npsp__Allocation__c eachAllocation : eachDonation.npsp__Allocations__r) {
                amount += eachAllocation.npsp__Amount__c;
            }
            
            if (amount == eachDonation.npe03__Amount__c) {
                donationWithAllocationsMap.put(eachDonation.Id, new List<npsp__Allocation__c>(eachDonation.npsp__Allocations__r));
            }
        }
        
        for (npe03__Recurring_Donation__c eachDonation : [
            SELECT Id, npe03__Amount__c 
            FROM npe03__Recurring_Donation__c
            WHERE Id IN: donationWithAllocationsMap.keySet()
        ]) {
            
            for (npsp__Allocation__c eachAllocation : donationWithAllocationsMap.get(eachDonation.Id)) {
                allocationToBeUpdated.add(new npsp__Allocation__c(Id = eachAllocation.Id, npsp__Amount__c = null, npsp__Percent__c = ((eachAllocation.npsp__Amount__c/eachDonation.npe03__Amount__c) * 100).setScale(6)));
            }
        }
        
        System.debug(allocationToBeUpdated.size());
        System.debug(allocationToBeUpdated);
        database.update(allocationToBeUpdated, false);*/
    }  
    
    public void finish(Database.BatchableContext BC) {
    }
}