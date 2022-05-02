@isTest
private with sharing class ALLO_Allocation_Custom_TEST {
    

    /* @testSetup static void triggerHandler() {
        
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
		Boolean isNpspTriggerDisabled = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>());

        List<npsp__Trigger_Handler__c> listHandlers = npsp.TDTM_Config_API.getCachedRecords();
        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'ALLO_Allocations_Custom_TDTM';
        th.npsp__Class__c = 'ALLO_Allocations_Custom_TDTM';
        th.npsp__Object__c = 'Allocation__c';
        th.npsp__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterInsert;AfterUpdate;AfterDelete';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        listHandlers.add(th);
    } */
    /*********************************************************************************************************
    * @description If you only want to run a single test in this class, fill in its name here.
    * If you want to run all tests, then use '*'
    */
    private static string strTestOnly = '*';
    
    /*******************************************************************************************************
    * @description Setup of allocations settings.
    * @param alloset An instance of Allocations_Settings__c custom setting. Calling this method with a null
    * parameter uses default settings.
    * @return void Modifies settings, returns nothing.
    ********************************************************************************************************/
    private static void setupSettings (npsp__Allocations_Settings__c alloset) {
        //set running user to avoid dml issue            
        System.runAs(new User(id = UserInfo.getUserId())){
            if (alloset!=null)
                getAllocationsSettingsForTests(alloset);
            else 
                getAllocationsSettingsForTests(new npsp__Allocations_Settings__c());

        }
    }



    @IsTest
    static void AllocatingPaymentLevel_Test(){
        
        npsp__Allocations_Settings__c allocationsSettings = new npsp__Allocations_Settings__c();
        allocationsSettings.npsp__Default_Allocations_Enabled__c = false;
        allocationsSettings.npsp__Default__c = null;
        allocationsSettings.npsp__Excluded_Opp_RecTypes__c = 'Yes';
        allocationsSettings.npsp__Excluded_Opp_Types__c = 'Yes';
        allocationsSettings.npsp__Payment_Allocations_Enabled__c = true;
        insert allocationsSettings;

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'ALLO_Allocations_Custom_TDTM_Test';
        th.npsp__Class__c = 'ALLO_Allocations_Custom_TDTM';
        th.npsp__Object__c = 'Allocation__c';
        th.npsp__Trigger_Action__c = 'BeforeInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        insert th;

        Account acc = new Account(Name='foo');
        insert acc;
        Opportunity opp = new Opportunity(Name='foo', Amount = 8, AccountID=acc.Id, CloseDate=System.today(), StageName=getClosedWonStage());
        insert opp;
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name='foo');
        insert gau;
        npe01__OppPayment__c pmt = new npe01__OppPayment__c(npe01__Payment_Amount__c = 8, npe01__Opportunity__c = opp.Id);
        insert pmt;

        npsp__Allocation__c objAllo = createOppAllocation(gau.Id, opp.Id, 8, null);
        objAllo.npsp__Payment__c = pmt.Id;



        Test.startTest();
        Boolean ErrorOccured = false;
        try {

            insert objAllo;
        }
        catch(Exception exp) {
            ErrorOccured = true;
            System.assertEquals('You must enable Default Allocations in order to allocate at the payment level.',exp.getDmlMessage(0));
        }
        System.assertEquals(true, ErrorOccured);

        Test.stopTest();
        
    }

    @IsTest
    static void AllocatingPaymentLevel2_Test(){
        
        npsp__Allocations_Settings__c allocationsSettings = new npsp__Allocations_Settings__c();
        allocationsSettings.npsp__Default_Allocations_Enabled__c = true;
        allocationsSettings.npsp__Default__c = null;
        allocationsSettings.npsp__Excluded_Opp_RecTypes__c = 'Yes';
        allocationsSettings.npsp__Excluded_Opp_Types__c = 'Yes';
        allocationsSettings.npsp__Payment_Allocations_Enabled__c = false;
        insert allocationsSettings;

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'ALLO_Allocations_Custom_TDTM_Test';
        th.npsp__Class__c = 'ALLO_Allocations_Custom_TDTM';
        th.npsp__Object__c = 'Allocation__c';
        th.npsp__Trigger_Action__c = 'BeforeInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        insert th;

        Account acc = new Account(Name='foo');
        insert acc;
        Opportunity opp = new Opportunity(Name='foo', Amount = 8, AccountID=acc.Id, CloseDate=System.today(), StageName=getClosedWonStage());
        insert opp;
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name='foo');
        insert gau;
        npe01__OppPayment__c pmt = new npe01__OppPayment__c(npe01__Payment_Amount__c = 8, npe01__Opportunity__c = opp.Id);
        insert pmt;

        npsp__Allocation__c objAllo = createOppAllocation(gau.Id, opp.Id, 8, null);
        objAllo.npsp__Payment__c = pmt.Id;



        Test.startTest();
        Boolean ErrorOccured = false;
        try {

            insert objAllo;
        }
        catch(Exception exp) {
            ErrorOccured = true;
            System.assertEquals('Payment-level Allocations aren\'t enabled for your organization. Try allocating at the Opportunity level instead.',exp.getDmlMessage(0));
        }
        System.assertEquals(true, ErrorOccured);

        Test.stopTest();
        
    }

        @IsTest
        static void AllocatingPaymentLevelSuccess_Test(){
            
            npsp__Allocations_Settings__c allocationsSettings = new npsp__Allocations_Settings__c();
            allocationsSettings.npsp__Default_Allocations_Enabled__c = false;
            allocationsSettings.npsp__Default__c = null;
            allocationsSettings.npsp__Excluded_Opp_RecTypes__c = 'Yes';
            allocationsSettings.npsp__Excluded_Opp_Types__c = 'Yes';
            allocationsSettings.npsp__Payment_Allocations_Enabled__c = false;
            insert allocationsSettings;

            npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
            th.Name = 'ALLO_Allocations_Custom_TDTM_Test';
            th.npsp__Class__c = 'ALLO_Allocations_Custom_TDTM';
            th.npsp__Object__c = 'Allocation__c';
            th.npsp__Trigger_Action__c = 'BeforeInsert';
            th.npsp__Active__c = true;
            th.npsp__Load_Order__c = 1;
            th.npsp__Asynchronous__c = false;
            insert th;

            Account acc = new Account(Name='foo');
            insert acc;
            Opportunity opp = new Opportunity(Name='foo', Amount = 8, AccountID=acc.Id, CloseDate=System.today(), StageName=getClosedWonStage());
            insert opp;
            npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name='foo');
            insert gau;
            npe01__OppPayment__c pmt = new npe01__OppPayment__c(npe01__Payment_Amount__c = 8, npe01__Opportunity__c = opp.Id);
            insert pmt;

            npsp__Allocation__c objAllo = createOppAllocation(gau.Id, opp.Id, 8, null);
            objAllo.npsp__Payment__c = pmt.Id;



            Test.startTest();
            Boolean ErrorOccured = false;
            try {

                insert objAllo;
            }
            catch(Exception exp) {
                ErrorOccured = true;
                System.assertEquals('Payment-level Allocations aren\'t enabled for your organization. Try allocating at the Opportunity level instead.',exp.getDmlMessage(0));
            }
            System.assertEquals(true, ErrorOccured);

            ErrorOccured = false;
            try {

                npsp__Allocation__c objAlloNoAmount = createOppAllocation(gau.Id, opp.Id, null, null);
                insert objAlloNoAmount;
            }
            catch(Exception exp) {
                ErrorOccured = true;
                System.assertEquals(Label.npsp.alloAmountOrPercent,exp.getDmlMessage(0));
            }
            System.assertEquals(true, ErrorOccured);

            ErrorOccured = false;
            try {

                npsp__Allocation__c objAlloAmountGreater = createOppAllocation(gau.Id, opp.Id, 10.00, null);
                insert objAlloAmountGreater;
            }
            catch(Exception exp) {
                ErrorOccured = true;
                System.assertEquals(Label.npsp.alloTotalExceedsOppAmt,exp.getDmlMessage(0));
            }
            System.assertEquals(true, ErrorOccured);

            ErrorOccured = false;
            try {

                npsp__Allocation__c objAlloPercent90 = createOppAllocation(gau.Id, opp.Id, null, 90);
                npsp__Allocation__c objAlloPercent50 = createOppAllocation(gau.Id, opp.Id, null, 50);
                insert objAlloPercent90;
                insert objAlloPercent50;
            }
            catch(Exception exp) {
                ErrorOccured = true;
                System.assertEquals(Label.npsp.alloPercentExceed100,exp.getDmlMessage(0));
            }
            System.assertEquals(true, ErrorOccured);

            Test.stopTest();
            
        }


        @IsTest
        static void AllocatingBeforeUpdate_Test(){
            
            npsp__Allocations_Settings__c allocationsSettings = new npsp__Allocations_Settings__c();
            allocationsSettings.npsp__Default_Allocations_Enabled__c = false;
            allocationsSettings.npsp__Default__c = null;
            allocationsSettings.npsp__Excluded_Opp_RecTypes__c = 'Yes';
            allocationsSettings.npsp__Excluded_Opp_Types__c = 'Yes';
            allocationsSettings.npsp__Payment_Allocations_Enabled__c = false;
            insert allocationsSettings;

            npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
            th.Name = 'ALLO_Allocations_Custom_TDTM_Test';
            th.npsp__Class__c = 'ALLO_Allocations_Custom_TDTM';
            th.npsp__Object__c = 'Allocation__c';
            th.npsp__Trigger_Action__c = 'BeforeUpdate';
            th.npsp__Active__c = true;
            th.npsp__Load_Order__c = 1;
            th.npsp__Asynchronous__c = false;
            insert th;

            Account acc = new Account(Name='foo');
            insert acc;
            Opportunity opp = new Opportunity(Name='foo', Amount = 8, AccountID=acc.Id, CloseDate=System.today(), StageName=getClosedWonStage());
            insert opp;
            npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name='foo');
            insert gau;
            npe01__OppPayment__c pmt = new npe01__OppPayment__c(npe01__Payment_Amount__c = 8, npe01__Opportunity__c = opp.Id);
            insert pmt;

            npsp__Allocation__c objAllo = createOppAllocation(gau.Id, opp.Id, 8, null);
            objAllo.npsp__Payment__c = pmt.Id;



            Test.startTest();
           
            Boolean ErrorOccured = false;
            try {

                npsp__Allocation__c objAlloCurrencyChange = createOppAllocation(gau.Id, opp.Id, 5, null);
                objAlloCurrencyChange.CurrencyISOCode = 'GBP';
                insert objAlloCurrencyChange;
                objAlloCurrencyChange.CurrencyISOCode = 'USD';
                update objAlloCurrencyChange;

            }
            catch(Exception exp) {
                ErrorOccured = true;
                System.assertEquals(Label.npsp.alloModifyCurrency,exp.getDmlMessage(0));
            }
            System.assertEquals(true, ErrorOccured);

            Test.stopTest();
            
        }



    /*******************************************************************************************************
    * @description Recurring Donation Allocations test:
    * Create recurring donation. Pledged opportunity is generated automatically with a default allocation.
    * Create allocations for the recurring donation, verify opp allocations are created, default opp
    * allocation is deleted.
    * Set opp to closed/won, modify recurring donation allocations: closed opportunity's allocations are
    * unchanged.
    * Create new opportunity for the recurring donation schedule: RD allocations are created.
    * Create a recurring donation allocation to exceed the opportunity amount: open opportunity only gets
    * percent based allocations.
    * Remove allocation that exceed's opportunity amount: all RD allocations are created.
    * Delete a recurring donation allocation: corresponding opportunity allocation is also deleted.
    ********************************************************************************************************/
    static testMethod void recurringDonationsValidation() {

        npsp__Trigger_Handler__c th = new npsp__Trigger_Handler__c();
        th.Name = 'ALLO_Allocations_Custom_TDTM_Test';
        th.npsp__Class__c = 'ALLO_Allocations_Custom_TDTM';
        th.npsp__Object__c = 'Allocation__c';
        th.npsp__Trigger_Action__c = 'AfterInsert';
        th.npsp__Active__c = true;
        th.npsp__Load_Order__c = 1;
        th.npsp__Asynchronous__c = false;
        insert th;
        npsp__Trigger_Handler__c th1 = new npsp__Trigger_Handler__c();
        th1.Name = 'ALLO_Allocations_TDTM_Opp';
        th1.npsp__Class__c = 'ALLO_Allocations_TDTM';
        th1.npsp__Object__c = 'Opportunity';
        th1.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate';
        th1.npsp__Active__c = true;
        th1.npsp__Load_Order__c = 1;
        th1.npsp__Asynchronous__c = false;
        insert th1;
        npsp__Trigger_Handler__c th2 = new npsp__Trigger_Handler__c();
        th2.Name = 'ALLO_Allocations_TDTM_Pay';
        th2.npsp__Class__c = 'ALLO_Allocations_TDTM';
        th2.npsp__Object__c = 'npe01__OppPayment__c';
        th2.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate';
        th2.npsp__Active__c = true;
        th2.npsp__Load_Order__c = 1;
        th2.npsp__Asynchronous__c = false;
        insert th2;
        
        npsp__Trigger_Handler__c th3 = new npsp__Trigger_Handler__c();
        th3.Name = 'ALLO_PaymentSync_TDTM_Pay';
        th3.npsp__Class__c = 'ALLO_PaymentSync_TDTM';
        th3.npsp__Object__c = 'npe01__OppPayment__c';
        th3.npsp__Trigger_Action__c = 'AfterInsert;AfterUpdate';
        th3.npsp__Active__c = true;
        th3.npsp__Load_Order__c = 1;
        th3.npsp__Asynchronous__c = false;
        insert th3;

        npsp__General_Accounting_Unit__c defaultgau = new npsp__General_Accounting_Unit__c(Name='General');
        insert defaultgau;

        npsp__Allocations_Settings__c allocationsSettings = new npsp__Allocations_Settings__c();
            allocationsSettings.npsp__Default_Allocations_Enabled__c = true;
            allocationsSettings.npsp__Default__c = defaultGau.Id;
            insert allocationsSettings;

        Account acc = new Account(Name='foo');
        insert acc;
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name = 'foo');
        insert gau;
        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c();
        rd.npe03__Installment_Period__c = 'Yearly';
        rd.npe03__Date_Established__c = System.today();
        rd.npe03__Organization__c = acc.Id;
        rd.npe03__Schedule_Type__c = 'Multiply By';
        rd.npe03__Open_Ended_Status__c = 'Open';

        // this initial creation of the RD with default allocations set up, which get copied to the opp
        // will be what we soql limit profile in this test (and thus the startTest/stopTest).
        Test.startTest();
        insert rd;
        Test.stopTest();

        //query for the opportunity automatically created by the schedule
        //list<Opportunity> queryOpp = [SELECT Id, npe03__Recurring_Donation__c, Amount, CloseDate, StageName FROM Opportunity WHERE npe03__Recurring_Donation__c = :rd.Id];
        //System.assertEquals(1,queryOpp.size(),'A single opportunity should be created.');

        //list<npsp__Allocation__c> queryAllo = getAllocationsOrderByPercent(queryOpp[0].Id);
        //System.assertEquals(1,queryAllo.size(),'A single default allocation should be created.');
        //System.assertEquals(defaultgau.Id,queryAllo[0].npsp__General_Accounting_Unit__c,'The allocation should be assigned to the default General Accounting Unit.');
        //System.assertEquals(20,queryAllo[0].npsp__Amount__c,'The default allocation should be for the total amount of the Opportunity.');

        Opportunity intialOpp = new Opportunity(Name='foo', npe03__Recurring_Donation__c = rd.Id, Amount = 20, AccountID=acc.Id, CloseDate=System.today(), StageName=getOpenStage());
        insert intialOpp;

        list<npsp__Allocation__c> alloForInsert = new list<npsp__Allocation__c>();
        npsp__Allocation__c percentAllo = new npsp__Allocation__c(npsp__Recurring_Donation__c = rd.Id, npsp__Percent__c = 50, npsp__General_Accounting_Unit__c = gau.Id);
        alloForInsert.add(percentAllo);
        npsp__Allocation__c amountAllo = new npsp__Allocation__c(npsp__Recurring_Donation__c = rd.Id, npsp__Amount__c = 10, npsp__General_Accounting_Unit__c = gau.Id);
        alloForInsert.add(amountAllo);
        insert alloForInsert;


        List<npsp__Allocation__c>  queryAllo = getAllocationsOrderByPercent(intialOpp.Id);
        System.assertEquals(2,queryAllo.size(), 'Allocations for the open Recurring Donation Opportunity should be created automatically after they are created for the Recurring Donation.');
        System.assertEquals(gau.Id,queryAllo[0].npsp__General_Accounting_Unit__c, 'Allocations should be to the non-default GAU.');
        System.assertEquals(gau.Id,queryAllo[1].npsp__General_Accounting_Unit__c, 'Allocations should be to the non-default GAU.');
        System.assertEquals(10,queryAllo[1].npsp__Amount__c, 'The percentage based allocation amount should be set based on the opportunity amount.');

        intialOpp.StageName = getClosedWonStage();
        update intialOpp;

        Opportunity opp = new Opportunity(Name='foo', npe03__Recurring_Donation__c = rd.Id, Amount = 20, AccountID=acc.Id, CloseDate=System.today(), StageName=getOpenStage());
        insert opp;

        percentAllo.npsp__Percent__c = 20;
        update percentAllo;
        queryAllo = getAllocationsOrderByPercent(intialOpp.Id);
        System.assertEquals(2,queryAllo.size(), 'Allocations for the closed/won opportunity should be unchanged.');
        System.assertEquals(50,queryAllo[1].npsp__Percent__c, 'The percentage based allocation should be unchanged.');

        

        queryAllo = getAllocationsOrderByAmount(opp.Id);
        //System.assertEquals(3,queryAllo.size(), 'Allocations for the open Recurring Donation Opportunity should be created automatically when the opportunity is created.');

        npsp__Allocation__c exceedAllo = new npsp__Allocation__c(npsp__Recurring_Donation__c = rd.Id, npsp__Amount__c = 10, npsp__General_Accounting_Unit__c = gau.Id);
        insert exceedAllo;

        queryAllo = getAllocationsOrderByPercent(opp.Id);
       // System.assertEquals(2,queryAllo.size(), 'Only percent based Opportunity Allocation should exist: ' + queryAllo);
       // System.assertEquals(16,queryAllo[0].npsp__Amount__c, 'The percentage based allocation amount should be set based on the opportunity amount: ' + queryAllo);

        delete exceedAllo;

        queryAllo = getAllocationsOrderByAmount(opp.Id);
        //System.assertEquals(3,queryAllo.size(), 'Allocations for the open Recurring Donation Opportunity should be created automatically when the opportunity is created.');

        delete amountAllo;

        queryAllo = getAllocationsOrderByPercent(opp.Id);
        //System.assertEquals(2,queryAllo.size(), 'Opportunity Allocation should be deleted along with the Recurring Donation allocation.');
        //System.assertEquals(16,queryAllo[0].npsp__Amount__c, 'The percentage based allocation amount should be set based on the opportunity amount.');
    }
    

    // Helpers
    ////////////

    /*********************************************************************************************************
    * @description Get all Allocations ordered by Amount
    * @return List<Allocation__c> A list of all Allocations 
    **********************************************************************************************************/
    private static List<npsp__Allocation__c> getAllocationsOrderByAmount() {
        return Database.query(getAllocationsQuery().build() + ' ORDER BY npsp__Amount__c');
    }

    /*********************************************************************************************************
    * @description Get all Allocations ordered by Percent
    * @return List<Allocation__c> A list of all Allocations 
    **********************************************************************************************************/
    private static List<npsp__Allocation__c> getAllocationsOrderByPercent() {
        return Database.query(getAllocationsQuery().build() + ' ORDER BY npsp__Percent__c');
    }

    /*********************************************************************************************************
    * @description Get Allocations for the Opportunity ordered by Amount
    * @param oppId An Opportunity Id
    * @return List<Allocation__c> A list of Allocations assigned to the Opportunity
    **********************************************************************************************************/
    private static List<npsp__Allocation__c> getAllocationsOrderByAmount(Id oppId) {
        return Database.query(getAllocationsQuery(oppId).build() + ' ORDER BY npsp__Amount__c');
    }

    /*********************************************************************************************************
    * @description Get Allocations for the Opportunity ordered by Percent
    * @param oppId An Opportunity Id
    * @return List<Allocation__c> A list of Allocations assigned to the Opportunity
    **********************************************************************************************************/
    private static List<npsp__Allocation__c> getAllocationsOrderByPercent(Id oppId) {
        return Database.query(getAllocationsQuery(oppId).build() + ' ORDER BY npsp__Percent__c');
    }

    /*********************************************************************************************************
    * @description Build query to retrieve Allocations for the Opportunity
    * @return UTIL_Query Allocation SOQL
    **********************************************************************************************************/
    private static UTIL_QueryCus getAllocationsQuery(Id oppId) {
        return getAllocationsQuery()
            .withWhere(String.format('npsp__Opportunity__c = \'\'{0}\'\'', new String[] { oppId }));
    }

    /*********************************************************************************************************
    * @description Get Allocations for the Payment and GAU ordered by Percent
    * @param paymentId A npe01__OppPayment__c Id
    * @param gauId A General_Accounting_Unit__c Id
    * @return List<Allocation__c> A list of Allocations assigned to the Opportunity
    **********************************************************************************************************/
    private static List<npsp__Allocation__c> getAllocationsOrderByPercent(Id paymentId, Id gauId) {
        return Database.query(getAllocationsQuery(paymentId, gauId).build() + ' ORDER BY npsp__Percent__c');
    }

    /*********************************************************************************************************
    * @description Build query to retrieve Allocation by payment Id and GAU
    * @param paymentId A npe01__OppPayment__c Id
    * @param gauId A General_Accounting_Unit__c Id
    * @return UTIL_Query Allocation SOQL
    **********************************************************************************************************/
    private static UTIL_QueryCus getAllocationsQuery(Id paymentId, Id gauId) {
        return getAllocationsQuery()
            .withWhere(String.format('npsp__Payment__c = \'\'{0}\'\'', new String[] { paymentId }))
            .withWhere(String.format('npsp__General_Accounting_Unit__c = \'\'{0}\'\'', new String[] { gauId }));
    }


    /*********************************************************************************************************
    * @description Build query to retrieve all Allocations
    * @return UTIL_Query Allocation SOQL
    **********************************************************************************************************/
    private static UTIL_QueryCus getAllocationsQuery() {
        return new UTIL_QueryCus()
            .withSelectFields(new String[]{
                'npsp__General_Accounting_Unit__c', 
                'npsp__General_Accounting_Unit__r.Name', 
                'npsp__Amount__c', 
                'npsp__Percent__c' 
            })
            .withFrom('npsp__Allocation__c');
    }

    public static string closedWonStage;
    public static string openStage;
    
    public static String getClosedWonStage(){
        if (closedWonStage == null){
            List<OpportunityStage> closedWonStages = [select masterlabel from opportunitystage where isActive = true and iswon = true];
            
            if(closedWonStages.size()>0){
                closedWonStage = closedWonStages[0].masterlabel;
            } else {
                closedWonStage = '';
            }
        }
        
        return closedWonStage;
    }

    public static String getOpenStage(){
        if (openStage == null){
            List<OpportunityStage> openStages = [select masterlabel from opportunitystage where isActive = true and iswon = false];
            
            if(openStages.size()>0){
                openStage = openStages[0].masterlabel;
            } else {
                openStage = '';
            }
        }
        
        return openStage;
    }

    private static RecordTypeInfo getRecordTypeInfoForTests(sObjectType objectType) {
        List<Schema.RecordTypeInfo> recordTypeInfos = objectType.getDescribe().getRecordTypeInfos();
        for (Schema.RecordTypeInfo rti : recordTypeInfos) {
            if (!rti.isMaster() && rti.isAvailable()) {
                return rti;
            }
        }
        return null;
    }

    public static String getRecordTypeNameForGiftsTests(sObjectType objectType) {
        return getRecordTypeInfoForTests(objectType).getName();
    }

    private static RecordTypeInfo getRecordTypeInfo(sObjectType objectType, String recordTypeName) {
        Map<String, Schema.RecordTypeInfo> recordTypeInfos = objectType.getDescribe().getRecordTypeInfosByName();
        if (recordTypeInfos.containsKey(recordTypeName)) {
            return recordTypeInfos.get(recordTypeName);
        } else {
            return null;
        }
    }

    public static Id getRecordTypeId(sObjectType objectType, String recordTypeName) {
        return getRecordTypeInfo(objectType, recordTypeName).getRecordTypeId();
    }

    static npsp__Allocations_Settings__c allocationsSettings;

    public static npsp__Allocations_Settings__c  getAllocationsSettingsForTests(npsp__Allocations_Settings__c  mySettings) {
        if (allocationsSettings == null)
            allocationsSettings = new npsp__Allocations_Settings__c();

        allocationsSettings.npsp__Default_Allocations_Enabled__c = mySettings.npsp__Default_Allocations_Enabled__c;
        allocationsSettings.npsp__Default__c = mySettings.npsp__Default__c;
        allocationsSettings.npsp__Excluded_Opp_RecTypes__c = mySettings.npsp__Excluded_Opp_RecTypes__c;
        allocationsSettings.npsp__Excluded_Opp_Types__c = mySettings.npsp__Excluded_Opp_Types__c;
        allocationsSettings.npsp__Rollup_N_Day_Value__c = mySettings.npsp__Rollup_N_Day_Value__c;
        allocationsSettings.npsp__Use_Fiscal_Year_for_Rollups__c = mySettings.npsp__Use_Fiscal_Year_for_Rollups__c;
        //orgAllocationsSettings = allocationsSettings;
        return allocationsSettings;
    }

    private static npsp__Allocation__c createOppAllocation(Id gauId, Id oppId, Decimal amt, Double percent) {
        return new npsp__Allocation__c(
            npsp__Opportunity__c = oppId,
            npsp__General_Accounting_Unit__c = gauId,
            npsp__Percent__c = percent,
            npsp__Amount__c = amt
        );
    }
}