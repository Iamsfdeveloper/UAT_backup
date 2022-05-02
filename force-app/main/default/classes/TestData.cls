public class TestData {
    
    public Static void createData(){
        Opportunity objOpp = [SELECT Id, IsDeleted, AccountId, RecordTypeId, IsPrivate, Name, Description, StageName, Amount, Probability, ExpectedRevenue, TotalOpportunityQuantity, CloseDate, Type, NextStep, LeadSource, IsClosed, IsWon, ForecastCategory, ForecastCategoryName, CurrencyIsoCode, CampaignId, HasOpportunityLineItem, Pricebook2Id, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, PushCount, LastStageChangeDate, FiscalQuarter, FiscalYear, Fiscal, ContactId, LastViewedDate, LastReferencedDate, SyncedQuoteId, ContractId, HasOpenActivity, HasOverdueTask, LastAmountChangedHistoryId, LastCloseDateChangedHistoryId, Budget_Confirmed__c, Discovery_Completed__c, ROI_Analysis_Completed__c, npe01__Amount_Outstanding__c, Loss_Reason__c, npe01__Contact_Id_for_Role__c, npe01__Do_Not_Automatically_Create_Payment__c, npe01__Is_Opp_From_Individual__c, npe01__Member_Level__c, npe01__Membership_End_Date__c, npe01__Membership_Origin__c, npe01__Membership_Start_Date__c, npe01__Amount_Written_Off__c, npe01__Number_of_Payments__c, npe01__Payments_Made__c, npo02__CombinedRollupFieldset__c, npo02__systemHouseholdContactRoleProcessor__c, npe03__Recurring_Donation__c, npsp__Acknowledgment_Date__c, npsp__Acknowledgment_Status__c, npsp__Ask_Date__c, npsp__Batch__c, npsp__Closed_Lost_Reason__c, npsp__Fair_Market_Value__c, npsp__Gift_Strategy__c, npsp__Grant_Contract_Date__c, npsp__Grant_Contract_Number__c, npsp__Grant_Period_End_Date__c, npsp__Grant_Period_Start_Date__c, npsp__Grant_Program_Area_s__c, npsp__Grant_Requirements_Website__c, npsp__Honoree_Contact__c, npsp__Honoree_Name__c, npsp__In_Kind_Description__c, npsp__In_Kind_Donor_Declared_Value__c, npsp__In_Kind_Type__c, npsp__Is_Grant_Renewal__c, npsp__Matching_Gift_Account__c, npsp__Matching_Gift_Employer__c, npsp__Matching_Gift_Status__c, npsp__Matching_Gift__c, npsp__Notification_Message__c, npsp__Notification_Preference__c, npsp__Notification_Recipient_Contact__c, npsp__Notification_Recipient_Information__c, npsp__Notification_Recipient_Name__c, npsp__Previous_Grant_Opportunity__c, npsp__Primary_Contact_Campaign_Member_Status__c, npsp__Primary_Contact__c, npsp__Qualified_Date__c, npsp__Recurring_Donation_Installment_Name__c, npsp__Recurring_Donation_Installment_Number__c, npsp__Requested_Amount__c, npsp__Tribute_Type__c, npsp__Next_Grant_Deadline_Due_Date__c, Donation_Type__c, Gift_Aid_Submitted_Value__c, Gift_Aid_Submitted__c, Transaction_Id__c, Medium__c, npsp__DisableContactRoleAutomation__c, npsp__CommitmentId__c, GUID__c, Is_Recurring__c, Payment_Details__c, Recurring_Setup__c, Source_Opportunity__c, Card_Payment_Details__c, npsp__Batch_Number__c, Gift_Aid_Eligible_Value__c, IsFirstGift__c, DonationCode__c, Donation_Frequency__c, Gift_Aid_Declaration__c, Number_of_Installments__c, Payment_Schedule__c, Recurring_Type__c, Basket_Collection_Id__c, Effective_Date__c, Gift_Aid_Declaration_Status__c, Gift_Aid_Eligible_Value_Actuals__c, Regional_Office__c, Website_Code__c, Precluded_Gift_Aid_Value__c, Total_Refund__c, Donor_Name__c, Current_Year_Value__c, Gift_Aid_Eligible_Status__c, Casesafe_Donation_ID__c, Source__c, Donation_Amount_Excluding_SR__c, Source_Donation_Transaction_ID__c, Donation_Amount_Olive_Trees__c, Payment_Method__c, Estimate_Gift_Aid_Value__c, Agency_Fees__c, Bank_Reference__c, Bank__c, Donor_ID_Item_Code__c, Duplicate_Key_Agencies__c, Duplicate_Key_Bank_Organizations__c, Duplicate_Key_Bank__c, Fundraising_Page_URL__c, Net_Donation_Amount__c, Item_Code__c, Skip_Process_Automation__c, Stipulation_Type__c, Type__c, Donation_created_time__c, EMIAmount__c, Department__c, Row_Index__c, Transaction_Source__c, Fundraising_Team__c, Fundraiser__c, XFactor_2__c, XFactor_1__c, Mailing_Street__c, End_Date__c, Contact_Email__c, Contact_Mobile_Number__c, Donor_Email__c, Donor_ID__c, Created_Date_Close_Date__c, Recurring_Payment_Method__c, Mailing_Address__c, Mailing_City__c, Mailing_Postcode__c, Total_Donation_Amount__c, Do_Not_Post__c, Regional_Office_Code__c, Check_for_regional_Code_Website_Code__c, Contact_Record_Type__c, Campaign_Record_Type__c, Gift_Refund_Value__c, Has_Ticket_Items__c, Gift_Aid_Value__c, Basket_Status__c, Gift_Aid_Difference__c, Gift_Aid_Claim_Value__c, Basket__c, Account_Holder_Name__c, Account_Number__c, Donation__c, Finance_Approver_User__c, Refund_Reason__c, Sort_Code__c, Total_Amount_Expected__c, Refund_Approval__c FROM Opportunity  WHERE Id='0060C000009H8wxQAC'];
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        for (integer i=0;i<=1;i++)  {
            
            Opportunity newObjOpp = objOpp.clone(false, true, false, false);
            newObjOpp.StageName = 'Awaiting Payment Details';
            newObjOpp.Transaction_Id__c = '';
            lstOpp.add(newObjOpp);   
        }
        insert lstOpp;
        
        npsp__Allocation__c objAllocation = [SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, npsp__Amount__c, npsp__Campaign__c, npsp__General_Accounting_Unit__c, npsp__Opportunity__c, npsp__Percent__c, npsp__Recurring_Donation__c, npsp__Payment__c, Gift_Aid_Eligible__c, Orphan__c, Stage__c, Check_Paid_Status__c, DMS_Donation_Line_Item_ID__c, Receipt_Note__c, Stipulation_Type__c, Quantity__c, GAU_Name__c, Date_of_Birth__c, Gift_Aid_Eligible_Allocation__c, Name__c, Special_Instruction_Index__c, Include_In_General_Receipt__c, GAU_Name_for_Conga__c, Is_Olive_Tree__c, Donor_ID_Item_Code__c, Item_Product_Type__c, Donation_Item_Code__c, Skip_Process_Automation__c, Country__c, Programme_Category__c, Close_Date__c, Is_Source_Donation_Allocation__c, Orphan_Id__c, Orphan_Account_Name__c, Orphan_DMS_ID__c, Opportunity_ID__c, Instruction__c, Is_Credit__c, Is_Debit__c, Recurring_Donation_Id_Donation__c, Parent_Allocation__c, Notes__c FROM npsp__Allocation__c WHERE npsp__Opportunity__c =: objOpp.Id];
        Income_Direct_Debit__c objDD = [SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Account__c, Contact__c, DD_Account_City__c, DD_Account_Email__c, DD_Account_Holder_FirstName__c, DD_Account_Holder_LastName__c, DD_Account_Holder_Title__c, DD_Account_Number_OK__c, DD_Account_PostCode__c, DD_Account_State__c, DD_Account_Street__c, DD_Bank_Account_Name__c, DD_Bank_Account_Number__c, DD_Bank_Address__c, DD_Bank_City__c, DD_Bank_Name__c, DD_Bank_Phone__c, DD_Bank_Postcode__c, DD_Bank_Sort_Code__c, DD_Branch_Name__c, DD_Collection_Day__c, DD_Collection_Period__c, DD_Collection_Reference__c, DD_Collection_Stretch__c, DD_Collection_Type__c, DD_Count_Of_Failed_Collections__c, DD_End_Date__c, DD_Final_Collection_Amount__c, DD_First_Collection_Amount__c, DD_First_Collection_Date__c, DD_Hold_Reason__c, DD_Last_Collected_Date__c, DD_Last_Collection_Failed__c, DD_Next_Collection_Date__c, DD_OK__c, DD_Ongoing_Collection_Amount__c, DD_Plan__c, DD_Single_Account_Holder__c, DD_Sort_Code_OK__c, DD_Start_Date__c, DD_Status__c, Opportunity__c, DD_Total_Amount_Debited__c, Last_Processed_Date__c, Recurring_Donation__c, Basket__c FROM Income_Direct_Debit__c WHERE Id ='a100C000002Mu79QAC'];

        List<npsp__Allocation__c> lstAllo = new List<npsp__Allocation__c>();
        List<Income_Direct_Debit__c> lstDD = new List<Income_Direct_Debit__c>();
        String idStr = '';
        for (Opportunity newObjOpp : lstOpp) {
            
            npsp__Allocation__c newObjAllocation = objAllocation.clone(false, true, false, false);
            newObjAllocation.npsp__Opportunity__c  = newObjOpp.Id;
            newObjAllocation.DMS_Donation_Line_Item_ID__c='';
            lstAllo.add(newObjAllocation);
            
            Income_Direct_Debit__c newobjDD = objDD.clone(false, true, false, false);
        	newobjDD.Opportunity__c = newObjOpp.Id;
            lstDD.add(newobjDD);
            idStr = idStr+newObjOpp.Id+',';   
            newObjOpp.StageName = 'Paid';    
        }
        insert lstAllo;
        insert lstDD;
        
        update lstOpp;

		Recurring_Donation_Batch_Errors__c errorlog = HA_Logger.CreateErrorLog('INSERT TEST DATA','TEST DATA DD',idStr);
        insert errorlog;
        
        

    }

}