({
    doInit: function (component, event, helper) {
        let action = component.get("c.getDonationValues");
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                var results = response.getReturnValue();
                if(results.donationRec.length){
                    var pageArr = [];
                    component.set("v.recentDonationList", results.donationRec);
                    component.set("v.donation", results.donationRec[0]);
                    for(var i = 0;i < results.donationRec.length; i++){
                        pageArr.push(i);
                    }
                    component.set("v.pageSize", pageArr);
                }
                if(results.conRec != undefined && results.conRec != null){                    
                    component.set("v.donorDetails", results.conRec);
                    let loggedUser = {'donorDetails':component.get("v.donorDetails"),'menu':{'logout':'/secur/logout.jsp','myAccount':'/family'}};
                    //sessionStorage.setItem('localStr',JSON.stringify(loggedUser));
					window.document.cookie = "sessiontest="+JSON.stringify(loggedUser);+"path=/;domain=humanappeal.org.uk;";
                }
            }
        });
        $A.enqueueAction(action);
    },
    toggleEditModal: function (component, event, helper) {
        component.set("v.showModal", !component.get("v.showModal"));
    },
    changeDonation: function (component, event, helper) {
        var sourceId = event.target.getAttribute('id');
        var donationList = component.get("v.recentDonationList");
        component.set("v.donation", donationList[sourceId]);
        
    },
    navigateToDonation : function(component, event, helper) {

        let url = location.href;
    
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": url + 'my-donations'
        });
        urlEvent.fire();
    }
})