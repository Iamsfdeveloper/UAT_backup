/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 02-02-2022
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   11-16-2020   Iamsfdeveloper   Initial Version
**/

public  without Sharing class HA_newDonationController {
   
    public static Map<Id,Decimal> getItemsPriceByCampaignId(String campaignId , String currencyISOCode){
        Map<Id,Decimal> ItemsIdByPriceMap = new Map<Id,Decimal>();
       for(Campaign_Product_Allocation__c CPA:[Select Id,Item__c,Item_Price__c,CurrencyIsoCode FROM Campaign_Product_Allocation__c Where Campaign__c=:campaignId AND CurrencyIsoCode=:currencyISOCode])
            ItemsIdByPriceMap.put(CPA.Item__c,CPA.Item_Price__c);
       return ItemsIdByPriceMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getItems(String queryFilter , String currencyISOCode,String paymentScheduleId,String campaignId,String regOfficeCode){
        System.debug('***regionalOfficeCode**:-'+regOfficeCode);
        Map<String,Object> returnValue = new Map<String,Object>();
        Set<Id> itemsIds = new Set<Id>();
        String regionalOfficeCode = 'UK';
        
        for(Payment_Schedule_Allocation__c PSA:[Select Id,General_Accounting_Unit__c, Payment_Schedule__c FROM Payment_Schedule_Allocation__c Where Payment_Schedule__c =:paymentScheduleId AND General_Accounting_Unit__c != null AND General_Accounting_Unit__r.npsp__Active__c=true  and (General_Accounting_Unit__r.Regional_Office_code__c = 'All' or General_Accounting_Unit__r.Regional_Office_code__c =: regOfficeCode)]){
                
            itemsIds.add(PSA.General_Accounting_Unit__c);
        }
        
        if (regOfficeCode == 'US' || regOfficeCode == 'IE') {
            set<Id> pbItems = new set<Id>();
            
            regionalOfficeCode = regOfficeCode;
            for(PriceBookEntry pbe: [SELECT Id, General_Accounting_unit__c FROM PriceBookEntry WHERE Pricebook2.Regional_office_Code__c =:regOfficeCode and General_Accounting_unit__c != null]){
                if(pbe.General_Accounting_unit__c != null)
                    pbItems.add(pbe.General_Accounting_unit__c);
            }
            String currencyISOCodeFilter = 'WHERE CurrencyIsoCode =\''+currencyISOCode+'\' AND Pricebook2.Regional_office_Code__c =\''+regionalOfficeCode+'\'';
            String query = 'SELECT Id,Country__c,Sponsored_Orphan_Only__c,Skip_Special_Instruction__c,Price_Editable__c,Product_Type__c,Special_message__c,Donation_Item_Code__c,Name,toLabel(Stipulation__c) stipulationlabel,Stipulation__c ,(Select UnitPrice,Annual_Price__c,CurrencyIsoCode  FROM Price_Book_Entries__r '+currencyISOCodeFilter+'  ) FROM npsp__General_Accounting_Unit__c Where Id IN: itemsIds ';
            System.debug('QueryFilter '+queryFilter);
            if(String.isNotEmpty(queryFilter)) 
                query = 'SELECT Id,Country__c,Sponsored_Orphan_Only__c,Skip_Special_Instruction__c,Price_Editable__c,Product_Type__c,Donation_Item_Code__c,Special_message__c,Name,toLabel(Stipulation__c) stipulationlabel,Stipulation__c,(Select UnitPrice,Annual_Price__c,CurrencyIsoCode  FROM Price_Book_Entries__r '+currencyISOCodeFilter+') FROM npsp__General_Accounting_Unit__c WHERE  Id IN: itemsIds AND '+queryFilter;
            System.debug('QueryFilter '+query);
            List<npsp__General_Accounting_Unit__c> ItemList = Database.query(query);
            for(Integer i=0;i<ItemList.size();i++){
                if(ItemList[i].Product_Type__c =='Qty-based (Special Request)' && !pbItems.contains(ItemList[i].Id))
                  ItemList.remove(i);
            }
            If(String.isNotEmpty(campaignId)){
                returnValue.put('campaignItemPrice',getItemsPriceByCampaignId(campaignId,currencyISOCode));
            }
            returnValue.put('items',ItemList);
        }
        else{
        
        String currencyISOCodeFilter = 'WHERE CurrencyIsoCode =\''+currencyISOCode+'\' AND Pricebook2.Regional_office_Code__c =\''+regionalOfficeCode+'\'';
        String query = 'SELECT Id,Country__c,Sponsored_Orphan_Only__c,Skip_Special_Instruction__c,Price_Editable__c,Product_Type__c,Special_message__c,Donation_Item_Code__c,Name,toLabel(Stipulation__c) stipulationlabel,Stipulation__c ,(Select UnitPrice,Annual_Price__c,CurrencyIsoCode  FROM Price_Book_Entries__r '+currencyISOCodeFilter+'  ) FROM npsp__General_Accounting_Unit__c Where Id IN: itemsIds ';
        System.debug('QueryFilter '+queryFilter);
        if(String.isNotEmpty(queryFilter)) 
            query = 'SELECT Id,Country__c,Sponsored_Orphan_Only__c,Skip_Special_Instruction__c,Price_Editable__c,Product_Type__c,Donation_Item_Code__c,Special_message__c,Name,toLabel(Stipulation__c) stipulationlabel,Stipulation__c,(Select UnitPrice,Annual_Price__c,CurrencyIsoCode  FROM Price_Book_Entries__r '+currencyISOCodeFilter+') FROM npsp__General_Accounting_Unit__c WHERE  Id IN: itemsIds AND '+queryFilter;
        System.debug('QueryFilter '+query);
        List<npsp__General_Accounting_Unit__c> ItemList = Database.query(query);
        If(String.isNotEmpty(campaignId)){
            returnValue.put('campaignItemPrice',getItemsPriceByCampaignId(campaignId,currencyISOCode));
        }
        returnValue.put('items',ItemList);
        }
        return returnValue;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> doInit(String regOfficeCode) {
        Map<String,Object>  returnValue= new Map<String,Object>();
        List<HA_selectOption> stipulationType = new List<HA_selectOption>();
        List<HA_selectOption> countryList = new List<HA_selectOption>();
        returnValue.put('single',(Object)Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId());
        for(Schema.PicklistEntry ple:npsp__General_Accounting_Unit__c.Stipulation__c.getDescribe().getPicklistValues()){
            stipulationType.add(new HA_selectOption(ple.getLabel(),ple.getValue()));
        }
        returnValue.put('stipulationType',(Object)stipulationType);
        for(Schema.PicklistEntry ple:npsp__General_Accounting_Unit__c.Country__c.getDescribe().getPicklistValues()){
            countryList.add(new HA_selectOption(ple.getLabel(),ple.getValue(),ple.isDefaultValue()));
        }
        returnValue.put('countryList',(Object)countryList);
        returnValue.put('today',System.today());
        System.debug('****regOfficeCode:--'+regOfficeCode);
        if (regOfficeCode == 'US') {

            returnValue.put('currencyISOCode',(Object)'USD');
        }
        else if (regOfficeCode == 'ES' || regOfficeCode == 'IE') {

            returnValue.put('currencyISOCode',(Object)'EUR');
        }
        else {
            returnValue.put('currencyISOCode',(Object)UserInfo.getDefaultCurrency());
        }
        
        return returnValue;
    }
    @AuraEnabled
    public static Opportunity saveAllocation(String opportunityDetail,String itemAllocation, String specialInstruction,String recurringDonations,String regOfficeCode){
        
        String guid = HA_Utility.generateGUID();
        Map<Integer,Id> specialIndexMap = New Map<Integer,Id>();
        List<npsp__Allocation__c> allocationList = new List<npsp__Allocation__c>();
        Opportunity opp = new Opportunity();
		System.debug('recurringDonations'+recurringDonations);
        List<Opportunity> recurringDonationsList = new List<Opportunity>();
		List<npe01__OppPayment__c> scheduleList =(String.isNotEmpty(recurringDonations))?(List<npe01__OppPayment__c>)JSON.deserialize(recurringDonations, List<npe01__OppPayment__c>.class):new List<npe01__OppPayment__c>();
        List<npe01__OppPayment__c> paymentsToInsert = new List<npe01__OppPayment__c>();
        Id CardPaymentRecTypeId = Schema.SObjectType.npe01__OppPayment__c.getRecordTypeInfosByDeveloperName().get('Card_Payment').getRecordTypeId();
        try{
            if(String.isNotEmpty(opportunityDetail)){
                opp = (Opportunity)JSON.deserialize(opportunityDetail,Opportunity.class);
				opp.GUID__c = guid;
                if(scheduleList.size()>0){
                  opp.Number_of_Installments__c = scheduleList.size();
				  opp.Effective_Date__c =   scheduleList[0].npe01__Payment_Date__c;
                }
                upsert opp;
            }
            /**Item Allocations */
       Decimal TotalPercentage = 100.000000;
 	   Decimal allocatedPercentage = 0;
        if(String.isNotEmpty(itemAllocation)){
            allocationList = (List<npsp__Allocation__c>)JSON.deserialize(itemAllocation,List<npsp__Allocation__c>.class);
            for(Integer i=0;i<allocationList.size();i++){
                Decimal ItemPercentage = (opp.Amount != null && opp.Amount != 0.00)?((allocationList[i].npsp__Amount__c/opp.Amount)*100).setScale(6):null;
                if(ItemPercentage != null){
                    if((allocatedPercentage+ItemPercentage)>TotalPercentage)
                        ItemPercentage = (TotalPercentage - (allocatedPercentage)).setScale(6);	
                    else
                        allocatedPercentage +=ItemPercentage;
                }
                allocationList[i].npsp__Opportunity__c = opp.id;
                allocationList[i].npsp__Percent__c = ItemPercentage;
                if (regOfficeCode == 'US') {

                    allocationList[i].CurrencyIsoCode = 'USD';
                }
            }
            System.debug('***allocationList**:--'+allocationList);
            if(allocationList.size()>0)
            upsert allocationList;
        }
        if(opp.Donation_Type__c =='10D' || opp.Donation_Type__c =='10N' || opp.Donation_Type__c=='30N'){
          
             for(npe01__OppPayment__c p:scheduleList){
                npe01__OppPayment__c payment = p.clone();
                payment.Payment_Reference__c = HA_Utility.generateGUID();
                payment.npsp__Type__c='Sale';
                payment.CurrencyIsoCode = Opp.currencyIsoCode;
                payment.npe01__Opportunity__c = Opp.Id;
                payment.RecordTypeId=CardPaymentRecTypeId;
                payment.npe01__Payment_Method__c = 'Card Payment';
                paymentsToInsert.add(payment);
                }
        }
        if(paymentsToInsert.size()>0)
        upsert paymentsToInsert;
       
        }catch (DmlException de) {
            Integer numErrors = de.getNumDml();
            System.debug('getNumDml=' + numErrors);
            for(Integer i=0;i<numErrors;i++) {
                throw new CustomException(de.getDmlMessage(i));
            }
           
        }Catch(Exception ex){
            throw new CustomException(ex.getMessage());
        }
        return opp;
        
    }
   @AuraEnabled(cacheable=true)
    public static List<contact> getOrphanList(String selectedCountry,String recordId,String selectedAge,String selectedGender,String searchParam,string[] selectedRowIds, string selectedStatus){
        List<contact> orphanList = new List<contact>();
        System.debug('recordId '+recordId);
        if(String.isEmpty(recordId)){
            String query = 'SELECT Name,Id,Orphan_Is_Mother_Alive__c,Sponsoree_ID__c,Country__c,Current_Age__c ,Gender__c,Sponsorship_Status__c FROM Contact Where RecordType.DeveloperName=\'Orphan\' AND Is_Active__c=true AND Sponsorship_Status__c != \'Sponsored\' AND Sponsoree_Is_Reserved__c = false AND Sponsoree_ID__c !=\'DefaultOrphan\'';
         	
            String queryFilter = '';
            
    
            if(String.isNotEmpty(searchParam)){
                String nameorId = '%'+searchParam+'%';
                queryFilter += ' AND ( Name like :nameorId OR Sponsoree_ID__c like :nameorId ) ';
            }
            
            if(String.isNotEmpty(selectedCountry) && selectedCountry != 'General')
                queryFilter += ' AND Country__c=\''+selectedCountry+'\' ';
            if(String.isNotEmpty(selectedGender))
                queryFilter += ' AND Gender__c=\''+selectedGender+'\' ';
            if(String.isNotEmpty(selectedAge))
                queryFilter += ' AND '+selectedAge;
            if(String.isNotEmpty(selectedStatus))
                queryFilter += ' AND Sponsorship_Status__c=\''+selectedStatus+'\' ';//added to filter out by sponsorship Status - 18/04
            query += queryFilter+' order by Sponsorship_Status__c desc  limit 70';
            System.debug('query===>'+query);
                orphanList = Database.query(query);
            }else{
                set<String> OrphanIds = new Set<String>();
                for(Sponsorship__c sp : [SELECT Orphan__c FROM Sponsorship__c Where Donor__c =:recordId and IsActive__c = true]){
                    OrphanIds.add(sp.Orphan__c);
                }
                orphanIds.addAll(selectedRowIds);
                orphanList = [SELECT Name,Id,Orphan_Is_Mother_Alive__c,Sponsoree_ID__c,Country__c,Current_Age__c ,Gender__c,Sponsorship_Status__c FROM Contact Where RecordType.DeveloperName='Orphan' AND Is_Active__c=true  AND Id IN:orphanIds];// OR Id=:selectedRowIds)
                
            }
        return orphanList;
    }
    @AuraEnabled(cacheable=true)
    public static List<contact> getOrphanByNameOrId(String searchParam,String country){
        List<contact> orphanList = new List<contact>();
        if(String.isNotEmpty(searchParam)){
            string queryFilter = '%'+searchParam+'%';
            if(country !='General'){
                orphanList = [SELECT Name,Id,Orphan_Is_Mother_Alive__c,Sponsoree_ID__c,Country__c,Age__c,Gender__c,Sponsorship_Status__c FROM Contact Where RecordType.DeveloperName='Orphan' AND Is_Active__c=true AND Sponsorship_Status__c != 'Sponsored' AND Sponsoree_Is_Reserved__c = false  AND Country__c=:country AND (Name like :queryFilter OR Sponsoree_ID__c like :queryFilter) AND Sponsoree_ID__c !='DefaultOrphan' order by Sponsorship_Status__c desc limit 100];
            }else{
                orphanList = [SELECT Name,Id,Orphan_Is_Mother_Alive__c,Sponsoree_ID__c,Country__c,Age__c,Gender__c,Sponsorship_Status__c FROM Contact Where RecordType.DeveloperName='Orphan' AND Is_Active__c=true AND Sponsorship_Status__c != 'Sponsored' AND Sponsoree_Is_Reserved__c = false  AND (Name like :queryFilter OR Sponsoree_ID__c like :queryFilter) AND Sponsoree_ID__c !='DefaultOrphan' order by Sponsorship_Status__c desc limit 100];
            }
        }
        return orphanList;
    }
    @AuraEnabled
    public static Boolean createTask(String obj,String parentRecordId){
        Task taskObj = (Task)JSON.deserialize(obj,Task.class);
		system.debug('parentRecordId'+parentRecordId);
        try {
            taskObj.ActivityDate = System.Today();
            if(!Test.isRunningTest() && parentRecordId instanceOf Id){
                AgentWork aw = [SELECT HandleTime, ActiveTime, SpeedToAnswer, CloseDateTime, AcceptDateTime, ServiceChannelId, Status, WorkItemId, UserId, Name, Id, AssignedDateTime, CreatedDate, LastModifiedDate, LastModifiedById FROM AgentWork WHERE WorkItemId=:parentRecordId order by CreatedDate  DESC limit 1];
                Long timediff = (System.now().getTime() - aw.AssignedDateTime.getTime())/1000;
                taskObj.CallDurationInSeconds = (Integer)timediff;
            }
            insert taskObj;
			if(parentRecordId instanceOf Id)
            updateCampaingMemberWithOutcome(taskObj.Call_OutCome__c,parentRecordId);
            return true;
        } catch (Exception ex) {
            throw new CustomException(ex.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean createTaskAndUpdateRecord(String obj,String parentRecordId,String updateObj){
        Task taskObj = (Task)JSON.deserialize(obj,Task.class);
        Contact contactObj = (Contact)JSON.deserialize(updateObj, Contact.class);
        try {
            taskObj.ActivityDate = System.Today();
            if(!Test.isRunningTest()){
                AgentWork aw = [SELECT HandleTime, ActiveTime, SpeedToAnswer, CloseDateTime, AcceptDateTime, ServiceChannelId, Status, WorkItemId, UserId, Name, Id, AssignedDateTime, CreatedDate, LastModifiedDate, LastModifiedById FROM AgentWork WHERE WorkItemId=:parentRecordId order by CreatedDate  DESC limit 1];
                Long timediff = (System.now().getTime() - aw.AssignedDateTime.getTime())/1000;
                taskObj.CallDurationInSeconds = (Integer)timediff;
            }
            insert taskObj;
            updateCampaingMemberWithOutcome(taskObj.Call_OutCome__c,parentRecordId);
            upsert contactObj;
            return true;
        } catch (Exception ex) {
           throw new CustomException(ex.getMessage());
        }
    }
    
  
    public static void updateCampaingMemberWithOutcome(String callOutcome,String callRecordId){
        CampaignMember cm = [SELECT Id, Status, Call_List_Id__c FROM CampaignMember Where Call_List_Id__c=:callRecordId limit 1];
        cm.Status = callOutcome;
        upsert new Call_List__c(Id=callRecordId,isClosed__c=true);
        upsert cm;
	}
    
    //Custom Exception class
    public class CustomException extends Exception {
        
    }

    /**
    * @description 
    * @author Iamsfdeveloper | 06-23-2021 
    * @return List<HA_selectOption> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<HA_selectOption>  getCountryList(){
        List<HA_selectOption> countryList = new List<HA_selectOption>();
        try {
            for(Schema.PicklistEntry ple:npsp__General_Accounting_Unit__c.Country__c.getDescribe().getPicklistValues()){
                if(ple.getLabel() !='General')
                    countryList.add(new HA_selectOption(ple.getLabel(),ple.getValue(),ple.isDefaultValue()));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return countryList;
    }
    
}