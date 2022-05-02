/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 01-18-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   11-19-2020   Iamsfdeveloper   Initial Version
**/
({
    closeFocusedTab : function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            let parentTabId = response.parentTabId;
            workspaceAPI.closeTab({tabId: parentTabId});
       }) .catch(function(error) {
            console.log(error);
        });
    },
    showSpinner:function(component){
        component.set("v.loaded",true);
    },
    hideSpinner:function(component){
        component.set("v.loaded",false);
    },
    enableReadyForNextCall:function(component){
        component.set("v.readyForNextCall",true);
    },

    showDonationModal: function(component, evt) {
        var modalBody;//,
        try{
            $A.createComponent("c:newDonation", {recordId:component.get("v.recordId"),regionalOfficeCode:component.get("v.objContact.Regional_Office_Code__c"),onopendonation:component.getReference("c.openDonationInSubtab"),oncanceldonation:component.getReference("c.cancelDonation"),campaignId:component.get("v.callRecord.CampaignId__c")},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({
                       header: "Create Donation",
                       body: modalBody,
                       showCloseButton: true,
                       cssClass: "slds-modal_large",
                       closeCallback: function() {
                        
                        component.set("v.loaded",false);
                       }
                   }).then(function (overlay) {
                    // cache the overlay into the component
                    component._overlay = overlay;
                });
               }
           });
        }catch(ex){
            console.log(ex);
        }
    },
    _ApexLogCall:function(cmp,event,callOutcome){
        this.showSpinner(cmp);
        let logACall = cmp.get("c.createTask");
        let taskObj = cmp.get("v.taskObj");
        taskObj.Subject = "Call - "+callOutcome;
        taskObj.Status = 'Completed';
        taskObj.TaskSubtype='Call';
        taskObj.Description = (cmp.find("taskDesc").get("v.value")=='')?callOutcome:cmp.find("taskDesc").get("v.value");
        taskObj.whoId= cmp.get("v.recordId");
        taskObj.Call_OutCome__c = callOutcome;
        taskObj.Call_Type__c='Outbound';
       // $A.util.isUndefined(cmp.get("v.callRecordId"))?'':cmp.get("v.callRecordId");
        logACall.setParam('parentRecordId',$A.util.isUndefined(cmp.get("v.callRecordId"))?'':cmp.get("v.callRecordId"));
        logACall.setParam('obj',JSON.stringify(taskObj));
            logACall.setCallback(this,function(response){
                if(response.getState()==='SUCCESS'){
                    cmp.find("taskDesc").set("v.value",'');
                    this.hideSpinner(cmp);
                    $A.get('e.force:refreshView').fire();
                    this.enableReadyForNextCall(cmp);
                }else{
                    this.showToast('error','Error',response.getError()[0].message);
                    this.hideSpinner(cmp);
                } 
            });
            $A.enqueueAction(logACall);
        
    },
    showToast : function(type,title,errMessage) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "type":type,
        "title": title+"!",
        "message": errMessage+'.'
    });
    //toastEvent.fire();
}
})