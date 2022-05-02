({
    init : function(component, event, helper) {

		var action = component.get("c.generateCardPaymentLink");
		action.setParams({oppId : component.get('v.recordId')});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
	
                component.set("v.paymentURL", response.getReturnValue());
                component.set("v.isURLAvailable", true);
                $A.get('e.force:refreshView').fire();
			}
		});

		$A.enqueueAction(action);	
    },
    gotoURL : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url":"/apex/TotalProcessingPayment?recId="+component.get('v.recordId')
        });
        urlEvent.fire(); }
})