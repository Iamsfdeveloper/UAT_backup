/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 02-09-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   02-08-2021   Iamsfdeveloper   Initial Version
**/
({
    recordUpdated: function(component, event, helper) {
        
        var changeType = event.getParams().changeType;
        
        if (changeType === "ERROR") { /* handle error; do this first! */ }
        else if (changeType === "LOADED") { /* handle record load */
            component.find('postalCode').set('v.value',component.get("v.contactRecord.MailingPostalCode"));
        	helper._getAddress(component);
        }
            else if (changeType === "REMOVED") { /* handle record removal */ }
                else if (changeType === "CHANGED") { /* handle record change */ }
    },
	handleKeyUp : function(component, event, helper) {
		helper._getAddress(component);
    },
    handleKeyUpAddress: function(component, event, helper) {
        
    },
    handleOnFoucs:function(component, event, helper) {
       
        component.set('v.onfocusShow',true);
        component.set('v.canBlur',false);
        
    },
   handleClickToRemove: function(component, event, helper) {
       component.set("v.selectedAddressObject",{});
       component.selectedIndex = undefined;
       component.find("selectAddress").focus();
       
    },
    handleOnSelect : function(component, event, helper) {
        let addressList = component.get("v.resultAddress");
        component.selectedIndex = event.currentTarget.dataset.index;
        component.set("v.selectedAddressObject",addressList[component.selectedIndex]); 
        let formatAddressAction = component.get("c.getFormattedAddress");
        formatAddressAction.setParam('Id',event.currentTarget.dataset.value);
        formatAddressAction.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
                component.set('v.onfocusShow',false);
                component.set("v.addressObject",response.getReturnValue());
            }
        });
        $A.enqueueAction(formatAddressAction);
        
    },
    handleSaveRecord:function(component, event, helper){
        if(!component.find("mailingAddress").checkValidity()){
            component.find("mailingAddress"). reportValidity();
            return;
        }
        component.set("v.loaded",true);
        let resultAddressObject = component.get("v.addressObject");
        let contactRecord = component.get("v.contactRecord");
        contactRecord.MailingStreet = resultAddressObject.Line1 +', '+resultAddressObject.Line2;
        contactRecord.MailingCountry = resultAddressObject.CountryName;
        contactRecord.MailingState = resultAddressObject.Province;
        contactRecord.MailingCity = resultAddressObject.City;
        contactRecord.MailingPostalCode =resultAddressObject.PostalCode;
        component.set("v.contactRecord",contactRecord);
        component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                
                
                if(component.find("recordAddressEditor")){
                    let CurrentAddressRecord = component.get("v.CurrentAddressRecord");
                    CurrentAddressRecord.npsp__Verified__c = true;
                    CurrentAddressRecord.npsp__Verification_Status__c = 'Verified';
					component.set("v.CurrentAddressRecord",CurrentAddressRecord); 
                    component.find("recordAddressEditor").saveRecord(function(saveAddressResult){
                        if(saveAddressResult.state === "SUCCESS" || saveAddressResult.state === "DRAFT"){
                            component.set("v.loaded",false);
                            $A.get('e.force:refreshView').fire();
                            helper.showToast('success',"Success!","Address has been updated successfully.");
                        }
                        
                    });                                                   
                }   
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' +
                           JSON.stringify(saveResult.error));
                component.set("v.loaded",false);
                helper.showToast('error',"Error!",JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            	component.set("v.loaded",false);
                helper.showToast('error',"Error!",JSON.stringify(saveResult.error));
            }
        }));}
    
})