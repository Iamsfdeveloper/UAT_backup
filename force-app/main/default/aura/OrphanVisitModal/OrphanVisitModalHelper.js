({
statusChange_helper : function (component, event, helper) {
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
           // window.location.reload();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Success!",
                message: "Successfull!",
                type: "success"
            });
           toastEvent.fire();
            $A.get('e.force:refreshView').fire();
        } 
        else if (event.getParam('status') === "ERROR") {
            component.set("v.hasError", true);
        }
		
	}
})