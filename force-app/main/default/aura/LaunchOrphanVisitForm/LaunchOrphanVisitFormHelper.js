({
    fetchOVHelper : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.fetchOrphanVisits");
        console.log(recordId);
        if(recordId == null || recordId == ''){
            component.set("v.showSearch", true);
            console.log(component.get("v.showSearch"));
        }else{
            component.set("v.showSearch", false);
        }
        action.setParams({OrphanId :recordId });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.OrphanVisitList", response.getReturnValue());
            }
        });
        var action2 = component.get("c.countOrphanVisitsbySearch");
        action2.setParams({key : null,OrphanId :component.get("v.recordId")});
        action2.setCallback(this, function(response1){
            var state1 = response1.getState();
            if (state1 === "SUCCESS") {
                component.set("v.countOV", response1.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action2);
    },
    
   })