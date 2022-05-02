/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 06-11-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   06-11-2021   Iamsfdeveloper   Initial Version
**/
({
    CSV2JSON: function (component,csv) {
        var arr = []; 
        arr =  csv.split('\n');
        //arr.pop();
        var jsonObj = [];
        var headers = arr[0].split(',');
        for(var i = 1; i < arr.length; i++) {
            var data = arr[i].split(',');
            var obj = {};
            if(data.lenght>1 && headers.length != data.length){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "title": "Error!",
                    "message": "Upload File Contains, additional comma(\,) or Extra Lines"
                });
            toastEvent.fire();
                return undefined;
            }
            for(var j = 0; j < data.length; j++) {
                obj[headers[j].trim()] = data[j].trim();
                
            }
            jsonObj.push(obj);
        }
        var json = JSON.stringify(jsonObj);
        return json;
    },
    
    createDonations : function(cmp, data) {
        var action = cmp.get('c.insertDonationsFromCSVFile');
        action.setParams({
            dataFromSpreadsheet : data, 
            uploadType : cmp.get('v.value'),
            fileName : cmp.get('v.fileNameValue')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                
                    cmp.set("v.spinner", false);
                    cmp.set("v.hideButton",true);
                    cmp.set("v.showResults",true);
                    var responseValue =response.getReturnValue();
                    responseValue.forEach(function(record){
                        record.linkName = '/'+record.Id;
                    });
                	cmp.set("v.processList",responseValue);
                cmp.set('v.mycolumns', [
                    {label: 'Process Start Date', fieldName: 'CreatedDate', type: 'date',typeAttributes: {day: 'numeric',  month: 'short',  year: 'numeric',  hour: '2-digit',  minute: '2-digit',  second: '2-digit',  hour12: true}},
                    {label: 'Name', fieldName: 'linkName', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
                    {label: 'Upload Type', fieldName: 'Upload_File_Type__c', type: 'text'},
                    {label: 'Status', fieldName: 'Status__c', type: 'text'}
                ]);
            }
        });
        $A.enqueueAction(action);
    }
})