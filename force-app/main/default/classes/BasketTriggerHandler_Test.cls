/**
* @description       : 
* @author            : Iamsfdeveloper
* @group             : 
* @last modified on  : 02-15-2022
* @last modified by  : Iamsfdeveloper
**/
@isTest
public class BasketTriggerHandler_Test {
    
    @testSetup
    static void makeData(){
        Profile p = [SELECT Id From Profile Where Name = 'System Administrator' limit 1];
        insert new User(Department= 'Systems & Developement',Alias = 'user1',EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='Europe/London', ProfileId=p.Id,username='website-'+Crypto.getRandomInteger()+'@humanAppeal.org.uk',isActive=true,email='website@humanAppeal.org.uk',lastname='user1',FirstName='Test',Payment_Country_Code__c ='UK');
        npsp__General_Accounting_Unit__c item = new npsp__General_Accounting_Unit__c(Name = 'HumanAppeal Donation', Donation_Item_Code__c = 'DEFAULT-2021',npsp__Active__c = true);
        upsert item Donation_Item_Code__c;
        HA_Payment_Schedule__c singleScheule = (HA_Payment_Schedule__c)TestFactory.createSObject(new HA_Payment_Schedule__c(Name='Single',Code__c='SD',Frequency__c='Single'), 'TestFactoryDefaults.PaymentSchedulesDefaults', true);
        HA_Payment_Schedule__c TenNights = (HA_Payment_Schedule__c)TestFactory.createSObject(new HA_Payment_Schedule__c(Name='Single',Code__c='10N',Frequency__c='Daily'), 'TestFactoryDefaults.PaymentSchedulesDefaults', true);
        HA_Payment_Schedule__c ThirtyNights = (HA_Payment_Schedule__c)TestFactory.createSObject(new HA_Payment_Schedule__c(Name='Single',Code__c='30N',Frequency__c='Daily'), 'TestFactoryDefaults.PaymentSchedulesDefaults', true);
        List<Payment_Schedule_Allocation__c> pslist =new List<Payment_Schedule_Allocation__c>{
                                                                    	new Payment_Schedule_Allocation__c(General_Accounting_Unit__c=item.Id, Payment_Schedule__c=singleScheule.Id),
                                                                        new Payment_Schedule_Allocation__c(General_Accounting_Unit__c=item.Id, Payment_Schedule__c=TenNights.Id),
                                                                        new Payment_Schedule_Allocation__c(General_Accounting_Unit__c=item.Id, Payment_Schedule__c=ThirtyNights.Id)
                                                    }; 
       insert pslist; 
    }
    @IsTest
    static void unit1(){
        List<npsp__Trigger_Handler__c> listHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'BasketTriggerHandler_TDTM';
        th.npsp__Class__c = 'BasketTriggerHandler_TDTM';
        th.npsp__Object__c = 'Basket__c';
        th.npsp__Trigger_Action__c = 'AfterInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        listHandlers.add(th);
        npsp__Trigger_Handler__c donationth = new npsp__Trigger_Handler__c();
        donationth.Name = 'CreateRecurringService_TDTM';
        donationth.npsp__Class__c = 'CreateRecurringService_TDTM';
        donationth.npsp__Object__c = 'Opportunity';
        donationth.npsp__Trigger_Action__c = 'AfterInsert,AfterUpdate';
        donationth.npsp__Active__c = true;
        donationth.npsp__Load_Order__c = 5;
        donationth.npsp__Asynchronous__c = false;
        listHandlers.add(donationth);
        User u = [Select Id From User where username like '%@humanAppeal.org.uk' and IsActive=true limit 1];
        StaticResource sr = [
            SELECT Id, Body
            FROM StaticResource
            WHERE Name = :'TestJSONv4'
            LIMIT 1
        ];
        String jsonBody = sr.Body.toString();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/service/apexrest/donationAPI';
        req.httpMethod = 'POST';
        req.requestBody = sr.Body;
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        System.runAs(u){ 
            donationAPI.doPost();
        }
        Test.stopTest();
        //System.assertEquals(200, res.statusCode); 
    }
    @IsTest
    Static void unit2(){
        Test.startTest();
        checkoutDataType checkout = new checkoutDataType();
        checkoutDataType.NewDonationDataType donationDT= new checkoutDataType.NewDonationDataType();
        donationDT.supporter = new checkoutDataType.NewDonationSupporterDataType();
        donationDT.basket = new checkoutDataType.NewDonationBasketDataType();
        donationDT.PaymentMethods =new List<checkoutDataType.paymentMethodDataType>{new checkoutDataType.paymentMethodDataType()};
            donationDT.basket.ItemGroups = new List<checkoutDataType.donationGroup>{new checkoutDataType.donationGroup()};
                donationDT.basket.ItemGroups[0].items = new List<checkoutDataType.NewDonationBasketItemDataType>{new checkoutDataType.NewDonationBasketItemDataType()};
                    checkoutDataType.PaymentScheduleList paymentscheduleList = new checkoutDataType.PaymentScheduleList();
        checkoutDataType.SchemeData SchemaDataLsit = new checkoutDataType.SchemeData();
        checkoutDataType.ValidationResponse ddResponse = new checkoutDataType.ValidationResponse();
        
        
        Test.stopTest();
        
    }
 @IsTest
    Static void unit1_Negative(){
       User u = [Select Id From User where username like '%@humanAppeal.org.uk' and IsActive=true limit 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/service/apexrest/donationAPI';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('Testing Negative');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        
        System.runAs(u){ 
            donationAPI.doPost();
        }
        Test.stopTest();
    }
    @IsTest
    static void unit3(){
        List<npsp__Trigger_Handler__c> listHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'BasketTriggerHandler_TDTM';
        th.npsp__Class__c = 'BasketTriggerHandler_TDTM';
        th.npsp__Object__c = 'Basket__c';
        th.npsp__Trigger_Action__c = 'AfterInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        listHandlers.add(th);
        npsp__Trigger_Handler__c donationth = new npsp__Trigger_Handler__c();
        donationth.Name = 'CreateRecurringService_TDTM';
        donationth.npsp__Class__c = 'CreateRecurringService_TDTM';
        donationth.npsp__Object__c = 'Opportunity';
        donationth.npsp__Trigger_Action__c = 'BeforeUpdate,AfterUpdate';
        donationth.npsp__Active__c = true;
        donationth.npsp__Load_Order__c = 5;
        donationth.npsp__Asynchronous__c = false;
        listHandlers.add(donationth);
        User u = [Select Id From User where username like '%@humanAppeal.org.uk' and IsActive=true limit 1];
        StaticResource sr = [
            SELECT Id, Body
            FROM StaticResource
            WHERE Name = :'TestJSONv4_1'
            LIMIT 1
        ];
        String jsonBody = sr.Body.toString();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/service/apexrest/donationAPI';
        req.httpMethod = 'POST';
        req.requestBody = sr.Body;
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        System.runAs(u){ 
            donationAPI.doPost();
        }
        Test.stopTest();
        
    }
    @IsTest
    static void unit4(){
        List<npsp__Trigger_Handler__c> listHandlers = npsp.TDTM_Config_API.getCachedRecords();
        
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'BasketTriggerHandler_TDTM';
        th.npsp__Class__c = 'BasketTriggerHandler_TDTM';
        th.npsp__Object__c = 'Basket__c';
        th.npsp__Trigger_Action__c = 'AfterInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        listHandlers.add(th);
        npsp__Trigger_Handler__c donationth = new npsp__Trigger_Handler__c();
        donationth.Name = 'CreateRecurringService_TDTM';
        donationth.npsp__Class__c = 'CreateRecurringService_TDTM';
        donationth.npsp__Object__c = 'Opportunity';
        donationth.npsp__Trigger_Action__c = 'BeforeUpdate,AfterUpdate';
        donationth.npsp__Active__c = true;
        donationth.npsp__Load_Order__c = 5;
        donationth.npsp__Asynchronous__c = false;
        listHandlers.add(donationth);
        User u = [Select Id From User where username like '%@humanAppeal.org.uk' and IsActive=true limit 1];
        StaticResource sr = [
            SELECT Id, Body
            FROM StaticResource
            WHERE Name = :'TestJSON_6'
            LIMIT 1
        ];
        String jsonBody = sr.Body.toString();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/service/apexrest/donationAPI';
        req.httpMethod = 'POST';
        req.requestBody = sr.Body;
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        System.runAs(u){ 
            donationAPI.doPost();
        }
        Test.stopTest();
        
    }
}