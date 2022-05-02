/**
* @description       : 
* @author            : Iamsfdeveloper
* @group             : 
* @last modified on  : 06-30-2021
* @last modified by  : Iamsfdeveloper
* Modifications Log 
* Ver   Date         Author           Modification
* 1.0   06-29-2021   Iamsfdeveloper   Initial Version
**/
global class BulkUploadBatch_GAU implements Database.Batchable<sObject>{
    public  Set<String> itemCodes = new Set<String>();
    public  Map<String,ID> itemCodetoId = new Map<String,ID>();
    public  Id bulkRecordId;
    public Boolean executePaymentbatch = true;
    public String query = 'select id,Donation_Date__c,donorId__c,itemCode__c,stipulation__c,File_Name__r.Upload_File_Type__c,'+
        'gaEligible__c,stage__c,currCode__c,amount__c,sfContactId__c,agencyFees__c,netDonationAmount__c,'+
        'bankReference__c,primaryCampaignSource__c,medium__c,paymentMethod__c,bank__c,'+
        'regionalOffice__c,fundRaisingUrl__c,sfAccountId__c,File_Name__c,Row_Index__c,Opportunity__c,Opportunity__r.Transaction_Id__c,GAU_Allocation__c,Payment__c,transactionSource__c  from Bulk_Upload_Data__c where GAU_Allocation__c = NULL';
    public BulkUploadBatch_GAU(String bulkRecordId){
        this.bulkRecordId = bulkRecordId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('BulkUploadBatch_GAU query'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Bulk_Upload_Data__c> scope) {
        for(Bulk_Upload_Data__c c : scope){
            if(!String.isBlank(c.itemCode__c)){
                itemCodes.add(c.itemCode__c);
            }
        }
        for(npsp__General_Accounting_Unit__c  n : [Select Id,Donation_Item_Code__c from npsp__General_Accounting_Unit__c where Donation_Item_Code__c IN:itemCodes ]){
            itemCodetoId.put(n.Donation_Item_Code__c,n.Id);    
        }  
        insertAllocations(scope); 
    }
    global void finish(Database.BatchableContext BC) {
        if(executePaymentbatch){
            BulkUploadBatch_Payment PaymentsBatch = new BulkUploadBatch_Payment(bulkRecordId);
            PaymentsBatch.query = 'select id,Donation_Date__c,donorId__c,itemCode__c,stipulation__c,File_Name__r.Upload_File_Type__c,'+
                'gaEligible__c,stage__c,currCode__c,amount__c,sfContactId__c,agencyFees__c,netDonationAmount__c,'+
                'bankReference__c,primaryCampaignSource__c,medium__c,paymentMethod__c,bank__c,'+
                'regionalOffice__c,fundRaisingUrl__c,sfAccountId__c,File_Name__c,Row_Index__c,Opportunity__c,Opportunity__r.Transaction_Id__c,GAU_Allocation__c,Payment__c,transactionSource__c  from Bulk_Upload_Data__c where Payment__c = null and GAU_Allocation__c != null  and Opportunity__c != null and File_Name__c='+'\''+bulkRecordId+'\'';
            
            Database.executebatch(PaymentsBatch,25);
        }
        
    }
    private  void insertAllocations(List<Bulk_Upload_Data__c> dataList){
        List<npsp__Allocation__c> newAllocs = new List<npsp__Allocation__c>();
        for(Bulk_Upload_Data__c c : dataList){
            if(c.GAU_Allocation__c == null){
                npsp__Allocation__c alloc = new npsp__Allocation__c();
                alloc.CurrencyIsoCode = c.currCode__c;
                alloc.npsp__Amount__c = String.isBlank(c.amount__c) ? 0.00 : decimal.valueOf(c.amount__c);
                alloc.Stipulation_Type__c = c.stipulation__c;
                alloc.npsp__General_Accounting_Unit__c = itemCodetoId.get(c.itemCode__c);
                alloc.npsp__Opportunity__c = c.Opportunity__c;
                alloc.Check_Paid_Status__c = true; 
                alloc.Skip_Process_Automation__c = true;
                alloc.npsp__Campaign__c = c.Campaign__c;
                newAllocs.add(alloc);
            }
        }   
        
        if(newAllocs.size() > 0){
            Database.SaveResult[] srList = Database.insert(newAllocs, false);
            
            // Iterate through each returned result
            for (Integer i=0;i<srList.size();i++) {
                Database.SaveResult sr = srList[i];
                if (!sr.isSuccess()) {
                    String ErrorMessage = '';
                    for(Database.Error err : sr.getErrors()) {
                        ErrorMessage =err.getMessage(); 
                        //ErrorMessage +='StatusCode => '+err.getStatusCode(); 
                        // ErrorMessage +=' Message => '+err.getMessage(); 
                        // ErrorMessage +=' Fields => '+err.getFields();  
                    }
                    dataList[i].Error_Message__c = ErrorMessage;
                    dataList[i].hasError__c = true;
                }else{
                    dataList[i].hasError__c = false;
                    dataList[i].Error_Message__c='';
                    dataList[i].Is_Allocation_Processed__c = true;
                    dataList[i].GAU_Allocation__c = sr.getId();  
                }
            }
            Update dataList;
        }  
    }
}