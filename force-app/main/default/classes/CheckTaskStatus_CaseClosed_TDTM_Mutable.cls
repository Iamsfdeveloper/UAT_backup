global with sharing class CheckTaskStatus_CaseClosed_TDTM_Mutable extends npsp.TDTM_RunnableMutable {
    global override void run(List<SObject> listNew, List<SObject> listOld,
            npsp.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult,
            npsp.TDTM_Runnable.DmlWrapper dmlWrapper) {
                try{
                Map<Id,Case> newMap = new Map<Id,Case>((List<Case>)listNew);
                if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {    
                    Set<Id> closeCaseIds = new Set<Id>();
                    for(Case tempcase:(List<Case>)listNew){
                        if(tempcase.status =='Closed')
                            closeCaseIds.add(tempcase.Id);
                    }
                    If(closeCaseIds.size()>0){
                        Integer TotalRows = (Integer)[Select Count(Id) TotalRows FROM Task Where Status='Open' AND WhatId IN: closeCaseIds][0].get('TotalRows');
                        if(TotalRows>0)
                            listNew[0].addError('Please complete all Open Task,Before Closing Case');
                    }
                }
            }Catch(Exception e){
                String ErrorContext = 'TriggerIsExecuting: '+Trigger.isExecuting+' OperationType: '+Trigger.operationType+' isFuture: '+System.isFuture()+' ApexClassName: updateItemAllocationGiftAid_TDTM_Mutable userId :'+UserInfo.getUserId();
                HA_Logger.CreateErrorLog(JSON.Serialize(e),'Contact',ErrorContext);
                throw e;
            }       

    }
}