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
global class BulkUploadBatch_Payment implements Database.Batchable<sObject>{
    public  Set<String> itemCodes = new Set<String>();
    public  Map<String,ID> itemCodetoId = new Map<String,ID>();
    public  Id bulkRecordId;
    public String query = 'select id,Donation_Date__c,donorId__c,itemCode__c,stipulation__c,File_Name__r.Upload_File_Type__c,'+
            'gaEligible__c,stage__c,currCode__c,amount__c,sfContactId__c,agencyFees__c,netDonationAmount__c,'+
            'bankReference__c,primaryCampaignSource__c,medium__c,paymentMethod__c,bank__c,'+
            'regionalOffice__c,fundRaisingUrl__c,sfAccountId__c,File_Name__c,Row_Index__c,Opportunity__c,Opportunity__r.Transaction_Id__c,GAU_Allocation__c,Payment__c,transactionSource__c  from Bulk_Upload_Data__c where GAU_Allocation__c = NULL';
    public BulkUploadBatch_Payment(String bulkRecordId){
        this.bulkRecordId = bulkRecordId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('BulkUploadBatch_GAU query'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Bulk_Upload_Data__c> scope) {
        insertPayments(scope); 
}
global void finish(Database.BatchableContext BC) {
    if(bulkRecordId != null){
        Bulk_Upload_Donations__c  b = [Select Name,Id,Status__c,Total_Donations_Failed__c,Total_Allocations_Failed__c,Total_Payments_Failed__c,Total_Row_Count__c, Total_Donation_Amount__c ,Total_Donations__c,Total_Payments__c,Total_Allocations__c,CreatedBy.Email from Bulk_Upload_Donations__c Where Id=:bulkRecordId];
        if(b.Total_Donations__c ==b.Total_Row_Count__c && b.Total_Donations__c ==b.Total_Allocations__c && b.Total_Donations__c ==b.Total_Payments__c)
            b.Status__c='Success';
            else
            b.Status__c='Failed';
        upsert b;
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
                // Send an email to the Apex job's submitter notifying of job completion.
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {a.CreatedBy.Email,'iamsfdeveloper@gmail.com'};
                mail.setToAddresses(toAddresses);
                mail.setSubject('Bulk Upload Donation ' + b.Status__c);
                mail.setPlainTextBody
                ('File Name ' + b.Name +
                '\n Donations Insert '+b.Total_Donations__c+
                '\n Donations Item Insert '+b.Total_Allocations__c+
                '\n Donations Payment Insert '+b.Total_Payments__c+
                '\n Donations Failed To Insert '+b.Total_Donations_Failed__c);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
}
private  void insertPayments(List<Bulk_Upload_Data__c> dataList){
    List<npe01__OppPayment__c> insertPayment = new List<npe01__OppPayment__c>();
    Map<String,Id> banksMap = new Map<String,Id>();
    Id agencyRecId = Schema.SObjectType.npe01__OppPayment__c.getRecordTypeInfosByDeveloperName().get('Online_Crowdfunding').getRecordTypeId(); 
    Id cardTerminalId = Schema.SObjectType.npe01__OppPayment__c.getRecordTypeInfosByDeveloperName().get('Card_Terminal').getRecordTypeId(); 
    Id bankTransferRecId = Schema.SObjectType.npe01__OppPayment__c.getRecordTypeInfosByDeveloperName().get('Bank_Transfer').getRecordTypeId(); 
    for(Bank_Account__c b : [Select Id, Name from Bank_Account__c]){
        banksMap.put(b.Name,b.Id);    
    }
    for(Bulk_Upload_Data__c c : dataList){
    //for(Opportunity o : [Select Id,Amount,CloseDate,Bank_Reference__c,CurrencyIsoCode,Payment_Method__c,Bank__c,Net_Donation_Amount__c,Transaction_Source__c from Opportunity where Id IN:newOpps]){
        npe01__OppPayment__c payment = new npe01__OppPayment__c(npe01__Payment_Method__c = c.paymentMethod__c,
        npe01__Payment_Amount__c=String.isBlank(c.amount__c) ? 0.00 : decimal.valueOf(c.amount__c),
        npe01__Payment_Date__c=c.Donation_Date__c,Bank_Notes__c = c.BankReference__c,
        npe01__Paid__c = true,CurrencyIsoCode = c.currCode__c,
        npe01__Opportunity__c = c.Opportunity__c
        );
        if(c.Bank__c != null && banksMap.containskey(c.Bank__c)){
            payment.Deposit_Bank_Account__c = banksMap.get(c.Bank__c);
        }
        If(c.File_Name__r.Upload_File_Type__c=='BankTransfers' || c.File_Name__r.Upload_File_Type__c=='BankTransfersOrg')
            payment.RecordTypeId = bankTransferRecId;
        
        else if(c.File_Name__r.Upload_File_Type__c=='CardTerminals'){
                    payment.RecordTypeId = cardTerminalId; 
                    payment.Transaction_Source__c  = c.transactionSource__c;
                }
      else  if(c.File_Name__r.Upload_File_Type__c.startsWithIgnoreCase('Agencies')){
            payment.RecordTypeId = agencyRecId;
            payment.Transaction_Source__c  = c.transactionSource__c;
            //payment.npe01__Payment_Amount__c  = String.isBlank(c.netDonationAmount__c) ? 0.00 : decimal.valueOf(c.netDonationAmount__c);
        }  
        insertPayment.add(payment); 
        
    }
    if(insertPayment.size() > 0){ 
        Database.SaveResult[] srList = Database.insert(insertPayment, false);
             
            // Iterate through each returned result
            for (Integer i=0;i<srList.size();i++) {
                Database.SaveResult sr = srList[i];
                if (!sr.isSuccess()) {
                    String ErrorMessage = '';
                    for(Database.Error err : sr.getErrors()) {
                        ErrorMessage =err.getMessage(); 
                        //ErrorMessage +='StatusCode => '+err.getStatusCode(); 
                        //ErrorMessage +=' Message => '+err.getMessage(); 
                        //ErrorMessage +=' Fields => '+err.getFields();  
                    }
                    dataList[i].Error_Message__c = ErrorMessage;
                    dataList[i].hasError__c = true;
                }else{
                    dataList[i].hasError__c = false;
                    dataList[i].Error_Message__c='';
                    dataList[i].Is_Payment_Processed__c = true;
                    dataList[i].Payment__c = sr.getId();  
                }
            }
            Update dataList;
    }   
}
}