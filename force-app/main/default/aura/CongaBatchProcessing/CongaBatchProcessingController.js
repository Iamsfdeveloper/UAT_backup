({
    doInit : function(component, event, helper) {
        component.set("v.spinner", true);
        var initAction = component.get('c.initGetData');
        initAction.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                component.set("v.spinner", false);
                var responseValue = response.getReturnValue();
                component.set("v.processList",responseValue.bulkLogs);
                component.set("v.General_ReceiptsWithout_Orphans_and_OTC",responseValue.generalWithoutOrphanAndOlive);
                component.set("v.General_Receipts_And_Orphan_Packs",responseValue.generalWithOrphans);
                component.set("v.General_Receipts_and_Olive_Tree_Certs",responseValue.generalWithOliveTree);
                component.set("v.Payment_Receipts_Without_Orphans",responseValue.paymentReceiptWithoutOrphanAndOlive);
                component.set("v.Payment_Receipt_Orphan_Packs",responseValue.paymentReceiptWithOrphans);
                component.set("v.Poetry_Receipts",responseValue.poetryReceipts);
                console.log(component.get("v.processList"));
                component.set('v.mycolumns', [
                    {label: 'Batch Name', fieldName: 'Batch_Name__c', type: 'text'},
                    {label: 'Batch Status', fieldName: 'Batch_Status__c', type: 'text'},
                    {label: 'Failure Reason', fieldName: 'Failure_Reason__c', type: 'text'}
                ]);
                
            }
        });
        $A.enqueueAction(initAction);        
    },
    exportDataURL: function (component, event, helper) {
        component.set("v.spinner", true);
        var buttonType = event.getSource().getLocalId();
        var action = component.get('c.exportDataUsingCongaComposerURL');
        action.setParams({
            processName : buttonType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var responseValue = response.getReturnValue();
                component.set("v.spinner", false);
                component.set("v.showResults",true);
                component.set("v.processList",responseValue['logs']);
                component.set('v.mycolumns', [
                    {label: 'Batch Name', fieldName: 'Batch_Name__c', type: 'text'},
                    {label: 'Batch Status', fieldName: 'Batch_Status__c', type: 'text'},
                    {label: 'Failure Reason', fieldName: 'Failure_Reason__c', type: 'text'}
                ]);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Export Process Initiated, Please check below for the status",
                    "type": 'success',
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                if(!$A.util.isUndefined(responseValue['url'])){
                    let urls = responseValue['url'];
                    if(urls.length>0)
                        window.open(urls[0]);
                    if(urls.length>1)
                        window.open(urls[1]);
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    exportData: function (component, event, helper) {
        component.set("v.spinner", true);
        var buttonType = event.getSource().getLocalId();
        var action = component.get('c.exportDataUsingCongaComposer');
        action.setParams({
            processName : buttonType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                var responseValue = response.getReturnValue();
                component.set("v.spinner", false);
                component.set("v.showResults",true);
                component.set("v.processList",responseValue);
                component.set('v.mycolumns', [
                    {label: 'Batch Name', fieldName: 'Batch_Name__c', type: 'text'},
                    {label: 'Batch Status', fieldName: 'Batch_Status__c', type: 'text'},
                    {label: 'Failure Reason', fieldName: 'Failure_Reason__c', type: 'text'}
                ]);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Export Process Initiated, Please check below for the status",
                    "type": 'success',
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    },
    navigateToOnDemandRecord:function(component,event){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/APXTConga4__Composer_QuickMerge__c/a1v4J000003bX99QAE/view"
        });
        urlEvent.fire();
        //https://humanappeal--uat.lightning.force.com/lightning/r/APXTConga4__Composer_QuickMerge__c/a1v4J000003bX99QAE/view
    }
})