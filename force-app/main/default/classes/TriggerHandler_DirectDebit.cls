/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 01-12-2022
 * @last modified by  : Iamsfdeveloper
**/
public without sharing class TriggerHandler_DirectDebit {
    public static void OnBeforeInsert(List<Income_Direct_Debit__c> newRecords)
    {
        
    }

    public static void OnAfterInsert(Map<Id, Income_Direct_Debit__c> newRecords)
    {
        Set<Id> ddIds = new Set<Id>();
		List<Opportunity> opportunities = new List<Opportunity>();
        for(Income_Direct_Debit__c dd : newRecords.values())
        {
            if(dd.Opportunity__c != null && dd.Recurring_Donation__c == null){
                IF(dd.DD_First_Collection_Date__c != null)
                {
                    opportunities.add(new Opportunity(Payment_Method__c ='Direct Debit',Id=dd.Opportunity__c,StageName = (dd.DD_Status__c  =='New Instruction' && dd.DD_Sort_Code_OK__c && dd.DD_OK__c && dd.DD_Account_Number_OK__c)?'Paid':'In Payment Processing'));
                }else{
                    ddIds.add(dd.Id);
                }
            }
        }

        if(opportunities.Size() > 0)
        {
             update opportunities;
                        
        }    
        //Future Method for web callout to get Collection Dates
        //For Direct Debits From checkoutv4
        if(ddIds.size()>0)
            DirectDebitConfiguartion.updateCollectionDate(ddIds);
           
    }

    public static void OnBeforeUpdate(Map<Id, Income_Direct_Debit__c> newRecords, Map<Id, Income_Direct_Debit__c> oldRecords)
    {
    }
    
    public static void OnAfterUpdate(Map<Id, Income_Direct_Debit__c> newRecords, Map<Id, Income_Direct_Debit__c> oldRecords)
    {
         Set<Id> oppIds = new Set<Id>();
		List<Opportunity> opportunities = new List<Opportunity>();
        for(Income_Direct_Debit__c dd : [Select Id,DD_Status__c,Opportunity__c ,Recurring_Donation__c,DD_Sort_Code_OK__c,DD_OK__c,DD_Account_Number_OK__c FROM Income_Direct_Debit__c Where Id IN: newRecords.keyset() and Opportunity__r.StageName Not In ('Paid','In Payment Processing') AND DD_First_Collection_Date__c != null])
        {
            if(dd.Opportunity__c != null && dd.Recurring_Donation__c == null)
            {
                opportunities.add(new Opportunity(Payment_Method__c ='Direct Debit',Id=dd.Opportunity__c,StageName = (dd.DD_Status__c  =='New Instruction' && dd.DD_Sort_Code_OK__c && dd.DD_OK__c && dd.DD_Account_Number_OK__c)?'Paid':'In Payment Processing'));
            }
        }

        if(opportunities.Size() > 0)
        {
             update opportunities;
                        
        }    
    }
}