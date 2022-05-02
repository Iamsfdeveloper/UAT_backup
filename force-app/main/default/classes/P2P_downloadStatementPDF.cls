public without sharing class P2P_downloadStatementPDF {
    public Contact donor {get;set;}
    public List<npsp__Allocation__c> donationList {get;set;}
    public Date startDate {get;set;}
    public Date endDate {get;set;}
    public Map<String,Decimal> totalByType {get;set;}
    public P2P_downloadStatementPDF(){
        //ApexPages.currentPage().getParameters().get('recordId');
        //To do ReplaceId with HA_Utility.getUserInfoContactId()
        //getdownloadStatementPDF('0032500001Yu0pAAAR',ApexPages.currentPage().getParameters().get('startDate'),ApexPages.currentPage().getParameters().get('endDate'));
        getdownloadStatementPDF(HA_Utility.getUserInfoContactId(), ApexPages.currentPage().getParameters().get('startDate'), ApexPages.currentPage().getParameters().get('endDate'));
        ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=Donation-statement_'+startDate.format()+'_'+endDate.format()+'.pdf');
    }
    public void getdownloadStatementPDF(Id recordId,String start_Date,String end_Date ){
        this.donor = [SELECT Id, Donor_Id__c, currencyISOCode, Name, MailingCity, MailingStreet, MailingCountry, MailingPostalCode, MailingState FROM Contact WHERE Id =:recordId];
        this.startDate = date.valueOf(start_Date);
        this.endDate = date.valueOf(end_Date);
        this.donationList = [SELECT Id, npsp__Amount__c, npsp__Opportunity__r.currencyIsoCode, npsp__Opportunity__r.CloseDate, npsp__Opportunity__r.Donation_Type__c, Stipulation_Type__c, npsp__General_Accounting_Unit__r.Name, npsp__Opportunity__r.Gift_Aid_Eligible_Status__c, Gift_Aid_Value__c , Country__c FROM npsp__Allocation__c WHERE npsp__Opportunity__c != null AND npsp__Opportunity__r.npsp__Primary_Contact__c =: donor.Id AND  npsp__Opportunity__r.IsWon = true AND  npsp__Opportunity__r.Type = 'Donation' AND  npsp__Opportunity__r.closeDate >=:startDate AND npsp__Opportunity__r.closeDate <=:endDate ];
    	totalByType = getTotalType();  
    }
    public string getformatStartDate(){
        return startDate.format();
    }
    public string getformatEndDate(){
        return endDate.format();
    }
    public Map<String,Decimal> getTotalType(){
        Map<String,Decimal> totalByType = new Map<String,Decimal>();
        for(AggregateResult ar : [SELECT SUM(npsp__Amount__c) amount,toLabel(Stipulation_Type__c) type FROM npsp__Allocation__c Where npsp__Opportunity__c != null AND npsp__Opportunity__r.npsp__Primary_Contact__c =: donor.Id AND  npsp__Opportunity__r.IsWon = true AND  npsp__Opportunity__r.Type='Donation' AND  npsp__Opportunity__r.closeDate >=:startDate AND npsp__Opportunity__r.closeDate <=:endDate GROUP BY Stipulation_Type__c ]){
            Decimal value = (ar.get('amount') != null)?(Decimal)ar.get('amount'):0.00;
            totalByType.put(String.valueOf(ar.get('type')),value.setScale(2));
        }
        return totalByType;
    }
    public Decimal getTotalAmount(){
        AggregateResult ar = [SELECT SUM(npsp__Amount__c) amount,SUM(Gift_Aid_Value__c) giftAidValue FROM npsp__Allocation__c Where npsp__Opportunity__c != null AND npsp__Opportunity__r.npsp__Primary_Contact__c =: donor.Id AND  npsp__Opportunity__r.IsWon = true AND  npsp__Opportunity__r.Type='Donation' AND  npsp__Opportunity__r.closeDate >=:startDate AND npsp__Opportunity__r.closeDate <=:endDate];
        Decimal value =  (ar.get('amount') != null)?(Decimal)ar.get('amount'):0.00;
        Decimal giftAidValue =  (ar.get('giftAidValue') != null)?(Decimal)ar.get('giftAidValue'):0.00;
        value +=giftAidValue;
        return value.setScale(2);
    }
    public Decimal getGiftAidAmount(){
        AggregateResult ar = [SELECT SUM(Gift_Aid_Value__c) giftAidValue FROM npsp__Allocation__c WHERE npsp__Opportunity__c != null AND npsp__Opportunity__r.npsp__Primary_Contact__c =: donor.Id AND  npsp__Opportunity__r.IsWon = true AND  npsp__Opportunity__r.Type='Donation' AND  npsp__Opportunity__r.closeDate >=:startDate AND npsp__Opportunity__r.closeDate <=:endDate];
        Decimal value =  (ar.get('giftAidValue') != null)?(Decimal)ar.get('giftAidValue'):0.00;
        return value.setScale(2);
    }
}