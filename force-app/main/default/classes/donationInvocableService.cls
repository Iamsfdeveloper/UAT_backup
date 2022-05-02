/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 01-19-2022
 * @last modified by  : Iamsfdeveloper
Todo
2 Move Paymentplan to Recurring Donation Object - after May 2022
1 Create payment schedule from groupIndexMapToPaymentScheduleList for 10N and 30N  -  added in queueableMethodx
**/
public class donationInvocableService {
// final static variables
private static final string OPP_STAGE = 'Awaiting Payment Details';
private static final string DONATION_RECTYPE = 'Donation';
private static final string OPP_NAME = 'System Generated';
private static final string PP_TYPE = 'Payment Plan - Source';
private static final string SD_TYPE = 'Donation';
// static variables
private static string donorUnqiueKey; // Frist - Name,
private static string donationType; // Single (1) / Recurring (2)
public static  DateTime transactionTimeUtc;
private static string currencyIsoCode = 'GBP'; // Default GBP
private static string siteCode; 
private static Results response = new Results();
private static string basketCollectionId;
private static boolean exceptionOccurred= false;
Private Static String DefaultOrphanId;// = getDefaultOrphanId();
Private Static String requestJSON;
private Static String giftAidStatus = '';
Private Static Contact existingContact = null;
Private Static Id CampaignId;
private Static Map<String,Id> codeMapById = new Map<String,Id>();
private Static Map<String,Integer> groupIndexMapToPaymentIndex = new Map<String,Integer>();
private static List<Recurring_Donation_Batch_Errors__c> errorLogList = new List<Recurring_Donation_Batch_Errors__c>();
private Static Map<String,List<checkoutDataType.PaymentScheduleList>> groupIndexMapToPaymentScheduleList = new Map<String,List<checkoutDataType.PaymentScheduleList>>();
@InvocableMethod(label='New Donation')
public static List<Results> createDonation(List<Requests> request) {
    List<SObject> outputCollection = new List<SObject>();
    List<Results> responseWrapper = new List<Results>();
    
    for(HA_Payment_Schedule__c paymentschedules:[SELECT Id,Code__c, Frequency__c, Processing_Time__c, Start_Date__c, End_Date__c, Name FROM HA_Payment_Schedule__c Where Code__c != null and Is_Active__c=true and Is_External__c = true]){
        codeMapById.put(paymentschedules.Code__c,paymentschedules.Id);
    }
   List<checkoutDataType.paymentMethodDataType> PaymentMethods = new List<checkoutDataType.paymentMethodDataType>();
   Map<String,Opportunity> oppMapByGroupId; 
   // List<Donation__c> donationList = new List<Donation__c>();
//
            /*
                Donation__c mydonation  = new Donation__c( Basket_Details__c= JSON.serialize(nd.basket), Donor_Details__c = JSON.serialize(nd.supporter), Payment_Details__c = JSON.serialize(nd.PaymentMethods), Basket_Collection_Id__c =nd.BasketId, Donation_Date_Time__c =nd.transactionTimeUtc, Regional_Office_Code__c =nd.siteCode);
                insert mydonation;
            */
           
    try {
        for (Requests r : request) {
            for (checkoutDataType.NewDonationDataType nd : r.newDonation) {
                Contact c = new Contact();
                oppMapByGroupId = new  Map<String,Opportunity>();
                try{
                basketCollectionId = nd.BasketId;
                siteCode = nd.siteCode;
                transactionTimeUtc = nd.transactionTimeUtc;
                getCurrencyIsoCode(nd.basket);
                c = newContact(nd.supporter);
                oppMapByGroupId = newOpportunity(nd.basket);
                
                if (oppMapByGroupId != null) {
                    newAllocation(nd.basket,oppMapByGroupId);   
                    PaymentMethods.addAll(nd.PaymentMethods);
                    
                
                }                
                
                outputCollection.addAll(oppMapByGroupId.values());
                
                }catch(contactException ce){
                    errorLogList.add(HA_Logger.CreateErrorLogContactException(JSON.serialize(r.newDonation),basketCollectionId,ce.getMessage()));
                    continue;
                }
                
                catch(DonationException de){
                    errorLogList.add(HA_Logger.CreateErrorDonationException(c.Id,basketCollectionId,JSON.serialize(r.newDonation),de.getMessage()));
                    continue;
                }
            }
        }
        if(PaymentMethods.size()>0){
        donationInvocableService.PaymentSchedule ps = new donationInvocableService.PaymentSchedule(PaymentMethods,oppMapByGroupId,groupIndexMapToPaymentIndex,groupIndexMapToPaymentScheduleList);
        System.enqueueJob(ps);
        }
       
    } catch (Exception ex) {
        String exceptionCause = 'ExceptionName:'+ex.getTypeName()+' Line Number:'+ex.getLineNumber()+' Message:'+ex.getMessage()+' TrackStraceException:'+ex.getStackTraceString();
        response.errors = exceptionCause;
        errorLogList.add(HA_Logger.CreateErrorLog(JSON.serialize(request),basketCollectionId,exceptionCause));
    }
    if(errorLogList.size()>0){
    insert errorLogList;
    response.errorId = new Map<Id,Recurring_Donation_Batch_Errors__c>(errorLogList).keySet().toString();
    }
    response.outputCollection = outputCollection;
    responseWrapper.add(response);
    return responseWrapper;
}
private static void getCurrencyIsoCode(checkoutDataType.NewDonationBasketDataType b) {
    currencyIsoCode = b.currencyIsoCode;
}
// Requests input - Apex-defined data type
public class Requests {
    @InvocableVariable(required=true)
    public List<checkoutDataType.NewDonationDataType> newDonation;
}

// Result output array of sobject (Opps)
public class Results {
    public Results() {
        outputCollection = new List<SObject>();
    }
    
    @InvocableVariable public String errors;
    @InvocableVariable public String errorId;
    @InvocableVariable public List<SObject> outputCollection;
}

private static Contact newContact(checkoutDataType.NewDonationSupporterDataType d) {
    //Concatenate Address details for the Mailing Street
    String addressLine1 = d.addressLine1;
    String addressLine2 = d.addressLine2;
    String mailingStreet = addressLine1 + '\n' + addressLine2;
    // TODO: Why have we dropped address3?
    
    Contact c = new Contact();
    c.Salutation = d.title;
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
    c.Email = d.email;
    c.Unique_Donor_Id__c = donorUnqiueKey;
    if(d.GiftAidDeclared != 'Unspecified'){
        c.Gift_Aid_Status__c  = d.GiftAidDeclared;
        giftAidStatus = d.GiftAidDeclared;
    }
    if(String.isNotEmpty(d.nationalIdentificationNumber))
        c.National_Identification_Number__c = d.nationalIdentificationNumber;
    
    
    if(d.SubscribeSmsList){
        c.Can_Appeal_Via_Sms__c = 'Yes';
        c.SMS_Preference_declared__c = 'Via_Website';
    }
    //c.Has_Opted_Out_Of_SMS__c = (d.SubscribeSmsList ? false : true);
    c.CurrencyIsoCode = currencyIsoCode;
    
    try{
        If(d.IsOrganisation){
            Account Orgnaization = new Account(BillingStreet = mailingStreet,BillingCity = d.townCity,
                                                    BillingState = d.state, Phone = d.telephone,BillingPostalCode = d.postalCode,
                                                    BillingCountry = getCountryName(d.countryCode),Billing_Email__c = d.email, 
                                                    Name=d.organisationName,Regional_Office_Code__c =siteCode,
                                                    RecordTypeId=Schema.sObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId());
            insert Orgnaization;
            c.AccountId = Orgnaization.Id;
            c.RecordTypeId=Schema.sObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        }
        existingContact = getSingleContact();
        if(existingContact != null){
            c.Id = existingContact.Id;
            upsert c;
        }else{
            upsert c Unique_Donor_Id__c;
        }
    } catch (Exception ex) {
        
        String exceptionCause = 'ExceptionName:'+ex.getTypeName()+' Line Number:'+ex.getLineNumber()+' Message:'+ex.getMessage()+' TrackStraceException:'+ex.getStackTraceString();
        throw new contactException(exceptionCause);
    }
    return c;
}
private static Contact getSingleContact() {
   
    try{
        if(existingContact != null) return existingContact;
        existingContact =  [SELECT Id, Unique_Donor_Id__c, CurrencyIsoCode, AccountId FROM Contact WHERE Unique_Donor_Id__c  = :donorUnqiueKey limit 1];
    }catch(QueryException  ex){
        existingContact = null; 
    }
    return existingContact;
}
private static string getCountryName(String countryCode) {
    return [
        SELECT Country_Name__c
        FROM Country_Mapping__mdt
        WHERE Country_Code_alpha_3__c = :countryCode
    ]?.Country_Name__c;
}
private static Map<String,Opportunity> newOpportunity(checkoutDataType.NewDonationBasketDataType b) {
    Id donationrecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(DONATION_RECTYPE).getRecordTypeId();
    
    Contact c = getSingleContact();
   
    Decimal oppAmount = 0.00;
    Map<String,Opportunity> oppMapByDonationType = new Map<String,Opportunity>();
 
    for (checkoutDataType.donationGroup ig : b.ItemGroups) {
            //for (checkoutDataType.NewDonationBasketItemDataType i : ig.items) {
            String Campaign_Id = getWebsiteCampaignId('Website-'+siteCode);
            String key = ig.GroupId;
            Opportunity tempOpp = (oppMapByDonationType.get(key)!= null)?oppMapByDonationType.get(key): new Opportunity(Type=(ig.donationType =='SD')?SD_TYPE:PP_TYPE,Gift_Aid_Eligible_Status__c = giftAidStatus,Medium__c ='Online',AccountId = c.AccountId,Amount=0.00,npsp__Primary_Contact__c = c.Id,ContactId = c.Id,Name = OPP_NAME,RecordTypeId =donationrecTypeId,StageName = OPP_STAGE,CurrencyIsoCode = currencyIsoCode,Donation_Type__c=ig.donationType,Payment_Schedule__c = (codeMapById != null && codeMapById.get(ig.donationType) != null)?codeMapById.get(ig.donationType):null,website_code__c = siteCode,Regional_Office_Code__c=siteCode,Basket_Collection_Id__c=basketCollectionId);
            groupIndexMapToPaymentIndex.put(key,ig.PaymentMethodIndex);
            if(ig.donationType =='30N' || ig.donationType =='10N' || ig.donationType =='10D'){
                tempOpp.Recurring_Type__c ='Fixed';
                tempOpp.Number_of_Installments__c = (ig.donationType =='30N')?30:10;
                tempOpp.Type =SD_TYPE;
                if(ig.PaymentScheduleList.size()>0)
                groupIndexMapToPaymentScheduleList.put(ig.GroupId,ig.PaymentScheduleList);
            }
            tempOpp.CloseDate = transactionTimeUtc.date();
            tempOpp.Transaction_Id__c = ig.GroupId;
            tempOpp.CampaignId = Campaign_Id;
            tempOpp.Amount = ig.amount;
            
            oppMapByDonationType.put(key,tempOpp);
    }
    
    if(oppMapByDonationType.values().size()>0){
        upsert oppMapByDonationType.values() Transaction_Id__c;

    }
    

    return oppMapByDonationType;
}
private static void newAllocation(checkoutDataType.NewDonationBasketDataType b,Map<String,Opportunity> oppMapByDT) {
    List<npsp__Allocation__c> aList = new List<npsp__Allocation__c>();
    for (checkoutDataType.donationGroup ig : b.ItemGroups) {
          
        for (checkoutDataType.NewDonationBasketItemDataType i : ig.items) {
            Decimal ItemPercentage = ((i.Amount/ig.Amount)*100).setScale(2);
            System.debug('ItemPercentage===>'+ItemPercentage);
            //npsp__Percent__c = (totalPercentage>=0)?totalPercentage:null,
            String key = ig.GroupId;
            npsp__General_Accounting_Unit__c p = new npsp__General_Accounting_Unit__c( Donation_Item_Code__c = i.DonationItemCode);
            npsp__Allocation__c a = new npsp__Allocation__c(npsp__Opportunity__c = oppMapByDT.get(key).Id,
                                                            npsp__General_Accounting_Unit__r = p,Quantity__c =1,
                                                            npsp__Amount__c = i.Amount,
                                                            CurrencyIsoCode = currencyIsoCode,
                                                            Stipulation_Type__c = i.stipulationCode,
                                                            Notes__c = JSON.serialize(i)
                                                        );
            if(i.SchemeData.size()>0){
                for(checkoutDataType.SchemeData schemeDataObject:(List<checkoutDataType.SchemeData>)i.SchemeData){
                    if(schemeDataObject != null){
                        switch on schemeDataObject.ParameterCode{
                            when 'Name' {
                            a.Name__c = schemeDataObject.ParameterValue;
                            }
                            when 'DateOfBirth' {
                            a.Date_of_Birth__c  = Date.parse(schemeDataObject.ParameterValue);
                            }
                            when 'OrphanSalesForceId','OrphanId'{
                            if(schemeDataObject.ParameterValue instanceof Id)
                                    a.Orphan__c = schemeDataObject.ParameterValue;
                                else if(DefaultOrphanId != null)
                                    a.Orphan__c =DefaultOrphanId;
                                    
                            }
                        }
                    }
                    
                }   
            }
        aList.add(a);
     }// End of items
    }//End of Groups
try {
    if (!aList.isEmpty()) {
        insert aList;
    }
} catch (Exception ex) {
exceptionOccurred = true;
String exceptionCause = 'ExceptionName:'+ex.getTypeName()+' Line Number:'+ex.getLineNumber()+' Message:'+ex.getMessage()+' TrackStraceException:'+ex.getStackTraceString();
response.errors = exceptionCause;
npsp__General_Accounting_Unit__c p = new npsp__General_Accounting_Unit__c(Donation_Item_Code__c = 'DEFAULT-2021',npsp__Active__c = true);
upsert p Donation_Item_Code__c;
for(Integer j=0;j<aList.size();j++){
    aList[j].npsp__General_Accounting_Unit__c = p.Id; 
    aList[j].npsp__General_Accounting_Unit__r=p;
}
insert aList; 
}
}
private static Id getWebsiteCampaignId(String campaignCode){
    return [Select Id From Campaign Where Name =: campaignCode]?.Id;
}
/**
* @description 
* @author Iamsfdeveloper | 01-14-2021 
* @return Id 
**/
Private Static Id getDefaultOrphanId(){
        return [Select Id FROM Contact Where Sponsoree_ID__c='DefaultOrphan' and RecordType.developerName='Orphan' Limit 1]?.Id;
}
/*Create Payment Async Method*/
Private static void createPaymentRecords(List<checkoutDataType.paymentMethodDataType> paymentMethods,Map<String,Opportunity> OpportunityMap,Map<String,Integer> groupIndexMap2PaymentIndex,Map<String,List<checkoutDataType.PaymentScheduleList>> PaymentScheduleList ){
    Map<Integer,checkoutDataType.paymentMethodDataType> paymentMethodIndexMap = new Map<Integer,checkoutDataType.paymentMethodDataType>();
    try{
   
    List<npe01__OppPayment__c> paymentsToInsert = new List<npe01__OppPayment__c>();    
    List<Income_Direct_Debit__c> DirectDebitToInsert = new List<Income_Direct_Debit__c>();    
    Map<String,Income_Card_Payment__c> CardSetupToInsertMap = new Map<String,Income_Card_Payment__c>(); 
    List<Income_Card_Payment__c> CardSetupToInsert = new List<Income_Card_Payment__c>(); 
    Id CardPaymentRecTypeId = Schema.SObjectType.npe01__OppPayment__c.getRecordTypeInfosByDeveloperName().get('Card_Payment').getRecordTypeId();
    
    for(checkoutDataType.paymentMethodDataType pm:paymentMethods){ 
        paymentMethodIndexMap.put(pm.PaymentMethodIndex,pm);
    }
    for(String groupId:OpportunityMap.keySet()){
        checkoutDataType.paymentMethodDataType tempPaymentMethod = paymentMethodIndexMap.get(groupIndexMap2PaymentIndex.get(groupId));
        Opportunity Opp = OpportunityMap.get(groupId);
        if(tempPaymentMethod != null){
            System.debug('tempPaymentMethod===>'+tempPaymentMethod);
            switch on tempPaymentMethod.Id{
                when 'card'{
                    if(tempPaymentMethod.Status =='succeeded'){
                        switch on Opp.Donation_Type__c{
                            When 'SD'{
                                CardSetupToInsert.add(new Income_Card_Payment__c(First_Payment_Taken__c = true,Transaction_Source__c = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=tempPaymentMethod.PaymentIntent,First_Payment_Amount__c = opp.Amount,Payment_Method_Id__c =tempPaymentMethod.PaymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Gateway_Customer_Reference__c=tempPaymentMethod.customerId,Opportunity__c=opp.Id,Payment_Status__c=tempPaymentMethod.Status));
                                    //Income_Card_Payment__c temp = (CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) != null)?CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId): new Income_Card_Payment__c(First_Payment_Taken__c = true,Transaction_Source__c = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=tempPaymentMethod.PaymentIntent,First_Payment_Amount__c = opp.Amount,Payment_Method_Id__c =tempPaymentMethod.PaymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Gateway_Customer_Reference__c=tempPaymentMethod.customerId,Opportunity__c=opp.Id,Payment_Status__c=tempPaymentMethod.Status);
                                    //temp.First_Payment_Amount__c += opp.Amount;
                                    //CardSetupToInsert.put(tempPaymentMethod.PaymentMethodId,temp);
                                    //paymentsToInsert.add(new npe01__OppPayment__c(Card_Details__r = new Income_Card_Payment__c(Payment_Method_Id__c=tempPaymentMethod.PaymentMethodId),npsp__Type__c='Sale',CurrencyIsoCode = Opp.currencyIsoCode,npe01__Opportunity__c = Opp.Id,RecordTypeId=CardPaymentRecTypeId,Contact__c = opp.npsp__Primary_Contact__c,npe01__Payment_Method__c = 'Card Payment',npe01__Payment_Amount__c=Opp.Amount,npe01__Paid__c=true,npe01__Payment_Date__c=tempPaymentMethod.DateTimeCreated.date(),Gateway_Customer_Reference__c = tempPaymentMethod.CustomerId,npsp__Gateway_ID__c=tempPaymentMethod.CustomerId,npsp__Gateway_Payment_ID__c = tempPaymentMethod.PaymentMethodId,Order_ID__c = tempPaymentMethod.PaymentIntent,Transaction_ID__c = tempPaymentMethod.PaymentIntent));
                                
                            }
                            when 'RD'{
                                 CardSetupToInsert.add(new Income_Card_Payment__c(First_Payment_Taken__c = true,Transaction_Source__c = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=tempPaymentMethod.PaymentIntent,First_Payment_Amount__c = opp.Amount,Payment_Method_Id__c =tempPaymentMethod.PaymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Gateway_Customer_Reference__c=tempPaymentMethod.customerId,Opportunity__c=opp.Id,Payment_Status__c=tempPaymentMethod.Status));
                                 
                                    //Income_Card_Payment__c temp = (CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) != null)?CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId): new Income_Card_Payment__c(First_Payment_Taken__c = true,Transaction_Source__c = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=tempPaymentMethod.PaymentIntent,First_Payment_Amount__c = opp.Amount,Payment_Method_Id__c =tempPaymentMethod.PaymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Gateway_Customer_Reference__c=tempPaymentMethod.customerId,Opportunity__c=opp.Id,Payment_Status__c=tempPaymentMethod.Status);
                                    //temp.First_Payment_Amount__c += opp.Amount;
                                    //CardSetupToInsert.put(tempPaymentMethod.PaymentMethodId,temp);
                                
                            }
                            when '10N','30N'{
                                 CardSetupToInsert.add(new Income_Card_Payment__c(First_Payment_Taken__c = true,Transaction_Source__c = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=tempPaymentMethod.PaymentIntent,First_Payment_Amount__c = opp.Amount,Payment_Method_Id__c =tempPaymentMethod.PaymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Gateway_Customer_Reference__c=tempPaymentMethod.customerId,Opportunity__c=opp.Id,Payment_Status__c=tempPaymentMethod.Status));
                                 
                                //Income_Card_Payment__c temp = (CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) != null)?CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId): new Income_Card_Payment__c(First_Payment_Taken__c = true,Transaction_Source__c = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=tempPaymentMethod.PaymentIntent,First_Payment_Amount__c = opp.Amount,Payment_Method_Id__c =tempPaymentMethod.PaymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Gateway_Customer_Reference__c=tempPaymentMethod.customerId,Opportunity__c=opp.Id,Payment_Status__c=tempPaymentMethod.Status);
                                //CardSetupToInsert.put(tempPaymentMethod.PaymentMethodId,temp);
                                if(PaymentScheduleList.size()>0 && PaymentScheduleList.get(groupId) != null){
                                    Integer counter = (Opp.Donation_Type__c =='10N')?(10-PaymentScheduleList.get(groupId).size())+1:(30-PaymentScheduleList.get(groupId).size())+1;
                                for(checkoutDataType.PaymentScheduleList ps : PaymentScheduleList.get(groupId)){
                                    paymentsToInsert.add(new npe01__OppPayment__c(Payment_Description__c = 'Night-'+counter,Payment_Reference__c = HA_Utility.generateGUID(),Card_Details__r = new Income_Card_Payment__c(Payment_Method_Id__c=tempPaymentMethod.PaymentMethodId),npsp__Type__c='Sale',CurrencyIsoCode = Opp.currencyIsoCode,npe01__Opportunity__c = Opp.Id,RecordTypeId=CardPaymentRecTypeId,Contact__c = opp.npsp__Primary_Contact__c,npe01__Payment_Method__c = 'Card Payment',npe01__Payment_Amount__c=ps.Amount,npe01__Payment_Date__c=ps.Date_Time.date(),npsp__Authorized_Date__c=tempPaymentMethod.DateTimeCreated,Bank_Notes__c = JSON.serialize(ps),Gateway_Customer_Reference__c = tempPaymentMethod.CustomerId,npsp__Gateway_ID__c=tempPaymentMethod.CustomerId,npsp__Gateway_Payment_ID__c = tempPaymentMethod.PaymentMethodId));
                                }
                               }
                                
                            }
                            when '10D'{
                                //Income_Card_Payment__c temp = (CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) != null)?CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId): new Income_Card_Payment__c(First_Payment_Taken__c = true,Transaction_Source__c = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=tempPaymentMethod.PaymentIntent,First_Payment_Amount__c = opp.Amount,Payment_Method_Id__c =tempPaymentMethod.PaymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Gateway_Customer_Reference__c=tempPaymentMethod.customerId,Opportunity__c=opp.Id,Payment_Status__c=tempPaymentMethod.Status);
                                //CardSetupToInsert.put(tempPaymentMethod.PaymentMethodId,temp);
                               if(PaymentScheduleList.size()>0 && PaymentScheduleList.get(groupId) != null){
                                    Integer counter = (10-PaymentScheduleList.get(groupId).size())+1;
                                for(checkoutDataType.PaymentScheduleList ps : PaymentScheduleList.get(groupId)){
                                    paymentsToInsert.add(new npe01__OppPayment__c(Payment_Description__c = 'Day-'+Counter,Payment_Reference__c = HA_Utility.generateGUID(),Card_Details__r = new Income_Card_Payment__c(Payment_Method_Id__c=tempPaymentMethod.PaymentMethodId),npsp__Type__c='Sale',CurrencyIsoCode = Opp.currencyIsoCode,npe01__Opportunity__c = Opp.Id,RecordTypeId=CardPaymentRecTypeId,Contact__c = opp.npsp__Primary_Contact__c,npe01__Payment_Method__c = 'Card Payment',npe01__Payment_Amount__c=ps.Amount,npe01__Payment_Date__c=ps.Date_Time.date(),npsp__Authorized_Date__c=tempPaymentMethod.DateTimeCreated,Bank_Notes__c = JSON.serialize(ps),Gateway_Customer_Reference__c = tempPaymentMethod.CustomerId,npsp__Gateway_ID__c=tempPaymentMethod.CustomerId,npsp__Gateway_Payment_ID__c = tempPaymentMethod.PaymentMethodId));
                                }
                               }
                                
                            }
                        }
                    }
                }
                When 'bacs_debit'{
                        if(tempPaymentMethod.AcceptTerms==true && Opp.Donation_Type__c =='RD'){
                            Income_Direct_Debit__c dd =new Income_Direct_Debit__c(DD_Bank_Account_Name__c = tempPaymentMethod.AccountHolder,
                            CurrencyIsoCode = Opp.currencyIsoCode,DD_Bank_Account_Number__c = tempPaymentMethod.AccountNumber,
                            DD_Collection_Period__c = 'Monthly',DD_Collection_Day__c='1',DD_Status__c = 'New Instruction',Opportunity__c = opp.Id,
                            DD_Bank_Sort_Code__c = tempPaymentMethod.SortCode,DD_First_Collection_Amount__c = opp.Amount,DD_Start_Date__c=opp.closeDate,DD_End_Date__c = opp.CloseDate.addMonths(120),Contact__c=opp.npsp__Primary_Contact__c,Account__c=opp.accountId);  
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
                        //Income_Card_Payment__c temp = (CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId) != null)?CardSetupToInsert.get(tempPaymentMethod.PaymentMethodId): new Income_Card_Payment__c(First_Payment_Taken__c = true,Transaction_Source__c = tempPaymentMethod.Id, Transaction_Type__c ='Authorised',Authorisation_Date__c=tempPaymentMethod.DateTimeCreated,Order_ID__c=tempPaymentMethod.PaymentIntent,First_Payment_Amount__c = opp.Amount,Payment_Method_Id__c =tempPaymentMethod.PaymentMethodId, CurrencyIsoCode = Opp.currencyIsoCode,Gateway_Customer_Reference__c=tempPaymentMethod.customerId,Opportunity__c=opp.Id,Payment_Status__c=tempPaymentMethod.Status);
                        //CardSetupToInsert.put(tempPaymentMethod.PaymentMethodId,temp);
                    }
                }
                //No default 
            }

        }
    }
    if(CardSetupToInsert.size()>0){
        upsert CardSetupToInsert;
    }
    if(paymentsToInsert.size()>0){
        upsert paymentsToInsert;
    }
    if(DirectDebitToInsert.size()>0){
        upsert DirectDebitToInsert;
    }
    
}Catch(Exception ex){
    String exceptionCause = 'ExceptionName:'+ex.getTypeName()+' Line Number:'+ex.getLineNumber()+' Message:'+ex.getMessage()+' TrackStraceException:'+ex.getStackTraceString();
   
    for(String key : OpportunityMap.keySet()){
        String PaymentSchedulist = (PaymentScheduleList.keyset().contains(key))?JSON.serialize(PaymentScheduleList.get(key)):'';
        Recurring_Donation_Batch_Errors__c error=  new Recurring_Donation_Batch_Errors__c(Opportunity__c=OpportunityMap.get(key).Id,basketId__c = key,Payment_Details__c =JSON.serialize(paymentMethodIndexMap.get(groupIndexMap2PaymentIndex.get(key))),EventDetails__c = PaymentSchedulist,Error_Context__c=exceptionCause);
        errorLogList.add(error);
    }
    if(errorLogList.size()>0)
    insert errorLogList;
}
}
Public class PaymentSchedule implements   Queueable{
    private List<checkoutDataType.paymentMethodDataType> paymentMethods;
    private Map<String,Opportunity> OpportunityMap;
    private Map<String,Integer> groupIndexMapToPaymentIndex ;
    private Map<String,List<checkoutDataType.PaymentScheduleList>> PaymentScheduleList;
    public  PaymentSchedule(List<checkoutDataType.paymentMethodDataType> paymentMethods,Map<String,Opportunity> OpportunityMap,Map<String,Integer> groupIndexMapToPaymentIndex,Map<String,List<checkoutDataType.PaymentScheduleList>>  PaymentScheduleList ){
        this.paymentMethods = paymentMethods;
        this.OpportunityMap = OpportunityMap;
        this.groupIndexMapToPaymentIndex = groupIndexMapToPaymentIndex;
        this.PaymentScheduleList = PaymentScheduleList;
    }
    public void execute(QueueableContext context) {
        createPaymentRecords(paymentMethods,OpportunityMap,groupIndexMapToPaymentIndex,PaymentScheduleList);
    }
}  
/*

Public static void enqueuePaymentSchedule(Opportunity Donation,checkoutDataType.NewDonationBasketItemDataType Item){
    donationInvocableService.HA_PaymentSchedule_Queueable psq = new donationInvocableService.HA_PaymentSchedule_Queueable();
    psq.populatePaymentScheduleList(Donation,Item);
    System.enqueueJob(psq);
}
public class HA_PaymentSchedule_Queueable implements Queueable {
    public  checkoutDataType.NewDonationBasketItemDataType Item;
    public Opportunity Donation;
    public void populatePaymentScheduleList(Opportunity Donation,checkoutDataType.NewDonationBasketItemDataType Item){
        this.Donation = Donation;
        this.Item = Item;
    }
    public void execute(QueueableContext context) {
        ContentVersion conVer = new ContentVersion(Donation__c =Donation.Id,ContentLocation = 'S',PathOnClient = 'Payment_Schedule_List.txt',Title = 'Payment_Schedule_List',VersionData = Blob.valueOf(JSON.serialize(Item.PaymentScheduleList)));
        insert conVer;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();
        cdlToInsert.add(New ContentDocumentLink(LinkedEntityId = Donation.Id,ContentDocumentId = conDoc,shareType = 'V'));
        String GrpName = (Test.isRunningTest())?'Integration_Users_Test':'Integration_Users';
        cdlToInsert.add(New ContentDocumentLink(LinkedEntityId = [SELECT Id FROM CollaborationGroup Where Name =:GrpName].Id,ContentDocumentId = conDoc,shareType = 'V'));
        insert cdlToInsert;
        
        
    }
}
*/
public class contactException extends Exception{}
public class donationException extends Exception{}
public class allocationException extends Exception{}
}