@isTest
public class createInstruction_Test {
	@TestSetup
    private static void makedata(){
        List<npsp__General_Accounting_Unit__c> items = (List<npsp__General_Accounting_Unit__c>)TestFactory.createSObjectList(new npsp__General_Accounting_Unit__c(Regional_Office_Code__c='All',Name='Test_Pledge_Item',Donation_Item_code__c='xx-501',Product_Type__c='Pledge'),1,'TestFactoryDefaults.GeneralAccountUnitsDefaults');
        insert items;
        Campaign c =  (Campaign)TestFactory.createSObject(new Campaign(Name='Test_Pledge', RecordTypeId=Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Pledge').getRecordTypeId(),Pledged_Amount__c =100.00));
		insert c;
        insert new npsp__Allocation__c(npsp__General_Accounting_Unit__c = items[0].Id,npsp__Percent__c=100,npsp__Campaign__c=c.Id);
    }
    private static testmethod  void unit1(){
        Test.startTest();
        Map<String,Object> results = createInstruction.doInit();
        Map<String,Object> getItems = createInstruction.getItems(' Name like \'Test1234%\'','GBP');
        createInstruction.getCampaignDetails([Select Id From Campaign Where Name ='Test_Pledge']?.Id);
        String campaignId = [Select Id From Campaign Where Name ='Test_Pledge']?.Id ;
        String obj = '{"campaign__c":\"'+campaignId+'\" , "Type__c":"Implementation","Instruction_Notes__c":"Test is Notes"}';
        String itemAllocationId= [Select Id From npsp__General_Accounting_Unit__c Where Product_Type__c = 'Pledge']?.Id;
        List<npsp__Allocation__c> itemList = new List<npsp__Allocation__c>{new npsp__Allocation__c(npsp__General_Accounting_Unit__c=itemAllocationId,npsp__Amount__c=10)};
        createInstruction.saveAllocation(obj,JSON.serialize(itemList));
        Test.stopTest();
    }
}