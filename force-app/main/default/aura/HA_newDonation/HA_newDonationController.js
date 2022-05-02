/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 01-18-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   11-20-2020   Iamsfdeveloper   Initial Version
**/
({
      doInit:function(component,event,helper){
        var workspaceAPI = component.find("workspace");
      
        if(workspaceAPI){ //&& !component.get("v.isDoneRendering")){
           // component.set("v.isDoneRendering", true);
            workspaceAPI.getFocusedTabInfo().then(function(res) {
            console.log(JSON.stringify(res));
            component.set("v.callRecordId",res.pageReference.state.ws.split('/')[4]);
            
        }) .catch(function(error) {
            console.log('HA_newDonation=>doInit==>'+error);
        });
        }    
    },
    openDonationInSubtab:function(component,event,helper){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            if(response){
                workspaceAPI.getFocusedTabInfo().then(function(resp) {
                    workspaceAPI.openSubtab({
                        parentTabId: resp.tabId,
                        url: '/lightning/r/Opportunity/'+event.getParam('donationId')+'/view',
                        focus: true
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });     
            }else{
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": event.getParam('donationId')
                });
                navEvt.fire();
            }
        })
        .catch(function(error) {
            console.log('HA_newDonation=>openDonationInSubtab==>'+error);
        });
        
    },
    handleCanceAction:function(component){
        $A.get("e.force:closeQuickAction").fire();
    }

})