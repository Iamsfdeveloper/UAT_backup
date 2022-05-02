/**
* @description       : 
* @author            : Iamsfdeveloper
* @group             : 
* @last modified on  : 06-30-2021
* @last modified by  : Iamsfdeveloper
* Modifications Log 
* Ver   Date         Author           Modification
* 1.0   06-07-2021   Iamsfdeveloper   Initial Version
**/
global class BulkUploadProcessFutureCampaign  implements Database.Batchable<sObject>, Database.Stateful{
    public  Set<String> donorIds = new Set<String>();
    public  Set<String> accountIds = new Set<String>();
    public  Set<String> contactIds = new Set<String>();
    public  static Map<String,ID> donorIdToContactIDMap = new Map<String,ID>();
    public  static Map<String,ID> campaignNameToIDMap = new Map<String,ID>();
    public  static Map<String,Bulk_Upload_Data__c> donorIdItemMap = new Map<String,Bulk_Upload_Data__c>();    
    public  Set<String> parentCampaign = new Set<String>();
    public  Static Id oppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId(); 
    public  Integer rowIndex = 0;
    public   List<Bulk_Upload_Data__c> dataInsertList = new List<Bulk_Upload_Data__c>();    
    public  String ErrorMessage;
    public  Id bulkRecordId;
    public  String upLoadType;
    public String dataFromSpreadsheet;
    public Boolean singleRun;
    public String query;
    public String recordTypeId;
    
    public BulkUploadProcessFutureCampaign(Id recId,String upType,String dataString,Boolean singleRunExecution) {
        this.bulkRecordId = recId;
        this.upLoadType = upType;
        dataFromSpreadsheet = dataString;
        singleRun = singleRunExecution; 
        if(upType == 'Pledge'){
            this.recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Pledge').getRecordTypeId();
        }else{
            this.recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Donor_Pledge').getRecordTypeId();
        }         
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('dataFromSpreadsheet=='+dataFromSpreadsheet);
        try{
            if(!String.isBlank(dataFromSpreadsheet) && singleRun == false){
                dataFromSpreadsheet = dataFromSpreadsheet.replace('Primary Campaign: Campaign Name', 'name');
                dataFromSpreadsheet = dataFromSpreadsheet.replace('Donor', 'donorId');
                dataFromSpreadsheet = dataFromSpreadsheet.replace('Description', 'description');
                dataFromSpreadsheet = dataFromSpreadsheet.replace('Fundraising page url', 'fundraisingURL');
                dataFromSpreadsheet = dataFromSpreadsheet.replace('Source', 'source');
                dataFromSpreadsheet = dataFromSpreadsheet.replace('Department', 'department');
                dataFromSpreadsheet = dataFromSpreadsheet.replace('Campaign Currency', 'currCode');
                dataFromSpreadsheet = dataFromSpreadsheet.replace('Active', 'isActive');
                dataFromSpreadsheet = dataFromSpreadsheet.replace('Status', 'status');
                dataFromSpreadsheet = dataFromSpreadsheet.replace('Holding Item code', 'donationItemCode');
                dataFromSpreadsheet = dataFromSpreadsheet.replace('Parent Campaign (Team Link)', 'parentCampaign');
                System.debug('dataFromSpreadsheet=='+dataFromSpreadsheet);
                List<CsvWrapper> dataList = (List<csvWrapper>)JSON.deserialize(dataFromSpreadsheet, List<CsvWrapper>.class);                 
                for(CsvWrapper c : dataList){ 
                    System.debug('c=='+c);
                    Bulk_Upload_Data__c tempList = new Bulk_Upload_Data__c ();
                    if(!String.isBlank(c.name)){
                        tempList.CampaignName__c  = c.name;
                        tempList.donorId__c = c.donorId;
                        tempList.Campaign_Description__c = c.description;
                        tempList.fundRaisingUrl__c = c.fundraisingURL;
                        tempList.Campaign_Department__c = c.department;                    
                        tempList.currCode__c = c.currCode;
                        tempList.Campaign_Active__c = c.isActive;
                        tempList.stage__c = c.status;
                        tempList.primaryCampaignSource__c = c.source;
                        tempList.itemCode__c = c.donationItemCode;
                        tempList.Campaign_Parent__c = c.parentCampaign;    
                        tempList.File_Name__c = bulkRecordId;
                        dataInsertList.add(tempList);
                    }
                    
                }
                Insert dataInsertList;            
                query = 'SELECT id,donorId__c,itemCode__c,File_Name__r.Upload_File_Type__c,CampaignName__c,'+
                    'stage__c,currCode__c,Campaign_Description__c,fundRaisingUrl__c,Campaign_Department__c,'+
                    'primaryCampaignSource__c,Campaign_Active__c, Campaign_Parent__c,'+
                    'File_Name__c,Row_Index__c FROM Bulk_Upload_Data__c WHERE File_Name__c='+'\''+bulkRecordId+'\'';
                
            }
        }Catch(Exception e){                
            ErrorMessage = e.getMessage();                
        }        
        system.debug('query'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Bulk_Upload_Data__c> scope) {
        
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
        Boolean isNpspTriggerDisabled = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>());
        
        for(Bulk_Upload_Data__c c : scope){	
            if(!String.isBlank(c.donorId__c)){
                donorIds.add(c.donorId__c);               
            }
            if(!String.isBlank(c.Campaign_Parent__c)){
                parentCampaign.add(c.Campaign_Parent__c);
            }
        }
        
        for(Contact c : [Select Id, Donor_ID__c  FROM Contact where Donor_ID__c  IN: donorIds OR ID IN :donorIds]){
            donorIdToContactIDMap.put(c.Donor_ID__c,c.Id); 
        }
        
        for(Campaign c : [Select Id, Name FROM Campaign WHERE Name IN: parentCampaign]){
            campaignNameToIDMap.put(c.Name, c.Id); 
        }
        
        insertCampaign(scope, recordTypeId);
    }   
    
    global void finish(Database.BatchableContext BC) {
        if(String.isNotBlank(ErrorMessage))
            update new Bulk_Upload_Donations__c(Id=bulkRecordId,Error_Reason__c=ErrorMessage);
        else{
            BulkUploadBatch_GAU Allocationbatch = new BulkUploadBatch_GAU(bulkRecordId);
            Allocationbatch.executePaymentbatch = false;
            Allocationbatch.query = 'select id,Donation_Date__c,donorId__c,itemCode__c,stipulation__c,File_Name__r.Upload_File_Type__c,Campaign__c,'+
                'gaEligible__c,stage__c,currCode__c,amount__c,sfContactId__c,agencyFees__c,netDonationAmount__c,'+
                'bankReference__c,primaryCampaignSource__c,medium__c,paymentMethod__c,bank__c,'+
                'regionalOffice__c,fundRaisingUrl__c,sfAccountId__c,File_Name__c,Row_Index__c,Opportunity__c,Opportunity__r.Transaction_Id__c,GAU_Allocation__c,Payment__c,transactionSource__c  from Bulk_Upload_Data__c where GAU_Allocation__c = null and File_Name__c='+'\''+bulkRecordId+'\'';
            Database.executebatch(Allocationbatch,25);
        } 
    }
    
    
    private void insertCampaign(List<Bulk_Upload_Data__c> dataList, String recordTypeId){
        List<Campaign> newCampaign = new List<Campaign>();
        List<Bulk_Upload_Data__c> udpatedataList = new List<Bulk_Upload_Data__c>();
        Map<String,Campaign> campIdtoName = new Map<String,Campaign>();
        System.debug('campaignNameToIDMap=='+campaignNameToIDMap);
        for(Bulk_Upload_Data__c c : dataList){
            System.debug('c=='+c);
            if(c.Campaign_Parent__c != null && campaignNameToIDMap.containsKey(c.Campaign_Parent__c)){
                rowIndex+=1;
                Campaign cam = new Campaign();
                cam.ParentId = campaignNameToIDMap.get(c.Campaign_Parent__c);
                if(!String.isBlank(c.CampaignName__c)){
                    cam.Name = c.CampaignName__c;
                }                
                cam.Description = c.Campaign_Description__c;
                cam.Department__c = c.Campaign_Department__c;
                cam.IsActive = Boolean.valueOf(c.Campaign_Active__c);
                cam.Status = c.stage__c;
                cam.Source__c = c.primaryCampaignSource__c;
                cam.CurrencyIsoCode = c.currCode__c;
                cam.Upload_Transaction_ID__c = c.id;
                cam.RecordTypeId = recordTypeId;
                if(!String.isBlank(c.fundRaisingUrl__c)){
                    cam.Fundraising_page_url__c = c.fundRaisingUrl__c;
                }                
                if(c.donorId__c != null && !c.donorId__c.startsWith('003') && donorIdToContactIDMap.containsKey(c.donorId__c)){
                    cam.Donor__c = donorIdToContactIDMap.get(c.donorId__c);
                }else if(c.donorId__c != null && c.donorId__c.startsWith('003')){
                    cam.Donor__c = c.donorId__c;
                }
                newCampaign.add(cam);
                c.Row_Index__c = String.valueof(rowIndex);
                c.Error_Message__c = '';
                c.hasError__c = false;
            }else{
                c.Error_Message__c = 'Parent Campaign Not found';
                c.hasError__c = true;                
            }
        }
        System.debug('dataList=='+dataList);
        System.debug('newCampaign=='+newCampaign);
        update dataList;
        if(newCampaign.size() > 0){
            
            Database.SaveResult[] srList = Database.insert(newCampaign, false);
            System.debug('srList=='+srList);
            // Iterate through each returned result
            for (Integer i=0;i<srList.size();i++) {
                Database.SaveResult sr = srList[i];
                Campaign cam = newCampaign[i];
                Bulk_Upload_Data__c temp = new Bulk_Upload_Data__c(Id=cam.Upload_Transaction_ID__c);
                if (!sr.isSuccess()) {
                    String ErrorMessage = '';
                    for(Database.Error err : sr.getErrors()) {
                        ErrorMessage =err.getMessage();                         
                    }
                    temp.hasError__c = true;
                    temp.Error_Message__c = ErrorMessage;
                }else{
                    temp.hasError__c = false;
                    temp.Error_Message__c = '';
                    temp.Is_Campaign_Processed__c = true;
                    temp.Campaign__c = sr.getId();  
                }
                udpatedataList.add(temp);
            }
            if(udpatedataList.size()>0)
                Update udpatedataList;
        }
    }
    public class CsvWrapper{        
        public String name;
        public String donorId;
        public String description;
        public String fundraisingURL;
        public String source;
        public String currCode;
        public String department;
        public String isActive;
        public String status;
        public String donationItemCode;
        public String parentCampaign;        
    }    
    
}