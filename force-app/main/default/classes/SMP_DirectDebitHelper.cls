public with sharing class SMP_DirectDebitHelper{
    public static Map<Id, Income_Direct_Debit__c> getParentDirectDebitsFromHistories(List<Income_Debit_History__c> historiesMap){
        System.debug('#### getParentDirectDebitsFromHistories');

        Set<Id> directDebitIds = new Set<Id>();

        for(Income_Debit_History__c history : historiesMap){
            directDebitIds.add(history.Income_Direct_Debit__c);
        }

        Map<Id, Income_Direct_Debit__c> directDebits = new Map<Id, Income_Direct_Debit__c>([SELECT Id, Opportunity__c, DD_Account_Email__c 
                                                                                            FROM Income_Direct_Debit__c
                                                                                            WHERE Id IN :directDebitIds]);

        return directDebits;
    }

    public static List<Income_Debit_History__c> getNewInstructions(List<Income_Debit_History__c> histories){
        System.debug('#### getNewInstructions');
        System.debug('#### histories: '+histories);

        List<Income_Debit_History__c> newInstructionsList = new List<Income_Debit_History__c>();

        for(Income_Debit_History__c history : histories){
            if(history.DD_Status__c == 'New Instruction'){
                newInstructionsList.add(history);
            }
        }

        return newInstructionsList;
    }

    public static List<Income_Debit_History__c> getNewInstructionsByStage(List<Income_Debit_History__c> newDDHistories, Map<Id, Income_Debit_History__c> oldDDHistories, String stage)
    {
        System.debug('#### getNewInstructionsByStage');
        System.debug('#### newDDHistories: ' + newDDHistories);
        System.debug('#### oldDDHistories: ' + oldDDHistories);
        System.debug('#### stage: ' + stage);

        List<Income_Debit_History__c> newInstructionsList = new List<Income_Debit_History__c>();

        for(Income_Debit_History__c history : newDDHistories)
        {
            if(history.DD_Status__c == 'New Instruction')
            {
                if(history.DD_Stage__c == stage && (oldDDHistories == null || oldDDHistories.get(history.Id) == null || oldDDHistories.get(history.Id).DD_Stage__c != stage))
                {
                    newInstructionsList.add(history);
                }               
            }
        }

        return newInstructionsList;
    }

    public static List<Income_Debit_History__c> getCollections(List<Income_Debit_History__c> histories)
    {
        System.debug('#### getCollections');
        System.debug('#### histories: '+histories);

        List<Income_Debit_History__c> collectionsList = new List<Income_Debit_History__c>();

        for(Income_Debit_History__c history : histories)
        {
            if(history.DD_Status__c == 'First Collection' || history.DD_Status__c == 'Ongoing Collection' || history.DD_Status__c == 'Final Collection'
                || history.DD_Status__c == 'First Represent' || history.DD_Status__c == 'Second Represent' || history.DD_Status__c == 'Third Represent')
            {
                collectionsList.add(history);
            }
        }

        return collectionsList;
    }

    public static List<Income_Debit_History__c> getCollectionsByStage(List<Income_Debit_History__c> newDDHistories, Map<Id, Income_Debit_History__c> oldDDHistories, String stage)
    {
        System.debug('#### getCollectionsByStage');
        System.debug('#### newDDHistories: ' + newDDHistories);
        System.debug('#### oldDDHistories: ' + oldDDHistories);
        System.debug('#### stage: ' + stage);
        
        List<Income_Debit_History__c> collections = new List<Income_Debit_History__c>();

        for(Income_Debit_History__c history : newDDHistories)
        {
            if(history.DD_Status__c == 'First Collection' || history.DD_Status__c == 'Ongoing Collection' || history.DD_Status__c == 'Final Collection'
                || history.DD_Status__c == 'First Represent' || history.DD_Status__c == 'Second Represent' || history.DD_Status__c == 'Third Represent')
            {
                if(history.DD_Stage__c == stage && (oldDDHistories == null || oldDDHistories.get(history.Id) == null || oldDDHistories.get(history.Id).DD_Stage__c != stage))
                {
                    collections.add(history);
                }               
            }
        }

        return collections;
    }

    public static List<Income_Debit_History__c> getHistoriesByStatus(List<Income_Debit_History__c> histories, Map<Id, Income_Debit_History__c> oldDDHistories, String status)
    {
        System.debug('#### getHistoriesByStatus');
        System.debug('#### histories: ' + histories);
        System.debug('#### oldDDHistories: ' + oldDDHistories);
        System.debug('#### status: ' + status);

        List<Income_Debit_History__c> collectionsList = new List<Income_Debit_History__c>();

        for(Income_Debit_History__c history : histories)
        {
            if(String.isNotBlank(history.DD_Status__c) && history.DD_Status__c.contains(status) && (oldDDHistories == null || oldDDHistories.get(history.Id) == null || history.DD_Status__c != oldDDHistories.get(history.Id).DD_Status__c))
            {
                collectionsList.add(history);
            }
        }

        System.debug('#### Returning: ' + collectionsList);
        return collectionsList;
    }

    public static List<Income_Debit_History__c> getHistoriesByReasonCode(List<Income_Debit_History__c> histories, Map<Id, Income_Debit_History__c> oldDDHistories, Set<String> reasonCodes)
    {
        System.debug('#### getHistoriesByReasonCode');
        System.debug('#### histories: ' + histories);
        System.debug('#### oldDDHistories: ' + oldDDHistories);
        System.debug('#### reasonCodes: ' + reasonCodes);

        List<Income_Debit_History__c> collectionsList = new List<Income_Debit_History__c>();

        for(Income_Debit_History__c history : histories)
        {
            for (String reasonCode : reasonCodes) 
            {     
                if(String.isNotBlank(history.DD_Code__c) && history.DD_Code__c.contains(reasonCode) 
                    && (oldDDHistories == null || oldDDHistories.get(history.Id) == null || history.DD_Code__c != oldDDHistories.get(history.Id).DD_Code__c))
                {
                    collectionsList.add(history);
                }
            }
        }

        return collectionsList;
    }
}