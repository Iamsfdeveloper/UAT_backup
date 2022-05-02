public without sharing class UTIL_CustomSettingsFacadeCus {
    
    static npo02__Households_Settings__c householdsSettings;
    static npo02__Households_Settings__c orgHouseholdsSettings;
    static npsp__Allocations_Settings__c orgAllocationsSettings;
    static npsp__Allocations_Settings__c allocationsSettings;
    static npe01__Contacts_And_Orgs_Settings__c contactsSettings;
    public static String ALL_PROCESSOR = 'All New or Edited Contacts';
    public static String ALL_INDIVIDUALS_PROCESSOR = 'All Individual Contacts';
    public static String NO_HOUSEHOLDS_PROCESSOR = 'No Contacts';
    public static final String HH_ACCOUNT_PROCESSOR = 'Household Account';
    
    public static npo02__Households_Settings__c getHouseholdsSettings() {
        if(Test.isRunningTest() && householdsSettings == null) {
            householdsSettings = new npo02__Households_Settings__c();
            configHouseholdSettings(householdsSettings);
        } else if (householdsSettings == null) {
            householdsSettings = npo02__Households_Settings__c.getInstance();
            if(householdsSettings.Id == null)
                householdsSettings = getOrgHouseholdsSettings();
        }  
        return householdsSettings;
    }
    
    public static npo02__Households_Settings__c getOrgHouseholdsSettings() {
        if(orgHouseholdsSettings == null) {
            orgHouseholdsSettings = npo02__Households_Settings__c.getOrgDefaults();
            if(orgHouseholdsSettings.Id == null) {
                configHouseholdSettings(orgHouseholdsSettings);
                orgHouseholdsSettings.Setupownerid = UserInfo.getOrganizationId();
                if(!Test.isRunningTest())
                    upsert orgHouseholdsSettings;
            }
        }
        return orgHouseholdsSettings;
    }
    
    private static void configHouseholdSettings(npo02__Households_Settings__c hs) {
        String oldProcessor = '';
        //modified to check again the Id instead of the object
        //get the model they used to be in 
        Schema.DescribeFieldResult F = Schema.sObjectType.Contact.fields.npo02__SystemHouseholdProcessor__c; 
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        
        for(Schema.PicklistEntry pe : P){
            if (pe.isDefaultValue()){
                if (pe.getValue() == ALL_PROCESSOR){
                    oldProcessor = ALL_PROCESSOR;
                } else if (pe.getValue() == ALL_INDIVIDUALS_PROCESSOR){
                    oldProcessor = ALL_INDIVIDUALS_PROCESSOR;
                } else if (pe.getValue() == NO_HOUSEHOLDS_PROCESSOR){
                    oldProcessor = NO_HOUSEHOLDS_PROCESSOR;
                }
                break;
            }
        }
        //set them up with their old setting in the new settings object
        if (oldProcessor == ALL_PROCESSOR){
            hs.npo02__Household_Rules__c = ALL_PROCESSOR;
        } else if (oldProcessor == ALL_INDIVIDUALS_PROCESSOR){
            hs.npo02__Household_Rules__c = ALL_INDIVIDUALS_PROCESSOR;
        } else if (oldProcessor == NO_HOUSEHOLDS_PROCESSOR){
            hs.npo02__Household_Rules__c = NO_HOUSEHOLDS_PROCESSOR;
        } else {
            hs.npo02__Household_Rules__c = NO_HOUSEHOLDS_PROCESSOR;
        }
 
        hs.npo02__Household_Member_Contact_Role__c = label.npo02.Household_Member_Contact_Role;
        hs.npo02__Always_Rollup_to_Primary_Contact__c = false;
        hs.npo02__Enable_Opp_Rollup_Triggers__c = true;
        hs.npo02__Excluded_Account_Opp_Rectypes__c = null;
        hs.npo02__Excluded_Account_Opp_Types__c = null;
        hs.npo02__Excluded_Contact_Opp_Rectypes__c = null;
        hs.npo02__Excluded_Contact_Opp_Types__c = null;
        hs.npo02__Membership_Record_Types__c = null;
        hs.npo02__Rollup_N_Day_Value__c = 365;
        hs.npo02__Membership_Grace_Period__c = 30;
        hs.npo02__Advanced_Household_Naming__c = true;
        hs.npo02__Async_Household_Naming__c = false;
        hs.npo02__Schedule_Job_Limit__c = 25;
        hs.npo02__Household_OCR_Excluded_Recordtypes__c = null;
        hs.npo02__Household_Creation_Excluded_Recordtypes__c = null;
        hs.npo02__Enable_Soft_Credit_Rollups__c = true;
        hs.npo02__Soft_Credit_Roles__c = 'Matched Donor;Soft Credit;Household Member';
        hs.npsp__Matched_Donor_Role__c = 'Matched Donor';
        hs.npo02__Household_Contact_Roles_On__c = true;

        // new HH Account model overrides having HH objects
        if (contactsSettings != null && contactsSettings.npe01__Account_Processor__c == HH_ACCOUNT_PROCESSOR) {
            hs.npo02__Household_Rules__c = NO_HOUSEHOLDS_PROCESSOR;
        }
    }
	
	public static npsp__Allocations_Settings__c getAllocationsSettings() {
        if(Test.isRunningTest() && allocationsSettings == null) {
            allocationsSettings = new npsp__Allocations_Settings__c();
            configAllocationsSettings(allocationsSettings);
        } else if (allocationsSettings == null) {
            allocationsSettings = npsp__Allocations_Settings__c.getInstance();
            if (allocationsSettings.Id == null) {
                allocationsSettings = getOrgAllocationsSettings();
            }
        }
        return allocationsSettings;
    }

	public static void configAllocationsSettings(npsp__Allocations_Settings__c allosettings) {
        //disable allocations by default
        allosettings.npsp__Default_Allocations_Enabled__c = false;
        allosettings.npsp__Default__c = null;
        allosettings.npsp__Excluded_Opp_RecTypes__c = null;
        allosettings.npsp__Excluded_Opp_Types__c = null;
        allosettings.npsp__Rollup_N_Day_Value__c = 365;
        allosettings.npsp__Use_Fiscal_Year_for_Rollups__c = false;
    }   
    
    public static npsp__Allocations_Settings__c getOrgAllocationsSettings() {
        if (orgAllocationsSettings==null) {
            orgAllocationsSettings = npsp__Allocations_Settings__c.getOrgDefaults();
            if (orgAllocationsSettings.Id == null) {
                configAllocationsSettings(orgAllocationsSettings);
                if(!Test.isRunningTest())
                    upsert orgAllocationsSettings;
            }
        }
        return orgAllocationsSettings;
    }
    
    


}