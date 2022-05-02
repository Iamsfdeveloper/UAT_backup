trigger DirectDebitHistoryTrigger on Income_Debit_History__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

    TriggerSettings__c ts = TriggerSettings__c.getOrgDefaults();
    if(ts.Direct_Debit_History_Trigger__c)
    {
        if (Trigger.isBefore)
        {
            if(Trigger.isInsert)
            {
                TriggerHandler_DirectDebitHistory.OnBeforeInsert(Trigger.new);
            }

            if(Trigger.isUpdate)
            {
                TriggerHandler_DirectDebitHistory.OnBeforeUpdate(Trigger.newMap, Trigger.oldMap);
            }

            if(Trigger.isDelete)
            {
            }    
        } 
        else if (Trigger.isAfter)
        {
            if(Trigger.isInsert)
            {
                TriggerHandler_DirectDebitHistory.OnAfterInsert(Trigger.newMap);
            }

            if(Trigger.isUpdate)
            {
                TriggerHandler_DirectDebitHistory.OnAfterUpdate(Trigger.newMap, Trigger.oldMap);
            }

            if(Trigger.isDelete)
            {
            }

            if(Trigger.isUndelete)
            {
            } 
        }
    }
}