/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 10-11-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   07-19-2021   Iamsfdeveloper   Initial Version
**/
public with sharing class createInstruction {

    @AuraEnabled(cacheable=true) 
    public static Map<String,Object> doInit(){
        Map<String,Object>  returnValue= new Map<String,Object>();
        List<HA_selectOption> stipulationType = new List<HA_selectOption>();
        List<HA_selectOption> countryList = new List<HA_selectOption>();
        
        for(Schema.PicklistEntry ple:npsp__General_Accounting_Unit__c.Stipulation__c.getDescribe().getPicklistValues()){
            stipulationType.add(new HA_selectOption(ple.getLabel(),ple.getValue()));
        }
        returnValue.put('stipulationType',(Object)stipulationType);
        for(Schema.PicklistEntry ple:npsp__General_Accounting_Unit__c.Country__c.getDescribe().getPicklistValues()){
            countryList.add(new HA_selectOption(ple.getLabel(),ple.getValue(),ple.isDefaultValue()));
        }
        returnValue.put('countryList',(Object)countryList);
        returnValue.put('today',System.today());
        returnValue.put('currencyISOCode',(Object)UserInfo.getDefaultCurrency());
        return returnValue;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getItems(String queryFilter , String currencyISOCode){
        Map<String,Object> returnValue = new Map<String,Object>();
        Set<Id> itemsIds = new Set<Id>();
        String currencyISOCodeFilter = 'WHERE CurrencyIsoCode =\''+currencyISOCode+'\'';
        String query = 'SELECT Id,Country__c,Sponsored_Orphan_Only__c,Skip_Special_Instruction__c,Price_Editable__c,Product_Type__c,Special_message__c,Donation_Item_Code__c,Name,toLabel(Stipulation__c) stipulationlabel,Stipulation__c ,(Select UnitPrice,Annual_Price__c,CurrencyIsoCode  FROM Price_Book_Entries__r '+currencyISOCodeFilter+') FROM npsp__General_Accounting_Unit__c Where npsp__Active__c=true AND ( Regional_Office_code__c =\'All\' or Regional_Office_code__c =\''+HA_utility.getUserInfoRegionalCode()+'\') AND  (Product_Type__c = \'Qty-based (Special Request)\' or ( Product_Type__c = \'Sponsorship\' AND Sponsored_Orphan_Only__c = false AND Country__c=\'General\'))';
        System.debug('QueryFilter '+queryFilter);
        if(String.isNotEmpty(queryFilter)) 
            query = 'SELECT Id,Country__c,Sponsored_Orphan_Only__c,Skip_Special_Instruction__c,Price_Editable__c,Product_Type__c,Donation_Item_Code__c,Special_message__c,Name,toLabel(Stipulation__c) stipulationlabel,Stipulation__c,(Select UnitPrice,Annual_Price__c,CurrencyIsoCode  FROM Price_Book_Entries__r '+currencyISOCodeFilter+') FROM npsp__General_Accounting_Unit__c WHERE  npsp__Active__c=true AND ( Regional_Office_code__c =\'All\' or Regional_Office_code__c =\''+HA_utility.getUserInfoRegionalCode()+'\') AND '+queryFilter;
        System.debug('QueryFilter '+query);
        List<npsp__General_Accounting_Unit__c> ItemList = Database.query(query);
        returnValue.put('items',ItemList);
        return returnValue;
    }
    @AuraEnabled(cacheable=true)
    public static Campaign getCampaignDetails(String recordId){
        return [Select Id,Name,Description,Available_Amount__c,Donor__c,(Select Id,CurrencyISOCode,npsp__Opportunity__c,npsp__General_Accounting_Unit__c,npsp__General_Accounting_Unit__r.Stipulation__c,npsp__General_Accounting_Unit__r.Id,npsp__General_Accounting_Unit__r.Country__c,npsp__General_Accounting_Unit__r.Sponsored_Orphan_Only__c,npsp__General_Accounting_Unit__r.Skip_Special_Instruction__c,npsp__General_Accounting_Unit__r.Price_Editable__c,npsp__General_Accounting_Unit__r.Product_Type__c,npsp__General_Accounting_Unit__r.Special_message__c,npsp__General_Accounting_Unit__r.Donation_Item_Code__c,npsp__General_Accounting_Unit__r.Name,toLabel(Stipulation_Type__c) stipulationlabel, npsp__Amount__c, Stipulation_Type__c, Receipt_Note__c, Country__c,Orphan__c From npsp__Allocations__r ),Regional_Office_code__c From Campaign Where Id=:recordId and IsActive = true ];
    }
    @AuraEnabled
    public static Instruction__c saveAllocation(String instructionDetail,String itemAllocation){
        
        List<npsp__Allocation__c> allocationList = new List<npsp__Allocation__c>();
        Instruction__c inst = new Instruction__c();
        try{
            if(String.isNotEmpty(instructionDetail)){
                inst = (Instruction__c)JSON.deserialize(instructionDetail,Instruction__c.class);
                upsert inst;
            }
        if(String.isNotEmpty(itemAllocation)){
            System.debug('itemAllocation  '+itemAllocation);
            allocationList = (List<npsp__Allocation__c>)JSON.deserialize(itemAllocation,List<npsp__Allocation__c>.class);
            
            for(Integer i=0;i<allocationList.size();i++){
                //allocationList[i].Type__c = 'Debit';
                allocationList[i].Instruction__c = inst.id;
            }
            System.debug('allocationList '+allocationList);
           if(allocationList.size()>0)
            upsert allocationList;
        }
        }Catch(Exception ex){
             System.debug(ex.getStackTraceString());
        }
        return inst;
        
    }
      //Custom Exception class
      public class CustomException extends Exception {
        
    }
}