({
	getDonations : function(component) {
        component.set("v.showSpinner", true);
        let action = component.get("c.getDonations");
        action.setParams({'PaymentPlan': component.get("v.paymentPlan")});
        action.setCallback(this,function(response){
            let state = response.getState();			
            if(state=='SUCCESS'){
                component.set("v.donationList",response.getReturnValue().donationList);
                component.set("v.contactId", response.getReturnValue().contactId);
                if(response.getReturnValue().donationList.length == 0){
                    component.set("v.showRow", false);
                }else{
                    var dType = [];
                    dType = response.getReturnValue().donationValueWrapper.totalByType;
                    for(var key in dType){
                        if(key == 'ZK'){
                            component.set("v.totalZakat", dType[key]);
                        }
                        if(key == 'SD'){
                            component.set("v.totalSadaqh", dType[key]);
                        }
                        if(key == 'XX'){
                            component.set("v.totalGeneral", dType[key]);
                        }
                    }
                    component.set("v.totalGiftAid", response.getReturnValue().donationValueWrapper.totalGift);
                    component.set("v.grandTotal", response.getReturnValue().donationValueWrapper.totalDonation);
                    component.set("v.showRow", true);
                }
                component.set("v.showSpinner", false);
            }
            else{
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
	},
    filterdata: function(component, event, helper) {    
        component.set("v.showSpinner", true);    
        let action = component.get("c.getFilteredData");
        action.setParams({
            'startDate' : component.get("v.startDate"),
            'endDate' : component.get("v.endDate"),
            'stype' : component.get("v.selectedType")
        });
        action.setCallback(this,function(response){            
            let state = response.getState();			
            if(state=='SUCCESS'){
                component.set("v.donationList",response.getReturnValue());
                if(response.getReturnValue().length == 0){
                    component.set("v.showRow", false);
                }else{
                    component.set("v.showRow", true);
                }
                component.set("v.showSpinner", false);
            }else{
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    }
})