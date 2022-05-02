/**
* @description       : 
* @author            : Iamsfdeveloper
* @group             : 
* @last modified on  : 13-04-2022
* @last modified by  : Iamsfdeveloper
* Modifications Log 
* Ver   Date         Author           Modification
* 1.0   13-04-2022   Iamsfdeveloper   Initial Version
**/
global class GAU_ValidationHandler {
    public static List<String> lstOfRecTypeId = new List<String>{Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Donor_Pledge').getRecordTypeId(), Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Pledge').getRecordTypeId()};
        
    global static void createCallList(List<Campaign> newList){          
        Set<String> lstOfCampaign = new Set<String>();            
        for(Campaign newRec : newList){
            if(newRec.isActive == TRUE && lstOfRecTypeId.contains(newRec.RecordTypeId)){
                lstOfCampaign.add(newRec.Id);
            }
        }
        
        if(lstOfCampaign.size() > 0){
            checkValidation(lstOfCampaign, newList);
        }
    }
    
    global static void createCallList(List<Campaign> newList, List<Campaign> oldList){        
        Map<Id, Campaign> oldCampaign = new Map<Id, Campaign>(oldList);
        Set<String> lstOfCampaign = new Set<String>();
        
        for(Campaign newRec : newList){
            if(newRec.isActive == TRUE && oldCampaign.get(newRec.Id).isActive == FALSE && lstOfRecTypeId.contains(newRec.RecordTypeId)){
                lstOfCampaign.add(newRec.Id);
            }
        }  
        
        if(lstOfCampaign.size() > 0){
            checkValidation(lstOfCampaign, newList);
        }       
    }
    
    public static void checkValidation(Set<String> lstOfCampaign, List<Campaign> newList){
        List<npsp__Allocation__c> lstOfItemAllocation = new List<npsp__Allocation__c>();
        Map<Id, npsp__Allocation__c> mapOfIdVsAllocation = new Map<Id, npsp__Allocation__c>();
        
        if(lstOfCampaign.size() > 0){
            lstOfItemAllocation = [SELECT Id , npsp__Campaign__c FROM npsp__Allocation__c WHERE npsp__Campaign__c IN :lstOfCampaign AND npsp__General_Accounting_Unit__c <> NULL];
        }
        
        for(npsp__Allocation__c eachRec : lstOfItemAllocation){
            mapOfIdVsAllocation.put(eachRec.npsp__Campaign__c, eachRec);           
        }
        
        for(Campaign newRec : newList){
            if(!mapOfIdVsAllocation.containsKey(newRec.Id)){
                newRec.addError('Atleast 1 Pledge Holding Item is required to activate a Pledge');
            }
        }
    }
    
}