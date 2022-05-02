public without Sharing class HA_ManageGroupMember {
 	@AuraEnabled(cacheable=true)
    Public static Map<String,Object> doInit(String recordId){
        Map<String,Object> returnVal = new Map<String,Object>();
        Map<Id,User> userMap = new Map<Id,User>([Select Id,Name From User Where (Profile.Name='HA Donor Care Advisor' or Profile.Name='HA Donor Care') AND IsActive=true order By FirstName]);
        Campaign c = [Select Id , Dialer_Queue__c From Campaign Where Id=:recordId AND Dialer_Queue__c != null];
        If(c != null){
            returnVal.put('QueueName',c.Dialer_Queue__c);
            Group g = [Select Id,DeveloperName FROM Group Where DeveloperName=:c.Dialer_Queue__c and Type='Queue'];
            if(g!= null){
                returnVal.put('groupId',g.Id);
                List<Id>  GroupMemberList = new List<Id>();
                List<GroupMember> actualexsitingMembers = new List<GroupMember>();
                for(GroupMember gm:[SELECT Id, GroupId, UserOrGroupId FROM GroupMember Where GroupId=:g.Id]){
                    String UserId =(String)gm.UserOrGroupId;
                    if(UserId.startsWithIgnoreCase('005') && userMap.get(gm.UserOrGroupId) != null){
                        GroupMemberList.add(gm.UserOrGroupId);
                        actualexsitingMembers.add(gm);
                    }
                }
                returnVal.put('exsitingMembers',GroupMemberList);
                returnVal.put('actualexsitingMembers',actualexsitingMembers);
            }
        }
        List<HA_selectOption>  userList = new List<HA_selectOption>();
        For(User u:userMap.values()){
            userList.add(new HA_selectOption(u.Name,u.Id));
        }
       
    	returnVal.put('userList',userList);
        return returnVal;
        
    }
    @AuraEnabled
    Public static void saveGroupMember(String membersToInsert,String membersToDelete){  
        List<GroupMember> membersToInsertList = (List<GroupMember>)JSON.deserialize(membersToInsert, List<GroupMember>.class);
        if(membersToInsertList.size()>0)insert membersToInsertList;
        List<GroupMember> membersToDeleteList = (List<GroupMember>)JSON.deserialize(membersToDelete, List<GroupMember>.class);
        if(membersToDeleteList.size()>0) delete membersToDeleteList;
       
    }
}