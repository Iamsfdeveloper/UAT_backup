global with sharing class CampaignTriggerHandler_TDTM_Mutable extends npsp.TDTM_RunnableMutable{
    global override void run(List<SObject> listNew, List<SObject> listOld,
    npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult,
    npsp.TDTM_Runnable.DmlWrapper dmlWrapper) {   
        
        try{
            if(triggerAction==npsp.TDTM_Runnable.Action.AfterInsert){
                if(objResult.getLabel() == 'CampaignMember'){
                    CreateCallList_For_CampaignMember.createCallList(listNew);
                }               
                
            }
            
            if(triggerAction==npsp.TDTM_Runnable.Action.BeforeUpdate){
                if(objResult.getLabel() == 'Campaign'){
                    GAU_ValidationHandler.createCallList(listNew, listOld); 
                }
            }
        }Catch(Exception e){String ErrorContext = 'TriggerIsExecuting: '+Trigger.isExecuting+' OperationType: '+Trigger.operationType+' isFuture: '+System.isFuture()+' ApexClassName: LeadTriggerHandler_TDTM_Mutable userId :'+UserInfo.getUserId();HA_Logger.CreateErrorLog(JSON.Serialize(e),'Contact',ErrorContext);throw e;} 
    }
}