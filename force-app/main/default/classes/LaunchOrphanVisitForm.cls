public with sharing class LaunchOrphanVisitForm{
    @AuraEnabled
    public static List <Orphan_Visit__c> fetchOrphanVisits(String OrphanId) {
        List<Orphan_Visit__c> listOrphanVisits = new List<Orphan_Visit__c>();
        if(String.isEmpty(OrphanId)){
        listOrphanVisits = [SELECT Id,Orphan__c, Orphan__r.Sponsoree_ID__c,Orphan__r.Name,
                            Status__c, Due_Date__c, Orphan_Visit_Form__c FROM Orphan_Visit__c
                           	where Status__c='In Progress' AND (Due_Date__c = THIS_YEAR OR Due_Date__c = LAST_YEAR ) ORDER By Due_Date__c ASC limit 10 ];
        }else{
            listOrphanVisits = [SELECT Id,Orphan__c, Orphan__r.Sponsoree_ID__c,Orphan__r.Name,
                                Status__c, Due_Date__c, Orphan_Visit_Form__c FROM Orphan_Visit__c
                                where Status__c='In Progress' AND (Due_Date__c = THIS_YEAR OR Due_Date__c = LAST_YEAR ) AND Orphan__c = :OrphanId ORDER By Due_Date__c ASC limit 10 ];
        }
        return listOrphanVisits;
    }
    @AuraEnabled
    public static List <Orphan_Visit__c> fetchOrphanVisitsbySearch(String key, String OrphanId) {
        String searchKey = '%'+key+'%';
        List<Orphan_Visit__c> listOrphanVisits = new List<Orphan_Visit__c>();
        listOrphanVisits = [SELECT Id,Orphan__c, Orphan__r.Sponsoree_ID__c,Orphan__r.Name,
                            Status__c, Due_Date__c, Orphan_Visit_Form__c FROM Orphan_Visit__c
                           	where Status__c='In Progress' AND (Due_Date__c = THIS_YEAR OR Due_Date__c = LAST_YEAR ) AND//AND Orphan__c=:OrphanId 
                            (Orphan__r.Name like :searchKey OR Orphan__r.Sponsoree_ID__c like:searchKey OR Orphan__r.MailingCity like:searchKey
                            OR Orphan__r.MailingCountry like:searchKey OR Orphan__r.MailingStreet like:searchKey OR Orphan__r.MailingState like: searchKey) ORDER By Due_Date__c ASC limit 10];
        return listOrphanVisits;
    }
    @AuraEnabled
    public static Integer countOrphanVisitsbySearch(String key,String OrphanId) {
        String searchKey = '%'+key+'%';
        List<Orphan_Visit__c> listOrphanVisits = new List<Orphan_Visit__c>();
        if(key!=null && !String.isBlank(key) && !String.isEmpty(key) && key!=''){
            listOrphanVisits = [SELECT Id,Orphan__c, Orphan__r.Sponsoree_ID__c,Orphan__r.Name,
                                Status__c, Due_Date__c, Orphan_Visit_Form__c FROM Orphan_Visit__c
                                where Status__c='In Progress' AND (Due_Date__c = THIS_YEAR OR Due_Date__c = LAST_YEAR ) AND
                                (Orphan__r.Name like :searchKey OR Orphan__r.Sponsoree_ID__c like:searchKey OR Orphan__r.MailingCity like:searchKey
                                OR Orphan__r.MailingCountry like:searchKey OR Orphan__r.MailingStreet like:searchKey OR Orphan__r.MailingState like: searchKey) ORDER By Due_Date__c ASC ];//AND Orphan__c=:OrphanId
            return listOrphanVisits.size();
        }else{
            listOrphanVisits = [SELECT Id,Orphan__c, Orphan__r.Sponsoree_ID__c,Orphan__r.Name,
                            	Status__c, Due_Date__c, Orphan_Visit_Form__c FROM Orphan_Visit__c
                           		where Status__c='In Progress' AND (Due_Date__c = THIS_YEAR OR Due_Date__c = LAST_YEAR ) ORDER By Due_Date__c ASC];//AND Orphan__c=:OrphanId
        	
            return listOrphanVisits.size();
        }
        
    }
}