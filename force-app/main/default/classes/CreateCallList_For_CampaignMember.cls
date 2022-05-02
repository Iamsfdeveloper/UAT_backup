/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 02-08-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   02-08-2021   Iamsfdeveloper   Initial Version
**/
global class CreateCallList_For_CampaignMember {
    global static void createCallList(List<CampaignMember> newList){
        list<Call_List__c> callListToInsert = new List<Call_List__c>();

        for(CampaignMember cm : newList){
            System.debug('cm.Contact_Type__c=====> '+cm.Contact_Type__c);
            if(cm.contactId !=null && cm.Campaign_Type__c =='Outbound_Calling' && cm.Contact_Type__c !='Orphan'){
                string Name = (cm.FirstName != null)? cm.FirstName+' '+cm.LastName:cm.LastName;
                callListToInsert.add(new Call_list__c(Name=Name,ContactId__c=cm.contactId,CampaignMemberId__c = cm.Id, CampaignId__c=cm.CampaignId, Queue_Name__c=cm.Queue_Name__c)); 
            }
        }
        if(callListToInsert.size()>0){
            insert callListToInsert;
        }
    }
}