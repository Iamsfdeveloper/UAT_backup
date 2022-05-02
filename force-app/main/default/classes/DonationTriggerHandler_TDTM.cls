/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 01-14-2022
 * @last modified by  : Iamsfdeveloper
**/
global class DonationTriggerHandler_TDTM extends npsp.TDTM_Runnable  {
    private static final string DONATION_TYPE = 'Donation';
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                             List<SObject> oldlist,
                                             npsp.TDTM_Runnable.Action triggerAction,
                                             Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
                                                
       	                                          
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            Map<Id,Opportunity> newOppMap = new Map<Id,Opportunity>((List<Opportunity>)newlist);
            Map<Id,Opportunity> oldOppMap = (oldlist!= null)?new Map<Id,Opportunity>((List<Opportunity>)oldlist):new Map<Id,Opportunity>();                                  
            set<Id> wonOppIds = new set<Id>();
            set<Id> contactIds = new set<Id>();
            Map<Id,Contact> contactMapValue = new Map<Id,Contact>();
            Map<Id,String> contactToItemCode = new Map<Id,String>(); 
            List<Opportunity> newOppList = (List<Opportunity>)newlist;   
            for(Integer i=0;i<newOppList.size();i++){
                if(newOppList[i].isWon && !OldOppMap.get(newOppList[i].Id).isWon){
                    if(newOppList[i].Type ==DONATION_TYPE)
                        wonOppIds.add(newOppList[i].Id);
                    if(newOppList[i].ContactId != null)
                    contactIds.add(newOppList[i].npsp__Primary_Contact__c);
                    
                }
            }
            
            if(contactIds.size()>0)
                contactMapValue.putAll([SELECT Id, Products_purchased__c  From Contact Where Id IN: contactIds]);
                
          if(contactIds.size()>0 && wonOppIds.size()>0)
          for (npsp__Allocation__c allo : [Select Id,npsp__Opportunity__c,npsp__Opportunity__r.npsp__Primary_Contact__c, Donation_Item_Code__c  From Npsp__Allocation__c Where npsp__Opportunity__c IN:wonOppIds ]) {
             if (contactMapValue.keyset().contains(allo.npsp__Opportunity__r.npsp__Primary_Contact__c)){
                  contact temp = contactMapValue.get(allo.npsp__Opportunity__r.npsp__Primary_Contact__c);
                  if(temp.Products_purchased__c == null)
                      temp.Products_purchased__c = allo.Donation_Item_Code__c;
                  else if(!temp.Products_purchased__c.containsIgnoreCase(allo.Donation_Item_Code__c))
            		temp.Products_purchased__c +=';'+allo.Donation_Item_Code__c;
                contactMapValue.put(temp.Id,temp);
            }
          }
            
        if(contactMapValue.size()>0)
         dmlWrapper.objectsToUpdate.addAll((List<Contact>)contactMapValue.values());
        
      }                                        
      
      return dmlWrapper;
    }
}