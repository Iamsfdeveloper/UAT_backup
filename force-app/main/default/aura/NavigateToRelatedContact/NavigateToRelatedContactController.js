({
	doInit : function(component, event, helper) {
        var omniAPI = component.find("omniToolkit");
        let agentStatus = '';
        omniAPI.getServicePresenceStatusId().then(function(result) {
            console.log('Status Id is: ' + result.statusName);
            agentStatus = result.statusName;
        }).catch(function(error) {
            console.log(error);
        });
        let contactAction = component.get("c.getContactDetailsFromCallList");
        contactAction.setParam('recordId',component.get("v.recordId"));
        contactAction.setCallback(this,function(response){
            var workspaceAPI = component.find("workspace");
            if(response.getState()=='SUCCESS' && response.getReturnValue()['contactId'] ){//&& agentStatus =='Available'
                workspaceAPI.getTabInfo().then(function(res) {
                    workspaceAPI.setTabIcon({
                        tabId: res.parentTabId,
                        icon: "standard:contact",
                        iconAlt: "Contact"
                    });
                    workspaceAPI.openSubtab({
                        url: '/lightning/r/Contact/'+response.getReturnValue()['contactId']+'/view',
                        focus: true
                    });   
                }).catch(function(error) {
                    console.log(error);
                });
            }
			
        });
$A.enqueueAction(contactAction);
	}
})