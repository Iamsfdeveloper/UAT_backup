/** Client-Side Controller **/
({
    initialize: function (component, event, helper) {
        let action = component.get('c.doInit');
        action.setParam('recordId',component.get('v.recordId'));
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
                component.set("v.listOptions", response.getReturnValue()['userList']);   
                component.set("v.QueueName", response.getReturnValue()['QueueName']);
                component.set("v.exsitingMembers", response.getReturnValue()['exsitingMembers']);
                component.set("v.actualexsitingMembers", response.getReturnValue()['actualexsitingMembers']);
                component.set("v.groupId", response.getReturnValue()['groupId']);
            }
            
        });
    $A.enqueueAction(action);
    },
    handleChange: function (cmp, event) {
        cmp.set('v.exsitingMembers',event.getParam("value"));
        cmp.set('v.disabled',false);
    },
    save: function (component, event) {
        component.set('v.loaded', !component.get('v.loaded'));
        let membersToDelete = [];
        let membersToInsert=[];
        let existingMemebers=[];
        let actualexsitingMembers = component.get("v.actualexsitingMembers");
        let modifiedMembers =component.get('v.exsitingMembers');
        console.log(actualexsitingMembers);
        
        for(let x in actualexsitingMembers){
            if(modifiedMembers.indexOf(actualexsitingMembers[x].UserOrGroupId) == -1)
                membersToDelete.push(actualexsitingMembers[x]);
            else
                existingMemebers.push(actualexsitingMembers[x].UserOrGroupId);
        }
        for(let x in modifiedMembers){
            if(existingMemebers.indexOf(modifiedMembers[x]) == -1)
                membersToInsert.push({'GroupId':component.get("v.groupId"),'UserOrGroupId':modifiedMembers[x]});
        }
        console.log('membersToDelete '+membersToDelete);
        console.log('membersToInsert '+membersToInsert);
        let action = component.get('c.saveGroupMember');
        action.setParam('membersToInsert',JSON.stringify(membersToInsert));
        action.setParam('membersToDelete',JSON.stringify(membersToDelete));
        
        action.setCallback(this,function(response){
            $A.get('e.force:refreshView').fire();
            component.set('v.loaded', !component.get('v.loaded'));
            component.set('v.disabled',true);
            location.reload();
        });
         $A.enqueueAction(action);
    },
})