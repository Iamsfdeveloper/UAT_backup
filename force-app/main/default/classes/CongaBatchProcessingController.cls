public with sharing class CongaBatchProcessingController {
    @AuraEnabled
    public Static Map<String,Object> exportDataUsingCongaComposerURL(String processName){
        
        Map<String,Object>  returnVal = new Map<String,Object>();
        Id recId;
        List<Conga_Batch_Processing_Logs__c> processList = [Select Id From Conga_Batch_Processing_Logs__c  where Batch_Name__c =:processName and CreatedDate=today and Batch_Status__c='Success' ];
        if(processList.size() == 0){
            Conga_Batch_Processing_Logs__c temp = new Conga_Batch_Processing_Logs__c();
            temp.Batch_Name__c =  processName;
            temp.Batch_Status__c = 'In Progress';
            Insert temp;
            processList.add(temp);
            returnVal.put('url',CongaApiService.exportDataUsingCongaComposer(temp.Id,processName));
            List<Conga_Batch_Processing_Logs__c> processingList = [Select Id,Batch_Name__c,Batch_Status__c, Failure_Reason__c  From Conga_Batch_Processing_Logs__c  where CreatedDate=today];
            
            returnVal.put('logs',processingList);
            
        }else{
            List<Conga_Batch_Processing_Logs__c> processingList = [Select Id,Batch_Name__c,Batch_Status__c, Failure_Reason__c  From Conga_Batch_Processing_Logs__c  where CreatedDate=today];
            returnVal.put('logs',processingList);
        }
        return returnVal;
    }
    @AuraEnabled
    public Static List<Conga_Batch_Processing_Logs__c> exportDataUsingCongaComposer(String processName){
        Id recId;
        List<Conga_Batch_Processing_Logs__c> processList = [Select Id From Conga_Batch_Processing_Logs__c  where Batch_Name__c =:processName and CreatedDate=today and Batch_Status__c='Success' ];
        if(processList.size() != 0){
            Conga_Batch_Processing_Logs__c temp = new Conga_Batch_Processing_Logs__c();
            temp.Batch_Name__c =  processName;
            temp.Batch_Status__c = 'In Progress';
            Insert temp;
            processList.add(temp);
            CongaApiService.exportDataUsingConga(temp.Id,processName);
            List<Conga_Batch_Processing_Logs__c> processingList = [Select Id,Batch_Name__c,Batch_Status__c, Failure_Reason__c  From Conga_Batch_Processing_Logs__c  where CreatedDate=today];
            
            return processingList;
            
        }else{
            List<Conga_Batch_Processing_Logs__c> processingList = [Select Id,Batch_Name__c,Batch_Status__c, Failure_Reason__c  From Conga_Batch_Processing_Logs__c  where CreatedDate=today];
            return processingList;
        }
    }
    
    @AuraEnabled
    public Static ResponseWrapper initGetData(){
        ResponseWrapper response = new ResponseWrapper();
        Id recId;
        List<Conga_Batch_Processing_Logs__c> processList = [Select Id,Batch_Name__c,Batch_Status__c, Failure_Reason__c From Conga_Batch_Processing_Logs__c  where CreatedDate=today];
        response.bulkLogs = processList;
        List<Conga_Metadata_Batch__c> getCongaDetails = [Select Id,Name,fileName__c,Merge_Record_Id__c ,Last_Run_Date_Time__c,Second_File_Name__c ,Second_Alias_Id__c,queryAliasId__c , queryId__c , templateId__c, Run_Second_Job__c , Second_Query_ID__c , Second_Template_ID__c from Conga_Metadata_Batch__c];
        for(Conga_Metadata_Batch__c c : getCongaDetails){
            if(c.Name == 'General_ReceiptsWithout_Orphans_and_OTC'){
            	response.generalWithoutOrphanAndOlive = [Select count() from opportunity where createddate >=:c.Last_Run_Date_Time__c And Skip_Process_Automation__c = false AND DonationCode__c!='RD' AND is_Recurring__c = false AND Isclosed=true And isWon= true and npsp__Primary_Contact__r.Is_Receipt_Via_Post__c = True And Donation_Amount_Excluding_SR__c > 0 and (NOT npsp__Primary_Contact__r.Firstname LIKE '%Anonymous%' ) and (NOT npsp__Primary_Contact__r.Lastname LIKE '%Anonymous%' ) limit 5000];    
            }
            else if(c.Name == 'Poetry_Receipts'){
				response.poetryReceipts = [ Select count()  From npsp__Allocation__c where createddate >=:c.Last_Run_Date_Time__c  AND  npsp__General_Accounting_Unit__c ='a0Z4J000002KHLcUAO' and npsp__Opportunity__r.Stagename ='Paid' ANd npsp__Opportunity__r.Skip_Process_Automation__c = false limit 5000];            
            }
            else if(c.Name == 'General_Receipts_and_Olive_Tree_Certs'){
                response.generalWithOliveTree = [ Select count() from opportunity where createddate >=:c.Last_Run_Date_Time__c AND Isclosed=true And Skip_Process_Automation__c = false And isWon= true And Donation_Amount_Olive_Trees__c > 0 and (NOT npsp__Primary_Contact__r.Firstname LIKE '%Anonymous%' ) and (NOT npsp__Primary_Contact__r.Lastname LIKE '%Anonymous%' ) limit 5000];
            } 
            else if(c.Name == 'Payment_Receipts_Without_Orphans'){
				response.paymentReceiptWithoutOrphanAndOlive = [ Select count() From opportunity where createddate >=:c.Last_Run_Date_Time__c AND StageName = 'Paid' And (DonationCode__c='RD' or is_Recurring__c = true) And type = 'payment plan - Source' AND Skip_Process_Automation__c = false  AND Isclosed=true And isWon= true and npsp__Primary_Contact__r.Is_Receipt_Via_Post__c = True And Donation_Amount_Excluding_SR__c > 0 And (NOT npsp__Primary_Contact__r.Firstname LIKE '%Anonymous%' ) and (NOT npsp__Primary_Contact__r.Lastname LIKE '%Anonymous%' ) limit 5000];               }
            else if(c.Name == 'Payment_Receipt_Orphan_Packs'){
				response.paymentReceiptWithOrphans  =   [ Select count()  FROM npsp__Allocation__c where createddate >=:c.Last_Run_Date_Time__c and npsp__Opportunity__r.Isclosed=true and npsp__Opportunity__r.Stagename='paid' And npsp__Opportunity__r.type = 'payment plan - Source' AND npsp__Opportunity__r.Skip_Process_Automation__c = false AND (npsp__Opportunity__r.DonationCode__c='RD' OR npsp__Opportunity__r.is_Recurring__c = true) AND npsp__Opportunity__r.IsWon=true and npsp__Opportunity__r.npsp__Primary_Contact__r.Is_Receipt_Via_Post__c = True And Orphan__c !=null limit 5000];            }
        }
        return response;
    } 
    
    public class ResponseWrapper {
        @AuraEnabled
        public List<Conga_Batch_Processing_Logs__c> bulkLogs { get; set; }
        @AuraEnabled
        public Integer generalWithoutOrphanAndOlive { get; set; }
        @AuraEnabled
        public Integer generalWithOrphans { get; set; }
        @AuraEnabled
        public Integer poetryReceipts { get; set; }        
        @AuraEnabled
        public Integer generalWithOliveTree{ get; set; }
        @AuraEnabled
        public Integer paymentReceiptWithoutOrphanAndOlive { get; set; }
        @AuraEnabled
        public Integer paymentReceiptWithOrphans { get; set; }        
    }     
}