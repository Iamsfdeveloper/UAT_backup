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
global class BulkUploadProcessFuture  implements Database.Batchable<sObject>, Database.Stateful{
    public  Set<String> donorIds = new Set<String>();
    public  Set<String> accountIds = new Set<String>();
    public  Set<String> contactIds = new Set<String>();
    public  static Map<String,ID> donorIdToContactIDMap = new Map<String,ID>();
    public  static Map<String,Bulk_Upload_Data__c> donorIdItemMap = new Map<String,Bulk_Upload_Data__c>();
    public  Set<String> sourceCampaign = new Set<String>();
    public  Static Id oppRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Donation').getRecordTypeId(); 
    public  Integer rowIndex = 0;
    public   List<Bulk_Upload_Data__c> dataInsertList = new List<Bulk_Upload_Data__c>();
    //public  List<Id> oppCreatedIds = new List<Id>();
    public  String ErrorMessage;
    public  Id bulkRecordId;
    public  String upLoadType;
    public String dataFromSpreadsheet;
    public Boolean singleRun;
    public String query = 'select id,Donation_Date__c,donorId__c,itemCode__c,stipulation__c,File_Name__r.Upload_File_Type__c,'+
            'gaEligible__c,stage__c,currCode__c,amount__c,sfContactId__c,agencyFees__c,netDonationAmount__c,Transaction_Id__c ,'+
            'bankReference__c,primaryCampaignSource__c,medium__c,paymentMethod__c,bank__c,'+
            'regionalOffice__c,fundRaisingUrl__c,sfAccountId__c,File_Name__c,Row_Index__c,Opportunity__c,Opportunity__r.Transaction_Id__c,GAU_Allocation__c,Payment__c,transactionSource__c  from Bulk_Upload_Data__c where Opportunity__c = NULL';
    public BulkUploadProcessFuture(Id recId){
        this.bulkRecordId = recId;
        this.query = 'select id,Donation_Date__c,donorId__c,itemCode__c,stipulation__c,File_Name__r.Upload_File_Type__c,'+
            'gaEligible__c,stage__c,currCode__c,amount__c,sfContactId__c,agencyFees__c,netDonationAmount__c,'+
            'bankReference__c,primaryCampaignSource__c,medium__c,paymentMethod__c,bank__c,Transaction_Id__c ,'+
            'regionalOffice__c,fundRaisingUrl__c,sfAccountId__c,File_Name__c,Row_Index__c,Opportunity__c,Opportunity__r.Transaction_Id__c,GAU_Allocation__c,Payment__c,transactionSource__c  from Bulk_Upload_Data__c where Is_Opportunity_Processed__c = False  and File_Name__c='+'\''+bulkRecordId+'\'';
    
    }
    public BulkUploadProcessFuture(Id recId,String upType,String dataString,Boolean singleRunExecution) {
        this.bulkRecordId = recId;
        this.upLoadType = upType;
        dataFromSpreadsheet = dataString;
        singleRun = singleRunExecution;
        system.debug('singleRun'+singleRun);        

    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        try{
       if(!String.isBlank(dataFromSpreadsheet) && singleRun == false){
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Date', 'dateValue');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Donor Id', 'donorId');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Item (GAU Allocation)', 'itemCode');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Stipulation', 'stipulation');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('GA Eligible', 'gaEligible');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Stage', 'stage');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Currency', 'currCode');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Amount', 'amount');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Agency Fees', 'agencyFees');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Net Donation Amount', 'netDonationAmount');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Bank Reference', 'bankReference');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Primary Campaign Source', 'primaryCampaignSource');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Medium', 'medium');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Payment method', 'paymentMethod');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Bank', 'bank');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Regional Office', 'regionalOffice');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Fundraising Page URL', 'fundRaisingUrl'); 
            dataFromSpreadsheet = dataFromSpreadsheet.replace('Net Donation amount', 'netDonationAmount');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('SFAccountId', 'sfAccountId');
            dataFromSpreadsheet = dataFromSpreadsheet.replace('sfContactId', 'sfContactId');
           dataFromSpreadsheet = dataFromSpreadsheet.replace('Transaction Source', 'transactionSource');
           dataFromSpreadsheet = dataFromSpreadsheet.replace('Transaction Id', 'transactionId');
            //dataFromSpreadsheet = dataFromSpreadsheet.replace('\\"', '');
            List<CsvWrapper> dataList = (List<csvWrapper>)JSON.deserialize(dataFromSpreadsheet, List<CsvWrapper>.class);                 
                for(CsvWrapper c : dataList){ 
                    Bulk_Upload_Data__c tempList = new Bulk_Upload_Data__c ();
                    tempList.Donation_Date__c  = c.dateValue;
                    tempList.donorId__c = c.donorId;
                    tempList.itemCode__c = c.itemCode;
                    tempList.stipulation__c = c.stipulation;
                    tempList.gaEligible__c = c.gaEligible;
                    tempList.stage__c = c.stage;
                    tempList.currCode__c = c.currCode;
                    tempList.amount__c = c.amount;
                    tempList.agencyFees__c = c.agencyFees;
                    tempList.netDonationAmount__c = c.netDonationAmount;
                    tempList.bankReference__c = c.bankReference;
                    tempList.primaryCampaignSource__c = c.primaryCampaignSource;
                    tempList.medium__c = c.medium;
                    tempList.paymentMethod__c = c.paymentMethod;
                    tempList.bank__c = c.bank;
                    tempList.regionalOffice__c = c.regionalOffice;
                    tempList.fundRaisingUrl__c  = c.fundRaisingUrl;
                    tempList.sfAccountId__c = c.sfAccountId; 
                    tempList.File_Name__c = bulkRecordId;
                    tempList.sfContactId__c = c.sfContactId;
                    tempList.transactionSource__c = c.transactionSource;
                    tempList.transaction_Id__c = c.transactionId;
                    dataInsertList.add(tempList);
                }
                Insert dataInsertList;            
             query = 'select id,Donation_Date__c,donorId__c,itemCode__c,stipulation__c,File_Name__r.Upload_File_Type__c,'+
            'gaEligible__c,stage__c,currCode__c,amount__c,sfContactId__c,agencyFees__c,netDonationAmount__c,'+
            'bankReference__c,primaryCampaignSource__c,medium__c,paymentMethod__c,bank__c,Transaction_Id__c ,'+
            'regionalOffice__c,fundRaisingUrl__c,sfAccountId__c,File_Name__c,Row_Index__c,Opportunity__c,Opportunity__r.Transaction_Id__c,GAU_Allocation__c,Payment__c,transactionSource__c  from Bulk_Upload_Data__c where File_Name__c='+'\''+bulkRecordId+'\'';
     
        }}Catch(Exception e){

            ErrorMessage = e.getMessage();
    
        }
         if(singleRun == true ){
            query = 'select id,Donation_Date__c,donorId__c,itemCode__c,stipulation__c,File_Name__r.Upload_File_Type__c,'+
            'gaEligible__c,stage__c,currCode__c,amount__c,sfContactId__c,agencyFees__c,netDonationAmount__c,'+
            'bankReference__c,primaryCampaignSource__c,medium__c,paymentMethod__c,bank__c,Transaction_Id__c ,'+
            'regionalOffice__c,fundRaisingUrl__c,sfAccountId__c,File_Name__c,Row_Index__c,Opportunity__c,Opportunity__r.Transaction_Id__c,GAU_Allocation__c,Payment__c,transactionSource__c  from Bulk_Upload_Data__c WHERE Opportunity__c = NULL';     
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
                    donorIdItemMap.put(c.donorId__c + c.itemCode__c,c);
                }  
                if(!String.isBlank(c.sfAccountId__c)){
                    accountIds.add(c.sfAccountId__c);
                }  
                
                if(!String.isBlank(c.sfContactId__c)){
                    contactIds.add(c.sfContactId__c);
                } 
                
                if(!String.isBlank(c.primaryCampaignSource__c)){
                    sourceCampaign.add(c.primaryCampaignSource__c.toLowerCase());
                }                         
            }
                    
            for(Contact c : [Select Id, Donor_ID__c  from Contact where Donor_ID__c  IN: donorIds]){
                donorIdToContactIDMap.put(c.Donor_ID__c,c.Id); 
            }
        
             insertOpportunities(scope);
                
    
    }   
    
    global void finish(Database.BatchableContext BC) {
        if(String.isNotBlank(ErrorMessage))
            update new Bulk_Upload_Donations__c(Id=bulkRecordId,Error_Reason__c=ErrorMessage);
          else{
                BulkUploadBatch_GAU Allocationbatch = new BulkUploadBatch_GAU(bulkRecordId);
                Allocationbatch.query = 'select id,Donation_Date__c,donorId__c,itemCode__c,stipulation__c,File_Name__r.Upload_File_Type__c,'+
                    'gaEligible__c,stage__c,currCode__c,amount__c,sfContactId__c,agencyFees__c,netDonationAmount__c,'+
                    'bankReference__c,primaryCampaignSource__c,medium__c,paymentMethod__c,bank__c,'+
                    'regionalOffice__c,fundRaisingUrl__c,sfAccountId__c,File_Name__c,Row_Index__c,Opportunity__c,Opportunity__r.Transaction_Id__c,GAU_Allocation__c,Payment__c,transactionSource__c, Transaction_Id__c   from Bulk_Upload_Data__c where GAU_Allocation__c = null  and Opportunity__c != null and File_Name__c='+'\''+bulkRecordId+'\'';
                Database.executebatch(Allocationbatch,25);
          }
    
        
    }
    
    
    private void insertOpportunities(List<Bulk_Upload_Data__c> dataList){
        List<Opportunity> newOpps = new List<Opportunity>();
        List<Bulk_Upload_Data__c> udpatedataList = new List<Bulk_Upload_Data__c>();
        Map<String,Campaign> campIdtoName = new Map<String,Campaign>();
        Id donCode = [Select Id from HA_Payment_Schedule__c where Code__c ='SD' and Is_Bulk_Upload_Allowed__c= true limit 1].Id;
        For(Campaign c : [Select Id,name,source__c from campaign where name in:sourceCampaign]){
            campIdtoName.put(c.Name.tolowercase(),c); 
        }
        
        for(Bulk_Upload_Data__c c : dataList){
            If(c.Opportunity__c == null){
            rowIndex+=1;
            if(donorIdToContactIDMap.containskey(c.donorId__c) || accountIds.contains(c.sfAccountId__c) || contactIds.contains(c.sfContactId__c)){
                Opportunity opp = New Opportunity();
                if(!String.isBlank(c.donorId__c)){
                    opp.npsp__Primary_Contact__c = donorIdToContactIDMap.get(c.donorId__c);
                }
                if(campIdtoName.containskey(c.primaryCampaignSource__c.toLowerCase())){
                    opp.CampaignId = campIdtoName.get(c.primaryCampaignSource__c.toLowerCase()).Id;
                    opp.Source__C =  campIdtoName.get(c.primaryCampaignSource__c.toLowerCase()).Source__C;
                }
                opp.StageName = c.stage__c;
                opp.Gift_Aid_Eligible_Status__c  = c.gaEligible__c == 'TRUE' ? 'Yes' : 'No';
                opp.CurrencyIsoCode = c.currCode__c;
                opp.Amount = String.isBlank(c.amount__c) ? 0.00 : decimal.valueOf(c.amount__c);
                opp.Agency_Fees__c = String.isBlank(c.agencyFees__c) ? 0.00 : decimal.valueOf(c.agencyFees__c);
                opp.Net_Donation_Amount__c = String.isBlank(c.netDonationAmount__c) ? 0.00 : decimal.valueOf(c.netDonationAmount__c);
                opp.Bank_Reference__c = c.bankReference__c;
                opp.Skip_Process_Automation__c = true;
                opp.Medium__c = c.medium__c;
                opp.Bank__c = c.bank__c;
                opp.Fundraising_Page_URL__c  = c.fundRaisingUrl__c;
                opp.Donor_ID_Item_Code__c = c.donorId__c + c.itemCode__c;
                opp.GUID__c  = c.Id;
                opp.Item_Code__c = c.itemCode__c;
                opp.Stipulation_Type__c = c.stipulation__c;
                opp.Transaction_Source__c = c.transactionSource__c;
                opp.Transaction_Id__c = c.Transaction_Id__c;
                if(!String.isBlank(c.sfAccountId__c)){
                    opp.AccountId = c.sfAccountId__c;
                    opp.Donor_ID_Item_Code__c = c.sfAccountId__c + c.itemCode__c;
                }  
                if(!String.isBlank(c.sfContactId__c)){
                    opp.ContactId = c.sfContactId__c;
                }                 
                opp.RecordTypeId = oppRecId;
                opp.Payment_Method__c = c.paymentMethod__c;
                opp.CloseDate = c.Donation_Date__c;
                opp.Payment_Schedule__c = donCode;
                opp.Donation_Type__c = 'SD';
                System.debug('==='+c.donorId__c+' === '+c.currCode__c+' === '+String.valueOf(c.amount__c)+' === '+((DateTime)c.Donation_Date__c).format('yyyy-mm-dd'));
                opp.Name = 'SD'+'-'+c.donorId__c + '-' +c.currCode__c + '-' +String.valueOf(c.amount__c)+'-' +((DateTime)c.Donation_Date__c).format('yyyy-mm-dd') ;  
                opp.Row_Index__c  = String.Valueof(rowIndex);
                newOpps.add(opp);
                c.Row_Index__c = String.valueof(rowIndex);
                c.Error_Message__c = '';
                c.hasError__c = false;
            }
            else{
                c.Error_Message__c = 'Donor Not found';
                c.hasError__c = true;
                
            }
        }
        } 
        update dataList;
        if(newOpps.size() > 0){
           
            Database.SaveResult[] srList = Database.insert(newOpps, false);
           
            // Iterate through each returned result
            for (Integer i=0;i<srList.size();i++) {
                Database.SaveResult sr = srList[i];
                Opportunity opp = newOpps[i];
                Bulk_Upload_Data__c temp = new Bulk_Upload_Data__c(Id=opp.GUID__c);
                if (!sr.isSuccess()) {
                    String ErrorMessage = '';
                    for(Database.Error err : sr.getErrors()) {
                        ErrorMessage =err.getMessage(); 
                        //ErrorMessage +='StatusCode => '+err.getStatusCode(); 
                        //ErrorMessage +=' Message => '+err.getMessage(); 
                        //ErrorMessage +=' Fields => '+err.getFields();  
                    }
                    temp.hasError__c = true;
                    temp.Error_Message__c = ErrorMessage;
                }else{
                    temp.hasError__c = false;
                    temp.Error_Message__c = '';
                    temp.Is_Opportunity_Processed__c = true;
                    temp.Opportunity__c = sr.getId();  
                }
                udpatedataList.add(temp);
            }
            if(udpatedataList.size()>0)
                Update udpatedataList;
        }
    }
    public class CsvWrapper{
        public Date dateValue;
        public String donorId;
        public String itemCode;
        public String stipulation;
        public String gaEligible;
        public String stage;
        public String currCode;
        public String amount;
        public String agencyFees;
        public String netDonationAmount;
        public String bankReference;
        public String primaryCampaignSource;
        public String medium;
        public String paymentMethod;
        public String bank;
        public String regionalOffice;
        public String fundRaisingUrl;
        public String sfAccountId;
        public String sfContactId;
        public String transactionSource;
        public String transactionId;
    }    
    
}