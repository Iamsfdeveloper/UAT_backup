({
	doInit : function(component, event, helper) {
		helper.getDonations(component);
	},
    switchTab:function(component,event,helper){
        debugger;
        if(event.currentTarget.dataset.name=='recurring')
            component.set("v.paymentPlan",true);
        else
            component.set("v.paymentPlan",false);
        helper.getDonations(component);
    },
    toggleFilter:function(component){
        component.set("v.showFilter",!component.get("v.showFilter"));
    },
    filterdata: function(component, event, helper) {        
        helper.filterdata(component, event, helper);
    },
    typeChange: function(component, event, helper){
        let sType = component.get("v.selectedType");
        var typeString = "";
        for(var i = 0; i < sType.length; i++){
            if(sType[i] == 'ZK'){
                typeString += $A.get("$Label.c.Zakat")+' ';
            }
            if(sType[i] == 'SD'){
                typeString += $A.get("$Label.c.Sadaqh")+' ';
            }
            if(sType[i] == 'XX'){
                typeString += $A.get("$Label.c.General")+' ';
            }
        }
        component.set("v.typeString", typeString);
    }
})