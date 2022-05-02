trigger CallListTrigger on Call_List__c (before insert, after insert) {
    
if(Trigger.isBefore && Trigger.isInsert){
    String Dailer_queue_Id ;
    if((Integer)[SELECT Count(Id) FROM Group Where DeveloperName like 'Dialer_Queue_%' AND Type='Queue'][0].get('expr0')>0){
        Map<String,Id> Dailer_queue_Map  = new Map<String,Id>();
        for(Group g:[SELECT Id, Name, DeveloperName, Type FROM Group Where DeveloperName like 'Dialer_Queue_%' AND Type='Queue'])
            Dailer_queue_Map.put(g.DeveloperName,g.Id);
        for(Call_List__c cl: Trigger.new){
            if(Dailer_queue_Map.get(cl.Queue_Name__c) != null)
                cl.ownerId = Dailer_queue_Map.get(cl.Queue_Name__c);
            
        }
    }

}else{
    List<CampaignMember> updateCM_WithCallListId = new List<CampaignMember>();
     for(Call_List__c cl: Trigger.new){
         if(cl.CampaignMemberId__c != null)
        updateCM_WithCallListId.add(new CampaignMember(Id=cl.CampaignMemberId__c,Call_List_Id__c=cl.Id));
     }
     if(updateCM_WithCallListId.size()>0)
        upsert updateCM_WithCallListId;
    }
}