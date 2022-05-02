public class ManageSponsorshipAfterEndDate implements Database.Batchable<sObject>{
   public final String Query = 'SELECT Id, Name, Orphan__c,Orphan__r.Is_Active__c, Donor__c, End_Date_Time__c, IsActive__c, Recurring_Donation__c, Status__c, Acknowledgment_Status__c FROM Sponsorship__c WHERE End_Date_Time__c = YESTERDAY AND IsActive__c = true';

   public Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext BC, List<sObject> scope){
      
       List<Sponsorship__c> lstSponsorship = (List<Sponsorship__c>) scope;  
       
       List<Sponsorship__c> lstNewHASponsorship = new List<Sponsorship__c>();
       
       List<Contact> lstUpdateOrphan = new List<Contact>();
       
       for (Sponsorship__c objSponsor : lstSponsorship) {
           	
           objSponsor.IsActive__c = false;
           if(objSponsor.Orphan__r.Is_Active__c){
               Sponsorship__c objHASponsor = new Sponsorship__c();
               objHASponsor.Donor_Organization__c = Label.Donor_Organization_Id ;
               objHASponsor.IsActive__c = true;
               objHASponsor.Orphan__c = objSponsor.Orphan__c;
               objHASponsor.Start_Date_Time__c = Datetime.now();
               objHASponsor.Status__c = 'Sponsored By HA';
               lstNewHASponsorship.add(objHASponsor);
           }
 
       }
       
      
       
       insert lstNewHASponsorship;
       
       for (Sponsorship__c objHASponsor : lstNewHASponsorship) {
           	           
           Contact objOrphan = new Contact();
           objOrphan.Id = objHASponsor.Orphan__c;
           objOrphan.Sponsorship_Status__c  = 'Sponsored By HA';
           objOrphan.Sponsorship__c = objHASponsor.Id;
           lstUpdateOrphan.add(objOrphan);
       }
       
       
       update lstUpdateOrphan;   
       
       update lstSponsorship;
   }

   public void finish(Database.BatchableContext BC){
		
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new String[] {UserInfo.getUserEmail()});
        mail.setSenderDisplayName('Human Appeal');
        mail.setSubject('Batch Processing Sponosorship After EndDate');
        mail.setPlainTextBody('Batch Process has completed');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });       
       
   }

}