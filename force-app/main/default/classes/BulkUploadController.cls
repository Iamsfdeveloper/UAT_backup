/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 06-11-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   06-11-2021   Iamsfdeveloper   Initial Version
**/
public without sharing class BulkUploadController {
    @AuraEnabled
    public Static  List<Bulk_Upload_Donations__c> insertDonationsFromCSVFile(String dataFromSpreadsheet,string uploadType,String fileName){
        List<Bulk_Upload_Donations__c> insertedDonationList = new List<Bulk_Upload_Donations__c>();
		insertedDonationList = [Select Id from Bulk_Upload_Donations__c where Name=:fileName];
            If(insertedDonationList.size() > 0){
                return insertedDonationList;
            }
            system.debug('dataFromSpreadsheet'+dataFromSpreadsheet);
            Bulk_Upload_Donations__c inserFileDetails = new Bulk_Upload_Donations__c ();
            inserFileDetails.Name  = fileName;
            inserFileDetails.Upload_File_Type__c  = uploadType;
            inserFileDetails.Status__c = 'In Progress';
            insert inserFileDetails;
            Attachment a = new Attachment(Body=Blob.valueOf(dataFromSpreadsheet),parentId=inserFileDetails.Id,Name=fileName);
            insert a;
            if(uploadType == 'Pledge' || uploadType == 'Donor_Pledge'){
                BulkUploadProcessFutureCampaign bulkCampaign = new BulkUploadProcessFutureCampaign(inserFileDetails.Id,uploadType,dataFromSpreadsheet,false);
                Database.executebatch(bulkCampaign, 25);
            }else{
                BulkUploadProcessFuture bupf = new BulkUploadProcessFuture(inserFileDetails.Id,uploadType,dataFromSpreadsheet,false)  ;
                Database.executebatch(bupf, 25);
            } 
        	insertedDonationList = [Select Id,Name,Upload_File_Type__c,Status__c,Total_Rows__c,Donation_Count__c,Total_Donation_Amount__c,Error_Reason__c,CreatedDate  From Bulk_Upload_Donations__c where createdbyid=:userinfo.getuserid() limit 20];
    		return insertedDonationList;         

    }
    
    @AuraEnabled
    public Static List<Bulk_Upload_Donations__c> initGetData(){
        Id recId;
        List<Bulk_Upload_Donations__c> processList = [Select Id,Name,Upload_File_Type__c,Status__c,Total_Rows__c,Donation_Count__c,Total_Donation_Amount__c,Error_Reason__c,CreatedDate  From Bulk_Upload_Donations__c where createdbyid=:userinfo.getuserid() limit 20];
        return processList;
    }           
    
}