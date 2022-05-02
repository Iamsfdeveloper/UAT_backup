public with sharing class TriggerHandler_DirectDebitHistory {

    public static void OnBeforeInsert(List<Income_Debit_History__c> newRecords){
        
    }

    public static void OnAfterInsert(Map<Id, Income_Debit_History__c> newRecords){
    }

    public static void OnBeforeUpdate(Map<Id, Income_Debit_History__c> newRecords, Map<Id, Income_Debit_History__c> oldRecords){
        System.debug('#### newRecords: ' + newRecords);
        System.debug('#### oldRecords: ' + oldRecords);
    }
    
    public static void OnAfterUpdate(Map<Id, Income_Debit_History__c> newRecords, Map<Id, Income_Debit_History__c> oldRecords){
        
    }
}