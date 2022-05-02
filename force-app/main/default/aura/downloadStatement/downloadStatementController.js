({
    doInit: function(component, event, helper) {
        let today = new Date();
        component.set("v.Today",today.getFullYear()+'-'+today.getMonth()+'-'+today.getDate());
        console.log(component.get("v.Today"));
    },
	toggleSideBar : function(component, event, helper) {
		component.set("v.showsideBar",!component.get("v.showsideBar"));
	},
    downloadStatement:function(component, event, helper){
        helper.getDonationStatement(component);
    }
    
})