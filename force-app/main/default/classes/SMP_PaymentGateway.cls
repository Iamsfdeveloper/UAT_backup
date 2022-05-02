public with sharing class SMP_PaymentGateway {
    public static final String MESSAGE_CALLOUTERROR = 'Error Calling SmarterPay Service.'; 
    public static final SmarterPay_Payment_Config__c paymentConfig = SmarterPay_Payment_Config__c.getInstance();

    public enum PaymentType {Ecommerce, MOTO, DeferredEcommerce, DeferredMOTO, AuthenticateAuthoriseEcommerce, AuthenticateAuthoriseMOTO}
    public enum Gateway {SAGEPAYPI, GLOBALPAYMENTS, STRIPE}
    
    /**
     * Used to generate any standard card payment/setup url including immediate and deferred transaction types.
     * @param Gateway paymentGateway Enum representing the payment gateway to be used in the transaction. Stripe, SagePay, GlobalPayments etc. See enum definition for options.
     * @param PaymentType paymentType The type of transaction to make. For example an immediate 'MOTO' or 'Ecommerce' payment, or a delayed payment such as 'DeferredEcommerce'. See enum definition for options.
     * @param Payment paymentIn The payment wrapper which defines the details of the transaction. Billing details, etc.
     */
    public static String generateCardPaymentURL(Payment paymentIn, Gateway paymentGateway, PaymentType paymentType) {
        GatewaySettings settings = getGatewaySettings(paymentGateway);

        System.debug('#### paymentIn: ' + paymentIn);
        System.debug('#### paymentConfig: ' + paymentConfig);
        System.debug('#### settings: ' + settings);

        paymentIn.PaymentType = String.valueOf(PaymentType);
        paymentIn.PaymentGateway = String.valueOf(paymentGateway);

        return generatePaymentUrl(paymentIn, settings);
    }

    private static String generatePaymentUrl(Payment thePayment, GatewaySettings settings){
        String url = '';

        switch on thePayment.PaymentType {
            when 'MOTO' {
                url = settings.motoURL;
            }   
            when 'Ecommerce' {
                url = settings.ecomURL;
            }
            when 'DeferredEcommerce' {
                url = settings.deferredEcommerceURL;
            }
            when 'DeferredMOTO' {
                url = settings.deferredMOTOURL;
            }
            when 'AuthenticateAuthoriseEcommerce' {
                url = settings.authenticateAuthoriseEcommerceURL;
            }
            when 'AuthenticateAuthoriseMOTO' {
                url = settings.authenticateAuthoriseMOTOURL;
            }
            when else {
                //return '';
            }
        }

        if(String.isBlank(thePayment.APIKey))
        {
            System.debug('#### blank ');
        }
        
        System.debug('#### settings.APIKey ' + settings.APIKey);
        
        thePayment.APIKey = String.isBlank(thePayment.APIKey) ? settings.APIKey : thePayment.APIKey;
        thePayment.incomeusername = String.isBlank(thePayment.incomeusername) ? settings.SMPUsername : thePayment.incomeusername;


        System.debug('#### thePayment.APIKey ' + thePayment.APIKey);

        String jsonString = JSON.serialize(thePayment);

        System.debug('#### jsonString: ' + jsonString);

        Blob jsonBlob = Blob.valueOf(jsonString);

        System.debug('#### jsonBlob: ' + jsonBlob);

        String encodedJSON = EncodingUtil.base64Encode(jsonBlob);        
        return url + '?payload=' + encodedJSON;
    }

    public static RepeatPaymentResponse doRepeatPayment(Gateway paymentGateway, RepeatPayment repeatPaymentIn) {
        GatewaySettings settings = getGatewaySettings(paymentGateway);

        repeatPaymentIn.APIKey = String.isBlank(repeatPaymentIn.APIKey) ? settings.APIKey : repeatPaymentIn.APIKey;
        repeatPaymentIn.incomeusername = String.isBlank(repeatPaymentIn.incomeusername) ? settings.SMPUsername : repeatPaymentIn.incomeusername;
        repeatPaymentIn.PaymentGateway = String.valueOf(paymentGateway);

        String jsonString = JSON.serialize(repeatPaymentIn);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
       
        request.setEndpoint(settings.repeatURL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(jsonString);

        System.Debug('#### JSON: '+request.getBody());

        HttpResponse response = http.send(request);

        System.debug('#### Response: ' + response);
        System.debug('#### Response Body: ' + response.getBody());
        System.debug('#### Response Status: ' + response.getStatus());
        System.debug('#### Response Status Code: ' + response.getStatusCode());
        
        RepeatPaymentResponse parsedResponse;

        // Parse the JSON response
        if(response.getStatusCode() == 200)
        {
            parsedResponse = (RepeatPaymentResponse) System.JSON.deserialize(response.getBody(), RepeatPaymentResponse.class);
        }
        else
        {
            parsedResponse = new RepeatPaymentResponse();
            parsedResponse.status = 'error';
            parsedResponse.message = MESSAGE_CALLOUTERROR + ' ' + response.getStatusCode() + ' ' + response.getStatus();
        }

        return parsedResponse;
    }

    public static RefundResponse doRefund(Gateway paymentGateway, Refund refundIn) {
        System.debug('#### Starting doRefund');

        GatewaySettings settings = getGatewaySettings(paymentGateway);

        refundIn.APIKey = String.isBlank(refundIn.APIKey) ? settings.APIKey : refundIn.APIKey;
        refundIn.incomeusername = String.isBlank(refundIn.incomeusername) ? settings.SMPUsername : refundIn.incomeusername;
        refundIn.PaymentGateway = String.valueOf(paymentGateway);

        String jsonString = JSON.serialize(refundIn);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
       
        request.setEndpoint(settings.refundURL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(jsonString);

        System.Debug('#### JSON: '+request.getBody());

        HttpResponse response = http.send(request);

        System.debug('#### Response: ' + response);
        System.debug('#### Response Body: ' + response.getBody());
        System.debug('#### Response Status: ' + response.getStatus());
        System.debug('#### Response Status Code: ' + response.getStatusCode());

        RefundResponse parsedResponse;

        // Parse the JSON response
        if(response.getStatusCode() == 200)
        {
            parsedResponse = (RefundResponse) System.JSON.deserialize(response.getBody(), RefundResponse.class);
        }
        else
        {
            parsedResponse = new RefundResponse();
            parsedResponse.status = 'error';
            parsedResponse.message = MESSAGE_CALLOUTERROR + ' ' + response.getStatusCode() + ' ' + response.getStatus();
        }

        return parsedResponse;
    }

    public static DeferredReleaseResponse doDeferredRelease(Gateway paymentGateway, DeferredRelease deferredReleaseIn) {
        GatewaySettings settings = getGatewaySettings(paymentGateway);

        deferredReleaseIn.APIKey = String.isBlank(deferredReleaseIn.APIKey) ? settings.APIKey : deferredReleaseIn.APIKey;
        deferredReleaseIn.incomeusername = String.isBlank(deferredReleaseIn.incomeusername) ? settings.SMPUsername : deferredReleaseIn.incomeusername;
        deferredReleaseIn.PaymentGateway = String.valueOf(paymentGateway);

        String jsonString = JSON.serialize(deferredReleaseIn);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
       
        request.setEndpoint(settings.deferredReleaseURL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(jsonString);

        System.Debug('#### JSON: '+request.getBody());

        HttpResponse response = http.send(request);

        System.debug('#### Response: ' + response);
        System.debug('#### Response Body: ' + response.getBody());
        System.debug('#### Response Status: ' + response.getStatus());
        System.debug('#### Response Status Code: ' + response.getStatusCode());

        DeferredReleaseResponse parsedResponse;

        // Parse the JSON response
        if(response.getStatusCode() == 200)
        {
            parsedResponse = (DeferredReleaseResponse) System.JSON.deserialize(response.getBody(), DeferredReleaseResponse.class);
        }
        else
        {
            parsedResponse = new DeferredReleaseResponse();
            parsedResponse.status = 'error';
            parsedResponse.message = MESSAGE_CALLOUTERROR + ' ' + response.getStatusCode() + ' ' + response.getStatus();
        }

        return parsedResponse;
    }

    public static AuthenticateAuthoriseReleaseResponse doAuthenticateAuthoriseRelease(Gateway paymentGateway, AuthenticateAuthoriseRelease authenticateAuthoriseReleaseIn) {
        GatewaySettings settings = getGatewaySettings(paymentGateway);

        authenticateAuthoriseReleaseIn.APIKey = String.isBlank(authenticateAuthoriseReleaseIn.APIKey) ? settings.APIKey : authenticateAuthoriseReleaseIn.APIKey;
        authenticateAuthoriseReleaseIn.incomeusername = String.isBlank(authenticateAuthoriseReleaseIn.incomeusername) ? settings.SMPUsername : authenticateAuthoriseReleaseIn.incomeusername;
        authenticateAuthoriseReleaseIn.PaymentGateway = String.valueOf(paymentGateway);

        String jsonString = JSON.serialize(authenticateAuthoriseReleaseIn);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
       
        request.setEndpoint(settings.authenticateAuthoriseReleaseURL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(jsonString);

        System.Debug('#### JSON: '+request.getBody());

        HttpResponse response = http.send(request);

        System.debug('#### Response: ' + response);
        System.debug('#### Response Body: ' + response.getBody());
        System.debug('#### Response Status: ' + response.getStatus());
        System.debug('#### Response Status Code: ' + response.getStatusCode());

        AuthenticateAuthoriseReleaseResponse parsedResponse;

        // Parse the JSON response
        if(response.getStatusCode() == 200)
        {
            parsedResponse = (AuthenticateAuthoriseReleaseResponse) System.JSON.deserialize(response.getBody(), AuthenticateAuthoriseReleaseResponse.class);
        }
        else
        {
            parsedResponse = new AuthenticateAuthoriseReleaseResponse();
            parsedResponse.status = 'error';
            parsedResponse.message = MESSAGE_CALLOUTERROR + ' ' + response.getStatusCode() + ' ' + response.getStatus();
        }

        return parsedResponse;
    }

    public static Gateway getGatewayEnumByPaymentVendor(String paymentVendor)
    {
        if(paymentVendor == 'Globalpay'){
            return Gateway.GLOBALPAYMENTS;
        }
        else if(paymentVendor == 'SagePayPi'){
            return Gateway.SAGEPAYPI;
        }
        else if(paymentVendor == 'Stripe'){
            return Gateway.STRIPE;
        }

        return null;
    }

    private static GatewaySettings getGatewaySettings(Gateway paymentGateway)
    {
        GatewaySettings settings = new GatewaySettings();

        settings.APIKey = paymentConfig.APIKey__c;
        settings.SMPUsername = paymentConfig.SmarterPay_User_Name__c;

        settings.motoURL = paymentConfig.Standard_MOTO__c;
        settings.ecomURL = paymentConfig.Standard_Ecommerce__c;
        settings.repeatURL = paymentConfig.Standard_Repeat__c;
        settings.refundURL = paymentConfig.Standard_Refund__c;
        settings.deferredMOTOURL = paymentConfig.Standard_Deferred_Capture_MOTO__c;
        settings.deferredEcommerceURL = paymentConfig.Standard_Deferred_Capture_Ecommerce__c;
        settings.deferredReleaseURL = paymentConfig.Standard_Deferred_Release__c;
        settings.authenticateAuthoriseMOTOURL = paymentConfig.Standard_Authenticate_Capture_MOTO__c;
        settings.authenticateAuthoriseEcommerceURL = paymentConfig.Standard_Authenticate_Capture_Ecommerce__c;
        settings.authenticateAuthoriseReleaseURL = paymentConfig.Standard_Authenticate_Release__c;

        return settings;
    }
    
    public static Date getNextRepeatPaymentDate(String stretchIn, String frequencyIn, String collectionDayIn, Date lastPaymentDateIn, Date endDate)
    {
        System.debug('#### getNextRepeatPaymentDate');
        System.debug('#### stretchIn: ' + stretchIn);
        System.debug('#### frequencyIn: ' + frequencyIn);
        System.debug('#### collectionDayIn: ' + collectionDayIn);
        System.debug('#### lastPaymentDateIn: ' + lastPaymentDateIn);
        System.debug('#### endDate: ' + endDate);

        Date nextPaymentDate = Date.Today();

        Integer stretch = Integer.valueOf(stretchIn);
    
        if (frequencyIn == 'Monthly')
        {
            Integer rpCollectionDayInteger = Integer.valueOf(collectionDayIn);

            if(lastPaymentDateIn.day() != rpCollectionDayInteger)
            {
                System.debug('#### Returning payment day to selected collection day.');

                Integer lastDayOfMonth = lastPaymentDateIn.addMonths(1).toStartOfMonth().addDays(-1).day();

                if(rpCollectionDayInteger <= lastDayOfMonth){
                    nextPaymentDate = Date.newInstance(lastPaymentDateIn.year(), lastPaymentDateIn.month(), rpCollectionDayInteger);
                }
            }

            nextPaymentDate = nextPaymentDate.addMonths(stretch);
        }
        else if (frequencyIn == 'Weekly')
        {
            nextPaymentDate = nextPaymentDate.AddDays(stretch * 7);
        }
        else if (frequencyIn == 'Daily')
        {
            nextPaymentDate = nextPaymentDate.AddDays(stretch * 1);
        }

        if (endDate != null)
        {
            if (nextPaymentDate > endDate)
            {                        
                nextPaymentDate = null;
            }
        }

        System.debug('#### nextPaymentDate: ' + nextPaymentDate);

        return nextPaymentDate;
    }

    public with sharing class Payment{
        public String APIKey {get; set;}
        public String PaymentType {get; set;}
        public String PaymentGateway {get; set;}
        
        public String vendorname {get; set;}
        public String incomeusername {get; set;}
        public String ownerID {get; set;}
        public String customerFirstName {get; set;}
        public String customerLastName {get; set;}

        public String firstReferenceId {get; set;}
        public String firstReferenceName {get; set;}
        public String firstReferenceObject {get; set;}
        public String firstReferenceObjectName {get; set;}
        public String secondReferenceId {get; set;}
        public String secondReferenceObject {get; set;}
        public String secondReferenceObjectName {get; set;}

        public String billingAddressOne {get; set;}
        public String billingAddressTwo {get; set;}
        public String billingAddressThree {get; set;}
        public String billingAddressCity {get; set;}
        public String billingAddressState {get; set;}
        public String billingAddressPostalCode {get; set;}
        public String billingAddressCountry {get; set;}

        public String shippingAddressOne {get; set;}
        public String shippingAddressTwo {get; set;}
        public String shippingAddressThree {get; set;}
        public String shippingAddressCity {get; set;}
        public String shippingAddressState {get; set;}
        public String shippingAddressPostalCode {get; set;}
        public String shippingAddressCountry {get; set;}

        public String internalPaymentDescription {get; set;}
        public String customerPaymentReference {get; set;}

        public String currencyCode {get; set;}
        public Decimal amount {get; set;}

        public String emailAddress {get; set;}

        public String recordtypeid {get; set;}

        public Boolean rpenabled {get; set;}
        public Decimal rpamount {get; set;}
        public String rpenddate {get; set;}
        public String rpfrequency {get; set;}
        public String rpnextpaymentdate {get; set;}
        public String rpstartdate {get; set;}
        public String rpstretch {get; set;}
        public String rpcollectionday {get; set;}
        public String rpdescription {get; set;}
    }

    public with sharing class RepeatPayment{
        public String APIKey {get; set;}
        public Boolean isAsync {get; set;}
        public String PaymentGateway {get; set;}

        public String incomeUserName {get; set;}
        public String incomeCardPaymentId {get; set;}
        public Decimal amount {get; set;}
        public String currencyCode {get; set;}

        public String internalPaymentDescription {get; set;}
        public String customerPaymentReference {get; set;}

        public String customerId {get; set;} // Stripe
        
        public String custId {get; set;} // GlobalPayments
        public String payId {get; set;} // GlobalPayments
    }

    public with sharing class Refund{
        public String APIKey {get; set;}
        public Boolean isAsync {get; set;}
        public String PaymentGateway {get; set;}

        public String incomeUserName {get; set;}
        public String incomeCardPaymentId {get; set;}
        public Decimal amount {get; set;}
        public String currencyCode {get; set;}

        public String internalPaymentDescription {get; set;}
        public String customerPaymentReference {get; set;}

        public String chargeId {get; set;} // Stripe

        public string orderId; // GlobalPayments
        public string paymentsReference; // GlobalPayments
        public string authCode; // GlobalPayments
        public string rebatePassword; // GlobalPayments
    }

    public with sharing class DeferredRelease{
        public String APIKey {get; set;}
        public Boolean isAsync {get; set;}
        public String PaymentGateway {get; set;}

        public String incomeUserName {get; set;}
        public String incomeCardPaymentId {get; set;}
        public Decimal amount {get; set;}
        public String currencyCode {get; set;}
        
        public String internalPaymentDescription {get; set;}
        public String customerPaymentReference {get; set;}

        public String customerId {get; set;} // Stripe
        
        public String custId {get; set;} // GlobalPayments
        public String payId {get; set;} // GlobalPayments
    }

    public with sharing class AuthenticateAuthoriseRelease{
        public String APIKey {get; set;}
        public Boolean isAsync {get; set;}
        public String PaymentGateway {get; set;}

        public String incomeUserName {get; set;}
        public String incomeCardPaymentId {get; set;}
        public Decimal amount {get; set;}
        public String currencyCode {get; set;}
        
        public String internalPaymentDescription {get; set;}
        public String customerPaymentReference {get; set;}

        public String customerId {get; set;} // Stripe
        
        public String custId {get; set;} // GlobalPayments
        public String payId {get; set;} // GlobalPayments
    }

    public with sharing class RepeatPaymentResponse{
        public String status {get; set;}
        public String message {get; set;}
        public ResponseData data;
    }

    public with sharing class DeferredReleaseResponse{
        public String status {get; set;}
        public String message {get; set;}
        public ResponseData data;
    }

    public with sharing class AuthenticateAuthoriseReleaseResponse{
        public String status {get; set;}
        public String message {get; set;}
        public ResponseData data;
    }

    public with sharing class RefundResponse{
        @AuraEnabled public String status {get; set;}
        @AuraEnabled public String message {get; set;}
        @AuraEnabled public ResponseData data;
    }

    public class ResponseData {
        @AuraEnabled public String incomeCardPaymentHistoryId;
    }

    public with sharing class GatewaySettings{
        public String APIKey {get; set;}
        public String SMPUsername {get; set;}
        public String motoURL {get; set;}
        public String ecomURL {get; set;}
        public String repeatURL {get; set;}
        public String refundURL {get; set;}
        public String deferredMOTOURL {get; set;}
        public String deferredEcommerceURL {get; set;}
        public String deferredReleaseURL {get; set;}
        public String authenticateAuthoriseMOTOURL {get; set;}
        public String authenticateAuthoriseEcommerceURL {get; set;}
        public String authenticateAuthoriseReleaseURL {get; set;}
    }
}