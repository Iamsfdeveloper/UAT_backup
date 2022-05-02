/**
* Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
**/
@IsTest
private class dlrs_npsp_AllocationTest
{
    @IsTest
    private static void testTrigger()
    {
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
        Boolean isNpspTriggerDisabled = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>());
        Test.startTest();
        contact contact = new Contact();
        contact.Firstname = 'Name1';
        contact.Lastname = 'Name2';
        contact.MailingCity = 'sss';
        contact.MailingCountry = 'sss';
        contact.MailingStreet = 'sss';
        contact.MailingPostalCode = 'sss';
        
        insert contact;
        
        
        npsp__General_Accounting_Unit__c testProduct = new npsp__General_Accounting_Unit__c(
            Name = 'Aqiqa',
            Donation_Item_Code__c = 'WIFU',
            Include_In_General_Receipt__c = true
        );
        insert testProduct;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
        opp.Amount = 5;
        opp.StageName = 'Awaiting Payment Details';
        opp.CloseDate = Date.Today();
        opp.npsp__Primary_Contact__c = contact.Id;
        insert opp;
        
        npsp__Allocation__c guaAllication = new npsp__Allocation__c(Type__c='Credit');
        guaAllication.npsp__Opportunity__c = opp.Id;
        guaAllication.npsp__Amount__c = 5;
        guaAllication.CurrencyIsoCode = 'GBP';
        guaAllication.npsp__General_Accounting_Unit__c = testProduct.Id;
        insert guaAllication;
        
        Instruction__c ints = new Instruction__c(Type__c ='Implementation',Instruction_Notes__c='Test Notes ',Funds_Allocated__c = 5);
        insert ints;
        
        npsp__Allocation__c guaAllication2 = new npsp__Allocation__c(Type__c='Credit');
        guaAllication2.Instruction__c = ints.Id;
        guaAllication2.npsp__Amount__c = 5;
        guaAllication2.CurrencyIsoCode = 'GBP';
        guaAllication2.npsp__General_Accounting_Unit__c = testProduct.Id;
        insert guaAllication2;
        Test.stopTest();
    }
}