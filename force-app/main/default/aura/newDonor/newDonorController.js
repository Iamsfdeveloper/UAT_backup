/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 01-10-2022
 * @last modified by  : Iamsfdeveloper
**/
({
    handleSuccess:function(component,event,helper){
        helper.showToast('success','Success...!','Record Update Successfully!');
        if(component.get("v.closeModal")){
            component.getEvent("close").fire();
        }else{
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    close:function(component,event,helper){
        if(component.get("v.closeModal")){
            component.getEvent("close").fire();
        }else{
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    handleSubmit:function(component,event,helper){
        event.preventDefault();
        if($A.util.isUndefinedOrNull(component.get("v.selectedAddressObject"))){
            helper.showToast('error','Error...!','Please Select Address');
            return;
        }else{
            
            var fields = event.getParam('fields');
            let address = component.get("v.selectedAddressObject");
            if(!$A.util.isEmpty(address)){
            if(!$A.util.isEmpty(address.Line1)){
                 fields.MailingStreet = component.get("v.selectedAddressObject.Line1");
            }
            if(!$A.util.isEmpty(address.Line2)){
                 fields.MailingStreet +=' '+component.get("v.selectedAddressObject.Line2");
            }
                if(!$A.util.isEmpty(address.City)){
                 fields.MailingCity = component.get("v.selectedAddressObject.City");
            }
                if(!$A.util.isEmpty(address.Province)){
                 fields.MailingState = component.get("v.selectedAddressObject.Province");
            }
                if(!$A.util.isEmpty(address.PostalCode)){
                 fields.MailingPostalCode = component.get("v.selectedAddressObject.PostalCode");
            }
                if(!$A.util.isEmpty(address.CountryName)){
                 fields.MailingCountry = component.get("v.selectedAddressObject.Line2");
            }
                
            }
            
            component.find('newDonor').submit(fields);
        }
       
    },
})