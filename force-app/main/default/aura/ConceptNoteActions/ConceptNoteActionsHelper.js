({
	showSpinner: function(component, event, helper) {

        component.set("v.spinner", true); 
    },
     
    hideSpinner : function(component,event,helper){
        
        component.set("v.spinner", false);
    }
})