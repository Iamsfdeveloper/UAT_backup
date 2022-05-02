/**
 * @File Name          : NewDonationInvocableService.cls
 * @Description        :
 * @Author             : agentgill
 * @Group              :
 * @Last Modified By   : Iamsfdeveloper
 * @Last Modified On   : 06-11-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    3/10/2020   agentgill     Initial Version
 * HA-89  4/15/2020   agentgill     Add Donation Type Property
 * HA-111  4/29/2020   agentgill    Map Telephone to Contact Phone
 * MixedItems 11/18/2020 Iamsfdeveloper    Mixed Items
 **/
public without sharing class NewDonationInvocableService {
    // final static variables
    private static final string OPP_STAGE = 'Awaiting Payment Details';
    private static final string OPP_RECTYPE = 'Donation';
    private static final string OPP_NAME = 'System Generated';
    private static final string PP_TYPE = 'Payment Plan - Source';
    private static final string SD_TYPE = 'Donation';
    // static variables
    private static string donorUnqiueKey; // Email
    private static string donationType; // Single (1) / Recurring (2)
    private static string transactionId; // Transaction GUID from Website
    private static string currencyIsoCode = 'GBP'; // Default GBP
    private static string siteCode; 
    private static Results response = new Results();
    private static string basketCollectionId;
    Private Static String DefaultOrphanId = getDefaultOrphanId();
    Private Static String requestJSON;
    private Static String giftAidStatus = '';
    Private Static Contact existingContact = null;
    Private Static Id CampaignId;
    public Static String newDonation;
    public static List<Recurring_Donation_Batch_Errors__c> erroList = new List<Recurring_Donation_Batch_Errors__c>();
    @InvocableMethod(label='New Donation')
    public static List<Results> newDonation(List<Requests> request) {
        List<SObject> outputCollection = new List<SObject>();
        List<Results> responseWrapper = new List<Results>();

        for (Requests r : request) {
            for (NewDonationDataType nd : r.newDonation) {
                try {
                    newDonation = JSON.serialize(r.newDonation);
                    // Set Transaction Variables
                    transactionId = nd.transactionId;
                    donationType = nd.donationType;
                    siteCode = nd.siteCode;
                    basketCollectionId = nd.basketCollectionId;
                    getCurrencyIsoCode(nd.basket);
					Contact c = newContact(nd.supporter);
                    Map<String,Opportunity> oppMapByDonationType = newOpportunity(nd.basket);
                    
                    if (oppMapByDonationType != null) {
                         newAllocation(nd.basket,oppMapByDonationType); 
                    }
                    outputCollection.addAll(oppMapByDonationType.values());
                } catch (Exception ex) {
                    erroList.add(HA_Logger.CreateErrorLog(newDonation,transactionId,'newDonation v3- Message => '+ex.getMessage()+'\n StackTrace =>'+ex.getStackTraceString()));
            		response.errors = ex.getMessage();
                }
            }
        }
        
        if(erroList.size()>0)
            Insert erroList;
       
        // Output results
        response.outputCollection = outputCollection;
        responseWrapper.add(response);
        return responseWrapper;
    }

    // Requests input - Apex-defined data type
    public class Requests {
        @InvocableVariable(required=true)
        public List<NewDonationDataType> newDonation;
    }

    // Result output array of sobject (Opps)
    public class Results {
        public Results() {
            outputCollection = new List<SObject>();
        }

        @InvocableVariable
        public String errors;

        @InvocableVariable
        public List<SObject> outputCollection;
    }

    /**
     * @description Set CurrencyIsoCode
     * @author agentgill | 4/4/2020
     * @param b
     * @return void
     **/
    private static void getCurrencyIsoCode(NewDonationBasketDataType b) {
        currencyIsoCode = b.currencyId;
    }

    /**
     * @description Upsert single Contact based on Email (externalId)
     * @author agentgill | 3/17/2020
     * @param d
     * @return Contact
     * //TODO: Check Country Code - Currently they are sending GBR, but Google says GB
     **/
    private static string getCountryName(String countryCode) {
        return [
            SELECT Country_Name__c
            FROM Country_Mapping__mdt
            WHERE Country_Code_alpha_3__c = :countryCode
        ]
        .Country_Name__c;
    }
	
    private static Contact newContact(NewDonationSupporterDataType d) {
        //Concatenate Address details for the Mailing Street
        String addressLine1 = d.addressLine1;
        String addressLine2 = d.addressLine2;
        String mailingStreet = addressLine1 + '\n' + addressLine2;
        // TODO: Why have we dropped address3?

        Contact c = new Contact();
        c.FirstName = d.firstName;
        c.LastName = d.lastName;
        c.MailingStreet = mailingStreet;
        c.MailingCity = d.townCity;
        c.MailingState = d.state;
        c.Phone = d.telephone;
        c.MailingPostalCode = d.postalCode;
        c.MailingCountry = getCountryName(d.countryCode);
        if(d.SubscribeEmailList){
            c.Can_Appeal_Via_Email__c = 'Yes';
            c.Email_Preference_declared__c = 'Via_Website';
        }
        donorUnqiueKey = d.firstName+'-'+d.LastName+'-'+d.email+'-'+siteCode;
		donorUnqiueKey = donorUnqiueKey.toLowerCase();
        donorUnqiueKey = donorUnqiueKey.deleteWhitespace();
        c.Email = d.email;
        c.External_Id__c = donorUnqiueKey;
        switch on siteCode {
            	
            when 'UK' {		
               
                if(d.giftAidDelcared != 'Unspecified'){
                    c.Gift_Aid_Status__c  = d.giftAidDelcared;
                    giftAidStatus = d.giftAidDelcared;
                }
            }
            when 'ES' {		
                if(String.isNotEmpty(d.nationalIdentificationNumber))
                 c.National_Identification_Number__c = d.nationalIdentificationNumber;
            }
        }
        if(d.SubscribeSmsList){
            c.Can_Appeal_Via_Sms__c = 'Yes';
            c.SMS_Preference_declared__c = 'Via_Website';
        }
        //c.Has_Opted_Out_Of_SMS__c = (d.SubscribeSmsList ? false : true);
        c.CurrencyIsoCode = currencyIsoCode;
        
        try{
            existingContact = getSingleContact();
            if(existingContact != null){
                c.Id = existingContact.Id;
                upsert c;
            }else{
                c.Regional_Office_Code__c = siteCode;
                upsert c External_Id__c;
            }
        } catch (Exception ex) {
            erroList.add(HA_Logger.CreateErrorLog(newDonation,transactionId,'newContact v3- Message => '+ex.getMessage()+'\n StackTrace =>'+ex.getStackTraceString()));
            response.errors = ex.getMessage();
        }
        return c;
    }

    /**
     * @description Get Single Contact based on External  Id
     * @author agentgill | 19/03/2020
     * @return Contact
     **/
    private static Contact getSingleContact() {
        try{
        if(existingContact != null) return existingContact;
            existingContact =  [SELECT Id, External_Id__c, CurrencyIsoCode, AccountId FROM Contact WHERE External_Id__c  = :donorUnqiueKey limit 1];
        }catch(QueryException  ex){
           existingContact = null; 
        }
        return existingContact;
    }

    /**
     * @description Insert a single opportunity
     * @author agentgill | 19/03/2020
     * @param b
     * @return Opportunity[]
     **/
    private static Map<String,Opportunity> newOpportunity(NewDonationBasketDataType b) {
        Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
            .get(OPP_RECTYPE)
            .getRecordTypeId();
        Contact c = getSingleContact();
        Map<String,Id> codeMapById = new Map<String,Id>();
        for(HA_Payment_Schedule__c paymentschedules:[SELECT Id,Code__c, Frequency__c, Processing_Time__c, Start_Date__c, End_Date__c, Name FROM HA_Payment_Schedule__c Where Code__c != null and Is_Active__c=true and Is_External__c = true]){
            codeMapById.put(paymentschedules.Code__c,paymentschedules.Id);
        }
        Decimal oppAmount = 0.00;
        Map<String,Opportunity> oppMapByDonationType = new Map<String,Opportunity>();
       
        // Loop items to get Total
         Integer counter =0;
        for (NewDonationBasketItemDataType i : b.items) {
             String Campaign_Id = null;
             String key = i.donationType;
            
            if(String.isBlank(Campaign_Id) && String.isNotEmpty(i.campaignCode) && String.valueOf(i.campaignCode) InstanceOf Id){
                Campaign_Id = i.campaignCode;
                key +='-'+i.campaignCode;
            }else
			Campaign_Id = getWebsiteCampaignId(i.campaignCode);
            System.debug('c===>'+c);
            Opportunity tempOpp = new Opportunity(Type=(i.donationType =='SD')?SD_TYPE:PP_TYPE,Gift_Aid_Eligible_Status__c = giftAidStatus,Medium__c ='Online',AccountId = c.AccountId,Amount=0.00,ContactId = c.Id,Name = OPP_NAME,CloseDate = Date.today(),RecordTypeId = recTypeId,StageName = OPP_STAGE,CurrencyIsoCode = currencyIsoCode,Donation_Type__c=i.donationType,Payment_Schedule__c = (codeMapById != null && codeMapById.get(i.donationType) != null)?codeMapById.get(i.donationType):null,website_code__c = siteCode,Regional_Office_Code__c=siteCode,Basket_Collection_Id__c=basketCollectionId);
            if(oppMapByDonationType.get(key)!= null)
                tempOpp = oppMapByDonationType.get(key);
            else{
                tempOpp.Transaction_Id__c = transactionId+'-'+i.donationType+'-'+counter;
                counter++;
            }
            if(i.SchemeData.size()>0 && (i.donationType =='30N' || i.donationType =='10N' || i.donationType =='10D')){
                for(NewDonationBasketItemDataType.SchemeData schemeDataObject:(List<NewDonationBasketItemDataType.SchemeData>)i.SchemeData){
                    if(schemeDataObject != null)
                        if(schemeDataObject.ParameterCode =='RECStartDate'){
                            tempOpp.Effective_Date__c = (Date.valueOf(schemeDataObject.ParameterValue)>System.Today())?Date.valueOf(schemeDataObject.ParameterValue):System.Today();
                            tempOpp.Recurring_Type__c ='Fixed';
                            tempOpp.Number_of_Installments__c = (i.donationType =='30N')?30:10;
                            break;
                        }
                }
            }
            System.debug('Campaign_Id==>'+Campaign_Id);
            tempOpp.CampaignId = Campaign_Id;
            tempOpp.Amount += i.amount;
            oppMapByDonationType.put(key,tempOpp);
        }

        
        if(oppMapByDonationType.values().size()>0){
            insert oppMapByDonationType.values();
        }
       

        return oppMapByDonationType;
    }

    /**
    * @description 
    * @author Iamsfdeveloper | 11-18-2020 
    * @param NewDonationBasketDataType 
    * @param Map<String,Opportunity> 
    * @return List<npsp__Allocation__c> 
    **/
    private static void newAllocation(NewDonationBasketDataType b,Map<String,Opportunity> oppMapByDT) {
        
        List<npsp__Allocation__c> aList = new List<npsp__Allocation__c>();
        Decimal counter=1;
        for (NewDonationBasketItemDataType i : b.items) {
            
            String Campaign_Id = null;
            String key = i.donationType;
            if(String.isBlank(Campaign_Id) && String.isNotEmpty(i.campaignCode) && String.valueof(i.campaignCode) InstanceOf Id){
                Campaign_Id = i.campaignCode;
                key +='-'+i.campaignCode;
            }
            npsp__General_Accounting_Unit__c p = new npsp__General_Accounting_Unit__c( Donation_Item_Code__c = i.DonationItemCode);
            npsp__Allocation__c a = new npsp__Allocation__c(Special_Instruction_Index__c =counter,npsp__Opportunity__c = oppMapByDT.get(key).Id,
                                                            npsp__General_Accounting_Unit__r = p,Quantity__c =1,npsp__Amount__c = i.Amount,CurrencyIsoCode = currencyIsoCode,Stipulation_Type__c = i.stipulationCode
                                                           );
            if(i.SchemeData.size()>0){
                for(NewDonationBasketItemDataType.SchemeData schemeDataObject:(List<NewDonationBasketItemDataType.SchemeData>)i.SchemeData){
                    if(schemeDataObject != null)
                        if(schemeDataObject.ParameterCode =='Name'){
                            a.Name__c = schemeDataObject.ParameterValue;
                        }else if(schemeDataObject.ParameterCode =='DateOfBirth'){
                            a.Date_of_Birth__c  = Date.parse(schemeDataObject.ParameterValue);
                        }else if(schemeDataObject.ParameterCode =='OrphanSalesForceId'){
                            if(schemeDataObject.ParameterValue instanceof Id)
                                a.Orphan__c = schemeDataObject.ParameterValue;
                        }else if(schemeDataObject.ParameterCode =='OrphanId'){
                            if(schemeDataObject.ParameterValue instanceof Id)
                                a.Orphan__c = schemeDataObject.ParameterValue;
                            else if(DefaultOrphanId != null)
                                a.Orphan__c =DefaultOrphanId;
                            
                        }  
                }
            }
            System.debug('PaymentScheduleList =====> '+i.PaymentScheduleList);
            if(i.PaymentScheduleList.size()>0 && (i.donationType =='30N' || i.donationType =='10N' || i.donationType =='10D' )){
                
                enqueuePaymentSchedule(oppMapByDT.get(key),i);
            }
            aList.add(a);
            counter++;
            
        }

        try {
            
            if (!aList.isEmpty()) {
                
                insert aList;
                
            }
        } catch (Exception ex) {
            npsp__General_Accounting_Unit__c p = new npsp__General_Accounting_Unit__c(Donation_Item_Code__c = 'DEFAULT-2021',npsp__Active__c = true);
            upsert p Donation_Item_Code__c;
            for(Integer j=0;j<aList.size();j++){aList[j].npsp__General_Accounting_Unit__c = p.Id; aList[j].npsp__General_Accounting_Unit__r=p;
            }
            insert aList;
            erroList.add(HA_Logger.CreateErrorLog(newDonation,transactionId,'newAllocation v3- Message => '+ex.getMessage()+'\n StackTrace =>'+ex.getStackTraceString()));
            response.errors = ex.getMessage();
        }
       
    }
    private static Id getWebsiteCampaignId(String campaignCode){
        if(CampaignId == null)
         CampaignId = [Select Id From Campaign Where Name =: campaignCode]?.Id;
        return CampaignId;
    }
    /**
    * @description 
    * @author Iamsfdeveloper | 01-14-2021 
    * @return Id 
    **/
    Private Static Id getDefaultOrphanId(){
  
        try{
            return [Select Id FROM Contact Where Sponsoree_ID__c='DefaultOrphan' and RecordType.developerName='Orphan' Limit 1].Id;
        }Catch(Exception ex){
            Account acc = new Account(external_ID__c='Human Appeal (Orphan Pool)',Name='Human Appeal (Orphan Pool)',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId());
            upsert acc external_ID__c;
            Contact con = new Contact(AccountId=acc.Id,FirstName='Default', LastName='Orphan',Is_Active__c=true,RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Orphan').getRecordTypeId(), Sponsoree_ID__c='DefaultOrphan');
            upsert con Sponsoree_ID__c;
            return con.Id;
        }
    }
    
    Public static void enqueuePaymentSchedule(Opportunity Donation,NewDonationBasketItemDataType Item){
        HA_PaymentSchedule_Queueable psq = new HA_PaymentSchedule_Queueable();
        psq.populatePaymentScheduleList(Donation,Item);
        System.enqueueJob(psq);
    }
}