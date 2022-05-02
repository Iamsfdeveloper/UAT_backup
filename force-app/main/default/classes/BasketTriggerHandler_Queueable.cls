/**
* @description       : 
* @author            : Iamsfdeveloper
* @group             : 
* @last modified on  : 01-27-2022 
* @last modified by  : Iamsfdeveloper
**/
public class BasketTriggerHandler_Queueable implements Queueable {
    public static List<Opportunity> donations = new List<Opportunity>();
    public static List<npsp__Allocation__c>  allocationsToInsert = new List<npsp__Allocation__c>();
    public static List<npe01__OppPayment__c> paymentsToInsert = new List<npe01__OppPayment__c>();
    private Static List<Income_Direct_Debit__c> DirectDebitToInsert = new List<Income_Direct_Debit__c>();    
    private Static Map<String,Income_Card_Payment__c> CardSetupToInsert = new Map<String,Income_Card_Payment__c>();  
    private Static Map<String,Opportunity> PaymentIndexMapOpportunity = new Map<String,Opportunity>();   
    private Static Map<String,Integer> groupIndexMapToPaymentIndex = new Map<String,Integer>();
    private Static Map<String,Opportunity> OpportunityMap = new Map<String,Opportunity>();
    private Static Map<String,Id> CampaignIdMap;
    private Static Map<String,List<checkoutDataType.PaymentScheduleList>> groupIndexMapToPaymentScheduleList = new Map<String,List<checkoutDataType.PaymentScheduleList>>(); 
    private static Map<String,Id> codeMapById = new Map<String,Id>();
    private static Map<String,Basket__c> basketIdMapTObject = new Map<String,Basket__c>();  
    private static npsp__General_Accounting_Unit__c defaultItem;
    public static List<npe03__Recurring_Donation__c> RecurringDonations = new List<npe03__Recurring_Donation__c>();
    public Static List<Account> accountsToUpsert = new List<Account>();
    
    static{
        CampaignIdMap = getWebsiteCampaignId();
        for(HA_Payment_Schedule__c paymentschedules:[SELECT Id,Code__c, Frequency__c, Processing_Time__c, Start_Date__c, End_Date__c, Name FROM HA_Payment_Schedule__c Where Code__c != null and Is_Active__c=true and Is_External__c = true]){
            codeMapById.put(paymentschedules.Code__c,paymentschedules.Id);
        }
        defaultItem = [Select Id From npsp__General_Accounting_Unit__c WHERE Donation_Item_Code__c = 'DEFAULT-2021'];
    }
    
    public List<Basket__c> newlist;
    public BasketTriggerHandler_Queueable(List<Basket__c> newlist){
        this.newlist = newlist ;  
    }
    public void execute(QueueableContext context) {
        Map<Id,Basket__c> basketNewMap = new Map<Id,Basket__c>((List<Basket__c>)newlist);
        try{
            
            List<Basket__c> basketToUpdate = new List<Basket__c>();
            Map<String,Contact> basketMapToContact  = new Map<String,Contact>();
            
            
            for (Basket__c  b : [Select Id,Tax_Status__c, Donation_Date_Time__c,Basket_Source__c,Status__c,Basket_External_Id__c,Contact__c,Account__c,Regional_Office_Code__c,CurrencyIsoCode,Donor_Details__c,Basket_Details__c,Payment_details__c From Basket__c Where Id IN :basketNewMap.keyset()]) {
                
                
                if (b.Status__c == 'Paid' && b.Basket_Source__c == 'Website')  {
                    basketIdMapTObject.put(b.Basket_External_Id__c,b);
                    checkoutDataType.NewDonationSupporterDataType supporter = (checkoutDataType.NewDonationSupporterDataType)JSON.deserialize(b.Donor_Details__c, checkoutDataType.NewDonationSupporterDataType.class);
                    b.Tax_Status__c  = supporter.GiftAidDeclared;
                    String ExternalId = '';
                    if(b.Account__c == null && supporter.IsOrganisation){
                        Account organization = newAccount(b.Basket_External_Id__c,supporter,b.Regional_Office_Code__c,b.CurrencyIsoCode);
                        b.Account__r = new Account(External_ID_From_DMS__c = organization.External_ID_From_DMS__c);
                        ExternalId = organization.External_ID_From_DMS__c;
                        accountsToUpsert.add(organization);
                    }else if(b.contact__c == null){
                        Contact c = newContact(b.Basket_External_Id__c,supporter,b.Regional_Office_Code__c,b.CurrencyIsoCode);
                        ExternalId = c.External_Id__c;
                        basketMapToContact.put(c.External_Id__c, c);
                        if(c!= null){
                            b.Contact__r  = new Contact(External_Id__c  = c.External_Id__c);
                            
                        }
                    }    
                    createDonations(supporter.IsOrganisation,ExternalId,b.Id,(checkoutDataType.NewDonationBasketDataType)JSON.deserialize(b.Basket_Details__c, checkoutDataType.NewDonationBasketDataType.class), b.Tax_Status__c, b.Donation_Date_Time__c, b.Regional_Office_Code__c,b.CurrencyIsoCode);
                    createPaymentRecords(supporter.IsOrganisation,ExternalId,b.Id,(List<Object>)JSON.deserializeUntyped(b.Payment_Details__c),OpportunityMap,groupIndexMapToPaymentScheduleList );
                    
                }
                basketToUpdate.add(b);
            }
            
            /* DML Operations*/
            if(accountsToUpsert.size()>0)
                Database.Upsert(accountsToUpsert,Account.Fields.External_ID_From_DMS__c,false);
            
            if(basketMapToContact.size()>0){
                //Database.Upsert(basketMapToContact.values(),Contact.Fields.Unique_Donor_Id__c,false);
                Database.Upsert(basketMapToContact.values(),Contact.Fields.External_Id__c,false);
                
            }
            
            if(OpportunityMap.size()>0){
                // Database.UpsertResult[] upsertList = Database.Upsert(OpportunityMap.values(),Opportunity.Fields.Transaction_Id__c,false);
                Database.upsert(OpportunityMap.values());
            }
            if(allocationsToInsert.size()>0){
                //upsert allocationsToInsert;
                Database.UpsertResult[] urList = Database.Upsert(allocationsToInsert,npsp__Allocation__c.fields.DMS_Donation_Line_Item_ID__c,false);
                List<npsp__Allocation__c> dmlRows = new List<npsp__Allocation__c>();
                // Iterate through each returned result
                for (Integer i=0;i<urList.size();i++) {
                    if(!urList[i].isSuccess()){
                        
                        npsp__Allocation__c alloc = allocationsToInsert[i].clone();
                        alloc.npsp__General_Accounting_Unit__r = null;
                        alloc.npsp__General_Accounting_Unit__c = defaultItem.Id;
                        dmlRows.add(alloc);
                    }
                    
                }
                if(dmlRows.size()>0) 
                    Insert dmlRows;
                
            }
            
            if(CardSetupToInsert.size()>0){
                //Database.Upsert(CardSetupToInsert.values(),Income_Card_Payment__c.fields.Payment_method_Id__c,false);
                Upsert CardSetupToInsert.values();
            }
            if(DirectDebitToInsert.size()>0){
                // Database.upsert(DirectDebitToInsert,Income_Direct_Debit__c.fields.External_Id__c,false);
                Database.Upsert(DirectDebitToInsert,false);
            }
            
            if(paymentsToInsert.size()>0){
                System.debug('paymentsToInsert==>'+paymentsToInsert);
                //Database.Insert(paymentsToInsert,false);
                Upsert paymentsToInsert;
            }
            
            if(basketToUpdate.size()>0){
                // Database.upsert(basketToUpdate,basket__c.fields.Basket_External_Id__c,false);
                upsert basketToUpdate;
            }
        }catch(Exception ex){
            insert HA_Logger.CreateErrorLog(JSON.serialize(newlist),JSON.serialize(basketNewMap.keyset()),ex.getStackTraceString()+'-'+ex.getMessage());
        }
    }
    /**Donation & Recurring Donation 
* To do dereference Source Opp and Directly create RecurringDonation
*/
    private static void createDonations(Boolean IsOrganization,String ExternalId,String basketRecordId,checkoutDataType.NewDonationBasketDataType b,String giftAidStatus ,DateTime transactionTimeUtc,String siteCode,String currencyIsoCode) {
        string OPP_STAGE = 'Awaiting Payment Details';
        string PP_TYPE = 'Payment Plan - Source';
        string SD_TYPE = 'Donation';
        string OPP_NAME = 'System Generated';
        Map<String,Opportunity> oppMapByDonationType = new Map<String,Opportunity>();
        Integer counter = 0;
        
        for (checkoutDataType.donationGroup ig : b.ItemGroups) {
            groupIndexMapToPaymentIndex.put(ig.GroupId,ig.PaymentMethodIndex);
            String Campaign_Id = (ig.PrimaryCampaignCode != null && ig.PrimaryCampaignCode instanceOf Id)?ig.PrimaryCampaignCode: CampaignIdMap.get('Website-'+siteCode);
            
            Opportunity tempOpp = new Opportunity(Basket__c = basketRecordId,Payment_Schedule__c = codeMapById.get(ig.donationType),Amount = ig.amount,CampaignId = Campaign_Id,Transaction_Id__c = ig.GroupId,Type=(ig.donationType =='RD' || ig.donationType =='RDA')?PP_TYPE:SD_TYPE,CloseDate = transactionTimeUtc.date(),Name =OPP_NAME, Gift_Aid_Eligible_Status__c = giftAidStatus,Medium__c ='Online',StageName = OPP_STAGE,CurrencyIsoCode = currencyIsoCode,Donation_Type__c=ig.donationType,website_code__c = siteCode,Regional_Office_Code__c=siteCode);
            If(IsOrganization)
                tempOpp.Account = new Account(External_ID_From_DMS__c=ExternalId);
            else {
                tempOpp.npsp__Primary_Contact__r = new Contact(External_Id__c=ExternalId);
            }
            if(ig.DonationType=='RDA')
                tempOpp.Recurring_Type__c ='Fixed';
            if(ig.donationType =='30N' || ig.donationType =='10N' || ig.donationType =='10D'){
                tempOpp.StageName = OPP_STAGE;
                tempOpp.Recurring_Type__c ='Fixed';
                tempOpp.Number_of_Installments__c = (ig.donationType =='30N')?30:10;
                if(ig.PaymentScheduleList.size()>0)
                    groupIndexMapToPaymentScheduleList.put(ig.GroupId,ig.PaymentScheduleList);
            }
            OpportunityMap.put(ig.GroupId,tempOpp);
            /**Item Allocations */
            Decimal TotalPercentage = 100.000000;
            Decimal allocatedPercentage = 0;
            for (checkoutDataType.NewDonationBasketItemDataType i : ig.items) {
                Decimal ItemPercentage = (ig.Amount != null && ig.Amount != 0.00)?((i.Amount/ig.Amount)*100).setScale(6):null;
                
                if((allocatedPercentage+ItemPercentage)>TotalPercentage)
                    ItemPercentage = (TotalPercentage - (allocatedPercentage)).setScale(6);	
                else
                    allocatedPercentage +=ItemPercentage;
                String key = ig.GroupId;
                npsp__General_Accounting_Unit__c p = new npsp__General_Accounting_Unit__c( Donation_Item_Code__c = i.DonationItemCode);
                npsp__Allocation__c a = new npsp__Allocation__c(npsp__Opportunity__r = new Opportunity(Transaction_Id__c = ig.GroupId),
                                                                npsp__General_Accounting_Unit__r = p,Quantity__c =1,
                                                                npsp__Amount__c = i.Amount,npsp__Percent__c =ItemPercentage ,
                                                                CurrencyIsoCode = currencyIsoCode,
                                                                Stipulation_Type__c = i.stipulationCode,
                                                                Notes__c = JSON.serialize(i)
                                                               );
                if(i.SchemeData.size()>0){
                    for(checkoutDataType.SchemeData schemeDataObject:(List<checkoutDataType.SchemeData>)i.SchemeData){
                        if(schemeDataObject != null){
                            String code = schemeDataObject.ParameterCode;
                            code = code.toLowerCase();
                            code = code.deleteWhitespace();
                            switch on code{
                                when 'name' {
                                    a.Name__c = schemeDataObject.ParameterValue;
                                }
                                when 'dateofbirth' {
                                    a.Date_of_Birth__c  = Date.parse(schemeDataObject.ParameterValue);
                                }
                                when 'orphansalesforceid','orphanid'{
                                    if(schemeDataObject.ParameterValue instanceof Id)
                                        a.Orphan__c = schemeDataObject.ParameterValue;
                                    else 
                                        a.Orphan__r =new Contact(Sponsoree_ID__c =schemeDataObject.ParameterValue);
                                    
                                }
                            }
                        }
                        
                    }   
                }
                a.DMS_Donation_Line_Item_ID__c = ig.GroupId+'-'+counter;
                allocationsToInsert.add(a);
                counter++;
            }       //End of ig.Items
            
        }//End of Groups
        
    }
    
    private static Map<String,Id> getWebsiteCampaignId(){
        Map<String,Id> campaignMap =new Map<String,Id>();
        for(Campaign c:[Select Id,Name From Campaign Where Name like 'Website%']){
            campaignMap.put(c.Name,c.id);
        }
        return campaignMap;
    }
    /*** Donor Creation */
    private static Account newAccount(String basketId,checkoutDataType.NewDonationSupporterDataType d,String siteCode,String currencyIsoCode) {
        String addressLine1 = d.addressLine1;
        String addressLine2 = d.addressLine2;
        String mailingStreet = addressLine1 + '\n' + addressLine2;
        String ExternalId = d.organisationName.deleteWhitespace();
        Account organization = new Account(BillingStreet = mailingStreet,BillingCity = d.townCity,External_ID_From_DMS__c=ExternalId.toLowerCase(),
                                           BillingState = d.state, Phone = d.telephone,BillingPostalCode = d.postalCode,
                                           BillingCountry = getCountryName(d.countryCode),Billing_Email__c = d.email, 
                                           Name=d.organisationName,Regional_Office_Code__c =siteCode,currencyIsoCode=currencyIsoCode,
                                           RecordTypeId=Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId());
        return organization;
    }
    private static Contact newContact(String basketId,checkoutDataType.NewDonationSupporterDataType d,String siteCode,String currencyIsoCode) {
        //Concatenate Address details for the Mailing Street
        String addressLine1 = d.addressLine1;
        String addressLine2 = d.addressLine2;
        String mailingStreet = addressLine1 + '\n' + addressLine2;
        
        Contact c = new Contact(
            Salutation = d.title,
            FirstName = d.firstName,
            LastName = d.lastName,
            MailingStreet = mailingStreet,
            MailingCity = d.townCity,
            MailingState = d.state,
            Phone = d.telephone,
            MailingPostalCode = d.postalCode,
            MailingCountry = getCountryName(d.countryCode),
            Email = d.email,
            CurrencyIsoCode = currencyIsoCode);
        if(String.isNotEmpty(d.nationalIdentificationNumber))
            c.National_Identification_Number__c = d.nationalIdentificationNumber;
        if(d.SubscribeSmsList){
            c.Can_Appeal_Via_Sms__c = 'Yes';
            c.SMS_Preference_declared__c = 'Via_Website';
        }
        if(d.SubscribeEmailList){
            c.Can_Appeal_Via_Email__c = 'Yes';
            c.Email_Preference_declared__c = 'Via_Website';
        }
        c.Regional_Office_Code__c = siteCode;
        
        /**
* Unique Key => External Id for Upsert
*  All  Regional Offices (FirstName,LastName,Email,SiteCode)
* */
        //c.Unique_Donor_Id__c =d.firstName+'-'+d.LastName+'-'+d.email+'-'+siteCode;
        String externalId = d.firstName+'-'+d.LastName+'-'+d.email+'-'+siteCode;
        externalId = externalId.deleteWhitespace();
        c.External_Id__c = externalId.toLowerCase();
        if(siteCode =='UK'){
            c.Gift_Aid_Status__c  = d.GiftAidDeclared;
        }
        return c;
    }
    private static string getCountryName(String countryCode) {
        return [
            SELECT Country_Name__c
            FROM Country_Mapping__mdt
            WHERE Country_Code_alpha_3__c = :countryCode
        ]?.Country_Name__c;
    }
    /**Payment Details */
    Private static void createPaymentRecords(Boolean IsOrganization,String ExternalId,String basketrecordId,List<Object> paymentMethodsList,Map<String,Opportunity> OpportunityMap,Map<String,List<checkoutDataType.PaymentScheduleList>> PaymentScheduleList ){
        Map<Integer,checkoutDataType.PaymentGateway> paymentMethodIndexMap = new Map<Integer,checkoutDataType.PaymentGateway>();
        Id CardPaymentRecTypeId = Schema.SObjectType.npe01__OppPayment__c.getRecordTypeInfosByDeveloperName().get('Card_Payment').getRecordTypeId();
        for(Integer i=0;i<paymentMethodsList.size();i++){ 
            Map<String,Object>  paymentRecords = (Map<String,Object> )paymentMethodsList[i];
            System.debug('keyset==>'+paymentRecords.keyset());
            switch on String.valueOf(paymentRecords.get('Gateway')){
                when 'Oppwa'{
                    checkoutDataType.TotalProcessing oopwa = (checkoutDataType.TotalProcessing)JSON.deserialize(JSON.serialize(paymentMethodsList[i]), checkoutDataType.TotalProcessing.class);
                    paymentMethodIndexMap.put(oopwa.PaymentMethodIndex,oopwa);
                }
                when else{
                    checkoutDataType.paymentMethodDataType Stripe = (checkoutDataType.paymentMethodDataType)JSON.deserialize(JSON.serialize(paymentMethodsList[i]), checkoutDataType.paymentMethodDataType.class);
                    paymentMethodIndexMap.put(Stripe.PaymentMethodIndex,Stripe);
                }
        
}
            
        }
        
        if(paymentMethodIndexMap.size()>0){        
        Integer index =0;
        
        for(String groupId:OpportunityMap.keySet()){
            Opportunity Opp = OpportunityMap.get(groupId);
            
           
		checkoutDataType.PaymentGateway pg = paymentMethodIndexMap.get(groupIndexMapToPaymentIndex.get(groupId));
            if(pg instanceOf checkoutDataType.TotalProcessing){
               checkoutDataType.TotalProcessing tempPaymentMethod = (checkoutDataType.TotalProcessing)pg;
                if(tempPaymentMethod.Status =='succeeded' || tempPaymentMethod.Status =='setup'){
                    String paymentIntent = tempPaymentMethod.PaymentIntent;
                    if(paymentIntent == null)paymentIntent = HA_Utility.generateGUID();
                    String paymentMethodId = tempPaymentMethod.PaymentMethodId;
                    if(paymentMethodId == null)paymentMethodId = HA_Utility.generateGUID();
                                switch on Opp.Donation_Type__c{
                                    When 'SD'{
                                       
                                        Income_Card_Payment__c temp = (CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) != null)?CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId): new Income_Card_Payment__c(Payment_Vendor__c ='Oppwa',First_Payment_Amount__c=tempPaymentMethod.Amount,First_Payment_Taken__c = true,basket__c = basketrecordId,Payment_Method_Type__c  = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=paymentIntent,Payment_Method_Id__c =paymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Payment_Status__c=tempPaymentMethod.Status);
                                        If(CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) == null){
                                            if(IsOrganization){
                                                temp.Account__r = new Account(External_ID_From_DMS__c= ExternalId);
                                            }else{
                                                temp.contact__r = new Contact(External_Id__c = ExternalId);
                                            } 
                                        }
                                        CardSetupToInsert.put(paymentMethodId,temp);
                                        paymentsToInsert.add(new npe01__OppPayment__c(DMS_DonationPayment_ID__c =groupId+'-'+index,   Card_Details__r = new Income_Card_Payment__c(Payment_Method_Id__c=paymentMethodId),npsp__Type__c='Sale',CurrencyIsoCode = Opp.currencyIsoCode,npe01__Opportunity__r = new Opportunity(Transaction_Id__c = groupId),RecordTypeId=CardPaymentRecTypeId,npe01__Payment_Method__c = 'Card Payment',npe01__Payment_Amount__c=Opp.Amount,npe01__Paid__c=true,npe01__Payment_Date__c=tempPaymentMethod.DateTimeCreated.date(),npsp__Gateway_Payment_ID__c =paymentMethodId,Order_ID__c =paymentIntent,Transaction_ID__c =paymentIntent));
                                        index++;
                                    }
                                    when 'RD','RDA'{
                                        Income_Card_Payment__c temp = null;
                                        If(CardSetupToInsert.get(paymentMethodId) != null){
                                            temp = CardSetupToInsert.get(paymentMethodId);
                                        }else{
                                            temp = new Income_Card_Payment__c(Payment_Vendor__c ='Oppwa',First_Payment_Amount__c=tempPaymentMethod.Amount,basket__c = basketrecordId,First_Payment_Taken__c = true,Payment_Method_Type__c  = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=paymentIntent,Payment_Method_Id__c =paymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Payment_Status__c=tempPaymentMethod.Status);
                                            if(IsOrganization){
                                                temp.Account__r = new Account(External_ID_From_DMS__c= ExternalId);
                                            }else{
                                                temp.contact__r = new Contact(External_Id__c = ExternalId);
                                            } 
                                        }
                                        CardSetupToInsert.put(paymentMethodId,temp);
                                        
                                        
                                        paymentsToInsert.add(new npe01__OppPayment__c(DMS_DonationPayment_ID__c =groupId+'-'+index,Payment_Status__c =tempPaymentMethod.Status,Card_Details__r = new Income_Card_Payment__c(Payment_Method_Id__c=paymentMethodId),npsp__Type__c='Setup',CurrencyIsoCode = Opp.currencyIsoCode,npe01__Opportunity__r = new Opportunity(Transaction_Id__c = groupId), Transaction_Type__c ='Setup' ,RecordTypeId=CardPaymentRecTypeId,npe01__Payment_Method__c = 'Card Payment',npe01__Payment_Amount__c=0.00,npe01__Payment_Date__c=tempPaymentMethod.DateTimeCreated.date(),npsp__Gateway_Payment_ID__c =paymentMethodId,Order_ID__c =paymentIntent,Transaction_ID__c =paymentIntent));
                                        index++;
                                    }
                                    when '10N','30N'{
                                        Income_Card_Payment__c temp = (CardSetupToInsert.get(paymentMethodId) != null)?CardSetupToInsert.get(paymentMethodId): new Income_Card_Payment__c(Payment_Vendor__c ='Oppwa',basket__c = basketrecordId,First_Payment_Taken__c = false,Payment_Method_Type__c  = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=paymentIntent,First_Payment_Amount__c = opp.Amount,Payment_Method_Id__c= paymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Payment_Status__c=tempPaymentMethod.Status);
					                                    
										If(CardSetupToInsert.get(paymentMethodId) == null){
                                            if(IsOrganization){
                                                temp.Account__r = new Account(External_ID_From_DMS__c= ExternalId);
                                            }else{
                                                temp.contact__r = new Contact(External_Id__c = ExternalId);
                                            } 
                                        }
                                        CardSetupToInsert.put(paymentMethodId,temp);
                                        if(PaymentScheduleList.size()>0 && PaymentScheduleList.get(groupId) != null){
                                            //To Calculate End date and Start Date on Email Template
                                            Opp.Number_of_Installments__c = PaymentScheduleList.get(groupId).size();
                                            Opp.Effective_Date__c = PaymentScheduleList.get(groupId)[0].Date_Time.date();
                                            Integer counter = (Opp.Donation_Type__c =='10N')?(10-PaymentScheduleList.get(groupId).size())+1:(30-PaymentScheduleList.get(groupId).size())+1;
                                            for(checkoutDataType.PaymentScheduleList ps : PaymentScheduleList.get(groupId)){
                                                paymentsToInsert.add(new npe01__OppPayment__c(DMS_DonationPayment_ID__c =groupId+'-'+index,Payment_Description__c = 'Night-'+counter,Payment_Reference__c = HA_Utility.generateGUID(),Card_Details__r = new Income_Card_Payment__c(Payment_Method_Id__c=paymentMethodId),npsp__Type__c='Sale',CurrencyIsoCode = Opp.currencyIsoCode,npe01__Opportunity__r = new Opportunity(Transaction_Id__c = groupId),RecordTypeId=CardPaymentRecTypeId,npe01__Payment_Method__c = 'Card Payment',npe01__Payment_Amount__c=ps.Amount,npe01__Payment_Date__c=ps.Date_Time.date(),npsp__Authorized_Date__c=tempPaymentMethod.DateTimeCreated,Bank_Notes__c = JSON.serialize(ps),npsp__Gateway_Payment_ID__c = paymentMethodId));
                                                index++;
												counter++;
                                            }
                                        } 

                                    }
                                    when '10D'{
                                        Income_Card_Payment__c temp = (CardSetupToInsert.get(paymentMethodId) != null)?CardSetupToInsert.get(paymentMethodId): new Income_Card_Payment__c(Payment_Vendor__c ='Oppwa',basket__c = basketrecordId,First_Payment_Taken__c = true,Payment_Method_Type__c  = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=paymentIntent,First_Payment_Amount__c = opp.Amount,Payment_Method_Id__c =paymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Payment_Status__c=tempPaymentMethod.Status);
                                        temp.basket__c = basketrecordId;
                                        If(CardSetupToInsert.get(paymentMethodId) == null){
                                            if(IsOrganization){
                                                temp.Account__r = new Account(External_ID_From_DMS__c= ExternalId);
                                            }else{
                                                temp.contact__r = new Contact(External_Id__c = ExternalId);
                                            } 
                                        }
                                        CardSetupToInsert.put(paymentMethodId,temp);
                                        if(PaymentScheduleList.size()>0 && PaymentScheduleList.get(groupId) != null){
                                            //To Calculate End date and Start Date on Email Template
                                            Opp.Number_of_Installments__c = PaymentScheduleList.get(groupId).size();
                                            Opp.Effective_Date__c = PaymentScheduleList.get(groupId)[0].Date_Time.date();
                                            Integer counter = (10-PaymentScheduleList.get(groupId).size())+1;
                                            for(checkoutDataType.PaymentScheduleList ps : PaymentScheduleList.get(groupId)){
                                                paymentsToInsert.add(new npe01__OppPayment__c(DMS_DonationPayment_ID__c =groupId+'-'+index,Payment_Description__c = 'Day-'+Counter,Payment_Reference__c = HA_Utility.generateGUID(),Card_Details__r = new Income_Card_Payment__c(Payment_Method_Id__c=paymentMethodId),npsp__Type__c='Sale',CurrencyIsoCode = Opp.currencyIsoCode,npe01__Opportunity__r = new Opportunity(Transaction_Id__c = groupId),RecordTypeId=CardPaymentRecTypeId,npe01__Payment_Method__c = 'Card Payment',npe01__Payment_Amount__c=ps.Amount,npe01__Payment_Date__c=ps.Date_Time.date(),npsp__Authorized_Date__c=tempPaymentMethod.DateTimeCreated,Bank_Notes__c = JSON.serialize(ps),npsp__Gateway_Payment_ID__c =paymentMethodId));
                                                index++;    
												Counter++;
                                            }
                                        }
                                        
                                    }
                                }
                            }
            }else{
                checkoutDataType.paymentMethodDataType tempPaymentMethod = (checkoutDataType.paymentMethodDataType)pg;
                
                
                if(tempPaymentMethod != null){
                    switch on tempPaymentMethod.Id{
                        when 'card'{
                            if(tempPaymentMethod.Status =='succeeded'){
                                switch on Opp.Donation_Type__c{
                                    When 'SD'{
                                        Income_Card_Payment__c temp = (CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) != null)?CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId): new Income_Card_Payment__c(First_Payment_Amount__c=tempPaymentMethod.Amount,First_Payment_Taken__c = true,basket__c = basketrecordId,Payment_Method_Type__c  = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=tempPaymentMethod.PaymentIntent,Payment_Method_Id__c =tempPaymentMethod.PaymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Gateway_Customer_Reference__c=tempPaymentMethod.customerId,Payment_Status__c=tempPaymentMethod.Status);
                                        If(CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) == null){
                                            if(IsOrganization){
                                                temp.Account__r = new Account(External_ID_From_DMS__c= ExternalId);
                                            }else{
                                                temp.contact__r = new Contact(External_Id__c = ExternalId);
                                            } 
                                        }
                                        CardSetupToInsert.put(tempPaymentMethod.PaymentMethodId,temp);
                                        paymentsToInsert.add(new npe01__OppPayment__c(DMS_DonationPayment_ID__c =groupId+'-'+index,   Card_Details__r = new Income_Card_Payment__c(Payment_Method_Id__c=tempPaymentMethod.PaymentMethodId),npsp__Type__c='Sale',CurrencyIsoCode = Opp.currencyIsoCode,npe01__Opportunity__r = new Opportunity(Transaction_Id__c = groupId),RecordTypeId=CardPaymentRecTypeId,npe01__Payment_Method__c = 'Card Payment',npe01__Payment_Amount__c=Opp.Amount,npe01__Paid__c=true,npe01__Payment_Date__c=tempPaymentMethod.DateTimeCreated.date(),Gateway_Customer_Reference__c = tempPaymentMethod.CustomerId,npsp__Gateway_ID__c=tempPaymentMethod.CustomerId,npsp__Gateway_Payment_ID__c = tempPaymentMethod.PaymentMethodId,Order_ID__c = tempPaymentMethod.PaymentIntent,Transaction_ID__c = tempPaymentMethod.PaymentIntent));
                                        index++;
                                    }
                                    when 'RD','RDA'{
                                        Income_Card_Payment__c temp = null;
                                        If(CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) != null){
                                            temp = CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId);
                                        }else{
                                            temp = new Income_Card_Payment__c(First_Payment_Amount__c=tempPaymentMethod.Amount,basket__c = basketrecordId,First_Payment_Taken__c = true,Payment_Method_Type__c  = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=tempPaymentMethod.PaymentIntent,Payment_Method_Id__c =tempPaymentMethod.PaymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Gateway_Customer_Reference__c=tempPaymentMethod.customerId,Payment_Status__c=tempPaymentMethod.Status);
                                            if(IsOrganization){
                                                temp.Account__r = new Account(External_ID_From_DMS__c= ExternalId);
                                            }else{
                                                temp.contact__r = new Contact(External_Id__c = ExternalId);
                                            } 
                                        }
                                        CardSetupToInsert.put(tempPaymentMethod.PaymentMethodId,temp);
                                        
                                        
                                        paymentsToInsert.add(new npe01__OppPayment__c(DMS_DonationPayment_ID__c =groupId+'-'+index,Payment_Status__c =tempPaymentMethod.Status,Card_Details__r = new Income_Card_Payment__c(Payment_Method_Id__c=tempPaymentMethod.PaymentMethodId),npsp__Type__c='Setup',CurrencyIsoCode = Opp.currencyIsoCode,npe01__Opportunity__r = new Opportunity(Transaction_Id__c = groupId), Transaction_Type__c ='Setup' ,RecordTypeId=CardPaymentRecTypeId,npe01__Payment_Method__c = 'Card Payment',npe01__Payment_Amount__c=0.00,npe01__Payment_Date__c=tempPaymentMethod.DateTimeCreated.date(),Gateway_Customer_Reference__c = tempPaymentMethod.CustomerId,npsp__Gateway_ID__c=tempPaymentMethod.CustomerId,npsp__Gateway_Payment_ID__c = tempPaymentMethod.PaymentMethodId,Order_ID__c = tempPaymentMethod.PaymentIntent,Transaction_ID__c = tempPaymentMethod.PaymentIntent));
                                        index++;
                                    }
                                    when '10N','30N'{
                                        Income_Card_Payment__c temp = (CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) != null)?CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId): new Income_Card_Payment__c(basket__c = basketrecordId,First_Payment_Taken__c = false,Payment_Method_Type__c  = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=tempPaymentMethod.PaymentIntent,First_Payment_Amount__c = opp.Amount,Payment_Method_Id__c =tempPaymentMethod.PaymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Gateway_Customer_Reference__c=tempPaymentMethod.customerId,Payment_Status__c=tempPaymentMethod.Status);
                                        If(CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) == null){
                                            if(IsOrganization){
                                                temp.Account__r = new Account(External_ID_From_DMS__c= ExternalId);
                                            }else{
                                                temp.contact__r = new Contact(External_Id__c = ExternalId);
                                            } 
                                        }
                                        CardSetupToInsert.put(tempPaymentMethod.PaymentMethodId,temp);
                                        if(PaymentScheduleList.size()>0 && PaymentScheduleList.get(groupId) != null){
                                            //To Calculate End date and Start Date on Email Template
                                            Opp.Number_of_Installments__c = PaymentScheduleList.get(groupId).size();
                                            Opp.Effective_Date__c = PaymentScheduleList.get(groupId)[0].Date_Time.date();
                                            Integer counter = (Opp.Donation_Type__c =='10N')?(10-PaymentScheduleList.get(groupId).size())+1:(30-PaymentScheduleList.get(groupId).size())+1;
                                            for(checkoutDataType.PaymentScheduleList ps : PaymentScheduleList.get(groupId)){
                                                paymentsToInsert.add(new npe01__OppPayment__c(DMS_DonationPayment_ID__c =groupId+'-'+index,Payment_Description__c = 'Night-'+counter,Payment_Reference__c = HA_Utility.generateGUID(),Card_Details__r = new Income_Card_Payment__c(Payment_Method_Id__c=tempPaymentMethod.PaymentMethodId),npsp__Type__c='Sale',CurrencyIsoCode = Opp.currencyIsoCode,npe01__Opportunity__r = new Opportunity(Transaction_Id__c = groupId),RecordTypeId=CardPaymentRecTypeId,npe01__Payment_Method__c = 'Card Payment',npe01__Payment_Amount__c=ps.Amount,npe01__Payment_Date__c=ps.Date_Time.date(),npsp__Authorized_Date__c=tempPaymentMethod.DateTimeCreated,Bank_Notes__c = JSON.serialize(ps),Gateway_Customer_Reference__c = tempPaymentMethod.CustomerId,npsp__Gateway_ID__c=tempPaymentMethod.CustomerId,npsp__Gateway_Payment_ID__c = tempPaymentMethod.PaymentMethodId));
                                                index++;
                                            }
                                        } 
                                    }
                                    when '10D'{
                                        Income_Card_Payment__c temp = (CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) != null)?CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId): new Income_Card_Payment__c(basket__c = basketrecordId,First_Payment_Taken__c = true,Payment_Method_Type__c  = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=tempPaymentMethod.PaymentIntent,First_Payment_Amount__c = opp.Amount,Payment_Method_Id__c =tempPaymentMethod.PaymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Gateway_Customer_Reference__c=tempPaymentMethod.customerId,Payment_Status__c=tempPaymentMethod.Status);
                                        temp.basket__c = basketrecordId;
                                        If(CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) == null){
                                            if(IsOrganization){
                                                temp.Account__r = new Account(External_ID_From_DMS__c= ExternalId);
                                            }else{
                                                temp.contact__r = new Contact(External_Id__c = ExternalId);
                                            } 
                                        }
                                        CardSetupToInsert.put(tempPaymentMethod.PaymentMethodId,temp);
                                        if(PaymentScheduleList.size()>0 && PaymentScheduleList.get(groupId) != null){
                                            //To Calculate End date and Start Date on Email Template
                                            Opp.Number_of_Installments__c = PaymentScheduleList.get(groupId).size();
                                            Opp.Effective_Date__c = PaymentScheduleList.get(groupId)[0].Date_Time.date();
                                            Integer counter = (10-PaymentScheduleList.get(groupId).size())+1;
                                            for(checkoutDataType.PaymentScheduleList ps : PaymentScheduleList.get(groupId)){
                                                paymentsToInsert.add(new npe01__OppPayment__c(DMS_DonationPayment_ID__c =groupId+'-'+index,Payment_Description__c = 'Day-'+Counter,Payment_Reference__c = HA_Utility.generateGUID(),Card_Details__r = new Income_Card_Payment__c(Payment_Method_Id__c=tempPaymentMethod.PaymentMethodId),npsp__Type__c='Sale',CurrencyIsoCode = Opp.currencyIsoCode,npe01__Opportunity__r = new Opportunity(Transaction_Id__c = groupId),RecordTypeId=CardPaymentRecTypeId,npe01__Payment_Method__c = 'Card Payment',npe01__Payment_Amount__c=ps.Amount,npe01__Payment_Date__c=ps.Date_Time.date(),npsp__Authorized_Date__c=tempPaymentMethod.DateTimeCreated,Bank_Notes__c = JSON.serialize(ps),Gateway_Customer_Reference__c = tempPaymentMethod.CustomerId,npsp__Gateway_ID__c=tempPaymentMethod.CustomerId,npsp__Gateway_Payment_ID__c = tempPaymentMethod.PaymentMethodId));
                                                index++;    
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                        When 'bacs_debit'{
                            if(tempPaymentMethod.AcceptTerms==true && Opp.Donation_Type__c =='RD'){
                                Income_Direct_Debit__c dd =new Income_Direct_Debit__c(DD_Bank_Account_Name__c = tempPaymentMethod.AccountHolder,
                                                                                      External_Id__c = groupId,
                                                                                      CurrencyIsoCode = Opp.currencyIsoCode,DD_Bank_Account_Number__c = tempPaymentMethod.AccountNumber,
                                                                                      DD_Collection_Period__c = 'Monthly',DD_Collection_Day__c='1',DD_Status__c = 'New Instruction',Opportunity__r = new Opportunity(Transaction_Id__c = groupId),
                                                                                      DD_Bank_Sort_Code__c = tempPaymentMethod.SortCode,DD_First_Collection_Amount__c = opp.Amount,DD_Ongoing_Collection_Amount__c= opp.Amount,DD_Start_Date__c=opp.closeDate,DD_End_Date__c = opp.CloseDate.addMonths(120));  
                                dd.basket__c = basketrecordId;
                                if(IsOrganization){
                                    dd.Account__r = new Account(External_ID_From_DMS__c= ExternalId);
                                }else{
                                    dd.contact__r = new Contact(External_Id__c = ExternalId);
                                } 
                                if(tempPaymentMethod.IsValidated){
                                    dd.DD_Sort_Code_OK__c =tempPaymentMethod.ValidationResponse.SortCodeOK;
                                    dd.DD_OK__c =tempPaymentMethod.ValidationResponse.DirectDebitsOK;
                                    dd.DD_Account_Number_OK__c = tempPaymentMethod.ValidationResponse.AccountCodeOK;
                                    dd.DD_Bank_Name__c =tempPaymentMethod.ValidationResponse.BankName;
                                    dd.DD_Branch_Name__c =tempPaymentMethod.ValidationResponse.BranchTitle;
                                    dd.DD_Bank_Postcode__c =tempPaymentMethod.ValidationResponse.BankAddressPostCode;
                                    dd.DD_Bank_City__c =tempPaymentMethod.ValidationResponse.BankAddressTown;
                                    dd.DD_Bank_Phone__c =tempPaymentMethod.ValidationResponse.Telephone;
                                    dd.DD_Bank_Address__c =tempPaymentMethod.ValidationResponse.BankAddress1+','+tempPaymentMethod.ValidationResponse.BankAddress2+','+tempPaymentMethod.ValidationResponse.BankAddress3+','+tempPaymentMethod.ValidationResponse.BankAddress4;
                                }
                                DirectDebitToInsert.add(dd);
                            }
                        }
                        when 'sepa_debit'{
                            if(tempPaymentMethod.Status =='succeeded' && Opp.Donation_Type__c =='RD'){
                                Income_Card_Payment__c temp = new Income_Card_Payment__c(basket__c =basketrecordId,Payment_Method_Type__c = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=tempPaymentMethod.PaymentIntent,Payment_Method_Id__c =tempPaymentMethod.PaymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Gateway_Customer_Reference__c=tempPaymentMethod.customerId,Opportunity__r=new Opportunity(Transaction_Id__c =groupId),Payment_Status__c=tempPaymentMethod.Status);
                                if(IsOrganization){
                                    temp.Account__r = new Account(External_ID_From_DMS__c= ExternalId);
                                }else{
                                    temp.contact__r = new Contact(External_Id__c = ExternalId);
                                }
                                CardSetupToInsert.put(tempPaymentMethod.PaymentMethodId,temp);
                                
                                paymentsToInsert.add(new npe01__OppPayment__c(DMS_DonationPayment_ID__c =groupId+'-'+index,Payment_Status__c =tempPaymentMethod.Status,Card_Details__r = new Income_Card_Payment__c(Payment_Method_Id__c=tempPaymentMethod.PaymentMethodId),npsp__Type__c='Setup',CurrencyIsoCode = Opp.currencyIsoCode,npe01__Opportunity__r = new Opportunity(Transaction_Id__c = groupId), Transaction_Type__c ='Setup',RecordTypeId=CardPaymentRecTypeId,npe01__Payment_Method__c = 'SEPA',npe01__Payment_Amount__c=0.00,npe01__Payment_Date__c=tempPaymentMethod.DateTimeCreated.date(),Gateway_Customer_Reference__c = tempPaymentMethod.CustomerId,npsp__Gateway_ID__c=tempPaymentMethod.CustomerId,npsp__Gateway_Payment_ID__c = tempPaymentMethod.PaymentMethodId,Order_ID__c = tempPaymentMethod.PaymentIntent,Transaction_ID__c = tempPaymentMethod.PaymentIntent));
                                index++;
                            }
                        }
                    }
                    
                }
            }
            
        }  
        }   
    }
}