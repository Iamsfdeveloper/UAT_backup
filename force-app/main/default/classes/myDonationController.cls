public without sharing class myDonationController {

    @AuraEnabled
    public static MyDonationWrapper getDonations(Boolean PaymentPlan){
        //Todo Filter by Logged In User
        //Todo Change the Gift_Aid_Eligible_Value__c = Actual field Used in Production
        try{
            MyDonationWrapper mWrapper = new MyDonationWrapper();
            Id contactId = HA_Utility.getUserInfoContactId();
            mWrapper.contactId = contactId;
            if(!PaymentPlan){                
                mWrapper.donationList = [SELECT Id,npsp__Amount__c,npsp__Opportunity__r.currencyIsoCode,npsp__Opportunity__r.CloseDate,
                                        npsp__Opportunity__r.Donation_Type__c, toLabel(Stipulation_Type__c),npsp__General_Accounting_Unit__r.Name,
                                        npsp__Opportunity__r.Gift_Aid_Eligible_Status__c, Gift_Aid_Value__c ,Country__c, GAU_Name__c, 
                                        Gift_Aid_Eligible_Allocation__c 
                                        FROM npsp__Allocation__c 
                                        WHERE npsp__Opportunity__c != NULL 
                                        AND npsp__Opportunity__r.npsp__Primary_Contact__c != NULL 
                                        AND npsp__Opportunity__r.npsp__Primary_Contact__c =: contactId 
                                        AND npsp__Opportunity__r.IsWon = true 
                                        AND  npsp__Opportunity__r.Type = 'Donation' 
                                        AND Stipulation_Type__c IN ('ZK', 'SD', 'XX') order by npsp__Opportunity__r.closeDate desc ];// and npsp__Opportunity__r.closedate >=:DATE.parse(sDate) AND npsp__Opportunity__r.closedate <=:DATE.parse(eDate) and Stipulation_Type__c =:stipulationtype];//[SELECT Id,Format(closeDate),toLabel(Donation_Type__c),CurrencyIsoCode,Gift_Aid_Eligible_Value__c,Amount,(Select Id, Name, npsp__Amount__c, npsp__Campaign__c, GAU_Name__c,npsp__General_Accounting_Unit__r.Name, Country__c, tolabel(Stipulation_Type__c), Stage__c From npsp__Allocations__r ) FROM Opportunity WHERE order by closedate desc];// WHERE Iswon = true and Type ='Donation' AND closedate = THIS_YEAR   AND npsp__Primary_Contact__c =: HA_Utility.getUserInfoContactId()
                mWrapper.donationValueWrapper = getTotalType(contactId);
            }else{
                mWrapper.donationList = [SELECT Id, Name,CurrencyIsoCode, npsp__Status__c,npsp__Day_of_Month__c, npsp__StartDate__c, 
                                        npsp__PaymentMethod__c, npsp__InstallmentFrequency__c,npe03__Amount__c, npe03__Contact__c, 
                                        npe03__Organization__c, npe03__Paid_Amount__c, npe03__Date_Established__c,
                                        (Select Id, Name, npsp__Amount__c, npsp__Campaign__c, npsp__General_Accounting_Unit__r.Name, Country__c, toLabel(Stipulation_Type__c), Stage__c FROM npsp__Allocations__r) 
                                        FROM npe03__Recurring_Donation__c 
                                        WHERE npe03__Contact__c =: contactId order by npsp__StartDate__c desc];// WHERE npsp__Status__c ='Active' order by npsp__StartDate__c limit 50 AND npsp__StartDate__c=THIS_YEAR   FROM Opporrtunity WHERE Iswon = true and Donation_Type__c ='Single' Limit 50];
            }
            return mWrapper;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<npsp__Allocation__c> getFilteredData(Date startDate, Date endDate, List<String> stype){
        try {
            String query = 'SELECT Id, npsp__Amount__c, npsp__Opportunity__r.currencyIsoCode, npsp__Opportunity__r.CloseDate, '+
                           'npsp__Opportunity__r.Donation_Type__c,toLabel(Stipulation_Type__c), npsp__General_Accounting_Unit__r.Name, '+
                           'npsp__Opportunity__r.Gift_Aid_Eligible_Status__c, Gift_Aid_Value__c ,Country__c, GAU_Name__c, Gift_Aid_Eligible_Allocation__c '+
                           'FROM npsp__Allocation__c '+
                           'WHERE npsp__Opportunity__c != null AND npsp__Opportunity__r.npsp__Primary_Contact__c != NULL AND  npsp__Opportunity__r.IsWon = true AND  npsp__Opportunity__r.Type = \'Donation\'';
            
            Id contactId = HA_Utility.getUserInfoContactId();
            if(contactId == NULL){
                return new List<npsp__Allocation__c>();
            }else{
                query += ' AND npsp__Opportunity__r.npsp__Primary_Contact__c = \'' + contactId + '\'';
                if(startDate != null){             
                    query += ' AND npsp__Opportunity__r.closeDate >= :startDate';
                }
                if(endDate != null){            
                    query += ' AND npsp__Opportunity__r.closeDate <= :endDate';
                }
                if(stype != null && stype.size() > 0){
                    query += ' AND Stipulation_Type__c IN (\'' + String.join(stype, '\',\'') + '\')';
                }   
            }
            return Database.query(query);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static MyDonationValuesWrapper getTotalType(Id contactId){
        Map<String,Decimal> totalByType = new Map<String,Decimal>();
        MyDonationValuesWrapper valueWrapper = new MyDonationValuesWrapper();
        Decimal giftTotal = 0.00;
        Decimal totalDonation = 0.00;
        for(AggregateResult ar : [SELECT SUM(npsp__Amount__c) amount, SUM(Gift_Aid_Value__c) gift, Stipulation_Type__c type 
                                  FROM npsp__Allocation__c 
                                  WHERE npsp__Opportunity__c != null 
                                  AND npsp__Opportunity__r.npsp__Primary_Contact__c <> NULL 
                                  AND npsp__Opportunity__r.npsp__Primary_Contact__c =: contactId 
                                  AND  npsp__Opportunity__r.IsWon = true 
                                  AND  npsp__Opportunity__r.Type = 'Donation' 
                                  AND  npsp__Opportunity__r.closeDate = THIS_YEAR 
                                  GROUP BY Stipulation_Type__c ]){
            Decimal value = (ar.get('amount') != null)?(Decimal)ar.get('amount'):0.00;
            Decimal giftValue = (ar.get('gift') != null)?(Decimal)ar.get('gift'):0.00;
            giftTotal += giftValue;
            totalDonation += value;
            totalByType.put(String.valueOf(ar.get('type')),value.setScale(2));
        }
        valueWrapper.totalDonation = totalDonation;
        valueWrapper.totalGift = giftTotal;
        valueWrapper.totalByType = totalByType;
        return valueWrapper;
    }

    public class MyDonationWrapper{
        @AuraEnabled
        public List<sObject> donationList;
        @AuraEnabled
        public MyDonationValuesWrapper donationValueWrapper;
        @AuraEnabled
        public String contactId;
        
        public MyDonationWrapper(){
            donationList = new List<sObject>();
            donationValueWrapper = new MyDonationValuesWrapper();
            contactId = '';
        }
    }

    public class MyDonationValuesWrapper{
        @AuraEnabled
        public Decimal totalGift;
        @AuraEnabled
        public Decimal totalDonation;
        @AuraEnabled
        public Map<String,Decimal> totalByType;
        
        public MyDonationValuesWrapper(){
            totalGift = 0;
            totalDonation = 0;
            totalByType = new Map<String,Decimal>();
        }
    }
}