trigger DirectDebitTrigger on Income_Direct_Debit__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

    TriggerSettings__c ts = TriggerSettings__c.getOrgDefaults();
    if(ts.Direct_Debit_Trigger__c)
    {
        if (Trigger.isBefore)
        {
            if(Trigger.isInsert)
            {
                TriggerHandler_DirectDebit.OnBeforeInsert(Trigger.new);
            }

            if(Trigger.isUpdate)
            {
                TriggerHandler_DirectDebit.OnBeforeUpdate(Trigger.newMap, Trigger.oldMap);
            }

            if(Trigger.isDelete)
            {
            }    
        } 
        else if (Trigger.isAfter)
        {
            if(Trigger.isInsert)
            {
                TriggerHandler_DirectDebit.OnAfterInsert(Trigger.newMap);
            }

            if(Trigger.isUpdate)
            {
                TriggerHandler_DirectDebit.OnAfterUpdate(Trigger.newMap, Trigger.oldMap);
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