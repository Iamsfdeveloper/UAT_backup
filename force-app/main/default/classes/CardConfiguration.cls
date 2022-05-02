public class CardConfiguration {
    @future(callout=true)
    public static void getCustomerPaymentMethod(set<Id> cardPaymentIds){
        
        if(cardPaymentIds.size()>0){
            Map<Id,Id> oppMapToCardPayment = new Map<Id,Id>();
            List<Opportunity> updateOpportunities = new List<Opportunity>();
            List<Income_Card_Payment__c> cardPaymentList = [Select Id,Transaction_Type__c,Payment_Status__c,Payment_Method_Id__c,Opportunity__c,Contact__r.Regional_Office_code__c,Gateway_Customer_Reference__c,Opportunity__r.Regional_office_code__c,Opportunity__r.DonationCode__c From Income_Card_Payment__c Where Id IN: cardPaymentIds and Payment_Method_Id__c = null];
            For(Income_Card_Payment__c cp:cardPaymentList){
                if (Limits.getCallouts() <= 100 && cp.Gateway_Customer_Reference__c != null &&  cp.Payment_Method_Id__c == null){
                    Opportunity opp = new Opportunity(Payment_Method__c ='Card Payment',Id=cp.Opportunity__c,StageName='In Payment Processing');
                    NewPaymentService ps = (NewPaymentService) di_Injector.Org.getInstance( NewPaymentService.class);
					HTTPResponse customerInfoResponse = ps.requestCustomerInformation(cp.Gateway_Customer_Reference__c,(cp.Opportunity__c != null)?cp.Opportunity__r.Regional_office_code__c:cp.Contact__r.Regional_Office_code__c);
                     if(customerInfoResponse.getStatusCode() ==200){
                            
                            Map<String,Object> responseMap =(Map<String,Object>)JSON.deserializeUntyped(customerInfoResponse.getBody());
                         Map<String,Object> invoiceSettingsMap =(Map<String,Object>)responseMap.get('invoice_settings');
                         if(String.valueOf(invoiceSettingsMap.get('default_payment_method')) != null ){
                             cp.Payment_Method_Id__c = String.valueOf(invoiceSettingsMap.get('default_payment_method'));
                             cp.Payment_Method_Type__c  = 'card';
                             if(cp.Opportunity__c != null && (cp.Transaction_Type__c =='Authenticate' || cp.Transaction_Type__c =='Sale'  || cp.Transaction_Type__c =='Authorised')  && (cp.Payment_Status__c =='succeeded' || cp.Payment_Status__c =='Successful')){
                                 
                                 Opp.StageName = 'Paid';
                                 if(cp.Opportunity__r.DonationCode__c =='10N' || cp.Opportunity__r.DonationCode__c =='30N' || cp.Opportunity__r.DonationCode__c == '10D'){
                                     Opp.StageName = 'Setup Completed';
                                     oppMapToCardPayment.put(cp.Opportunity__c,cp.Id);
                                 }
                                 updateOpportunities.add(opp);
                             
                             }
                         }
                     }
                    
                }
            }// End For loop
            
            Database.update(cardPaymentList,false);
            List<npe01__OppPayment__c> paymentsToUpdate = new List<npe01__OppPayment__c>();
            if(oppMapToCardPayment.size()>0){
                for(npe01__OppPayment__c payment : [Select Id,Card_Details__c,npe01__Opportunity__c,npe01__Paid__c FROM npe01__OppPayment__c Where npe01__Paid__c = false and npe01__Opportunity__c IN:oppMapToCardPayment.keySet() and (npe01__Opportunity__r.DonationCode__c ='30N' OR npe01__Opportunity__r.DonationCode__c ='10N' OR npe01__Opportunity__r.DonationCode__c ='10D')]){
                    payment.Card_Details__c = oppMapToCardPayment.get(payment.npe01__Opportunity__c);
                    paymentsToUpdate.add(payment);
                }
            }
            if(paymentsToUpdate.size()>0)
                Database.update(paymentsToUpdate,false);
            if(updateOpportunities.size()>0){
            	Database.update(updateOpportunities,false);
       		}
        }
    }// End of future Method
}