/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 04-22-2022
 * @last modified by  : Iamsfdeveloper
**/
/**
* @description       : 
* @author            : Iamsfdeveloper
* @group             : 
* @last modified on  : 04-22-2022
* @last modified by  : Iamsfdeveloper
**/
public without sharing class StripeController {
    Public String PostalCode {get;set;}
    private final string PROCESSING_STAGE = 'In Payment Processing';
    //lexOrigin
    public string lexOrigin {get{ return URL.getOrgDomainUrl().toExternalForm().split('\\.')[0] + '.lightning.force.com';} set;}
    public string billing_details    {get;set;}
    public Boolean setupOnly {get;set;}
    public Boolean saveCard {get;set;}
    Public Boolean isDisabled {get;set;}
    public pageReference disableBtn(){
        If(ApexPages.hasMessages(ApexPages.severity.Error))
            isDisabled = true;
        System.debug('isDisabled ==>'+isDisabled);
        return null;
    }
    
    public Boolean getSingle() {
        return this.singleDonation;
    }
    
    
    public Boolean single = true;
    public Boolean singleDonation ;
    public String SERVICE_NAME;
    public String PUBLISHABLE_KEY;
    
    public Opportunity opp {get;set;}
    public paymentwrapper paymentWrapper {get;set;}
    
    public String getpublishableKey(){   
        return PUBLISHABLE_KEY;
    }
    public Id recordId { get; set;}
    public String customerReferenceField {get;set;}
    public StripeController(){
        this.isDisabled = true;
        PostalCode = 'never';
    }
    
    //To do Only Setup Payment Intent for Future payments
    //To do Webhook only for Payment Intent Succeeded
    
    public HTTPResponse createPaymentIntent(paymentwrapper intialObject) {
        HTTPCalloutService serviceCalloutConfig = getPaymentConfig();
        //EndPoint Change
        String PaymentIntentEnpointURL = (setupOnly)?serviceCalloutConfig.getEndpointURL()+'/v1/setup_intents':serviceCalloutConfig.getEndpointURL()+'/v1/payment_intents';
        serviceCalloutConfig.setEndpointURL(PaymentIntentEnpointURL);
        
        serviceCalloutConfig.setURLParameter('customer',intialObject.customerId);

        //if(intialObject.IdempotencyKey != null)
          //  serviceCalloutConfig.setHeaderParameter('idempotency-key',intialObject.IdempotencyKey);
        if(!setupOnly){
        serviceCalloutConfig.setURLParameter('amount',intialObject.getAmountValue());
        serviceCalloutConfig.setURLParameter('currency',intialObject.currencyIsoCode);
        
        if(!singleDonation)
             serviceCalloutConfig.setURLParameter('setup_future_usage','off_session');
        }
        //if(intialObject.currencyIsoCode !='EUR')
            serviceCalloutConfig.setURLParameter('payment_method_types[]','card');
       // else
          //  serviceCalloutConfig.setURLParameter('payment_method_types[]','card&payment_method_types[]=sepa_debit');
        /**meta Data  */
        serviceCalloutConfig.setURLParameter('metadata[donationid]',intialObject.donationId);
        serviceCalloutConfig.setURLParameter('metadata[cartid]',intialObject.cartId);
        serviceCalloutConfig.setURLParameter('metadata[donorid]',intialObject.donorId);
        serviceCalloutConfig.setURLParameter('metadata[internalwizard]','true');
        return makeCallout(serviceCalloutConfig);
        
    }
    public HTTPResponse updatePaymentIntent(String paymentIntentId,Map<string,String> urlParameters) {
        HTTPCalloutService serviceCalloutConfig = getPaymentConfig();
        //EndPoint Change
        String PaymentIntentEnpointURL = (setupOnly)?serviceCalloutConfig.getEndpointURL()+'/v1/setup_intents':serviceCalloutConfig.getEndpointURL()+'/v1/payment_intents';
        PaymentIntentEnpointURL +='/'+paymentIntentId;
        serviceCalloutConfig.setEndpointURL(PaymentIntentEnpointURL);
        serviceCalloutConfig.urlParametersMap = urlParameters;
        
        return makeCallout(serviceCalloutConfig);
        
    }
    
    public PageReference getCustomer() {
        if(ApexPages.currentPage() != null && ApexPages.currentPage().getParameters().get('Id') != null){
            this.recordId = (Id)ApexPages.currentPage().getParameters().get('Id');
            Schema.SObjectType sobjectType = recordId.getSObjectType();
            String sobjectName = sobjectType.getDescribe().getName();
            paymentWrapper = new paymentwrapper();
            Switch on sobjectName {
                
                when 'Opportunity'{
                    
                    customerReferenceField = null;
                    string Query  = 'Select EMIAmount__c,Amount,Id,guid__c,npsp__Primary_contact__r.Gateway_Customer_Id__c,Payment_Client_Secret__c,Payment_Details__c,PaymentIntentId__c,Transaction_Id__c,npsp__Primary_contact__r.MailingStreet,npsp__Primary_contact__r.MailingState,npsp__Primary_contact__r.MailingCity, DonationCode__c,currencyIsoCode,npsp__Primary_contact__r.MailingCountry,npsp__Primary_contact__c,npsp__Primary_contact__r.Name,npsp__Primary_contact__r.Email,Regional_Office_Code__c,npsp__Primary_contact__r.mailingPostalCode FROM Opportunity Where Id=:recordId';
                    opp = (Opportunity)Database.query(Query);
                    singleDonation = (opp.DonationCode__c =='SD');
                    setupOnly = (opp.DonationCode__c =='10N'|| opp.DonationCode__c =='30N'||opp.DonationCode__c =='10D');
                    //To do Allocated RegionalOffice Code From Donation Object
                    paymentWrapper.RegionalOfficeCode = opp.Regional_Office_Code__c;
                    if(opp.npsp__Primary_contact__r.mailingPostalCode == null)
                        PostalCode = 'auto';
                    /*Siwtch Configuration Based on Enviornment*/
                    SERVICE_NAME = (HA_Utility.IsSandbox)?paymentWrapper.RegionalOfficeCode+'_Test':paymentWrapper.RegionalOfficeCode+'_Live';
                    PUBLISHABLE_KEY = HTTPCalloutConfiguration__mdt.getInstance(SERVICE_NAME).publishable_Key__c;
                    /*Get the Custom Metadata */
                    paymentWrapper.donationId =  opp.Id;
                    paymentWrapper.Amount =(opp.DonationCode__c =='EMI')?opp.EMIAmount__c:opp.Amount;
                    paymentWrapper.currencyIsoCode = opp.currencyIsoCode;
                    //paymentWrapper.customerId = null;
                    paymentWrapper.donorName = opp.npsp__Primary_contact__r.name;
                    paymentWrapper.donorEmail = opp.npsp__Primary_contact__r.Email;
                    paymentWrapper.donorPostalCode = opp.npsp__Primary_contact__r.mailingPostalCode;
                    paymentWrapper.donorId = opp.npsp__Primary_contact__c;
                    PaymentWrapper.IdempotencyKey = opp.guid__c;
                    PaymentWrapper.cartId = opp.guid__c;
                    paymentWrapper.donorCountry = opp.npsp__Primary_contact__r.MailingCountry;
                    billing_details = generate_billingdetails(paymentWrapper.donorName,paymentWrapper.donorEmail,paymentWrapper.donorPostalCode,paymentWrapper.donorCountry,opp.npsp__Primary_contact__r.MailingStreet,opp.npsp__Primary_contact__r.MailingState,opp.npsp__Primary_contact__r.MailingCity);
                    paymentWrapper.customerId = (opp.npsp__Primary_contact__r.Gateway_Customer_Id__c !=null)?opp.npsp__Primary_contact__r.Gateway_Customer_Id__c: createCustomer(paymentWrapper.donorName,paymentWrapper.donorEmail,paymentWrapper.donorPostalCode,paymentWrapper.donorId);
                    HTTPResponse response = createPaymentIntent(paymentWrapper);
                    
                    System.debug('@@@@ Status==>'+response.getStatusCode());
                    System.debug('@@@@ Status==>'+response.getBody());
                   
                    Map<String,Object> responseMap =(Map<String,Object>)JSON.deserializeUntyped(response.getBody()); 
                    if(response.getStatusCode() ==200){
                        paymentWrapper.client_Secret = (String)responseMap.get('client_secret');
                        opp.Payment_Client_Secret__c =  paymentWrapper.client_Secret;
                        opp.paymentIntentId__c = (String)responseMap.get('id'); 
                        paymentWrapper.paymentintentId = (String)responseMap.get('id');
                        opp.StageName ='In Payment Processing' ;
                    }else{
                        paymentWrapper.client_Secret = opp.Payment_Client_Secret__c;
                        paymentWrapper.paymentintentId =  opp.paymentIntentId__c;
                    }
   
                    
                }
                when else{
                    
                    System.debug('No Configuration Found');
                }
            }
            
        }
        update opp;
        
        if(opp.npsp__Primary_contact__r.Gateway_Customer_Id__c ==null && paymentWrapper.customerId !=null && paymentWrapper.donorId != null && paymentWrapper.donorId.startsWithIgnoreCase('003')){
            update new Contact(Gateway_Customer_Id__c =paymentWrapper.customerId,Id=paymentWrapper.donorId);
            
        }
        
        return null;
    }
    
    @AuraEnabled
    public Static String confirmPaymentDetails(Boolean setupOnly,String paymentMethodId,String setupInentId,String RegionalOfficeCode){
        String SERVICE_NAME = (HA_Utility.IsSandbox)?RegionalOfficeCode+'_Test':RegionalOfficeCode+'_Live';
        system.debug('paymentMethodId==>'+paymentMethodId);
        system.debug('setupInentId==>'+setupInentId);
        system.debug('RegionalOfficeCode==>'+RegionalOfficeCode);
        HTTPCalloutService serviceCalloutConfig = new HTTPCalloutService(String.valueOf(SERVICE_NAME));
        String customerEnpointURL = (setupOnly)?serviceCalloutConfig.getEndpointURL()+'/v1/setup_intents/'+setupInentId+'/confirm':serviceCalloutConfig.getEndpointURL()+'/v1/payment_intents/'+setupInentId+'/confirm';
        serviceCalloutConfig.setEndpointURL(customerEnpointURL);
        serviceCalloutConfig.setURLParameter('payment_method',paymentMethodId);
        serviceCalloutConfig.setURLParameter('payment_method_options[card][moto]','true');
        HttpResponse res = serviceCalloutConfig.sendRequest();
        System.debug('confirmPaymentDetails Response ===>'+res.getBody());
        return res.getBody();
    }  
    public String createCustomer(String Name,String Email, String PostalCode, String recordId){
        String customerId= '';
        try{
        HTTPCalloutService serviceCalloutConfig = getPaymentConfig();
        String customerEnpointURL = serviceCalloutConfig.getEndpointURL()+'/v1/customers';
        serviceCalloutConfig.setEndpointURL(customerEnpointURL);
        serviceCalloutConfig.setHeaderParameter('idempotency-key',recordId);
        serviceCalloutConfig.setURLParameter('name',EncodingUtil.urlEncode(Name,'UTF-8'));
        if(Email != null)
            serviceCalloutConfig.setURLParameter('email',Email);
        if(PostalCode != null)
            serviceCalloutConfig.setURLParameter('address[postal_code]',EncodingUtil.urlEncode(PostalCode,'UTF-8'));
        serviceCalloutConfig.setURLParameter('metadata[contactid]',recordId);
         serviceCalloutConfig.setURLParameter('metadata[internalwizard]','true');
        HttpResponse res = makeCallout(serviceCalloutConfig);
        Map<String,Object> resMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
        customerId = resMap.get('id').toString();
        }catch(Exception ex){
            HTTPCalloutService serviceCalloutConfig = getPaymentConfig();
            String customerEnpointURL = serviceCalloutConfig.getEndpointURL()+'/v1/customers';
            serviceCalloutConfig.setEndpointURL(customerEnpointURL);
            serviceCalloutConfig.setURLParameter('name',EncodingUtil.urlEncode(Name,'UTF-8'));
            if(Email != null)
                serviceCalloutConfig.setURLParameter('email',EncodingUtil.urlEncode(Email,'UTF-8'));
            if(PostalCode != null)
                serviceCalloutConfig.setURLParameter('address[postal_code]',EncodingUtil.urlEncode(PostalCode,'UTF-8'));
            serviceCalloutConfig.setURLParameter('metadata[contactid]',recordId);
            serviceCalloutConfig.setURLParameter('metadata[internalwizard]','true');
            HttpResponse res = makeCallout(serviceCalloutConfig);
            Map<String,Object> resMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            customerId = resMap.get('id').toString();
            String errMsg = ex.getLineNumber()+' : '+ex.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));

        }
       return customerId;
    }
    
    
    public HTTPCalloutService getPaymentConfig(){
        HTTPCalloutService   serviceCalloutConfig = new HTTPCalloutService(String.valueOf(SERVICE_NAME));
        return serviceCalloutConfig;
    }
    
    public HTTPResponse makeCallout(HTTPCalloutService service) {
        HTTPResponse res =  service.sendRequest();
        return res;
        
        
    }
    public static String getCurrencySymbolFromIso(String Iso) {
        Map<String,String> currencyIsoCodeToSymbol = new Map<String,String>();
        currencyIsoCodeToSymbol.put('USD','$');
        currencyIsoCodeToSymbol.put('CAD','$');
        currencyIsoCodeToSymbol.put('EUR','€');
        currencyIsoCodeToSymbol.put('GBP','£');
        
        String currencySymbol = (currencyIsoCodeToSymbol.get(Iso)!=null)?currencyIsoCodeToSymbol.get(Iso):iso;
        
        return currencySymbol;
    }
    
    public string getbuttonLabel(){
        return  (singleDonation)?'Pay':' Pay & Setup';
    }
    Public class paymentwrapper{
        /*Generic wrapper class for Account, Contact Donation and My Donations for P2P*/
        public String RegionalOfficeCode {get;set;}
        public String IdempotencyKey {get;set;}
        public String donorName {get;set;}
        public String donorEmail {get;set;}
        public String donorPostalCode {get;set;}
        public String donorId {get;set;}
        public String postalCode {get;set;}
        public String donorCountry {get;set;}
        public Id donationId {get;set;}
        public String cartId {get;set;} 
        public String paymentintentId {get;set;}
        public String paymentMethodId {get;set;}
        Public string customerId {get;set;}
        public Decimal Amount {get;set;}
        public Map<String,string> allowedPaymentMethods {get;set;}
        public string  client_Secret {get;set;}
        public string  currencyIsoCode {get;set;}
        public string customerReferenceField {get;set;}
        public string  getcurrencyIsoSymbol(){
            return StripeController.getCurrencySymbolFromIso(currencyIsoCode);
        }
        public string getAmountValue(){
            Integer amount= Integer.valueOf(this.Amount * 100);
            return String.valueOf(amount);
        }
        
        
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getDonationDetails(string recordId){
        Map<String,Object> retVal = new Map<String,Object>();
        try {
            Opportunity opp = [SELECT Id,Donation_Type__c,CloseDate,Amount,StageName,guid__c, Transaction_Id__c,npsp__Primary_contact__r.MailingStreet,npsp__Primary_contact__r.MailingState,npsp__Primary_contact__r.MailingCity, DonationCode__c,currencyIsoCode,npsp__Primary_contact__r.MailingCountry,npsp__Primary_contact__c,npsp__Primary_contact__r.Name,npsp__Primary_contact__r.Email,Regional_Office_Code__c,npsp__Primary_contact__r.mailingPostalCode FROM Opportunity Where Id=:recordId limit 1];
            retVal.put('opp',opp);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return retVal;
    }
    @AuraEnabled    
    Public Static void savePaymentDetails(string cardPaymentDetail,String paymentObject){
        try{
            
            Income_Card_Payment__c cardPayment = (Income_Card_Payment__c)JSON.deserialize(cardPaymentDetail,Income_Card_Payment__c.class);
            npe01__OppPayment__c Payment = null;
            if(paymentObject != '' && String.isNotEmpty(paymentObject)){
                Payment = (npe01__OppPayment__c)JSON.deserialize(paymentObject,npe01__OppPayment__c.class);
                System.debug('Payment'+Payment.CURRENCYISOCODE);
            }
            createCardDetails queueable = new createCardDetails(cardPayment,Payment);
            System.enqueueJob(queueable);
        }catch(Exception ex){
            insert HA_Logger.CreateErrorLog(JSON.serialize(cardPaymentDetail),JSON.serialize(paymentObject),ex.getStackTraceString()+' - '+ex.getMessage());
        }
        
    }
    public String generate_billingdetails(String Name,String Email,String postalCode,string Country,String Street,String State,String City){
        JSONGenerator gen  = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('billing_details');
        gen.writeStartObject();
        try{
            gen.writeStringField('name',EncodingUtil.urlEncode(Name,'UTF-8'));
            if(String.isNotBlank(Email))
                gen.writeStringField('email',Email);
            else
                gen.writeStringField('email','donor.care.carrs.rd@gmail.com');
        gen.writeStringField('phone','never');
        gen.writeFieldName('address');
        gen.writeStartObject();
        gen.writeStringField('city',(String.isBlank(City))?'never':EncodingUtil.urlEncode(City,'UTF-8'));
        gen.writeStringField('line1',(String.isBlank(Street))?'never':EncodingUtil.urlEncode(Street,'UTF-8'));
        gen.writeStringField('line2','never');
        gen.writeStringField('state',(String.isBlank(State))?'never':EncodingUtil.urlEncode(State,'UTF-8'));
        gen.writeStringField('postal_code',(String.isBlank(postalCode))?'never':EncodingUtil.urlEncode(postalCode,'UTF-8'));
        String CountryISOCode = HA_Utility.getCountryISOCode(Country);
        gen.writeStringField('country',(String.isBlank(CountryISOCode))?paymentWrapper.RegionalOfficeCode:CountryISOCode);
        gen.writeEndObject();//end Address Object
        gen.writeEndObject(); //end Billing_Details Object
        gen.writeEndObject(); //Main Object End
        gen.close();
       
        }catch(Exception ex){
           
            String errMsg = ex.getLineNumber()+' : '+ex.getMessage();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));
        }
         return gen.getAsString();
    }
    public class createCardDetails implements Queueable{
        Income_Card_Payment__c cardPayment;
        npe01__OppPayment__c Payment;
        public createCardDetails(Income_Card_Payment__c cardPayment,npe01__OppPayment__c Payment ){
            this.cardPayment = cardPayment;
            this.Payment= Payment;            
        }
        public void execute(QueueableContext context){
            try{
            System.debug('cardPayment==>'+cardPayment);
            upsert cardPayment Payment_Method_Id__c;
            if(Payment != null){
                Payment.card_Details__c = cardPayment.Id;
                upsert Payment; 
                
            }
            }catch(Exception ex){
                insert HA_Logger.CreateErrorLog(JSON.serialize(cardPayment),JSON.serialize(Payment),'InternalWizard : '+ex.getStackTraceString()+' - '+ex.getMessage());
            }
            
        }
    }
}