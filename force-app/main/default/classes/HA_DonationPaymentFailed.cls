/**
 * @description       : Check if the latest three payment have failed and inactivated the sponsorship
 * @author            : Kalpesh.Thakur@HumanAppeal.co.uk
 * @group             : 
 * @last modified on  : 10-12-2021
 * @last modified by  : Kalpesh.Thakur@HumanAppeal.co.uk
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   10-12-2021   Kalpesh.Thakur@HumanAppeal.co.uk   Initial Version
**/
global class HA_DonationPaymentFailed extends npsp.TDTM_Runnable  {
	
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                             List<SObject> oldlist,
                                             npsp.TDTM_Runnable.Action triggerAction,
                                             Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        List<Opportunity> newOppList = (List<Opportunity>) newlist;
        List<Opportunity> oldOppList = (List<Opportunity>) oldlist;
        Map<Id,Opportunity> oldOppMap = new Map<Id,Opportunity>(oldOppList);

        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
			
            Set<Id> recurringDonationIds = new Set<Id>(); 
            
            for (Opportunity objOpp : newOppList) {
                
                if (objOpp.StageName == 'Payment Failed' && objOpp.StageName != oldOppMap.get(objOpp.Id).StageName) {
                    	
                    recurringDonationIds.add(objOpp.npe03__Recurring_Donation__c);
                }
                
            }
            
            Map<Id,List<Opportunity>> mapDonationByRecurring = new Map<Id,List<Opportunity>>();
            Map<Id,Datetime> mapRecurringByStartDate = new Map<Id,Datetime>();

            
            for (npe03__Recurring_Donation__c objRecurringDonation : [SELECT Id, Name ,
                                                                     (SELECT Id,Name,StageName,npe03__Recurring_Donation__c,CreatedDate FROM npe03__Donations__r ORDER BY CreatedDate DESC LIMIT 3)  
                                                                      FROM npe03__Recurring_Donation__c 
                                                                      WHERE Id=:recurringDonationIds]) {
				
                if (objRecurringDonation.npe03__Donations__r.size() == 3) {
                  
                    for (Opportunity objDonation : objRecurringDonation.npe03__Donations__r) {
                    
                        if (mapDonationByRecurring.containsKey(objDonation.npe03__Recurring_Donation__c)
                        && objDonation.StageName == 'Payment Failed') {
                        
                            mapDonationByRecurring.get(objDonation.npe03__Recurring_Donation__c).add(objDonation);
                            
                            if (mapRecurringByStartDate.get(objDonation.npe03__Recurring_Donation__c) > objDonation.CreatedDate) {
                             	
                                mapRecurringByStartDate.put(objDonation.npe03__Recurring_Donation__c,objDonation.CreatedDate);
                            }
                        }
                        else if (objDonation.StageName == 'Payment Failed') {
                            
                            mapDonationByRecurring.put(objDonation.npe03__Recurring_Donation__c, new List<Opportunity>{objDonation});
                            mapRecurringByStartDate.put(objDonation.npe03__Recurring_Donation__c,objDonation.CreatedDate);
                        }
                	}
                }
            }
            
            Set<Id> failedRecurringDonationIds = new Set<Id>();
            
            for (Id recurringDonationId : mapDonationByRecurring.keyset()) {
                
                if (mapDonationByRecurring.get(recurringDonationId).size() == 3) {
                    	
                    failedRecurringDonationIds.add(recurringDonationId);
                } 
            }
            
            List<Sponsorship__c> lstSponsorship = new List<Sponsorship__c>();
            
            for (npe03__Recurring_Donation__c objRecurringDonation : [SELECT Id, Name ,
                                                                     (SELECT Id,Name,Recurring_Donation__c,IsActive__c,Donor_Organization__c,Donor__c,Donation__c, 
                                                                      		End_Date_Time__c,Orphan__c,Start_Date_Time__c,Status__c  
                                                                      FROM Sponsorships__r WHERE IsActive__c=true)  
                                                                      FROM npe03__Recurring_Donation__c 
                                                                      WHERE Id=:failedRecurringDonationIds]) {
                
                for (Sponsorship__c objSponsorship : objRecurringDonation.Sponsorships__r) {
                                                    
                    objSponsorship.End_Date_Time__c = Date.today();
                    objSponsorship.IsActive__c = false;
                    lstSponsorship.add(objSponsorship);
                    
                    Sponsorship__c objHASponsorship = objSponsorship.Clone(false, false, false, false);
                    objHASponsorship.Start_Date_Time__c = mapRecurringByStartDate.get(objRecurringDonation.Id);
                    objHASponsorship.Donor_Organization__c = Label.Donor_Organization_Id;
                    objHASponsorship.Donor__c = '';
                    objHASponsorship.End_Date_Time__c = null;
                    objHASponsorship.IsActive__c = true;
					objHASponsorship.Status__c = 'Sponsored By HA'; 
                    lstSponsorship.add(objHASponsorship);
                    
                }                                           
            }
            upsert lstSponsorship;
        }
      
      return dmlWrapper;
    }
}