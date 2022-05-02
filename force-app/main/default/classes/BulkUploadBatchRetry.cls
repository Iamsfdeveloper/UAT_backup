public class BulkUploadBatchRetry {
    public Bulk_Upload_Donations__c bulkUpload {get;set;}
    public string recordId {get;set;}
    public BulkUploadBatchRetry(ApexPages.StandardController sc){
        this.bulkUpload = [Select Id,Name, Status__c From Bulk_Upload_Donations__c Where Id=:sc.getId()];//sc.getRecord();
        recordId = sc.getId();
    }
    public PageReference retryBatch(){
        if(bulkUpload.status__c =='Failed'){
            BulkUploadProcessFuture batch = new BulkUploadProcessFuture(recordId);
            Database.executeBatch(batch, 25);
            update new Bulk_Upload_Donations__c(Id=recordId,Status__c = 'In Progress');
        }
        PageReference page = new PageReference('/'+recordId);
        page.setRedirect(true);
        return page;
    }
}