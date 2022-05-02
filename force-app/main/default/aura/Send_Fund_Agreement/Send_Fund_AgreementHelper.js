({
	resetCheck : function(component) {
		
         	var agreementStatus = component.get("v.Status");
            console.log('**agreementStatus**'+agreementStatus);
            if (agreementStatus != '') {
                
                component.set("v.isStatusCheck", true);
            }
            var action = component.get("c.isStatusCheck");
            action.setParams({
                'conceptNoteId': component.get("v.recordId")
            });
            action.setCallback(this, function(result) {
                var strValue = result.getReturnValue();
                console.log('****'+strValue);
                if (strValue == 'In Progress') {
                    
                    component.set("v.isDraft", false);
                    component.set("v.isCancelled", false);
                    component.set("v.isCompleted", false);
                    component.set("v.isInProgress", true);
                }
                else if (strValue == 'Completed') {
                    
                    component.set("v.isDraft", false);
                    component.set("v.isCancelled", false);
                    component.set("v.isInProgress", false);
                    component.set("v.isCompleted", true);
                }
                else if (strValue == 'Cancelled') {
                    
                    component.set("v.isDraft", false);
                    component.set("v.isCompleted", false);
                    component.set("v.isInProgress", false);
                    component.set("v.isCancelled", true);
                }
                else if (strValue == 'Draft') {
                    
                    component.set("v.isDraft", true);
                    component.set("v.isCancelled", false);
                    component.set("v.isCompleted", false);
                    component.set("v.isInProgress", false);
                }
    
            });
            $A.enqueueAction(action);
        },
    showSpinner: function(component, event, helper) {

        component.set("v.spinner", true); 
    },
     
    hideSpinner : function(component,event,helper){
        
        component.set("v.spinner", false);
    }
})