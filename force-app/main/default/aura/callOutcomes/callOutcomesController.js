/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 11-20-2020
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   11-19-2020   Iamsfdeveloper   Initial Version
**/
({
    doInit:function(cmp,event,helper){
        var workspaceAPI = cmp.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            if(response){
                cmp.isworkspaceAPI = response;
                workspaceAPI.getTabInfo().then(function(res) {
                    
                    if(res.pageReference.state.ws.split('/')[4] != undefined){
                        cmp.set("v.showDailer",true);
                    	cmp.set("v.callRecordId",res.pageReference.state.ws.split('/')[4]);
                }
                    
                });
            }
        }).catch(function(error) {
            console.log(error);
        });
    },
   logACall : function( cmp, event, helper ) {
            let callOutcome = event.getSource().get("v.name");
            var actionAPI = cmp.find("quickActionAPI");
            var fields = { Subject: {value: "Call - "+callOutcome,type:'Set'}, whoId: {Id: cmp.get("v.recordId")},Call_OutCome__c:{value:callOutcome,type:'Set'},Description:{value:cmp.get("v.taskObj.Description"),type:'Set'}};
            var args = {actionName: "LogACall", entityName: "Contact", targetFields: fields,submitOnSuccess:true};
            actionAPI.setActionFieldValues(args).then(function(){
                actionAPI.invokeAction(args);
                helper.closeFocusedTab(cmp);
            }).catch(function(e){
                console.error(e.errors);
            });
    },
    omniChannelWorkAssigned: function( cmp, event, helper ) {
        Console.log(event.getParams());
    },
    callback :function( cmp, event, helper ) {
            let callOutcome = event.getSource().get("v.name");
            var actionAPI = cmp.find("quickActionAPI");
        	let taskdesc = (cmp.find("taskDesc").get("v.value")=='')?callOutcome:cmp.find("taskDesc").get("v.value");
            var fields = { Subject: {value: callOutcome,type:'Set'}, whoId: {Id: cmp.get("v.recordId")},Description:{value:taskdesc,type:'Set'}};
            var args = {actionName: "NewTask", entityName: "Contact", targetFields: fields,submitOnSuccess:false};
            actionAPI.setActionFieldValues(args).then(function(){
                actionAPI.selectAction(args);
            }).catch(function(e){
                console.error(e.errors);
            });
    },
    SendEmail:function( cmp, event, helper ) {
        helper.showSpinner(cmp);
        var actionAPI = cmp.find("quickActionAPI");
        let args = {actionName: "SendEmail", entityName: "Contact",targetFields:{whoId:{value: cmp.get("v.recordId")}}};
        actionAPI.setActionFieldValues(args).then(function(result){
            
            actionAPI.invokeAction(args);
            
        }).catch(function(e){
            if(e.errors){
                //helper.hideSpinner(cmp);
                //If the specified action isn't found on the page, show an error message in the my component
            }
        });
    },
    logACallwithApex:function(cmp, event, helper){
        let callOutcome = event.getSource().get("v.name");
        helper._ApexLogCall(cmp,event,callOutcome);   
    },
    createDonationActivity:function(cmp, event, helper){
        let donationObj = event.getParam('message');
        let callOutcome = donationObj.callOutCome;
        let logACall = cmp.get("c.createTask");
        let taskObj = cmp.get("v.taskObj");
        taskObj.Subject = "Call - "+callOutcome;
        taskObj.Status = 'Completed';
        taskObj.TaskSubtype='Call';
        taskObj.Description = (cmp.find("taskDesc").get("v.value")=='')?callOutcome:cmp.find("taskDesc").get("v.value");
        taskObj.whoId= donationObj.contactId;
        taskObj.whatId= donationObj.opportunityId;
        taskObj.Call_OutCome__c = callOutcome;
        taskObj.CallType='Outbound';
        
        if(!$A.util.isUndefined(cmp.get("v.callRecordId"))){
            logACall.setParam('parentRecordId',cmp.get("v.callRecordId"));
            logACall.setParam('obj',JSON.stringify(taskObj));
            logACall.setCallback(this,function(response){
                if(response.getState()==='SUCCESS'){
                    cmp.find("taskDesc").set("v.value",'');
                    helper.hideSpinner(cmp);
                    $A.get('e.force:refreshView').fire();
                    helper.enableReadyForNextCall(cmp);
                }else{
                     helper.showToast('error','Error',response.getError()[0].message);
                    helper.hideSpinner(cmp);
                } 
            });
            $A.enqueueAction(logACall);
        }
    },
    logACallwithApexAndUpdate:function(cmp, event, helper){
        helper.showSpinner(cmp);
        let callOutcome = event.getSource().get("v.title");
        let contacObj = {Id:cmp.get("v.recordId")};
        contacObj[event.getSource().get("v.name")] = true;
        let logACall = cmp.get("c.createTaskAndUpdateRecord");
        let taskObj = cmp.get("v.taskObj");
        taskObj.Subject = "Call - "+callOutcome;
        taskObj.Status = 'Completed';
        taskObj.TaskSubtype='Call';
        taskObj.Description = (cmp.find("taskDesc").get("v.value")=='')?callOutcome:cmp.find("taskDesc").get("v.value");
        taskObj.whoId= cmp.get("v.recordId");
        taskObj.Call_OutCome__c = callOutcome;
        taskObj.CallType='Outbound';
        if(!$A.util.isUndefined(cmp.get("v.callRecordId"))){
            logACall.setParam('parentRecordId',cmp.get("v.callRecordId"));
            logACall.setParam('obj',JSON.stringify(taskObj));
            logACall.setParam('updateObj',JSON.stringify(contacObj));
            logACall.setCallback(this,function(response){
                if(response.getState()==='SUCCESS'){
                    cmp.find("taskDesc").set("v.value",'');
                    helper.hideSpinner(cmp);
                    $A.get('e.force:refreshView').fire();
                    helper.enableReadyForNextCall(cmp);
                }else{
                    helper.showToast('error','Error',response.getError()[0].message);
                    helper.hideSpinner(cmp);
                } 
            });
            $A.enqueueAction(logACall);
        }
        
       
        
    },
    Donation:function(cmp,event,helper){
        helper.showSpinner(cmp);
        /*
        var actionAPI = cmp.find("quickActionAPI");
        var args = {actionName: "Contact.Create_Donation"};
        actionAPI.selectAction(args).then(function(result){
            //Action selected; show data and set field values
        }).catch(function(e){
            if(e.errors){
                //If the specified action isn't found on the page, show an error message in the my component
            }
        });
        */
       helper.showDonationModal(cmp,event);
    
    },
    handleEmailSent:function(cmp,event,helper){
        
        if(event.getParam('message') == "Email sent." && event.getParam('type') =="success"){
            helper.hideSpinner(cmp);
        	helper._ApexLogCall(cmp,event,'Email'); 
        }else if(event.getParam('message') == "Task Call Back was created."){
        	helper._ApexLogCall(cmp,event,'Call Back'); 
        }
    },
    closeTab:function(cmp,event,helper){
        helper.closeFocusedTab(cmp);
    },
    openDonationInSubtab:function(component,event,helper){
       
        var workspaceAPI = component.find("workspace");
        if(component.isworkspaceAPI){
                workspaceAPI.openSubtab({
                        url:'/lightning/r/Opportunity/'+event.getParam('donationId')+'/view',
                        focus: true
                })
                .catch(function(error) {
                    console.log(error);
                });
                component._overlay.close();
        }else{
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": event.getParam('donationId')
            });
            navEvt.fire();
            component._overlay.close();
        }
        
    },
    cancelDonation:function(cmp,event,helper){
        cmp._overlay.close();
        helper.hideSpinner(cmp);
         
    },
})