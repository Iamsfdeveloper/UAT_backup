public class CreateTaskInstructionForRD implements Database.Batchable<sObject>{
    String CLOSED = 'CLOSED';
    String Id = 'a094J00000QOfFpQAL';
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id,Opportunity__c,Opportunity__r.npsp__Primary_Contact__c,npe03__Paid_Amount__c,Remaining_Amount__c,CurrencyISOCode,Regional_Office_Code__c from npe03__Recurring_Donation__c where npsp__Status__c =:CLOSED AND Id=:Id LIMIT 1';
      	return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<npe03__Recurring_Donation__c> listRDs){
        Map<String,String> mapSourceOppsIdRDId = new Map<String,String>();
        Map<String,WrapperDetails> mapWrapperDetails = new Map<String,WrapperDetails>();
        List<Task> listTaskstoInsert = new List<Task>();
        //List<npsp__Allocation__c> listGAUAllocations = new List<npsp__Allocation__c>();
        List<Opportunity> listDonations = new List<Opportunity>();
        //List<Task> listTasks = new List<Task>();
        Map<String,Opportunity> mapRDIdDonation = new Map<String,Opportunity>();
        Map<String,String> mapAllocationIdProductId = new Map<String,String>();
        Map<String,Double> mapProductIdProductPrice = new Map<String,Double>();
        Map<String,String> mapProductIdRDCurrency = new Map<String,String>();
        for(npe03__Recurring_Donation__c eachRD:listRDs){
            mapSourceOppsIdRDId.put(eachRD.Opportunity__c,eachRD.Id);
            if(!mapWrapperDetails.containsKey(eachRD.Id)){
                mapWrapperDetails.put(eachRD.Id,new WrapperDetails());                
            }
            mapWrapperDetails.get(eachRD.Id).RDId = eachRd.Id;
            mapWrapperDetails.get(eachRD.Id).RDTotalAmount = eachRd.npe03__Paid_Amount__c;
            mapWrapperDetails.get(eachRD.Id).CurrencyIsocode = eachRd.CurrencyIsoCode;
            mapWrapperDetails.get(eachRD.Id).ContactId = eachRd.Opportunity__r.npsp__Primary_Contact__c;
            mapWrapperDetails.get(eachRD.Id).RegionalCode = eachRd.Regional_Office_Code__c;
            //instead of remaining balance add how much total is used.
            mapWrapperDetails.get(eachRD.Id).RDRemainingAmount = eachRd.Remaining_Amount__c;//instead we can use it from existing task so no need to update RD
        }
        if(!mapSourceOppsIdRDId.keySet().isEmpty()){
            listDonations = [Select Id,npe03__Recurring_Donation__c,(Select Id,Name__c,npsp__Opportunity__c,npsp__General_Accounting_Unit__c,npsp__General_Accounting_Unit__r.Name,npsp__General_Accounting_Unit__r.Donation_Item_Code__c,npsp__Amount__c from npsp__Allocations__r 
                                        where npsp__General_Accounting_Unit__r.Product_Type__c='Qty-based (Special Request)'
                                        AND npsp__General_Accounting_Unit__r.Skip_Special_Instruction__c=false
                                        ) 
                             from Opportunity where npe03__Recurring_Donation__c IN:mapSourceOppsIdRDId.values()];
            for(Opportunity eachOpp: listDonations){
                if(!mapRDIdDonation.containsKey(eachOpp.npe03__Recurring_Donation__c)){
                    mapRDIdDonation.put(eachOpp.npe03__Recurring_Donation__c,eachOpp);
                }
            }
            for(Opportunity eachOpp:mapRDIdDonation.values()){
                if(mapWrapperDetails.containsKey(eachOpp.npe03__Recurring_Donation__c)){
                    if(eachOpp.npsp__Allocations__r.size()!=0 && !eachOpp.npsp__Allocations__r.isEmpty()){
                        for(npsp__Allocation__c eachAllocation:eachOpp.npsp__Allocations__r){
                            mapAllocationIdProductId.put(eachAllocation.Id,eachAllocation.npsp__General_Accounting_Unit__c);                        
                            mapProductIdRDCurrency.put(eachAllocation.npsp__General_Accounting_Unit__c,mapWrapperDetails.get(eachOpp.npe03__Recurring_Donation__c).CurrencyIsoCode);
                            mapWrapperDetails.get(eachOpp.npe03__Recurring_Donation__c).setGAUAllocations.add(eachAllocation);
            			}
                    }
                }
            }
            List<PriceBookEntry> listPBEntries = new List<PriceBookEntry>();
            listPBEntries = [Select Id,General_Accounting_Unit__c,UnitPrice,CurrencyISoCode from PriceBookEntry where General_Accounting_Unit__c IN:mapProductIdRDCurrency.keySet()];
            for(PriceBookEntry eachPBEntry:listPBEntries){
                if(eachPBEntry.CurrencyIsoCode==mapProductIdRDCurrency.get(eachPBEntry.General_Accounting_Unit__c)){
                    mapProductIdProductPrice.put(eachPBEntry.General_Accounting_Unit__c,eachPBEntry.UnitPrice);                    
                }
            }
            for(String RDId:mapWrapperDetails.keySet()){
                if(mapWrapperDetails.get(RDId).setGAUAllocations.size()!=0 && !mapWrapperDetails.get(RDId).setGAUAllocations.isEmpty()){
                    for(npsp__Allocation__c eachAllocation:mapWrapperDetails.get(RDId).setGAUAllocations){
                        if(mapWrapperDetails.get(RDId).RDTotalAmount>=mapProductIdProductPrice.get(mapAllocationIdProductId.get(eachAllocation.Id))){//eachAllocation.npsp__Amount__c
                            Task newTask = new Task();
                            newTask.WhatId = mapWrapperDetails.get(RDId).RDId;
                            newTask.GAU_Allocation__c = eachAllocation.Id;
                            newTask.Subject = eachAllocation.npsp__General_Accounting_Unit__r.Name+'-'+eachAllocation.npsp__General_Accounting_Unit__r.Donation_Item_Code__c;
                            newTask.ActivityDate = Date.today()+15;
                            newTask.Priority = 'Normal';
                            newTask.Status = 'Open';
                            newTask.WhoId = mapWrapperDetails.get(RDId).ContactId;
                            newTask.Additional_Notes__c = eachAllocation.Name__c;
                            newTask.Regional_Office_Code__c = mapWrapperDetails.get(RDId).RegionalCode;
                            newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Special_Instructions').getRecordTypeId();
                            mapWrapperDetails.get(RDId).RDTotalAmount = mapWrapperDetails.get(RDId).RDTotalAmount - mapProductIdProductPrice.get(mapAllocationIdProductId.get(eachAllocation.Id));//eachAllocation.npsp__Amount__c;
                            listTaskstoInsert.add(newTask);
                    	}                        
                    }
                }
            }
            if(!listTaskstoInsert.isEmpty()){
                insert listTaskstoInsert;
            }
            /*listGAUAllocations = [Select Id,npsp__Opportunity__c,npsp__General_Accounting_Unit__c,npsp__General_Accounting_Unit__r.Name,npsp__Amount__c from npsp__Allocation__c where npsp__Opportunity__c=:mapSourceOppsIdRDId.keySet()
                                  AND npsp__General_Accounting_Unit__r.Product_Type__c='Qty-based (Special Request)'
                                  AND npsp__General_Accounting_Unit__r.Skip_Special_Instruction__c=false ORDER BY npsp__Amount__c ASC];
            listTasks = [Select Id,WhoId,Remaining_Amount__c,GAU_Allocation__c from Task where WhoId=:mapSourceOppsIdRDId.values() ORDER BY CreatedDate ASC];
            if(!listGAUAllocations.isEmpty()){
                for(npsp__Allocation__c eachAllocation:listGAUAllocations){
                	if(mapWrapperDetails.containsKey(mapSourceOppsIdRDId.get(eachAllocation.npsp__Opportunity__c))){
                    	mapWrapperDetails.get(mapSourceOppsIdRDId.get(eachAllocation.npsp__Opportunity__c)).listGAUAllocations.add(eachAllocation);
                	}
            	}
            }
            if(!listTasks.isEmpty()){
                for(Task eachTask:listTasks){
                	if(mapWrapperDetails.containsKey(mapSourceOppsIdRDId.get(eachTask.WhoId))){
                    	mapWrapperDetails.get(mapSourceOppsIdRDId.get(eachTask.WhoId)).listTasks.add(eachTask);
                        mapWrapperDetails.get(mapSourceOppsIdRDId.get(eachTask.WhoId)).RDRemainingAmount = eachTask.Remaining_Amount__c;
                	}
            	}
            }
            for(npe03__Recurring_Donation__c eachRD:listRDs){
                if(mapWrapperDetails.get(eachRD.Id).listTasks.size()==0 || mapWrapperDetails.get(eachRD.Id).listTasks.isEmpty()){
                    for(npsp__Allocation__c eachAllocation:mapWrapperDetails.get(eachRD.Id).listGAUAllocations){
                        if(mapWrapperDetails.get(eachRD.Id).RDRemainingAmount==0 || mapWrapperDetails.get(eachRD.Id).RDRemainingAmount==null){
                            if(mapWrapperDetails.get(eachRD.Id).RDTotalAmount>=eachAllocation.npsp__Amount__c){
                                Task newTask = new Task();
                                newTask.WhoId = eachRD.Id;
                                newTask.GAU_Allocation__c = eachAllocation.npsp__General_Accounting_Unit__c;
                                newTask.Subject = 'Create Instruction for '+ eachAllocation.npsp__General_Accounting_Unit__r.Name;
                                newTask.ActivityDate = Date.newInstance(2021, 11, 30);
                                newTask.Priority = 'High';
                                newTask.Status = 'Open';
                                newTask.Remaining_Amount__c = mapWrapperDetails.get(eachRD.Id).RDTotalAmount - eachAllocation.npsp__Amount__c;
                                mapWrapperDetails.get(eachRD.Id).RDTotalAmount = mapWrapperDetails.get(eachRD.Id).RDTotalAmount - eachAllocation.npsp__Amount__c;
                            }
                        }
                    }
                }
            }*/
        }
    }
    public void finish(Database.BatchableContext BC){}
    public class WrapperDetails{
        Id RDId;
        String CurrencyIsocode;
        Id ContactId;
        String RegionalCode;
        List<npsp__Allocation__c> listGAUAllocations;
        Set<npsp__Allocation__c> setGAUAllocations;
        List<Task> listTasks;
        Double RDTotalAmount;
        Double RDRemainingAmount;
        Double RDToalUsedAmount;
        public WrapperDetails(){
            this.listGAUAllocations = new List<npsp__Allocation__c>();
            this.listTasks = new List<Task>();
            this.setGAUAllocations = new Set<npsp__Allocation__c>();
        }
    }
}