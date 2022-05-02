/**
* @File Name          : NewPaymentService.cls
* @Description        :
* @Author             : agentgill
* @Group              :
* @Last Modified By   : Iamsfdeveloper
* @Last Modified On   : 01-16-2022
* @Modification Log   :
* Ver       Date            Author                 Modification
* 1.0    12/06/2020   agentgill     Initial Version
* 
cus_HWf3JbnOa8rmEA -> This should give you a failed payment with insufficient funds.
cus_HWf27lulp9z62i -> This should give you a successful payment everytime.

**Execute Anonymous Apex with Currently Selected Text**

// Start
NewRecurringDonationService myBatch = new NewRecurringDonationService();
Database.executeBatch(myBatch, 100);
// End

**/
public with sharing class NewPaymentService {
    private static final String SERVICE_NAME = 'SPRepeatPayment';
    private static PaymentIntent pi;
    /**
* @description Request Payment
* @author agentgill | 6/22/2020
* @param s
* @param guid
* @return Boolean
**/
    public Boolean requestPayment(Sobject s, String guid) {
        Opportunity opp = (Opportunity)s;
        string serviceName = (opp.npe03__Recurring_Donation__r.Regional_Code__c != null)?opp.npe03__Recurring_Donation__r.Regional_Code__c:SERVICE_NAME;
        Map<String, String> paymentConfig = loadConfig(serviceName);
        pi = new PaymentIntent();
        pi.APIKey = paymentConfig.get('apiKey');
        pi.incomeUserName = paymentConfig.get('incomeUserName');
        pi.paymentGateway = paymentConfig.get('paymentGateway');
        pi.isAsync = true; // Calling service is hardcoded to async
        pi.internalPaymentDescription = guid;
        pi.amount = (Decimal) opp.Amount;
        pi.currencyCode = opp.CurrencyIsoCode;
        pi.incomeCardPaymentId = opp.npe03__Recurring_Donation__r.Card_Payment_Detail__c;
        
        // Seed
        pi.customerId = (String) opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c;
        HTTPResponse res = makeCallout();
        if (res.getStatusCode() == 202) {
            return true;
        } else {
            return false;
        }
    }
    public HTTPResponse getPaymentStatus(String paymentId,Opportunity opp) {
        String serviceName =  (HA_Utility.IsSandbox)?opp.npe03__Recurring_Donation__r.Regional_Office_Code__c+'_Test':opp.npe03__Recurring_Donation__r.Regional_Office_Code__c +'_Live';
        HTTPCalloutService serviceCalloutConfig = new HTTPCalloutService(ServiceName);
        String PaymentIntentEnpointURL = serviceCalloutConfig.getEndpointURL()+'/v1/payment_intents/'+paymentId;
        serviceCalloutConfig.setEndpointURL(PaymentIntentEnpointURL);
        HTTPResponse res = makeCallout(serviceCalloutConfig);
        return res;
    }
    public HTTPResponse requestPayment(String guid,Opportunity opp) {
        string serviceName =  (HA_Utility.IsSandbox)?opp.npe03__Recurring_Donation__r.Regional_Office_Code__c+'_Test':opp.npe03__Recurring_Donation__r.Regional_Office_Code__c +'_Live';
        HTTPCalloutService serviceCalloutConfig = new HTTPCalloutService(ServiceName);
        String PaymentIntentEnpointURL = serviceCalloutConfig.getEndpointURL()+'/v1/payment_intents';
        serviceCalloutConfig.setEndpointURL(PaymentIntentEnpointURL);
        System.debug('intialObject.customerId'+opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c);
        
        serviceCalloutConfig.setURLParameter('customer',opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c);
        
        serviceCalloutConfig.setHeaderParameter('idempotency-key',guid);
        Integer amount= Integer.valueOf(opp.amount * 100);
        serviceCalloutConfig.setURLParameter('amount',String.valueOf(Amount));
        serviceCalloutConfig.setURLParameter('currency',opp.currencyIsoCode);
        serviceCalloutConfig.setURLParameter('payment_method',opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c);
        serviceCalloutConfig.setURLParameter('off_session','true');
        serviceCalloutConfig.setURLParameter('confirm','true');
        if(opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c != null)
            serviceCalloutConfig.setURLParameter('payment_method_types[]',opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c);
        serviceCalloutConfig.setURLParameter('metadata[donationid]',opp.Id);
        serviceCalloutConfig.setURLParameter('metadata[cartid]',guid);
        serviceCalloutConfig.setURLParameter('metadata[donorid]',opp.npsp__Primary_contact__c);
        HTTPResponse res = makeCallout(serviceCalloutConfig);
        return res;
    }
 	public HTTPResponse requestPayment(String gatewayProvider,String guid,Opportunity opp) {
        HTTPResponse res = null;
        switch on gatewayProvider{
            when 'Oppwa'{
                string serviceName =  (HA_Utility.IsSandbox)?opp.npe03__Recurring_Donation__r.Regional_Office_Code__c+'_OPPWA_Test':opp.npe03__Recurring_Donation__r.Regional_Office_Code__c +'_OPPWA_Live';
        		HTTPCalloutService serviceCalloutConfig = new HTTPCalloutService(ServiceName);
                String PaymentIntentEnpointURL = serviceCalloutConfig.getEndpointURL()+'/v1/registrations/'+opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c+'/payments';
                serviceCalloutConfig.setEndpointURL(PaymentIntentEnpointURL);
                Map<String,String> requestBody = new Map<String,String>();
                decimal amount = opp.amount.setScale(2);
                requestBody.put('amount',String.valueOf(amount));
                requestBody.put('currency',opp.currencyIsoCode);
                requestBody.put('paymentType','PA');
                requestBody.put('standingInstruction.mode','REPEATED');
                requestBody.put('standingInstruction.type','UNSCHEDULED');
                requestBody.put('standingInstruction.source','MIT');
				requestBody.put('customParameters[donationId]',opp.id);
				 
                //requestBody.put('standingInstruction.initialTransactionId','8ac7a4a28006b41e01800765081a6c90');
                serviceCalloutConfig.setRequestBody(appendBodyParameters(requestBody));
                res = makeCallout(serviceCalloutConfig);
            }
            when else{
                string serviceName =  (HA_Utility.IsSandbox)?opp.npe03__Recurring_Donation__r.Regional_Office_Code__c+'_Test':opp.npe03__Recurring_Donation__r.Regional_Office_Code__c +'_Live';
                HTTPCalloutService serviceCalloutConfig = new HTTPCalloutService(ServiceName);
                String PaymentIntentEnpointURL = serviceCalloutConfig.getEndpointURL()+'/v1/payment_intents';
                serviceCalloutConfig.setEndpointURL(PaymentIntentEnpointURL);
                System.debug('intialObject.customerId'+opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c);
                
                serviceCalloutConfig.setURLParameter('customer',opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c);
                
                serviceCalloutConfig.setHeaderParameter('idempotency-key',guid);
                Integer amount= Integer.valueOf(opp.amount * 100);
                serviceCalloutConfig.setURLParameter('amount',String.valueOf(Amount));
                serviceCalloutConfig.setURLParameter('currency',opp.currencyIsoCode);
                serviceCalloutConfig.setURLParameter('payment_method',opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c);
                serviceCalloutConfig.setURLParameter('off_session','true');
                serviceCalloutConfig.setURLParameter('confirm','true');
                if(opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c != null)
                    serviceCalloutConfig.setURLParameter('payment_method_types[]',opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c);
                serviceCalloutConfig.setURLParameter('metadata[donationid]',opp.Id);
                serviceCalloutConfig.setURLParameter('metadata[cartid]',guid);
                serviceCalloutConfig.setURLParameter('metadata[donorid]',opp.npsp__Primary_contact__c);
                res = makeCallout(serviceCalloutConfig);
                
                
            }
        }
        return res;
    }
    public HTTPResponse requestNightPayment(String guid,Sobject s) {
        npe01__OppPayment__c payment = (npe01__OppPayment__c)s;
         HTTPResponse res = null;
        Switch on payment.Card_Details__r.Payment_Vendor__c {
        when 'Oppwa'{
                string serviceName =  (HA_Utility.IsSandbox)?payment.npe01__Opportunity__r.Regional_Office_Code__c+'_OPPWA_Test':payment.npe01__Opportunity__r.Regional_Office_Code__c +'_OPPWA_Live';
                HTTPCalloutService serviceCalloutConfig = new HTTPCalloutService(ServiceName);
                String PaymentIntentEnpointURL = serviceCalloutConfig.getEndpointURL()+'/v1/registrations/'+payment.Card_Details__r.Payment_Method_Id__c+'/payments';
                serviceCalloutConfig.setEndpointURL(PaymentIntentEnpointURL);
                Map<String,String> requestBody = new Map<String,String>();
                decimal amount = payment.npe01__Payment_Amount__c.setScale(2);
                requestBody.put('amount',String.valueOf(amount));
                requestBody.put('currency',payment.currencyIsoCode);
                requestBody.put('paymentType','PA');
                requestBody.put('standingInstruction.mode','REPEATED');
                requestBody.put('standingInstruction.type','UNSCHEDULED');
                requestBody.put('standingInstruction.source','MIT');
                serviceCalloutConfig.setRequestBody(appendBodyParameters(requestBody));
                res = makeCallout(serviceCalloutConfig);
        
            }
        when else{
        string serviceName =  (HA_Utility.IsSandbox)?payment.npe01__Opportunity__r.Regional_Office_Code__c+'_Test':payment.npe01__Opportunity__r.Regional_Office_Code__c +'_Live';
        HTTPCalloutService serviceCalloutConfig = new HTTPCalloutService(ServiceName);
        String PaymentIntentEnpointURL = serviceCalloutConfig.getEndpointURL()+'/v1/payment_intents';
        serviceCalloutConfig.setEndpointURL(PaymentIntentEnpointURL);
        
        //Required
        serviceCalloutConfig.setURLParameter('customer',payment.Card_Details__r.Gateway_Customer_Reference__c);
        
        serviceCalloutConfig.setHeaderParameter('idempotency-key',guid);
        Integer amount= Integer.valueOf(payment.npe01__Payment_Amount__c * 100);
        serviceCalloutConfig.setURLParameter('amount',String.valueOf(Amount));
        serviceCalloutConfig.setURLParameter('currency',payment.currencyIsoCode);
        //Required
        serviceCalloutConfig.setURLParameter('payment_method',payment.Card_Details__r.Payment_Method_Id__c);
        serviceCalloutConfig.setURLParameter('off_session','true');
        serviceCalloutConfig.setURLParameter('confirm','true');
        if(payment.Card_Details__r.Payment_Method_Type__c != null)
            serviceCalloutConfig.setURLParameter('payment_method_types[]',payment.Card_Details__r.Payment_Method_Type__c);
        serviceCalloutConfig.setURLParameter('metadata[donationid]',payment.npe01__Opportunity__c);
        serviceCalloutConfig.setURLParameter('metadata[cartid]',guid);
        serviceCalloutConfig.setURLParameter('metadata[paymentId]',payment.Id);
       res = makeCallout(serviceCalloutConfig);
            }
        }
        return res;
    }
    public HTTPResponse requestCustomerInformation(string customerReferenceId,String sitecode) {
        string serviceName =  (HA_Utility.IsSandbox)?sitecode+'_Test':sitecode +'_Live';
        HTTPCalloutService serviceCalloutConfig = new HTTPCalloutService(ServiceName);
        String PaymentIntentEnpointURL = serviceCalloutConfig.getEndpointURL()+'/v1/customers/'+customerReferenceId;
        serviceCalloutConfig.setEndpointURL(PaymentIntentEnpointURL);
        HTTPResponse res = makeCallout(serviceCalloutConfig);
        // 202 Accepted on the other hand means that the request have been accepted for processing, and the service will now start
        System.debug('HTTPResponse===>'+res);
        return res;
    }
    /**
* @description Load Default Payload Params from CMT HTTP Body
* @author agentgill | 28/06/2020
* @return Map<String, String>
**/
    private static Map<String, String> loadConfig(String ServiceName) {
        HTTPCalloutService paymentConfig = new HTTPCalloutService(
            String.valueOf(ServiceName)
        );
        Map<String, String> jsonMap = (Map<String, String>) JSON.deserialize(
            (String) paymentConfig.getRequestBody(),
            Map<String, String>.class
        );
        return jsonMap;
    }
    public HTTPResponse makeCallout(HTTPCalloutService service) {
        System.debug('@@HeaderParameters '+service.getHeaderParameters());
        System.debug('@@RequestBody '+service.getRequestBody());
        HTTPResponse res =  service.sendRequest();
        System.debug('@@Enpoint '+service.getEndpointURL());
        return res;
        
        
    }
    /**
* @description Handle Callout to Payment Service
* @author agentgill | 28/06/2020
* @return HTTPResponse
**/
    public static HTTPResponse makeCallout() {
        HTTPCalloutService service = new HTTPCalloutService(SERVICE_NAME);
        service.setRequestBody(JSON.serialize(pi));
        HTTPResponse res = service.sendRequest();
        return res;
    }
    
    /**
* @description Payload Data Type
*/
    private class PaymentIntent {
        private Boolean isAsync { get; set; }
        private String APIKey { get; set; }
        private String paymentGateway { get; set; }
        private String incomeUserName { get; set; }
        private String incomeCardPaymentId { get; set; }
        private Decimal amount { get; set; }
        private String currencyCode { get; set; }
        private String customerId { get; set; } // Stripe
        private String internalPaymentDescription { get; set; }
    }
    private String appendBodyParameters(Map<String,String> bodyParametersMap) {
        String bodyParamters = '';
        Set<String> ParamKeys = bodyParametersMap.keySet();
        if(!ParamKeys.isEmpty()) {
            for(String ParamKey : ParamKeys) {
                bodyParamters += ParamKey + '=' +bodyParametersMap.get(ParamKey)+ '&';
            }
            bodyParamters = bodyParamters.substringBeforeLast('&');
        }
        return bodyParamters;
    }
}