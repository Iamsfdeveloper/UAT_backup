trigger IncomeCardPaymentTrigger on Income_Card_Payment__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

    TriggerSettings__c ts = TriggerSettings__c.getOrgDefaults();
    if(ts.Card_Payment_Trigger__c)
    {
        if (Trigger.isBefore)
        {
            if(Trigger.isInsert)
            {
                TriggerHandler_CardPayment.OnBeforeInsert(Trigger.new);
            }

            if(Trigger.isUpdate)
            {
                TriggerHandler_CardPayment.OnBeforeUpdate(Trigger.newMap, Trigger.oldMap);
            }

            if(Trigger.isDelete)
            {
            }    
        } 
        else if (Trigger.isAfter)
        {
            if(Trigger.isInsert)
            {
               TriggerHandler_CardPayment.OnAfterInsert(Trigger.newMap);
            }

            if(Trigger.isUpdate)
            {
                TriggerHandler_CardPayment.OnAfterUpdate(Trigger.newMap, Trigger.oldMap);
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