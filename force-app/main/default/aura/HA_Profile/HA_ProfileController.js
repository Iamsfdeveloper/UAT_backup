({
	doInit : function(component, event, helper) {
		let action = component.get('c.getProfilePhotoURL');
        action.setParam('recordId',component.get('v.recordId'));
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set('v.profilePhotoUrl',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})