@IsTest
public class  CongaBatchProcessingControllerTest {
    public static final Integer RESPONSE_SUCCESS = 200;
	
     @IsTest
    private static void testSingleJob(){
        Conga_Metadata_Batch__c  first = new Conga_Metadata_Batch__c ();
        first.Name = 'Payment_Receipts_Without_Orphans';
        first.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        first.fileName__c  = '00P3L000000ewFJUAY';
        first.Last_Run_Date_Time__c   = system.now();
        first.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        first.queryAliasId__c  ='00P3L000000ewFJUAY';
        first.queryId__c  ='00P3L000000ewFJUAY';
        first.Run_Second_Job__c  =false;
        first.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        first.Second_File_Name__c  ='00P3L000000ewFJUAY';
        first.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        first.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        first.templateId__c      ='00P3L000000ewFJUAY';
        insert first ;    
        
                Conga_Metadata_Batch__c  fifth = new Conga_Metadata_Batch__c ();
        fifth.Name = 'General_ReceiptsWithout_Orphans_and_OTC';
        fifth.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        fifth.fileName__c  = '00P3L000000ewFJUAY';
        fifth.Last_Run_Date_Time__c   = system.now();
        fifth.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        fifth.queryAliasId__c  ='00P3L000000ewFJUAY';
        fifth.queryId__c  ='00P3L000000ewFJUAY';
        fifth.Run_Second_Job__c  =false;
        fifth.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        fifth.Second_File_Name__c  ='00P3L000000ewFJUAY';
        fifth.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        fifth.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        fifth.templateId__c      ='00P3L000000ewFJUAY';
        insert fifth ; 
        
        
                Conga_Metadata_Batch__c  second = new Conga_Metadata_Batch__c ();
        second.Name = 'Payment_Receipt_Orphan_Packs';
        second.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        second.fileName__c  = '00P3L000000ewFJUAY';
        second.Last_Run_Date_Time__c   = system.now();
        second.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        second.queryAliasId__c  ='00P3L000000ewFJUAY';
        second.queryId__c  ='00P3L000000ewFJUAY';
        second.Run_Second_Job__c  =false;
        second.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        second.Second_File_Name__c  ='00P3L000000ewFJUAY';
        second.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        second.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        second.templateId__c      ='00P3L000000ewFJUAY';
        insert second ; 
        
        
                Conga_Metadata_Batch__c  third = new Conga_Metadata_Batch__c ();
        third.Name = 'General_Receipts_and_Olive_Tree_Certs';
        third.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        third.fileName__c  = '00P3L000000ewFJUAY';
        third.Last_Run_Date_Time__c   = system.now();
        third.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        third.queryAliasId__c  ='00P3L000000ewFJUAY';
        third.queryId__c  ='00P3L000000ewFJUAY';
        third.Run_Second_Job__c  =false;
        third.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        third.Second_File_Name__c  ='00P3L000000ewFJUAY';
        third.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        third.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        third.templateId__c      ='00P3L000000ewFJUAY';
        insert third ; 
        
        
        Conga_Metadata_Batch__c  fourth = new Conga_Metadata_Batch__c ();
        fourth.Name = 'General_Receipts_And_Orphan_Packs';
        fourth.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        fourth.fileName__c  = '00P3L000000ewFJUAY';
        fourth.Last_Run_Date_Time__c   = system.now();
        fourth.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        fourth.queryAliasId__c  ='00P3L000000ewFJUAY';
        fourth.queryId__c  ='00P3L000000ewFJUAY';
        fourth.Run_Second_Job__c  =false;
        fourth.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        fourth.Second_File_Name__c  ='00P3L000000ewFJUAY';
        fourth.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        fourth.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        fourth.templateId__c      ='00P3L000000ewFJUAY';
        insert fourth ; 
        

        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            RESPONSE_SUCCESS,
            '00P3L000000ewFJUAY'
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        Test.startTest();
			CongaBatchProcessingController.exportDataUsingCongaComposerURL('General_Receipts_And_Orphan_Packs');
        	CongaBatchProcessingController.exportDataUsingCongaComposer('General_Receipts_And_Orphan_Packs');
        Test.stopTest();
    }
    
         @IsTest
    private static void testMultipJob(){
        Conga_Metadata_Batch__c  first = new Conga_Metadata_Batch__c ();
        first.Name = 'Payment_Receipts_Without_Orphans';
        first.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        first.fileName__c  = '00P3L000000ewFJUAY';
        first.Last_Run_Date_Time__c   = system.now();
        first.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        first.queryAliasId__c  ='00P3L000000ewFJUAY';
        first.queryId__c  ='00P3L000000ewFJUAY';
        first.Run_Second_Job__c  =false;
        first.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        first.Second_File_Name__c  ='00P3L000000ewFJUAY';
        first.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        first.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        first.templateId__c      ='00P3L000000ewFJUAY';
        insert first ;    
        
        Conga_Metadata_Batch__c  fifth = new Conga_Metadata_Batch__c ();
        fifth.Name = 'General_ReceiptsWithout_Orphans_and_OTC';
        fifth.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        fifth.fileName__c  = '00P3L000000ewFJUAY';
        fifth.Last_Run_Date_Time__c   = system.now();
        fifth.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        fifth.queryAliasId__c  ='00P3L000000ewFJUAY';
        fifth.queryId__c  ='00P3L000000ewFJUAY';
        fifth.Run_Second_Job__c  =false;
        fifth.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        fifth.Second_File_Name__c  ='00P3L000000ewFJUAY';
        fifth.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        fifth.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        fifth.templateId__c      ='00P3L000000ewFJUAY';
        insert fifth ; 
        
        
        Conga_Metadata_Batch__c  second = new Conga_Metadata_Batch__c ();
        second.Name = 'Payment_Receipt_Orphan_Packs';
        second.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        second.fileName__c  = '00P3L000000ewFJUAY';
        second.Last_Run_Date_Time__c   = system.now();
        second.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        second.queryAliasId__c  ='00P3L000000ewFJUAY';
        second.queryId__c  ='00P3L000000ewFJUAY';
        second.Run_Second_Job__c  =false;
        second.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        second.Second_File_Name__c  ='00P3L000000ewFJUAY';
        second.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        second.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        second.templateId__c      ='00P3L000000ewFJUAY';
        insert second ; 
        
        
        Conga_Metadata_Batch__c  third = new Conga_Metadata_Batch__c ();
        third.Name = 'General_Receipts_and_Olive_Tree_Certs';
        third.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        third.fileName__c  = '00P3L000000ewFJUAY';
        third.Last_Run_Date_Time__c   = system.now();
        third.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        third.queryAliasId__c  ='00P3L000000ewFJUAY';
        third.queryId__c  ='00P3L000000ewFJUAY';
        third.Run_Second_Job__c  =false;
        third.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        third.Second_File_Name__c  ='00P3L000000ewFJUAY';
        third.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        third.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        third.templateId__c      ='00P3L000000ewFJUAY';
        insert third ; 
        
        
        Conga_Metadata_Batch__c  fourth = new Conga_Metadata_Batch__c ();
        fourth.Name = 'General_Receipts_And_Orphan_Packs';
        fourth.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        fourth.fileName__c  = '00P3L000000ewFJUAY';
        fourth.Last_Run_Date_Time__c   = system.now();
        fourth.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        fourth.queryAliasId__c  ='00P3L000000ewFJUAY';
        fourth.queryId__c  ='00P3L000000ewFJUAY';
        fourth.Run_Second_Job__c  =true;
        fourth.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        fourth.Second_File_Name__c  ='00P3L000000ewFJUAY';
        fourth.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        fourth.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        fourth.templateId__c      ='00P3L000000ewFJUAY';
        insert fourth ; 
        

        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            RESPONSE_SUCCESS,
            '00P3L000000ewFJUAY'
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        Test.startTest();
			CongaBatchProcessingController.exportDataUsingCongaComposerURL('General_Receipts_And_Orphan_Packs');
        	CongaBatchProcessingController.exportDataUsingCongaComposer('General_Receipts_And_Orphan_Packs');
        Test.stopTest();
    }
    
          @IsTest
    private static void testInitData(){
        Conga_Metadata_Batch__c  first = new Conga_Metadata_Batch__c ();
        first.Name = 'Payment_Receipts_Without_Orphans';
        first.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        first.fileName__c  = '00P3L000000ewFJUAY';
        first.Last_Run_Date_Time__c   = system.now();
        first.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        first.queryAliasId__c  ='00P3L000000ewFJUAY';
        first.queryId__c  ='00P3L000000ewFJUAY';
        first.Run_Second_Job__c  =false;
        first.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        first.Second_File_Name__c  ='00P3L000000ewFJUAY';
        first.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        first.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        first.templateId__c      ='00P3L000000ewFJUAY';
        insert first ;    
        
        Conga_Metadata_Batch__c  fifth = new Conga_Metadata_Batch__c ();
        fifth.Name = 'General_ReceiptsWithout_Orphans_and_OTC';
        fifth.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        fifth.fileName__c  = '00P3L000000ewFJUAY';
        fifth.Last_Run_Date_Time__c   = system.now();
        fifth.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        fifth.queryAliasId__c  ='00P3L000000ewFJUAY';
        fifth.queryId__c  ='00P3L000000ewFJUAY';
        fifth.Run_Second_Job__c  =false;
        fifth.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        fifth.Second_File_Name__c  ='00P3L000000ewFJUAY';
        fifth.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        fifth.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        fifth.templateId__c      ='00P3L000000ewFJUAY';
        insert fifth ; 
        
        
        Conga_Metadata_Batch__c  second = new Conga_Metadata_Batch__c ();
        second.Name = 'Payment_Receipt_Orphan_Packs';
        second.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        second.fileName__c  = '00P3L000000ewFJUAY';
        second.Last_Run_Date_Time__c   = system.now();
        second.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        second.queryAliasId__c  ='00P3L000000ewFJUAY';
        second.queryId__c  ='00P3L000000ewFJUAY';
        second.Run_Second_Job__c  =false;
        second.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        second.Second_File_Name__c  ='00P3L000000ewFJUAY';
        second.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        second.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        second.templateId__c      ='00P3L000000ewFJUAY';
        insert second ; 
        
        
        Conga_Metadata_Batch__c  third = new Conga_Metadata_Batch__c ();
        third.Name = 'General_Receipts_and_Olive_Tree_Certs';
        third.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        third.fileName__c  = '00P3L000000ewFJUAY';
        third.Last_Run_Date_Time__c   = system.now();
        third.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        third.queryAliasId__c  ='00P3L000000ewFJUAY';
        third.queryId__c  ='00P3L000000ewFJUAY';
        third.Run_Second_Job__c  =false;
        third.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        third.Second_File_Name__c  ='00P3L000000ewFJUAY';
        third.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        third.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        third.templateId__c      ='00P3L000000ewFJUAY';
        insert third ; 
        
        
        Conga_Metadata_Batch__c  fourth = new Conga_Metadata_Batch__c ();
        fourth.Name = 'General_Receipts_And_Orphan_Packs';
        fourth.Conga_Email_CC__c  ='00P3L000000ewFJUAY';
        fourth.fileName__c  = '00P3L000000ewFJUAY';
        fourth.Last_Run_Date_Time__c   = system.now();
        fourth.Merge_Record_Id__c  ='00P3L000000ewFJUAY';
        fourth.queryAliasId__c  ='00P3L000000ewFJUAY';
        fourth.queryId__c  ='00P3L000000ewFJUAY';
        fourth.Run_Second_Job__c  =true;
        fourth.Second_Alias_Id__c  ='00P3L000000ewFJUAY';
        fourth.Second_File_Name__c  ='00P3L000000ewFJUAY';
        fourth.Second_Query_ID__c  ='00P3L000000ewFJUAY';
        fourth.Second_Template_ID__c    =  '00P3L000000ewFJUAY';
        fourth.templateId__c      ='00P3L000000ewFJUAY';
        insert fourth ; 
        

        HTTPCalloutServiceMock serviceMock = new HTTPCalloutServiceMock(
            RESPONSE_SUCCESS,
            '00P3L000000ewFJUAY'
        );
        Test.setMock(HTTPCalloutMock.class, serviceMock);
        Test.startTest();
        	CongaBatchProcessingController.initGetData();
        Test.stopTest();
    }
}