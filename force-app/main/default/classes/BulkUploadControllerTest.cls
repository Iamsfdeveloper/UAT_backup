@IsTest
public class  BulkUploadControllerTest {
    @IsTest
    private static void testInsertDonationsforAgencies(){
        
        contact con = new Contact();
        con.Firstname = 'Name1';
        con.Lastname = 'Name2';
        con.MailingCity = 'sss';
        con.MailingCountry = 'sss';
        con.MailingStreet = 'sss';
        con.MailingPostalCode = 'sss';
        con.Email = 'test@abc.com';
        con.Orphan_Transport_To_School__c='Walks'; 
        insert con;
        
        Contact inContact = [Select Id,Donor_ID__c from Contact Where Id =:con.Id];
        String data = '[ { "dateValue":"2020-08-17", "donorId":"'+inContact.Donor_ID__c+'", "itemCode":"ZZ20-20201", "stipulation":"Sadaqah", "gaEligible":"FALSE", "stage":"Paid", "currCode":"GBP", "amount":"20.00", "agencyFees":"0.58", "netDonationAmount":"19.42", "bankReference":"", "primaryCampaignSource":"Aftab Nawaz-12500-ZZ20-80801", "medium":"Agency", "paymentMethod":"JustGiving", "bank":"NATWEST 705", "regionalOffice":"HA UK - Cheadle", "Fundraising Page Title":"", "fundRaisingUrl":"http://www.justgiving.com/Shazia-Arshad", "Transaction Source":"JustGiving","":"" } ]';        
        npsp__General_Accounting_Unit__c testProduct = new npsp__General_Accounting_Unit__c(
        Name = 'Aqiqa',
        Donation_Item_Code__c = 'ZZ20-20201',
        Include_In_General_Receipt__c = true
        );
        insert testProduct;
        HA_Payment_Schedule__c donCode = new HA_Payment_Schedule__c(Is_Bulk_Upload_Allowed__c= true);
        donCode.Code__c = 'SD';
        insert donCode;
        
        Campaign camp = new Campaign();
        camp.name = 'Aftab Nawaz-12500-ZZ20-80801';
        camp.Dialer_Queue__c  = 'Dialer_Queue_UK_1';
        camp.Country__c = 'United Kingdom';
        insert camp;
        List<Bulk_Upload_Donations__c>  lrw  ;
        
        Test.startTest();
            lrw = BulkUploadController.insertDonationsFromCSVFile(data, 'Agencies','TEST.csv');
        Test.stopTest();
        
        Integer opportunityCount =[Select count() from Opportunity  where npsp__Primary_Contact__c=:con.Id];
        System.assertEquals(1,lrw.size());
        System.assertEquals(1, opportunityCount);   
    }
    
    @IsTest
    private static void testInsertDonationsforBankTransfers(){
        
        contact con = new Contact();
        con.Firstname = 'Name3';
        con.Lastname = 'Name4';
        con.MailingCity = 'bb';
        con.MailingCountry = 'bb';
        con.MailingStreet = 'bb';
        con.MailingPostalCode = 'bb';
        con.Email = 'testss@abcss.com';
        con.Orphan_Transport_To_School__c='Walks'; 
        insert con;
        
        Contact inContact = [Select Id,Donor_ID__c from Contact Where Id =:con.Id];
        
        String data = '[ { "dateValue":"2020-08-17", "donorId":"'+inContact.Donor_ID__c+'", "itemCode":"ZZ20-20201", "stipulation":"Sadaqah", "gaEligible":"FALSE", "stage":"Paid", "currCode":"GBP", "amount":"29.97", "agencyFees":"", "netDonationAmount":"", "bankReference":"CHARITIES TRUST  d1005733 ZF Automotive UK Limited", "primaryCampaignSource":"Lahouari Laroussi-770", "medium":"bank Transfer", "paymentMethod":"bank Transfer", "bank":"NATWEST 721", "regionalOffice":"HA UK - Cheadle", "Fundraising Page Title":"", "fundRaisingUrl":"" ,"Transaction Source":""} ]';        
        npsp__General_Accounting_Unit__c testProduct = new npsp__General_Accounting_Unit__c(
        Name = 'Aqiqa',
        Donation_Item_Code__c = 'ZZ20-20201',
        Include_In_General_Receipt__c = true
        );
        insert testProduct;
        
        HA_Payment_Schedule__c donCode = new HA_Payment_Schedule__c(Is_Bulk_Upload_Allowed__c= true);
        donCode.Code__c = 'SD';
        insert donCode;
        
        Campaign camp = new Campaign();
        camp.name = 'Aftab Nawaz-12500-ZZ20-80801';
        camp.Dialer_Queue__c  = 'Dialer_Queue_UK_1';
        camp.Country__c = 'United Kingdom';
        insert camp;
        List<Bulk_Upload_Donations__c>  lrw;
        
        Test.startTest();
            lrw = BulkUploadController.insertDonationsFromCSVFile(data, 'BankTransfers','TEST.csv');
        Test.stopTest();
        
        Integer opportunityCount =[Select count() from Opportunity  where npsp__Primary_Contact__c=:con.Id];
        System.assertEquals(1,lrw.size());
        System.assertEquals(1, opportunityCount);   
    }   
    
    @IsTest
    private static void testInsertDonationsforBankTransfersOrganizations(){
        Id accRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId(); 
        
        Account acc = new Account();
        acc.name = 'Test';
        acc.RecordTypeId = accRecId;
        Insert acc;
        HA_Payment_Schedule__c donCode = new HA_Payment_Schedule__c(Is_Bulk_Upload_Allowed__c= true);
        donCode.Code__c = 'SD';
        insert donCode;
        
        Campaign camp = new Campaign();
        camp.name = 'Aftab Nawaz-12500-ZZ20-80801';
        camp.Dialer_Queue__c  = 'Dialer_Queue_UK_1';
        camp.Country__c = 'United Kingdom';
        insert camp;        
        
        String data = '[ { "dateValue":"2020-08-17", "sfAccountId":"'+acc.Id+'","donorId":"", "itemCode":"ZZ20-20201", "stipulation":"Sadaqah", "gaEligible":"FALSE", "stage":"Paid", "currCode":"GBP", "amount":"29.97", "agencyFees":"", "netDonationAmount":"", "bankReference":"CHARITIES TRUST  d1005733 ZF Automotive UK Limited", "primaryCampaignSource":"Lahouari Laroussi-770", "medium":"bank Transfer", "paymentMethod":"bank Transfer", "bank":"NATWEST 721", "regionalOffice":"HA UK - Cheadle", "Fundraising Page Title":"", "fundRaisingUrl":"","Transaction Source":"" } ]';        
        npsp__General_Accounting_Unit__c testProduct = new npsp__General_Accounting_Unit__c(
        Name = 'Aqiqa',
        Donation_Item_Code__c = 'ZZ20-20201',
        Include_In_General_Receipt__c = true
        );
        insert testProduct;
        
        List<Bulk_Upload_Donations__c>  lrw;
        Test.startTest();
            lrw = BulkUploadController.insertDonationsFromCSVFile(data, 'BankTransfersOrg','TEST.csv');
        Test.stopTest();
        
        Integer opportunityCount =[Select count() from Opportunity  where AccountId=:acc.Id];
		System.assertEquals(1,lrw.size());
        System.assertEquals(1, opportunityCount); 
        lrw = BulkUploadController.initGetData();
        System.assertEquals(1,lrw.size());
    }
    
    @IsTest
    private static void testInsertSingleRun(){
        Id accRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId(); 
        
        Account acc = new Account();
        acc.name = 'Test';
        acc.RecordTypeId = accRecId;
        Insert acc;
        HA_Payment_Schedule__c donCode = new HA_Payment_Schedule__c(Is_Bulk_Upload_Allowed__c= true);
        donCode.Code__c = 'SD';
        insert donCode;
        
        Campaign camp = new Campaign();
        camp.name = 'Aftab Nawaz-12500-ZZ20-80801';
        camp.Dialer_Queue__c  = 'Dialer_Queue_UK_1';
        camp.Country__c = 'United Kingdom';
        insert camp;        
        
        String data = '[ { "dateValue":"2020-08-17", "sfAccountId":"'+acc.Id+'","donorId":"", "itemCode":"ZZ20-20201", "stipulation":"Sadaqah", "gaEligible":"FALSE", "stage":"Paid", "currCode":"GBP", "amount":"29.97", "agencyFees":"", "netDonationAmount":"", "bankReference":"CHARITIES TRUST  d1005733 ZF Automotive UK Limited", "primaryCampaignSource":"Lahouari Laroussi-770", "medium":"bank Transfer", "paymentMethod":"bank Transfer", "bank":"NATWEST 721", "regionalOffice":"HA UK - Cheadle", "Fundraising Page Title":"", "fundRaisingUrl":"","Transaction Source":"" } ]';        npsp__General_Accounting_Unit__c testProduct = new npsp__General_Accounting_Unit__c(
        Name = 'Aqiqa',
        Donation_Item_Code__c = 'ZZ20-20201',
        Include_In_General_Receipt__c = true
        );
        insert testProduct;
        
        Test.startTest();
        Bulk_Upload_Donations__c b =  new Bulk_Upload_Donations__c(Name='Test_Upload',Status__c='Failed');
        insert b;
        ApexPages.StandardController sc = new ApexPages.StandardController(b);
        BulkUploadBatchRetry bubr = new BulkUploadBatchRetry(sc);
        bubr.retryBatch();
            BulkUploadProcessFuture bupf = new BulkUploadProcessFuture(b.Id);
            Database.executebatch(bupf, 100);
        Test.stopTest();
    }    

  /*  @IsTest
    private static void testInsertDonationsforBankTransfersOrganizationsDuplicate(){
        Id accRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId(); 
        HA_Payment_Schedule__c donCode = new HA_Payment_Schedule__c();
        donCode.Code__c = 'SD';
        insert donCode;
        
        Campaign camp = new Campaign();
        camp.name = 'Aftab Nawaz-12500-ZZ20-80801';
        camp.Dialer_Queue__c  = 'Dialer_Queue_UK_1';
        camp.Country__c = 'United Kingdom';
        insert camp;        
        Account acc = new Account();
        acc.name = 'Test';
        acc.RecordTypeId = accRecId;
        Insert acc;
        
        
        String data = '[ { "dateValue":"2020-08-17", "sfAccountId":"'+acc.Id+'","donorId":"", "itemCode":"ZZ20-20201", "stipulation":"Sadaqah", "gaEligible":"FALSE", "stage":"Paid", "currCode":"GBP", "amount":"29.97", "agencyFees":"", "netDonationAmount":"", "bankReference":"CHARITIES TRUST  d1005733 ZF Automotive UK Limited", "primaryCampaignSource":"Lahouari Laroussi-770", "medium":"bank Transfer", "paymentMethod":"bank Transfer", "bank":"NATWEST 721", "regionalOffice":"HA UK - Cheadle", "Fundraising Page Title":"", "fundRaisingUrl":"" } ]';
        
        npsp__General_Accounting_Unit__c testProduct = new npsp__General_Accounting_Unit__c(
        Name = 'Aqiqa',
        Donation_Item_Code__c = 'ZZ20-20201',
        Include_In_General_Receipt__c = true
        );
        insert testProduct;
        
        string lrw;
        string lrw1;
        Test.startTest();
        	lrw = BulkUploadController.insertDonationsFromCSVFile(data, 'BankTransfersOrg');
        Test.stopTest();
        
        Integer opportunityCount =[Select count() from Opportunity  where AccountId=:acc.Id];
        System.assertEquals('Processing Donations is Initiated, It will take some time for the processing',lrw);

        System.assertEquals(1, opportunityCount);  
        
        Test.startTest();
            lrw1 = BulkUploadController.insertDonationsFromCSVFile(data, 'BankTransfersOrg');
        Test.stopTest();
        
        Integer opportunityCountdup =[Select count() from Opportunity  where AccountId=:acc.Id];
        System.assertEquals('Processing Donations is Initiated, It will take some time for the processing',lrw1);

        System.assertEquals(1, opportunityCountdup);   

    }     
    
    
    @IsTest
    private static void testInsertDonationsforAgenciesDuplicate(){
         HA_Payment_Schedule__c donCode = new HA_Payment_Schedule__c();
        donCode.Code__c = 'SD';
        insert donCode;
        
        Campaign camp = new Campaign();
        camp.name = 'Aftab Nawaz-12500-ZZ20-80801';
        camp.Dialer_Queue__c  = 'Dialer_Queue_UK_1';
        camp.Country__c = 'United Kingdom';
        insert camp;       
        contact con = new Contact();
        con.Firstname = 'Name1';
        con.Lastname = 'Name2';
        con.MailingCity = 'sss';
        con.MailingCountry = 'sss';
        con.MailingStreet = 'sss';
        con.MailingPostalCode = 'sss';
        con.Email = 'test@abc.com';
        con.Orphan_Transport_To_School__c='Walks'; 
        insert con;
        
        Contact inContact = [Select Id,Donor_ID__c from Contact Where Id =:con.Id];
        
        String data = '[ { "dateValue":"2020-08-17", "donorId":"'+inContact.Donor_ID__c+'", "itemCode":"ZZ20-20201", "stipulation":"Sadaqah", "gaEligible":"FALSE", "stage":"Paid", "currCode":"GBP", "amount":"20.00", "agencyFees":"0.58", "netDonationAmount":"19.42", "bankReference":"", "primaryCampaignSource":"Aftab Nawaz-12500-ZZ20-80801", "medium":"Agency", "paymentMethod":"JustGiving", "bank":"NATWEST 705", "regionalOffice":"HA UK - Cheadle", "Fundraising Page Title":"", "fundRaisingUrl":"http://www.justgiving.com/Shazia-Arshad", "":"" } ]';
        
        npsp__General_Accounting_Unit__c testProduct = new npsp__General_Accounting_Unit__c(
        Name = 'Aqiqa',
        Donation_Item_Code__c = 'ZZ20-20201',
        Include_In_General_Receipt__c = true
        );
        insert testProduct;
        String lrw;
        String lrw1;
        
        lrw = BulkUploadController.insertDonationsFromCSVFile(data, 'Agencies');
        Test.startTest();
        	Integer opportunityCount =[Select count() from Opportunity  where npsp__Primary_Contact__c=:con.Id];
        Test.stopTest();  
        System.assertEquals('Processing Donations is Initiated, It will take some time for the processing',lrw);
        System.assertEquals(1, opportunityCount);  
        
        Test.startTest();
            lrw1 = BulkUploadController.insertDonationsFromCSVFile(data, 'Agencies');
        Test.stopTest();    
        
        Integer opportunityCountdup =[Select count() from Opportunity  where npsp__Primary_Contact__c=:con.Id];
        System.assertEquals('Processing Donations is Initiated, It will take some time for the processing',lrw1);
        System.assertEquals(1, opportunityCountdup);         
    }    
    
    @IsTest
    private static void testInsertDonationsforBankTransfersDuplicates(){
          HA_Payment_Schedule__c donCode = new HA_Payment_Schedule__c();
        donCode.Code__c = 'SD';
        insert donCode;
        
        Campaign camp = new Campaign();
        camp.name = 'Aftab Nawaz-12500-ZZ20-80801';
        camp.Dialer_Queue__c  = 'Dialer_Queue_UK_1';
        camp.Country__c = 'United Kingdom';
        insert camp;      
        contact con = new Contact();
        con.Firstname = 'Name3';
        con.Lastname = 'Name4';
        con.MailingCity = 'bb';
        con.MailingCountry = 'bb';
        con.MailingStreet = 'bb';
        con.MailingPostalCode = 'bb';
        con.Email = 'testss@abcss.com';
        con.Orphan_Transport_To_School__c='Walks'; 
        insert con;
        
        Contact inContact = [Select Id,Donor_ID__c from Contact Where Id =:con.Id];
        
        String data = '[ { "dateValue":"2020-08-17", "donorId":"'+inContact.Donor_ID__c+'", "itemCode":"ZZ20-20201", "stipulation":"Sadaqah", "gaEligible":"FALSE", "stage":"Paid", "currCode":"GBP", "amount":"29.97", "agencyFees":"", "netDonationAmount":"", "bankReference":"CHARITIES TRUST  d1005733 ZF Automotive UK Limited", "primaryCampaignSource":"Lahouari Laroussi-770", "medium":"bank Transfer", "paymentMethod":"bank Transfer", "bank":"NATWEST 721", "regionalOffice":"HA UK - Cheadle", "Fundraising Page Title":"", "fundRaisingUrl":"" } ]';
        
        npsp__General_Accounting_Unit__c testProduct = new npsp__General_Accounting_Unit__c(
        Name = 'Aqiqa',
        Donation_Item_Code__c = 'ZZ20-20201',
        Include_In_General_Receipt__c = true
        );
        insert testProduct;
        String lrw;
        string lrw1;
        Test.startTest();
        	lrw = BulkUploadController.insertDonationsFromCSVFile(data, 'BankTransfers');
        Test.stopTest();
        
        Integer opportunityCount =[Select count() from Opportunity  where npsp__Primary_Contact__c=:con.Id];
         System.assertEquals('Processing Donations is Initiated, It will take some time for the processing',lrw);

        System.assertEquals(1, opportunityCount);        
        
        Test.startTest();
            lrw1 = BulkUploadController.insertDonationsFromCSVFile(data, 'BankTransfers');
        Test.stopTest();
        
        Integer opportunityCountdup =[Select count() from Opportunity  where npsp__Primary_Contact__c=:con.Id];
        System.assertEquals('Processing Donations is Initiated, It will take some time for the processing',lrw1);
        System.assertEquals(1, opportunityCountdup);   
    }   */    

}