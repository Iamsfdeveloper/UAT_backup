@isTest
public class HA_Generate_StatmentController_Test {
    @TestSetup
    static void createData(){
        List<Contact> contactList = (List<Contact>) TestFactory.createSObjectList(
            new Contact(Email='test@humanappeal.org.uk',RecordTypeId = (String)Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Donor').getRecordTypeId()),
            1,
            true
        );
        List<HA_Payment_Schedule__c> paymentScheduleList = (List<HA_Payment_Schedule__c>)TestFactory.createSObjectList(new HA_Payment_Schedule__c(),2,'TestFactoryDefaults.PaymentSchedulesDefaults');
        insert paymentScheduleList;
        System.debug(JSON.serialize(paymentScheduleList[0]));
        List<npsp__General_Accounting_Unit__c> items = (List<npsp__General_Accounting_Unit__c>)TestFactory.createSObjectList(new npsp__General_Accounting_Unit__c(),1,'TestFactoryDefaults.GeneralAccountUnitsDefaults');
        insert items;
        List<Opportunity> donationsList = TestFactory.createSObjectList(
            new Opportunity(npsp__Primary_Contact__c=contactList[0].Id,Amount=100,StageName='Paid',CloseDate=System.Today()),
            1,
            true
        );
        List<npsp__Allocation__c> items2Insert = new  List<npsp__Allocation__c>();
        for(Opportunity donation:donationsList){
            items2Insert.add(new npsp__Allocation__c(npsp__opportunity__c=donation.Id,npsp__General_Accounting_unit__c =items[0].Id,npsp__Amount__c=100.00));
        }
        insert items2Insert;
    }
    static testMethod void unitTest1(){
        Test.startTest();
        PageReference pageRef = Page.Generate_Donation_Statements;
        Test.setCurrentPage(pageRef);
        Contact con = [Select Id,Name FROM Contact Where Email like 'test@humanappeal.org.uk' limit 1];
        pageRef.getParameters().put('id',con.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(con);
        HA_Generate_StatmentController cc = new HA_Generate_StatmentController(sc);
        cc.sendEmail();
        System.assertEquals(true,cc.showEmailSent);
        cc.back();
        cc.show_SendEmail();
        System.assertEquals(false,cc.showEmailSent);
        Test.stopTest();
    }
    static testMethod void unitTest2(){
        Test.startTest();
        PageReference pageRef = Page.Donation_statement_PDF;
        Test.setCurrentPage(pageRef);
        Contact con = [Select Id,Name FROM Contact Where Email like 'test@humanappeal.org.uk' limit 1];
        pageRef.getParameters().put('id',con.Id);
        HA_Donation_Statement_Cmp_Ctrl rt = new HA_Donation_Statement_Cmp_Ctrl();
        rt.contactId = con.Id;
        rt.getBreakdown();
        rt.getBreakdownSize();
        rt.getTotalAmount(con.Id);  
        rt.getTotalGiftAid(con.Id);
        System.assertEquals(100,rt.totalAmount);
        
        Test.stopTest();
    }
    
    @isTest
    static void testfrenchWording() {
        NumbersToFrench.convertCurrency(1234.1);
        NumbersToFrench.convertCurrency(5234.5);
        NumbersToFrench.convertCurrency(77234.2);
        NumbersToFrench.convertCurrency(34.3);
        NumbersToFrench.convertCurrency(6.4);
        NumbersToFrench.convertCurrency(6123.6);
        NumbersToFrench.convertCurrency(883123.7);
        NumbersToFrench.convertCurrency(93123.8);
        NumbersToFrench.convertCurrency(312.9);
    }
}