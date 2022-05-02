({
	_getAddress : function(component) {
		var queryTerm = component.find('postalCode').get('v.value');
        let action = component.get("c.getAddress");
        if (queryTerm != undefined && queryTerm.length >=5) {
            component.set("v.selectedAddressObject",{});
            component.set("v.autoCompleteList",[]);
            component.set("v.addressObject",{});
            
            action.setParam('postalCode',queryTerm);
            action.setCallback(this,function(response){
                if(response.getState()=='SUCCESS'){
                    let result = response.getReturnValue();
                    if(result['addressList']){
                        component.set("v.resultAddress",result['addressList']);
                        component.set("v.autoCompleteList",result['addressList']);
                    }
                    if(result['formateddAddress']){
                        component.set("v.addressObject",result['formateddAddress']);
                        component.set("v.selectedAddressObject",result['addressList'][0]);
                        
                    }
                }
            });
            $A.enqueueAction(action);
        }
	},
    showToast:function(type,title,message){
        var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":type,
                    "title": title,
                    "message": message
                });
    }
})