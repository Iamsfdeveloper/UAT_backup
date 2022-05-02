/**
* @File Name          : NewRecurringDonationService.cls
* @Description        :
* @Author             : agentgill
* @Group              :
* @Last Modified By   : Iamsfdeveloper
* @Last Modified On   : 01-17-2022
* @Modification Log   :
* Ver       Date            Author      		    Modification
* 1.0    07/06/2020   agentgill     Initial Version
* 
// TODO: Throw exception when not enough callouts are availabvle

**Execute Anonymous Apex with Currently Selected Text**

// Start
NewRecurringDonationService myBatch = new NewRecurringDonationService();
myBatch.Query ='SELECT Id, Amount,npe03__Recurring_Donation__r.Regional_Office_Code__c,npe03__Recurring_Donation__r.Regional_Code__c,npsp__Primary_Contact__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c,CurrencyIsoCode,npe03__Recurring_Donation__r.Card_Payment_Detail__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c  FROM Opportunity WHERE npe03__Recurring_Donation__r.npsp__PaymentMethod__c = \'Card Payment\' AND CLOSEDATE = \'0062500000S9bfpAAB\'  AND npe03__Recurring_Donation__r.npsp__Status__c = \'Active\' ORDER BY Id';
Database.executeBatch(myBatch, 1);
// End

//Nightly Collection - start
Watch on FIlters First 
NewRecurringDonationService myBatch = new NewRecurringDonationService();
myBatch.collectionType='Nightly';
myBatch.Query ='SELECT Id,Payment_Reference__c,Card_Details__c,npe01__Payment_Amount__c,currencyIsoCode,Card_Details__r.Payment_Method_Type__c,Card_Details__r.Gateway_Customer_Reference__c,Card_Details__r.Payment_Method_Id__c,npe01__Payment_Date__c,npe01__Paid__c,npe01__Opportunity__c,npe01__Opportunity__r.Regional_Office_Code__c,npsp__Gateway_Payment_ID__c,Gateway_Customer_Reference__c FROM npe01__OppPayment__c WHERE npe01__Payment_Date__c=TODAY AND npe01__Paid__c =False AND npe01__Opportunity__r.IsClosed = false AND (npe01__Opportunity__r.DonationCode__c =\'10N\' OR npe01__Opportunity__r.DonationCode__c =\'30N\' OR npe01__Opportunity__r.DonationCode__c =\'10D\') AND Card_Details__c != null AND RecordType.DeveloperName=\'Card_Payment\'';
Database.executeBatch(myBatch, 75);

//Nightly Collection - End
//
//Recurring Donation Collection Batch
**Execute SOQL Query with Currently Selected Text**
SELECT Id, Amount,npe03__Recurring_Donation__r.Regional_Office_Code__c,npe03__Recurring_Donation__r.Regional_Code__c,npsp__Primary_Contact__c,
npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c,
CurrencyIsoCode,npe03__Recurring_Donation__r.Card_Payment_Detail__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c  
FROM Opportunity  WHERE npe03__Recurring_Donation__r.npsp__PaymentMethod__c = 'Card Payment' 
AND CloseDate = TODAY AND npe03__Recurring_Donation__r.npsp__Status__c = 'Active' 
AND StageName = 'Pledged' AND npe03__Recurring_Donation__r.Donation_type__c IN ('RD','RDA','EMI') 
AND npe03__Recurring_Donation__r.Card_Payment_Detail__c != null and npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c != null ORDER BY Id


* 
**/
public without sharing class NewRecurringDonationService implements  Database.Batchable<sObject>, Database.AllowsCallouts, Database.RaisesPlatformEvents {
    public string lastGatewayCustomerReference;
    public string lastGUID;
    public String collectionType;
    Public string query;
    private Boolean calloutSuccessful = false;
    
    private final string PROCESSING_STAGE = 'In Payment Processing';
    private final string PROCESSING_FAILED = 'Processing Failed';
    
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(collectionType =='Nightly'){
            if(String.isBlank(query))
                query = 'SELECT Id,Payment_Reference__c,Card_Details__r.Payment_Vendor__c,Card_Details__c,npe01__Payment_Amount__c,currencyIsoCode,Card_Details__r.Payment_Method_Type__c,Card_Details__r.Gateway_Customer_Reference__c,Card_Details__r.Payment_Method_Id__c,npe01__Payment_Date__c,npe01__Paid__c,npe01__Opportunity__c,npe01__Opportunity__r.Regional_Office_Code__c,npsp__Gateway_Payment_ID__c,Gateway_Customer_Reference__c FROM npe01__OppPayment__c WHERE npe01__Payment_Date__c=TODAY AND npe01__Paid__c =False AND npe01__Opportunity__r.IsClosed = false and npe01__Opportunity__r.StageName = \'Setup Completed\' AND (npe01__Opportunity__r.DonationCode__c =\'10N\' OR npe01__Opportunity__r.DonationCode__c =\'30N\' OR npe01__Opportunity__r.DonationCode__c =\'10D\') AND Card_Details__c != null AND RecordType.DeveloperName=\'Card_Payment\' AND Payment_Status__c=\'pending\' and Card_Details__r.Payment_vendor__c != \'Oppwa\'';
        }else if(collectionType =='SEPACollection'){
            if(String.isBlank(query))
                query = 'SELECT Id, Guid__c,Amount,Transaction_Id__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Vendor__c,npe03__Recurring_Donation__r.Regional_Office_Code__c,npe03__Recurring_Donation__r.Regional_Code__c,npsp__Primary_Contact__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c,'+
                +'CurrencyIsoCode,npe03__Recurring_Donation__r.Card_Payment_Detail__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c  FROM Opportunity  '+
                +'WHERE npe03__Recurring_Donation__r.npsp__PaymentMethod__c = \'SEPA\' AND npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c=\'sepa_debit\' AND CloseDate=THIS_MONTH AND  npe03__Recurring_Donation__r.npsp__Status__c = \'Active\' AND StageName = \'In Payment Processing\' AND npe03__Recurring_Donation__r.Donation_type__c IN (\'RD\',\'RDA\',\'EMI\') '+
                +'AND npe03__Recurring_Donation__r.Card_Payment_Detail__c != null and npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c != null AND Amount >0.00 ORDER BY Id ';
        }else{
            if(String.isBlank(query))
                query = 'SELECT Id, Amount,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Vendor__c,npe03__Recurring_Donation__r.Regional_Office_Code__c,npe03__Recurring_Donation__r.Regional_Code__c,npsp__Primary_Contact__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Type__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c,CurrencyIsoCode,npe03__Recurring_Donation__r.Card_Payment_Detail__c,npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c '+
                +' FROM Opportunity  WHERE npe03__Recurring_Donation__r.Card_Payment_Detail__c != null '+
                +' AND CloseDate = TODAY AND npe03__Recurring_Donation__r.npsp__Status__c = \'Active\' AND StageName = \'Pledged\' AND npe03__Recurring_Donation__r.Donation_type__c IN (\'RD\',\'RDA\',\'EMI\') ORDER BY Id';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Sobject> scope) {
        List<Opportunity> opps = new List<Opportunity>();
        List<npe01__OppPayment__c> paymentToUpsert = new List<npe01__OppPayment__c>();
        List<Recurring_Donation_Batch_Errors__c> errorList = new List<Recurring_Donation_Batch_Errors__c>();
        String RecordTypeId = Schema.SObjectType.npe01__OppPayment__c.getRecordTypeInfosByDeveloperName().get('Card_Payment').getRecordTypeId();
        
        Switch on collectionType{
            //sepa delayed payments
            when 'SEPACollection'{
                for (sobject s : scope) { 
                    Opportunity opp = (Opportunity)s;
                    // Available Callouts
                    if (Limits.getCallouts() <= 100 && opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Gateway_Customer_Reference__c != null) {
                        try{ 
                            NewPaymentService ps = (NewPaymentService) di_Injector.Org.getInstance( NewPaymentService.class);
                            if(opp.Transaction_Id__c != null){
                                HTTPResponse paymentResponse = ps.getPaymentStatus(opp.Transaction_Id__c,opp);
                                if(paymentResponse.getStatusCode() ==200){
                                  
                                    Map<String,Object> responseMap =(Map<String,Object>)JSON.deserializeUntyped(paymentResponse.getBody());
                                    System.debug('status==>'+responseMap.keyset()+'values=>'+responseMap.values());
                                    Map<String,Object> metadataMap = (Map<String,Object>)responseMap.get('metadata');
                                    System.debug('status==>'+String.valueOf(responseMap.get('status')));
                                    if(metadataMap.get('cartid') != null){
                                        npe01__OppPayment__c payment = new npe01__OppPayment__c(Payment_Reference__c = String.valueOf(metadataMap.get('cartid')));
                                        if(String.valueOf(responseMap.get('status')) =='succeeded'){
                                            payment.npe01__Paid__c = true;
                                            payment.Payment_Status__c = String.valueOf(responseMap.get('status'));
                                            paymentToUpsert.add(payment);
                                        }else if(String.valueOf(responseMap.get('status')) !='succeeded'){ 
                                            Map<String,Object> errorMap = (Map<String,Object>)responseMap.get('last_payment_error');
                                            System.debug('status==>'+errorMap.keyset()+'values=>'+errorMap.values());
                                            opp.Payment_Details__c  = String.valueOf(errorMap.get('code')) +' - '+String.valueOf(errorMap.get('message'));
                                            opp.stageName = PROCESSING_FAILED;
                                            payment.Payment_Status__c = String.valueOf(responseMap.get('status'));
                                            paymentToUpsert.add(payment);
                                        }
                                        
                                        opps.add(opp);
                                    }
                                }
                            }
                        }Catch(Exception ex){
                            String errMessage = ex.getStackTraceString()+'Message- '+ex.getMessage();
                            errorList.add(HA_Logger.CreateErrorLog(JSON.serialize(Opp),Opp.Id, errMessage));
                        }
                    }    
                }
            }
            //10N,30N or 10D collections
            When 'Nightly'{
               for (sobject s : scope) {
                    npe01__OppPayment__c payment = (npe01__OppPayment__c)s;
                 //  try{
               
                // Available Callouts
                if (Limits.getCallouts() <= 100 && payment.Card_Details__r.Payment_Method_Id__c != null)
                {
                    
                    NewPaymentService ps = (NewPaymentService) di_Injector.Org.getInstance( NewPaymentService.class);
                    HTTPResponse paymentResponse = ps.requestNightPayment(payment.Payment_Reference__c,s);
					System.debug('paymentResponse===>'+paymentResponse.getBody());
                    switch on payment.Card_Details__r.Payment_vendor__c {
                        when 'Oppwa'{
                            if(paymentResponse.getStatusCode() ==200){
                                Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(paymentResponse.getBody());
                                Map<String,Object> resultCodeMap = (Map<String,Object>)responseMap.get('result');
                                System.debug('result code '+resultCodeMap.get('code'));
                                System.debug('result description '+resultCodeMap.get('description'));
                                String resultcode = String.valueOf(resultCodeMap.get('code'));
                                Boolean flag = (Pattern.compile('^(000\\.000\\.|000\\.100\\.1|000\\.[36])').matcher(resultcode).find() || Pattern.compile('^(000\\.400\\.0[^3]|000\\.400\\.[0-1]{2}0)').matcher(resultcode).find());
                                system.debug('flag'+flag);
                                if(flag){
                                    
                                    payment.Order_Id__c = String.valueOf(responseMap.get('id'));
                                    payment.npe01__Payment_Method__c = 'Card Payment';
                                    payment.Payment_Status__c = 'succeeded';
                                    payment.npsp__Elevate_Payment_API_Status__c = 'succeeded';
                                    payment.npe01__Paid__c = true;
                                    Datetime createdDateTime = dateTime.valueOf(string.valueOf(responseMap.get('timestamp')));
                                    payment.npsp__Authorized_UTC_Timestamp__c = createdDateTime.format();
                                    payment.Payment_Vendor__c ='Oppwa';
                                    
                                }else if(Pattern.compile('^(000\\.400\\.[1][0-9][1-9]|000\\.400\\.2)').matcher(resultcode).find()){
                                    payment.npsp__Elevate_Payment_API_Declined_Reason__c  = String.valueOf(resultCodeMap.get('description'));
                                    payment.Payment_Status__c = 'Failed';
                                    payment.npsp__Elevate_Payment_API_Status__c = resultcode;
                                }
                                paymentToUpsert.add(payment);
                            }
                        }
                        when else{
                            
                  		  if(paymentResponse.getStatusCode() ==200){
                        
                        Map<String,Object> responseMap =(Map<String,Object>)JSON.deserializeUntyped(paymentResponse.getBody()); 
                        
                        payment.Order_Id__c = String.valueOf(responseMap.get('id'));
                        payment.npe01__Payment_Method__c = 'Card Payment';
                        payment.Payment_Status__c = String.valueOf(responseMap.get('status'));
                        payment.npsp__Elevate_Payment_API_Status__c = String.valueOf(responseMap.get('status'));
                        if(String.valueOf(responseMap.get('status')) =='succeeded'){
                            payment.npe01__Paid__c = true;
                        }
                        Datetime createdDateTime = datetime.newinstance(long.valueOf(string.valueOf(responseMap.get('created')))*1000);
                        payment.npsp__Authorized_UTC_Timestamp__c = createdDateTime.format();
                        payment.Payment_Vendor__c ='Stripe';
                        
                    }else{
                        Map<String,Object> responseMap =(Map<String,Object>)JSON.deserializeUntyped(paymentResponse.getBody()); 
                        System.debug('responseMap==>'+responseMap.keyset());
                        Map<String,Object> errorMap = (Map<String,Object>)responseMap.get('error');
                        System.debug('errorMap==>'+errorMap.keyset());
                        payment.npsp__Elevate_Payment_API_Declined_Reason__c  = String.valueOf(errorMap.get('message'));
                        payment.Payment_Description__c   = String.valueOf(errorMap.get('decline_code'));
                        payment.Payment_Status__c = String.valueOf(responseMap.get('status'));
                        payment.npsp__Elevate_Payment_API_Status__c = String.valueOf(responseMap.get('status'));
                    }
                    paymentToUpsert.add(payment);
                        }
                    }
                   
                }
            /*}Catch(Exception ex){
                   String errMessage = ex.getStackTraceString()+'Message- '+ex.getMessage();
                   errorList.add(HA_Logger.CreateErrorLog(JSON.serialize(payment),payment.Id, errMessage));
               }*/
            }
            }
            //Daily Repeat Service 
            when else{
                for (sobject s : scope) {
                Opportunity opp = (Opportunity)s;
                // Available Callouts
                if (Limits.getCallouts() <= 100 && opp.npe03__Recurring_Donation__r.Card_Payment_Detail__c != null) {
                    //lastGUID = generateGUID();
                    NewPaymentService ps = new NewPaymentService();//(NewPaymentService) di_Injector.Org.getInstance( NewPaymentService.class);
                    //CheckoutV4 Payments with Payment method Id
                    if(opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Method_Id__c != null){
                        HTTPResponse paymentResponse = ps.requestPayment(opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Vendor__c,opp.Id,opp);
						System.debug('paymentResponse===>'+paymentResponse);
                        Switch on opp.npe03__Recurring_Donation__r.Card_Payment_Detail__r.Payment_Vendor__c{
                            when 'Oppwa'{
                                if(paymentResponse.getStatusCode() ==200){
                                Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(paymentResponse.getBody());
                                Map<String,Object> resultCodeMap = (Map<String,Object>)responseMap.get('result');
                                System.debug('result code '+resultCodeMap.get('code'));
                                System.debug('result description '+resultCodeMap.get('description'));
                                String resultcode = String.valueOf(resultCodeMap.get('code'));
                                Boolean flag = (Pattern.compile('^(000\\.000\\.|000\\.100\\.1|000\\.[36])').matcher(resultcode).find() || Pattern.compile('^(000\\.400\\.0[^3]|000\\.400\\.[0-1]{2}0)').matcher(resultcode).find());
                                system.debug('flag'+flag);
                                if(flag){
                                    //amount, buildNumber, currency, descriptor, id, ndc, paymentType, result, risk, standingInstruction
                                    npe01__OppPayment__c payment = new npe01__OppPayment__c();
                                    payment.Order_Id__c = String.valueOf(responseMap.get('id'));
                                    payment.npe01__Payment_Amount__c = decimal.valueOf(String.valueOf(responseMap.get('amount'))).setScale(2);
                                    payment.currencyIsoCode = String.valueOf(responseMap.get('currency')).toUpperCase();
                                    payment.RecordTypeId = RecordTypeId;
                                    payment.npe01__Payment_Method__c = 'Card Payment';
                                    payment.Payment_Status__c = 'succeeded';
                                    payment.npe01__Paid__c = true;
                                    payment.npsp__Type__c='Sale';
                                    payment.npe01__Opportunity__c = opp.Id;
                                    Datetime createdDateTime = dateTime.valueOf(string.valueOf(responseMap.get('timestamp')));
                                    payment.npe01__Payment_Date__c = createdDateTime.date();
                                    payment.npsp__Authorized_Date__c = createdDateTime.date();
                                    payment.npsp__Authorized_UTC_Timestamp__c = createdDateTime.format();
                                    payment.Payment_Vendor__c ='Oppwa';
                                    payment.Payment_Reference__c =Opp.Id;
                                    payment.Bank_Notes__c = responseMap.toString();
                                    /* Update Opportunity with status and stage*/
                                    opp.Payment_Method__c = 'succeeded';
                                    opp.Payment_Details__c  = String.valueOf(resultCodeMap.get('description'));
                                    opp.stageName = PROCESSING_STAGE;
                                    paymentToUpsert.add(payment);
                                }else if(Pattern.compile('^(000\\.400\\.[1][0-9][1-9]|000\\.400\\.2)').matcher(resultcode).find()){
                                    opp.stageName = PROCESSING_FAILED;
                                    opp.Payment_Method__c = 'Failed-'+String.valueOf(resultCodeMap.get('code'));
                                    opp.Payment_Details__c  = String.valueOf(resultCodeMap.get('description'));
                                }
                              }
                            }
                            when else{
                                if(paymentResponse.getStatusCode() ==200){
                                    
                                    Map<String,Object> responseMap =(Map<String,Object>)JSON.deserializeUntyped(paymentResponse.getBody()); 
                                    npe01__OppPayment__c payment = new npe01__OppPayment__c();
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
                                    payment.Payment_Reference__c =Opp.Id;
                                    /* Update Opportunity with status and stage*/
                                    opp.Payment_Method__c = String.valueOf(responseMap.get('status'));
                                    opp.Payment_Details__c  = String.valueOf(responseMap.get('id'));
                                    opp.stageName = PROCESSING_STAGE;
                                    paymentToUpsert.add(payment);
                                }else{
                                    Map<String,Object> responseMap =(Map<String,Object>)JSON.deserializeUntyped(paymentResponse.getBody()); 
                                    Map<String,Object> errorMap = (Map<String,Object>)responseMap.get('error');
                                    opp.Payment_Details__c  = String.valueOf(errorMap.get('message'));
                                    opp.Payment_Method__c  = String.valueOf(errorMap.get('decline_code'));
                                    opp.stageName = PROCESSING_FAILED;
                                    
                                }
                            }
                        }
                        
                        opps.add(opp);
                    }else{
                        //Version 3 Payments
                        lastGUID = opp.Id;
                        calloutSuccessful = (HA_Utility.IsSandbox)?true:ps.requestPayment(s, lastGUID);
                        
                        if (calloutSuccessful) {
                            opps.add(new Opportunity(Id = opp.Id, StageName = PROCESSING_STAGE, GUID__c = lastGUID));
                        } else {
                            opps.add(new Opportunity(Id = opp.Id, StageName = (calloutSuccessful ? PROCESSING_STAGE: PROCESSING_FAILED), GUID__c = lastGUID));
                        }
                    }
                }
            }
            }
            
        }
        if (!opps.isEmpty()) {
            Database.update(opps,false); // Errors are sent to Event Bus - LogBatchApexEve
        }
        if(paymentToUpsert.size()>0){
            Database.upsert(paymentToUpsert,npe01__OppPayment__c.Fields.Payment_Reference__c,false);
        }
        if(errorList.size()>0){
            Database.insert(errorList);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('>>> NewRecurringDonationService finish nethod');
    }
    
    /**
* @description Generate GUID as Integration Correlation Key
* @author agentgill | 28/06/2020
* @return String
**/
    private static String generateGUID() {
        Blob b = Crypto.GenerateAESKey(128);String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0, 8) +'-' +h.SubString(8, 12) + '-' +h.SubString(12, 16) +'-' +h.SubString(16, 20) +'-' + h.substring(20);
    }
}