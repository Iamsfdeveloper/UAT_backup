({
	handleCanceAction:function(component){
        $A.get("e.force:closeQuickAction").fire();
    },
    navigateInstrcution:function(component,event){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.getParam('donationId')
        });
        navEvt.fire();
    }

})