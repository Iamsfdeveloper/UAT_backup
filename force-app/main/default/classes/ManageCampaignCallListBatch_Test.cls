@isTest
private class ManageCampaignCallListBatch_Test {
    
    @isTest
    private static void TestmanageCampaignCallListBatchDelete() {
        
        Campaign OutboundCallingCampaign = new Campaign(Name='Test',Type='Outbound_Calling',Country__c='United Kingdom',Dialer_Queue__c='Dialer_Queue_UK_1',IsActive=true);
        insert OutboundCallingCampaign;
        CampaignMemberStatus statusCallTo = new CampaignMemberStatus(CampaignId=OutboundCallingCampaign.Id,Label='To Call',IsDefault=false,HasResponded=false);
        insert statusCallTo;

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'HH_Account' AND SObjectType = 'Account'].Id;
        insert acc;
        
        List<Contact> lstContact = new List<Contact>();
        
        for (integer i=0;i<10;i++) {
            
            Contact objCon = new Contact();
            objCon.Firstname = 'FirstName'+i;
            objCon.Lastname = 'LastName'+i;
            objCon.Email = 'test2@test.com';
            objCon.MailingStreet = 'test';
            objCon.MailingCity = 'test';
            objCon.MailingPostalCode = 'test';
            objCon.MailingState = 'test';  
            objCon.MailingCountry = 'UK';
            objCon.AccountId = acc.Id;
            lstContact.add(objCon);
        }
        
        insert lstContact;
        
        List<CampaignMember> lstCampaignMem = new List<CampaignMember>();
        
        for (Contact objCon : lstContact) {
            
            CampaignMember newMember =  new CampaignMember(ContactId = objCon.Id, status='To Call', campaignid = OutboundCallingCampaign.id);
        	lstCampaignMem.add(newMember);
        }
         
        insert lstCampaignMem;
        
        List<Call_List__c> lstCallList = new List<Call_List__c>();
        
        for (CampaignMember objCampaignMem : lstCampaignMem) {
                                                          
            lstCallList.add(new Call_List__c(CampaignId__c =objCampaignMem.CampaignId,
                                             CampaignMemberId__c=objCampaignMem.Id,
                                             ContactId__c = objCampaignMem.ContactId,
                                             Queue_Name__c = OutboundCallingCampaign.Dialer_Queue__c));                                  
        }
        
        insert lstCallList;
        
        List<CampaignMember> lstUpdCampaignMem = new List<CampaignMember>();
        
        for (Call_List__c objCallList : lstCallList) {
            
            lstUpdCampaignMem.add(new CampaignMember(Id=objCallList.CampaignMemberId__c,Call_List_Id__c=objCallList.Id));
        }
        
        update lstUpdCampaignMem;
        
        
        OutboundCallingCampaign.IsActive = false;
        update OutboundCallingCampaign;
        
        Test.startTest();
        ManageCampaignCallListBatch campaignBatch = new ManageCampaignCallListBatch(OutboundCallingCampaign);
        Database.executeBatch(campaignBatch);
        Test.stopTest();
        
        List<Call_List__c> lstCallListCheck = [SELECT Id FROM Call_List__c];
        
        System.assertEquals(lstCallListCheck.size(),0);
    }
    
    @isTest
    private static void TestmanageCampaignCallListBatchCreate() {
        
        Campaign OutboundCallingCampaign = new Campaign(Name='Test',Type='Outbound_Calling',Country__c='United Kingdom',Dialer_Queue__c='Dialer_Queue_UK_1',IsActive=false);
        insert OutboundCallingCampaign;
        CampaignMemberStatus statusCallTo = new CampaignMemberStatus(CampaignId=OutboundCallingCampaign.Id,Label='To Call',IsDefault=false,HasResponded=false);
        insert statusCallTo;

        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'HH_Account' AND SObjectType = 'Account'].Id;
        insert acc;
        
        List<Contact> lstContact = new List<Contact>();
        
        for (integer i=0;i<10;i++) {
            
            Contact objCon = new Contact();
            objCon.Firstname = 'FirstName'+i;
            objCon.Lastname = 'LastName'+i;
            objCon.Email = 'test2@test.com';
            objCon.MailingStreet = 'test';
            objCon.MailingCity = 'test';
            objCon.MailingPostalCode = 'test';
            objCon.MailingState = 'test';  
            objCon.MailingCountry = 'UK';
            objCon.AccountId = acc.Id;
            lstContact.add(objCon);
        }
        
        insert lstContact;
        
        List<CampaignMember> lstCampaignMem = new List<CampaignMember>();
        
        for (Contact objCon : lstContact) {
            
            CampaignMember newMember =  new CampaignMember(ContactId = objCon.Id, status='To Call', campaignid = OutboundCallingCampaign.id);
        	lstCampaignMem.add(newMember);
        }
         
        insert lstCampaignMem;
        
        OutboundCallingCampaign.IsActive = true;
        update OutboundCallingCampaign;
        
        Test.startTest();
        ManageCampaignCallListBatch campaignBatch = new ManageCampaignCallListBatch(OutboundCallingCampaign);
        Database.executeBatch(campaignBatch);
        Test.stopTest();
        
        List<Call_List__c> lstCallListCheck = [SELECT Id FROM Call_List__c];
        
        System.assertEquals(lstCallListCheck.size(),10);
    }

}