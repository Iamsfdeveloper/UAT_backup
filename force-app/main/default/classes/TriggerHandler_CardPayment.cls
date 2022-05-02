/**
* @description       : 
* @author            : Iamsfdeveloper
* @group             : 
* @last modified on  : 01-12-2022
* @last modified by  : Iamsfdeveloper
**/
public without sharing class TriggerHandler_CardPayment {
    public static void OnBeforeInsert(List<Income_Card_Payment__c> newRecords)
    {
    }
    
    public static void OnAfterInsert(Map<Id, Income_Card_Payment__c> newRecords){  
        Set<Id> cardPaymentIds = new Set<Id>();
        List<Opportunity> updateOpportunities = new List<Opportunity>();
        List<npe01__OppPayment__c> paymentsToUpdate = new List<npe01__OppPayment__c>();
        Map<Id,Id> InternalWizardIdsOppMap = new Map<Id,Id>();
        set<Id> basketIds = new set<Id>();
        for(Income_Card_Payment__c card : [Select Id,Payment_Reference__c,Basket__c,Transaction_Type__c,Payment_Status__c,Payment_Method_Id__c,Opportunity__c,Contact__r.Regional_Office_code__c,Gateway_Customer_Reference__c,Opportunity__r.Regional_office_code__c,Opportunity__r.DonationCode__c From Income_Card_Payment__c Where Id IN: newRecords.Keyset()])
        {
            
            if(card.Payment_Method_Id__c == null  &&  card.Gateway_Customer_Reference__c != null && (card.Opportunity__c != null || card.Recurring_Donation__c != null)){
                //Retrieve Card Payment Method Id
                cardPaymentIds.add(card.Id);
            }else if(card.Payment_Method_Id__c != null  && card.Basket__c != null && (card.Transaction_Type__c =='Authenticate' || card.Transaction_Type__c =='Sale'  || card.Transaction_Type__c =='Authorised')  && (card.Payment_Status__c =='succeeded' || card.Payment_Status__c =='Successful' || card.Payment_Status__c =='setup') ){
                basketIds.add(card.Basket__c) ;  
                
            }
            else if(card.payment_Reference__c =='InternalWizard' && card.Payment_Method_Id__c != null  && card.Opportunity__c != null &&  (card.Transaction_Type__c =='Authenticate' || card.Transaction_Type__c =='Sale'  || card.Transaction_Type__c =='Authorised')  && (card.Payment_Status__c =='succeeded' || card.Payment_Status__c =='Successful' || card.Payment_Status__c =='setup') ){
                updateOpportunities.add(new Opportunity(Id=card.Opportunity__c,Payment_Method__c ='Card Payment',StageName = 'Setup Completed')) ;  
                InternalWizardIdsOppMap.put(card.Opportunity__c,card.Id);
                
            }
        }
        System.debug('basketIds=>'+basketIds);
        if(basketIds.size()>0)
            for(Opportunity opp:[Select Id,StageName,Payment_Method__c FROM Opportunity Where Basket__c IN: basketIds and DonationCode__c  IN ('10N','30N','10D') and StageName='Awaiting Payment Details']){
                opp.Payment_Method__c ='Card Payment';
                opp.StageName = 'Setup Completed';
                updateOpportunities.add(opp);
            }
        if(cardPaymentIds.size()>0 && !System.isFuture())
            CardConfiguration.getCustomerPaymentMethod(cardPaymentIds);
        if(updateOpportunities.size()>0){
            upsert updateOpportunities;
        }
        if(InternalWizardIdsOppMap.size()>0){
            for(npe01__OppPayment__c payment : [Select Id,Card_Details__c,npe01__Opportunity__c,npe01__Paid__c FROM npe01__OppPayment__c Where npe01__Paid__c = false and npe01__Opportunity__c IN:InternalWizardIdsOppMap.keyset() and (npe01__Opportunity__r.DonationCode__c ='30N' OR npe01__Opportunity__r.DonationCode__c ='10N' OR npe01__Opportunity__r.DonationCode__c ='10D')]){
                payment.Card_Details__c = InternalWizardIdsOppMap.get(payment.npe01__Opportunity__c);
                paymentsToUpdate.add(payment);
            }
        }
        if(paymentsToUpdate.size()>0)
            update paymentsToUpdate;
    }
    
    public static void OnBeforeUpdate(Map<Id, Income_Card_Payment__c> newRecords, Map<Id, Income_Card_Payment__c> oldRecords)
    {
        
    }
    
    public static void OnAfterUpdate(Map<Id, Income_Card_Payment__c> newRecords, Map<Id, Income_Card_Payment__c> oldRecords)
    {        
        List<npe03__Recurring_Donation__c> recurringDonations = new List<npe03__Recurring_Donation__c>();
        
        List<Income_Card_Payment__c> clonedCardPayment = new List<Income_Card_Payment__c>();
        List<Income_Card_Payment_History__c> clonedHistories = new List<Income_Card_Payment_History__c>();
        Set<String> oppIds = new Set<String>();
        Set<Id> cardPaymentIds = new Set<Id>();
        for(Income_Card_Payment__c card : newRecords.values())
        {
            if(card.Customer_Payment_Description__c  == 'Renewal' && card.Internal_Payment_Description__c != null && card.Internal_Payment_Description__c.startsWithIgnoreCase('a09'))
            {
                recurringDonations.add(new npe03__Recurring_Donation__c(Id = card.Internal_Payment_Description__c, Card_Payment_Detail__c = card.Id));
            }
            if(card.Payment_Method_Id__c == null  &&  card.Gateway_Customer_Reference__c != null && (card.Opportunity__c != null || card.Recurring_Donation__c != null)){
                //Retrieve Card Payment Method Id
                cardPaymentIds.add(card.Id);  
            }else if( card.Payment_Status__c == 'Successful'  && oldRecords.get(card.Id).Payment_Status__c != 'Successful' && (card.Transaction_Type__c == 'Sale' || card.Transaction_Type__c == 'Authenticate')){
                 
                    if(card.Opportunity__c != null)
                    {
                        oppIds.add(card.Opportunity__c);
                    } 
                    
                    if(String.isNotBlank(card.Internal_Payment_Description__c))
                    {
                        List<String> additionalOpportunityIds = card.Internal_Payment_Description__c.split(',');
                        
                        for(String s : additionalOpportunityIds)
                        {
                            if (s instanceOf Id)
                            {
                                oppIds.add(s);
                                Income_Card_Payment__c clone = card.clone();
                                clone.Opportunity__c = s;
                                clone.Source_Card_Payment__c = card.Id;
                                clonedCardPayment.add(clone);
                            }
                        }
                    }
                }
                
            
        }
        if(cardPaymentIds.size()>0){
            If(!System.isFuture())
            CardConfiguration.getCustomerPaymentMethod(cardPaymentIds);
       		// else
            //CardConfiguration.getCustomerPaymentMethodNonFuture(cardPaymentIds);
        }
        if(recurringDonations.size() > 0)
        {
            update recurringDonations;
        }
        
        if(oppIds.Size() > 0)
        {
            Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>([SELECT Id, Amount, StageName, Payment_Schedule__r.Frequency__c FROM Opportunity WHERE Id IN :oppIds]);
            
            if(clonedCardPayment.Size() > 0)
            {
                insert clonedCardPayment;
                
                for(Income_Card_Payment__c payment : clonedCardPayment)
                {
                    Opportunity opp = opportunities.get(payment.Opportunity__c);
                    
                    Income_Card_Payment_History__c clone = new Income_Card_Payment_History__c();
                    clone.CurrencyIsoCode = payment.CurrencyIsoCode;
                    clone.Income_Card_Payment__c = payment.Id;
                    clone.Payment_Status__c = 'Successful';                
                    clone.Transaction_Date__c = DateTime.now();
                    
                    if(opp.Payment_Schedule__r.Frequency__c == 'Single')
                    {
                        clone.Transaction_Type__c = 'Sale';
                        clone.Amount__c = opp.Amount;
                    }
                    else
                    {
                        // Must be a recurring payment schedule
                        clone.Transaction_Type__c = 'Authenticate';
                        clone.Amount__c = 0.00;
                    }
                    
                    clonedHistories.add(clone);
                }
                
                if(clonedHistories.Size() > 0)
                {
                    insert clonedHistories;
                }
            }
        }        
    }
}