/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_npsp_General_Accounting_UnitTrigger on npsp__General_Accounting_Unit__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(npsp__General_Accounting_Unit__c.SObjectType);
}