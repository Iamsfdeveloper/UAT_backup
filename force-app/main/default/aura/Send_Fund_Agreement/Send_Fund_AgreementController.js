({
	doInit: function(component, event, helper) {
		
        helper.resetCheck(component);
        
        
    },
    sendAgreement: function(component, event, helper){
        helper.showSpinner(component, event, helper);
        var action = component.get("c.sendAgreements");
        action.setParams({
            'conceptNoteId': component.get("v.recordId")
        });
        action.setCallback(this, function(result) {
            var strValue = result.getReturnValue();
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": strValue,
                "type" : "success"
            });
            toastEvent.fire();
			helper.hideSpinner(component, event, helper);
        });
        $A.enqueueAction(action);
    },   
    getAgreementStatusCheck: function(component, event, helper){
        helper.showSpinner(component, event, helper);
        console.log('****:--Inside get Agreement');
        var action = component.get("c.getAgreementStatus");
        action.setParams({
            'conceptNoteId': component.get("v.recordId")
        });
        action.setCallback(this, function(result) {
            var strValue = result.getReturnValue();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": strValue,
                "type" : "success"
            });
            toastEvent.fire();
			
            helper.resetCheck(component);
            helper.hideSpinner(component, event, helper);
        });
        $A.enqueueAction(action);
    }
})