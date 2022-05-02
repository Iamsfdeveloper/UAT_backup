public without sharing class myProfileDetails {
    @AuraEnabled
    public static RecentDonationWrapper getDonationValues(){
        RecentDonationWrapper rWrapper = new RecentDonationWrapper();   
       
        try{
             
            Id contactId = HA_Utility.getUserInfoContactId();
            // To Do replace WHERE Clause with Id=:HA_Utility.getUserInfoContactId()
            List<npsp__Allocation__c> donationContactList = new List<npsp__Allocation__c>();
            donationContactList = [SELECT Id, npsp__Amount__c, npsp__Opportunity__r.currencyIsoCode, npsp__Opportunity__r.CloseDate,
                                    npsp__Opportunity__r.Donation_Type__c, toLabel(Stipulation_Type__c), npsp__General_Accounting_Unit__r.Name, npsp__General_Accounting_Unit__r.Programme_Category__c,
                                    npsp__Opportunity__r.Gift_Aid_Eligible_Status__c, Gift_Aid_Value__c,Country__c, GAU_Name__c, 
                                    Gift_Aid_Eligible_Allocation__c, npsp__Opportunity__r.npsp__Primary_Contact__c, npsp__Opportunity__r.npsp__Primary_Contact__r.Name, npsp__Opportunity__r.npsp__Primary_Contact__r.MailingAddress
                                    FROM npsp__Allocation__c 
                                    WHERE npsp__Opportunity__c != NULL 
                                    AND npsp__Opportunity__r.npsp__Primary_Contact__c != NULL 
                                    AND npsp__Opportunity__r.npsp__Primary_Contact__c =: contactId
                                    AND npsp__Opportunity__r.IsWon = true 
                                    AND  npsp__Opportunity__r.Type = 'Donation' 
                                    AND Stipulation_Type__c IN ('ZK', 'SD', 'XX') ORDER BY npsp__Opportunity__r.CloseDate DESC LIMIT 5];
            if(donationContactList.size() > 0){  
                rWrapper.donationRec = donationContactList;
            }
            if(contactId != null){
                rWrapper.conRec = [SELECT Id, FirstName, LastName, MailingStreet, MailingCountry, MailingPostalCode, MailingCity, MailingState, Donor_Id__c, Email, MobilePhone, Gift_Aid_Status__c, npo02__FirstCloseDate__c, Current_Age__c FROM Contact WHERE Id = :contactId ];
            }            
            //returnValue.put('donorDetails',[Select Id,FirstName,LastName,MailingStreet,MailingCountry,MailingPostalCode,MailingCity,MailingState,Donor_Id__c,Email,MobilePhone,Gift_Aid_Status__c,npo02__FirstCloseDate__c,Current_Age__c From Contact Where Id='0032500001Yu0pAAAR' limit 1]);
           
        }catch(Exception ex){ 
            System.debug(ex.getMessage());
        }     
        return rWrapper;
    } 

    public class RecentDonationWrapper{
        @AuraEnabled
        public List<npsp__Allocation__c> donationRec;          
        @AuraEnabled
        public Contact conRec;
        public RecentDonationWrapper(){
            donationRec = new List<npsp__Allocation__c>();  
            conRec = new Contact();
        }
    }
}