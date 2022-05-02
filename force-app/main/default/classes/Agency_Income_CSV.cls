public class Agency_Income_CSV {
    String noCommaGAUName;
    String csvData;
    Date startDate;
    Date endDate;
    Map<Id,npe01__OppPayment__c> mapOppIdtoPayment;
    
    public Agency_Income_CSV(String sDate, String eDate){
        //TODO Select all fields from Agency with GAU report
        //TODO Integrate Date functionality - add start date/end date to file name
        //TODO List of items that have comma in name
        startDate = date.valueOf(sDate);
        endDate = date.valueOf(eDate);
        csvData = 'Allocation Amount,Item Code, Item Name,Payment Method,Payment Amount,Close Date, Donation Id, Donation Name, Medium, Transaction Source,Primary Campaign, Department, Payment Notes, Stipulation Type\n';
        
        mapOppIdtoPayment = new Map<Id,npe01__OppPayment__c >();        
        //Mapped Payment to OppId
        for(npe01__OppPayment__c payment:[Select Id,npe01__Opportunity__c,npe01__Payment_Amount__c,npe01__Payment_Method__c, Transaction_Source__c, Bank_Notes__c From npe01__OppPayment__c Where npe01__Opportunity__r.CloseDate >= :startDate and npe01__Opportunity__r.CloseDate <= :endDate and npe01__Opportunity__r.npe01__Number_of_Payments__c=1 and npe01__Opportunity__r.Type != 'Payment Plan - Source'and npe01__Opportunity__r.StageName='Paid' limit 50]){
        mapOppIdtoPayment.put(payment.npe01__Opportunity__c,payment);
        }
        System.debug(mapOppIdtoPayment.size());
        for(npsp__Allocation__c alloc :[Select Id,npsp__Opportunity__c,npsp__Amount__c,Donation_Item_Code__c,GAU_Name__c, Stipulation_Type__c From npsp__Allocation__c where npsp__Opportunity__c IN: mapOppIdtoPayment.keyset()]){
            noCommaGAUName = alloc.GAU_Name__C;
            if(noCommaGAUName.contains(',')){
                noCommaGAUName = noCommaGAUName.remove(',');
            }
            csvData += alloc.npsp__Amount__c+','+alloc.Donation_Item_Code__c+','+noCommaGAUName+','+mapOppIdtoPayment.get(alloc.npsp__Opportunity__c).npe01__Payment_Method__c+
                ','+mapOppIdtoPayment.get(alloc.npsp__Opportunity__c).npe01__Payment_Amount__c+','+ alloc.npsp__Opportunity__r.CloseDate+','+alloc.npsp__Opportunity__r.Casesafe_Donation_ID__c+
                ','+alloc.npsp__Opportunity__r.Name+','+alloc.npsp__Opportunity__r.Medium__c+mapOppIdtoPayment.get(alloc.npsp__Opportunity__c).Transaction_Source__c +
                ','+alloc.npsp__Opportunity__r.CampaignId+','+mapOppIdtoPayment.get(alloc.npsp__Opportunity__c).Bank_Notes__c +'\n';
        
        }
        Attachment att = new Attachment(Name='Reconcile_Data.csv',Body=Blob.valueOf(csvData),parentId='0014J00000ZpT1FQAV');
        insert att;
    }

}