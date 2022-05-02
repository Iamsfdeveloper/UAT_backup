({
	cloneCN : function(component, event, helper) {
		helper.showSpinner(component, event, helper); 
        var action = component.get("c.cloneConceptNote");
        action.setParams({
            'conceptNoteId': component.get("v.recordId")
        });
        action.setCallback(this, function(result) {
            var strValue = result.getReturnValue();
            var state = result.getState();
            helper.hideSpinner(component, event, helper); 
            if (state === "SUCCESS" && strValue != '' && strValue != null) { 
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": 'Concept Note Successfully cloned with related records',
                    "type" : "success"
                });
                toastEvent.fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": strValue
                });
                navEvt.fire();
            }
            else {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": 'Please Contact Administrator,Internal error occured',
                    "type" : "error"
                });
                toastEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
	}
})