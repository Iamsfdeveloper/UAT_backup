public without sharing class TriggerHandler_CardPaymentHistory {
    public static void OnBeforeInsert(List<Income_Card_Payment_History__c> newRecords)
    {
       
    }

    public static void OnAfterInsert(Map<Id, Income_Card_Payment_History__c> newRecords)
    {
        List<npe01__OppPayment__c> npspPaymentRecordList = new List<npe01__OppPayment__c>();
        Set<String> guidSet = new Set<String>();
        Set<Id> cardPaymentIds = new Set<Id>();
        List<Income_Card_Payment_History__c> successfulSales = new List<Income_Card_Payment_History__c>();
        List<Income_Card_Payment_History__c> successfulRefunds = new List<Income_Card_Payment_History__c>();

        for(Income_Card_Payment_History__c cardPaymentHistory : newRecords.values()){
            cardPaymentIds.add(cardPaymentHistory.Income_Card_Payment__c);

            if(cardPaymentHistory.Transaction_Type__c == 'Sale' && cardPaymentHistory.Payment_Status__c == 'Successful'){
                successfulSales.add(cardPaymentHistory);

                if(String.isNotBlank(cardPaymentHistory.Internal_Payment_Description__c)){
                    guidSet.add(cardPaymentHistory.Internal_Payment_Description__c);
                }
            }

            if(cardPaymentHistory.Transaction_Type__c == 'Refund' && cardPaymentHistory.Payment_Status__c == 'Successful'){
                successfulRefunds.add(cardPaymentHistory);

                if(String.isNotBlank(cardPaymentHistory.Internal_Payment_Description__c)){
                    guidSet.add(cardPaymentHistory.Internal_Payment_Description__c);
                }
            }
        }

        Map<Id, Income_Card_Payment__c> cardPaymentMap = new Map<Id, Income_Card_Payment__c>(
                                                                    [SELECT Id, Name, Authorisation_Date__c, Card_Expiry_Date__c, 
                                                                        Card_Number_Ending__c, Card_Type__c, Name_On_Card__c, 
                                                                        Opportunity__c, Payment_Vendor__c, Status__c, Contact__c 
                                                                    FROM Income_Card_Payment__c
                                                                    WHERE Id IN :cardPaymentIds]);
                            
        List<Opportunity> opps = getOpportunties(guidSet);

        npspPaymentRecordList.addAll(generateNPSPPayments(successfulSales, opps, cardPaymentMap));
        npspPaymentRecordList.addAll(generateNPSPPayments(successfulRefunds, opps, cardPaymentMap));

        if(npspPaymentRecordList.Size() > 0){
            try {
                insert npspPaymentRecordList;
            } catch (Exception e) {
                System.debug('#### NPSP Payment Failed To Insert');
            }            
        }
    }

    public static void OnBeforeUpdate(Map<Id, Income_Card_Payment_History__c> newRecords, Map<Id, Income_Card_Payment_History__c> oldRecords)
    {
    }
    
    public static void OnAfterUpdate(Map<Id, Income_Card_Payment_History__c> newRecords, Map<Id, Income_Card_Payment_History__c> oldRecords)
    {
    }

    private static List<Opportunity> getOpportunties(Set<String> guidSet) {
        return (List<Opportunity>) [
            SELECT Id, StageName, GUID__c, npsp__Primary_Contact__c 
            FROM Opportunity
            WHERE Id IN :guidSet
        ];
    }

    private static List<npe01__OppPayment__c> generateNPSPPayments(List<Income_Card_Payment_History__c> histories, List<Opportunity> opps, Map<Id, Income_Card_Payment__c> cardPayments)
    {
        List<npe01__OppPayment__c> npspPayments = new List<npe01__OppPayment__c>();

        for(Income_Card_Payment_History__c history : histories) {
            Boolean oppFound = false;
            Income_Card_Payment__c cardPayment = cardPayments.get(history.Income_Card_Payment__c);
            
            npe01__OppPayment__c payment = new npe01__OppPayment__c();
            /*Card Payment RecordType*/
            payment.Card_Payment_History__c = history.Id;
            payment.npe01__Payment_Method__c = 'Credit Card';
            payment.CurrencyIsoCode = history.CurrencyIsoCode;
            payment.npe01__Paid__c = true;
            payment.npe01__Payment_Date__c = Date.valueOf(history.Transaction_Date__c);
            
            if(history.Transaction_Type__c == 'Refund'){
                payment.npe01__Payment_Amount__c = history.Amount__c * -1;
                payment.npsp__Type__c = 'Refund';
            }
            else{
                payment.RecordTypeId = Schema.SObjectType.npe01__OppPayment__c.getRecordTypeInfosByDeveloperName().get('Card_Payment').getRecordTypeId();
                
                payment.Payment_Reference__c = history.Internal_Payment_Description__c;
                payment.Order_Id__c = history.Order_Id__c;
                //payment.Authorisation_Code__c = history.Authorisation_Code__c;
                payment.npsp__Authorized_Date__c = history.Transaction_Date__c;
                payment.npsp__Authorized_UTC_Timestamp__c = string.valueOf(history.Transaction_Date__c);
                payment.npsp__Card_Last_4__c = cardPayment.Card_Number_Ending__c;
                payment.npsp__Card_Network__c = cardPayment.Card_Type__c;
                payment.Card_Type__c = cardPayment.Card_Type__c;        
                payment.Name_On_Card__c = cardPayment.Name_On_Card__c;
                payment.Payment_Vendor__c = cardPayment.Payment_Vendor__c;
                payment.npe01__Payment_Amount__c = history.Amount__c;
                payment.npsp__Type__c = 'Sale';
                payment.Transaction_Type__c = 'Sale';
                /*Card Expiry Details*/
                if(cardPayment.Card_Expiry_Date__c != null){
                    payment.npsp__Card_Expiration_Month__c = String.valueOf(cardPayment.Card_Expiry_Date__c.month());
                    payment.npsp__Card_Expiration_Year__c = String.valueOf(cardPayment.Card_Expiry_Date__c.year());
                }
            }

            for(Opportunity o : opps) {
                if(history.Internal_Payment_Description__c == o.Id) {                   
                    // Must be a repeat card payment.
                    payment.npe01__Opportunity__c = o.Id;                    
                    payment.Contact__c = o.npsp__Primary_Contact__c;
                    payment.Status__c = 'RD'; 
                    
                    oppFound = true;
                }
            }

            if(oppFound == false) {
                // Must be a single card payment.
                payment.Status__c = 'SD';
                payment.npe01__Opportunity__c = cardPayment.Opportunity__c;
                payment.Contact__c = cardPayment.Contact__c;                
            }

            if(payment.npe01__Opportunity__c != null)
            {
                npspPayments.add(payment);
            }            
        }
        
        return npspPayments;
    }
}