/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 01-10-2022
 * @last modified by  : Iamsfdeveloper
**/
({
    showToast:function(type,title,message){
        var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":type,
                    "title": title,
                    "message": message
                });
        toastEvent.fire();
    }
})