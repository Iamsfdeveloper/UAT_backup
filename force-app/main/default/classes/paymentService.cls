/**
* @description       : 
* @author            : Iamsfdeveloper
* @group             : 
* @last modified on  : 12-23-2021
* @last modified by  : Iamsfdeveloper
**/
@RestResource(urlMapping='/paymentEventWebhook')
global class paymentService {
    // Todo Update the donation by CardId and Reconcile by CartId
    
    @HttpPost
    global static void  paymentEventListener() {
        List<npe01__OppPayment__c> paymentToUpsert = new List<npe01__OppPayment__c>();
        RestRequest req = RestContext.request;
        System.debug('Request Received=>'+req.requestBody);
        Map<String,Object> request =(Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
		System.debug(request.keyset());
        //paymentIntentStripe.Payment_IntentObject intentObj = paymentIntentStripe.parse(req.requestBody.toString());
        /*
String cardId  = intentObj.data.object_Z.metadata.cartid;
switch on intentObj.type {
when 'payment_intent.succeeded' {
Map<String,Object> responseMap =(Map<String,Object>)JSON.deserializeUntyped(paymentResponse.getBody()); 
npe01__OppPayment__c payment = new npe01__OppPayment__c();
payment.Payment_Reference__c = opp.GUID__c;
payment.Order_Id__c = String.valueOf(responseMap.get('id'));
payment.npe01__Payment_Amount__c = decimal.valueOf((Integer.valueOf(responseMap.get('amount'))/100)).setScale(2);
//responseMap.get('payment_method') store If required for Reconciliation
payment.currencyIsoCode = String.valueOf(responseMap.get('currency')).toUpperCase();
payment.RecordTypeId = RecordTypeId;
payment.npe01__Payment_Method__c = 'Card Payment';
payment.Payment_Status__c = String.valueOf(responseMap.get('status'));
if(String.valueOf(responseMap.get('status')) =='succeeded'){
payment.npe01__Paid__c = true;

}

payment.npsp__Type__c='Sale';
payment.npe01__Opportunity__c = opp.Id;
Datetime createdDateTime = datetime.newinstance(long.valueOf(string.valueOf(responseMap.get('created')))*1000);
payment.npe01__Payment_Date__c = createdDateTime.date();
payment.npsp__Authorized_Date__c = createdDateTime.date();
payment.npsp__Authorized_UTC_Timestamp__c = createdDateTime.format();
payment.Payment_Vendor__c ='Stripe';
payment.Payment_Reference__c =lastGUID;

opp.Transaction_Id__c  = String.valueOf(responseMap.get('id'));
opp.Payment_Details__c  = String.valueOf(responseMap.get('status'));
opp.stageName = PROCESSING_STAGE;

paymentToUpsert.add(payment);
}
when 'setup_intent.succeeded' {
Opportunity  opp = new Opportunity(Transaction_Id__c = cardId,StageName='Completed');
upsert opp Transaction_Id__c;
}
when else {
Opportunity  opp = new Opportunity(Transaction_Id__c = cardId,StageName='Payment Failed');
upsert opp Transaction_Id__c;
}
}
*/
    }
}