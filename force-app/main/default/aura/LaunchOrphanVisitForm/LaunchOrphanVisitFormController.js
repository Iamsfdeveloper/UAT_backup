({
    fetchOrphanVisit : function(component, event, helper) {
        helper.fetchOVHelper(component, event, helper);
    },
    
    closeModal:function(component,event,helper){
    component.set('v.ismodalClicked', false);
    var cmpTarget = component.find('Modalbox');
    var cmpBack = component.find('Modalbackdrop');
    $A.util.removeClass(cmpBack,'slds-backdrop--open');
    $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    openmodal: function(component,event,helper) {
        var record = event.target.id;
        component.set('v.recordIdOV',record);
        //console.log('record:',component.get("v.recordIdOV"));
        component.set('v.ismodalClicked', true);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    
    doSearch : function(component, event, helper) {
        var searchInput = component.find("searchInput");
        var searchValue = searchInput.get("v.value");
        var recordId = component.get("c.fetchOrphanVisits");
            var action = component.get("c.fetchOrphanVisitsbySearch");
            action.setParams({key : searchValue,OrphanId :component.get("v.recordId")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log(response.getReturnValue());
                    component.set("v.OrphanVisitList", response.getReturnValue());
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                    else {
                        console.log("Unknown Error");
                    }
                }
            });
        var action2 = component.get("c.countOrphanVisitsbySearch");
        action2.setParams({key : searchValue,OrphanId :component.get("v.recordId")});
        action2.setCallback(this, function(response1){
            var state1 = response1.getState();
            if (state1 === "SUCCESS") {
                component.set("v.countOV", response1.getReturnValue());
            }
        });
            $A.enqueueAction(action);
        $A.enqueueAction(action2);
        
    }
    
})