@isTest
private with sharing class ReceiptTemplateController_Test {

    @isTest static void ReceiptTemplateControllerTest() {

        Contact member = new Contact();
        member.FirstName = 'testFirst';
        member.LastName = 'testLast';  
        member.Email = 'example@example.com';      
        member.MailingStreet = 'Street'; 
        member.MailingCity = 'City';
        member.MailingState = 'State';
        member.MailingCountry = 'Country';
        member.MailingPostalCode = 'Country';
        insert member;

        npsp__General_Accounting_Unit__c item = new npsp__General_Accounting_Unit__c(npsp__Active__c=true,Donation_item_code__c='WFIU');
        insert item;

        Translation__c objTrans = new Translation__c();
        objTrans.Language__c = 'ES';
        objTrans.Item__c = item.Id;
        objTrans.Translated_Text__c = 'test Name';
        insert objTrans;

        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
        opp.Amount = 5;
        opp.StageName = 'test';
        opp.CloseDate = Date.Today();
        opp.npsp__Primary_Contact__c = member.Id;
        insert opp;

		npsp__Allocation__c itemAllocation = new npsp__Allocation__c(npsp__General_Accounting_Unit__c =item.Id ,npsp__Amount__c=5,npsp__Opportunity__c=opp.Id);
        insert itemAllocation;

        Test.startTest();
        
        npe03__Recurring_Donation__c rd = (npe03__Recurring_Donation__c) TestFactory.createSObject(
                new npe03__Recurring_Donation__c(
                    npe03__Contact__c = member.Id,
                    npe03__Amount__c = 100,
                    npsp__StartDate__c = Date.today(),
                    npsp__PaymentMethod__c = 'Card Payment',
                    npe03__Date_Established__c = Date.today(),
                    npsp__Day_of_Month__c = String.valueOf(Date.today().day())
                ),
                'TestFactoryDefaults.RDDefaults'
            );
        insert rd;
        
        Income_Card_Payment__c cardPayment = new Income_Card_Payment__c(Opportunity__c = opp.Id, Recurring_Donation__c = rd.Id, Contact__c = member.Id, Payment_Status__c = 'Created', Transaction_Type__c = 'Sale');
        insert cardPayment;

        cardPayment.Internal_Payment_Description__c=opp.Id;
        cardPayment.Payment_Status__c = 'Successful';
        update cardPayment;

        Income_Card_Payment_History__c cardPaymentHistory = new Income_Card_Payment_History__c(Income_Card_Payment__c = cardPayment.Id, Payment_Status__c = 'Successful', Transaction_Type__c = 'Sale', Transaction_Date__c = Date.Today() + 5);
        insert cardPaymentHistory;  

        ReceiptTemplateController receiptTemplate = new ReceiptTemplateController();
        receiptTemplate.oppId = opp.Id;
        receiptTemplate.lang = 'ES';

        Integer sizeInt = receiptTemplate.getBreakdownSize();
        List<ReceiptTemplateController.ProdWrap>  lstProd = receiptTemplate.getlstProdWrap();
        List<npsp__Allocation__c>  allocation = receiptTemplate.getProducts();
        List<npsp__Allocation__c>  parentAllocation = receiptTemplate.getParentAllocations();

        System.assertEquals(1, sizeInt);
        System.assertEquals(1, lstProd.size());
        System.assertEquals(0, parentAllocation.size());
        System.assertEquals(1, allocation.size());

        Test.stopTest();
    }
}