public with sharing class HA_TotalProcessingPaymentController {
	
    public Id opportunityId {get;set;}
    public String paymentURL {get;set;}
    public String paymentStatus {get;set;}
    public String resourcePath {get;set;}
    
    
    public HA_TotalProcessingPaymentController() {
		Map<String,String> mapURL = System.currentPageReference().getParameters();
        System.debug('****:-'+mapURL);
        if (mapURL.containsKey('recId') && !mapURL.containsKey('resourcePath')) {
            
            opportunityId = mapURL.get('recId');
        	paymentURL = generateCardPaymentLink(opportunityId);
        }
        else if (mapURL.containsKey('resourcePath')) {
            
            resourcePath = mapURL.get('resourcePath');
            opportunityId = mapURL.get('recId');
            //setPaymentStatus(resourcePath,opportunityId);
        }
        
    }

    
    public PageReference setPaymentStatus() {
        
        if(opportunityId != null && resourcePath != null ) {
            
            Opportunity objOpportunity = [SELECT Id,Amount,CurrencyISOCode FROM Opportunity WHERE Id=:opportunityId];
            
            HttpRequest request = new HttpRequest();
            request.setTimeout(120000);
            request.setEndpoint('https://eu-test.oppwa.com'+resourcePath+'?entityId=8ac7a4c77ef7c6d9017efcd2b36c1225');
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer OGFjN2E0Y2E3ZWY3YzhiNzAxN2VmY2QyYjIyZTEzZTZ8NXRrZFRNeERQUA==');
            
            //String data = 'entityId=8ac7a4c77ef7c6d9017efcd2b36c1225';
            //request.setBody(data);
            
            Http http = new Http();
            HTTPResponse res = http.send(request);
            System.debug('****:-'+res.getBody());
            TotalProcessingResponse processingRes  = (TotalProcessingResponse)JSON.deserialize(res.getBody(),TotalProcessingResponse.class);
            
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            
            if (processingRes.result.description.contains('successfully ')) {
                
                npe01__OppPayment__c payment = new npe01__OppPayment__c();
                payment.npe01__Opportunity__c = opportunityId;
                payment.npe01__Payment_Date__c = Date.today();
                payment.npe01__Payment_Amount__c = objOpportunity.Amount;
                payment.npe01__Payment_Method__c = 'Card Payment';
                payment.Status__c = 'SD'; 
                payment.CurrencyIsoCode = objOpportunity.CurrencyIsoCode;
                payment.npe01__Paid__c = true; 
                payment.Payment_Status__c = 'Completed';
                payment.npsp__Type__c = 'Sale';
                insert payment;
                pagereference pageref = new pagereference(baseUrl+'/lightning/r/npe01__OppPayment__c/'+payment.Id+'/view');
                pageref.setredirect(true);
                return pageref;
                
            }
            else {
                
                npe01__OppPayment__c payment = new npe01__OppPayment__c();
                payment.npe01__Opportunity__c = opportunityId;
                payment.npe01__Payment_Date__c = Date.today();
                payment.npe01__Payment_Amount__c = objOpportunity.Amount;
                payment.npe01__Payment_Method__c = 'Card Payment';
                payment.Status__c = 'SD'; 
                payment.CurrencyIsoCode = objOpportunity.CurrencyIsoCode;
                payment.npe01__Paid__c = false;    
                payment.Payment_Status__c = 'Failed'; 
                payment.npsp__Type__c = 'Sale';
                insert payment;
                pagereference pageref = new pagereference(baseUrl+'/lightning/r/npe01__OppPayment__c/'+payment.Id+'/view');
                pageref.setredirect(true);
                return pageref;
            }
        
        }
        
        return null;
    }
    
     @AuraEnabled
    public static String generateCardPaymentLink(String oppId) {
        
        Opportunity objOpportunity = [SELECT Id,Amount,CurrencyISOCode,Donation_Type__c  FROM Opportunity WHERE Id=:oppId];
        
        HttpRequest request = new HttpRequest();
        request.setTimeout(120000);
        
        String data = 'entityId=8ac7a4c77ef7c6d9017efcd2b36c1225'+'&amount='+objOpportunity.Amount+'&currency='+objOpportunity.CurrencyISOCode;
        
        if (objOpportunity.Donation_Type__c == 'RD' || objOpportunity.Donation_Type__c == 'RDA' || objOpportunity.Donation_Type__c == 'EMI') {
            	
            data = 'entityId=8ac7a4c77ef7c6d9017efcd2b36c1225'+'&amount='+objOpportunity.Amount+'&currency='+objOpportunity.CurrencyISOCode+'&paymentType=DB&standingInstruction.mode=INITIAL&standingInstruction.type=UNSCHEDULED&standingInstruction.source=CIT&createRegistration=true';
        	request.setBody(data);
        }
        else if (objOpportunity.Donation_Type__c == '10N ' || objOpportunity.Donation_Type__c == '30N' || objOpportunity.Donation_Type__c == '27N' || objOpportunity.Donation_Type__c == '30D' || objOpportunity.Donation_Type__c == '10D') {
            
            data = 'entityId=8ac7a4c77ef7c6d9017efcd2b36c1225'+'&amount='+objOpportunity.Amount+'&currency='+objOpportunity.CurrencyISOCode+'&standingInstruction.mode=INITIAL&standingInstruction.type=UNSCHEDULED&standingInstruction.source=CIT&createRegistration=true';
        	request.setBody(data);
        }
        
       	request.setEndpoint('https://eu-test.oppwa.com/v1/checkouts');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer OGFjN2E0Y2E3ZWY3YzhiNzAxN2VmY2QyYjIyZTEzZTZ8NXRrZFRNeERQUA==');
        
        
        
        Http http = new Http();
        HTTPResponse res = http.send(request);
        System.debug('****:-'+res.getBody());
        TotalProcessingResponse processingRes  = (TotalProcessingResponse)JSON.deserialize(res.getBody(),TotalProcessingResponse.class);
        if (processingRes.result.description == 'successfully created checkout') {
            
            return 'https://eu-test.oppwa.com/v1/paymentWidgets.js?checkoutId='+processingRes.id;
        }
        else {
            
            return processingRes.result.description;
        }
        
        
    }
    
    public class TotalProcessingResponse {
        public ResultData result;
        public String buildNumber;
        public String timestamp;
        public String ndc;
        public String id;
        public String registrationId;
        
    }
    
    public class ResultData {
        public String code;
        public String description;
    }
}