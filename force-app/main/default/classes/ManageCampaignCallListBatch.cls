public class ManageCampaignCallListBatch implements Database.Batchable<sObject> {
    
    @InvocableMethod
    public static void manageCampaignList(List<Id> camIds){
        System.debug(camIds); 
        Campaign objCampaign = [SELECT Id,Name,IsActive,Dialer_Queue__c FROM Campaign WHERE Id=:camIds[0]];
        ManageCampaignCallListBatch batch = new ManageCampaignCallListBatch(objCampaign);
        Database.executeBatch(batch);
    }
    
    private Campaign objCampaign;
    private List<String> lstError = new List<String>();
    
    
    public ManageCampaignCallListBatch(Campaign objCamp) {
        
        this.objCampaign = objCamp;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
      String query = 'SELECT Id,CampaignId,ContactId,Status,Call_List_Id__c,Campaign.IsActive,Campaign.Dialer_Queue__c '+
          			 'FROM CampaignMember '+
                     'WHERE CampaignId=\''+objCampaign.Id+'\' AND Status =\'To Call\' AND ContactId != null';  

        
      return Database.getQueryLocator(query);
   }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        
        try {
            
            List<CampaignMember> lstCampaignMember = (List<CampaignMember>) scope; 

            if (objCampaign.IsActive == false) {
                
                Set<Id> setCallListIds = new Set<Id>();
                
                for (CampaignMember objCampaignMem : lstCampaignMember) {

                   setCallListIds.add(objCampaignMem.Call_List_Id__c);                                  
                }
                
                List<Call_List__c> lstCallList = new List<Call_List__c>();
                
                lstCallList = [SELECT Id FROM Call_List__c WHERE Id=:setCallListIds];
                
                if (!lstCallList.isEmpty()) {
                    
                    delete lstCallList;
                }
            }
            else {
                
                List<Call_List__c> lstCallList = new List<Call_List__c>();
                
                Set<Id> setCallListIds = new Set<Id>();
                
                for (CampaignMember objCampaignMem : lstCampaignMember) {
                    
                    setCallListIds.add(objCampaignMem.Call_List_Id__c);                                  
                }
                
                Map<Id,Call_List__c> mapCallList = new Map<Id,Call_List__c>([SELECT Id FROM Call_List__c WHERE Id=:setCallListIds]);
                
                for (CampaignMember objCampaignMem : lstCampaignMember) {
                    
                    if (!mapCallList.containsKey(objCampaignMem.Call_List_Id__c)) {
                        
                        lstCallList.add(new Call_List__c(CampaignId__c =objCampaignMem.CampaignId,
                                                     CampaignMemberId__c=objCampaignMem.Id,
                                                     ContactId__c = objCampaignMem.ContactId,
                                                     Queue_Name__c = objCampaign.Dialer_Queue__c));  
                        
                    }                               
                }
                
                if (!lstCallList.isEmpty()) {
                    
                    insert lstCallList;
                }
            } 
            
        }
        catch(Exception exp) {
            
            lstError.add(exp.getMessage());
        }
    }
    
   	public void finish(Database.BatchableContext BC) {
        
        objCampaign.Call_List_Clearing_In_Progress__c = false;
        update objCampaign;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[] {UserInfo.getUserEmail()}; 
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Human Appeal Support');
        
        if (lstError.isEmpty()) {
            
            if (objCampaign.IsActive == true) {
                
                mail.setSubject(objCampaign.Name+' Campaign as been successfully Activated');
                mail.setPlainTextBody('The Campaign : ' + objCampaign.Name+' has been activated.');
            }
            else {
                
                mail.setSubject(objCampaign.Name+' Campaign as been successfully Deactivated');
                mail.setPlainTextBody('The Campaign : ' + objCampaign.Name+' has been Activated.');
            }
        }
        else {
            
            String strError = string.join(lstError,',');
            
            if (objCampaign.IsActive == true) {
                
                mail.setSubject('Error Occured While activating the Campaign- '+objCampaign.Name);
                mail.setPlainTextBody('While activating the Campaign following error occured :- '+strError);
            }
            else {
                
                mail.setSubject('Error Occured While deactivated the Campaign- '+objCampaign.Name);
                mail.setPlainTextBody('While deactivated the Campaign following error occured :- '+strError);
            }
        }

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   	
    }
}