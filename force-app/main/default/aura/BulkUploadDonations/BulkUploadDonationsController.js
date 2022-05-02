/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 06-07-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   06-07-2021   Iamsfdeveloper   Initial Version
**/
({
     doInit : function(component, event, helper) {
        var initAction = component.get('c.initGetData');
        initAction.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var responseValue =response.getReturnValue();
                responseValue.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set("v.processList",responseValue);
                console.log(component.get("v.processList"));
                component.set('v.mycolumns', [
                    {label: 'Process Start Date', fieldName: 'CreatedDate', type: 'date',typeAttributes: {day: 'numeric',  month: 'short',  year: 'numeric',  hour: '2-digit',  minute: '2-digit',  second: '2-digit',  hour12: true}},
                    {label: 'Name', fieldName: 'linkName', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
                    {label: 'Upload Type', fieldName: 'Upload_File_Type__c', type: 'text'},
                    {label: 'Status', fieldName: 'Status__c', type: 'text'}
                ]);
            }
        });
        $A.enqueueAction(initAction);        
    },
    CreateRecord: function (component, event, helper) {
        component.set("v.hideButton",true);
        component.set("v.spinner", true);
        var fileInput = component.find("file").getElement();
        console.log(fileInput);
        if(fileInput.files.length>0){
        var file = fileInput.files[0];
        component.set("v.fileNameValue",file.name);
        if (file) {
            var reader = new FileReader();
            reader.readAsText(file, "UTF-8");
            reader.onload = function (evt) {
                var csv = evt.target.result;
                var result = helper.CSV2JSON(component,csv);
                if(result)
                var result1 = helper.createDonations(component,result);
                else{
                    component.set("v.spinner", false);
                    component.set("v.hideButton",false);
                    return;
                }
                  
            }
            reader.onerror = function (evt) {
                console.log("error reading file");
            }
        }
        }else{
            component.set("v.spinner", false);
            component.set("v.hideButton",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"error",
                "title": "Error!",
                "message": "Please Select the File to Upload."
            });
            toastEvent.fire();
        }
    }
    
    
})