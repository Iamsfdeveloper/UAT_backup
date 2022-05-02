({
	Init : function(component, event, helper) {
		let action = component.get("c.doInit");
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.donation",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})