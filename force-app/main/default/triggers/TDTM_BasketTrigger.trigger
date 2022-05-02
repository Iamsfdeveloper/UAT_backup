/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 01-22-2022
 * @last modified by  : Iamsfdeveloper
**/
trigger TDTM_BasketTrigger on basket__c (after delete, after insert, after undelete,after update, before delete, before insert, before update) {

    npsp.TDTM_Config_API.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.isUndelete, Trigger.new, Trigger.old, Schema.SObjectType.basket__c);
                                         
    
}