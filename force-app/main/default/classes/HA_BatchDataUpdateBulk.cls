/**
 * @description       : 
 * @author            : Kalpesh.Thakur@HumanAppeal.co.uk
 * @group             : 
 * @last modified on  : 08-05-2021
 * @last modified by  : Kalpesh.Thakur@HumanAppeal.co.uk
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   008-05-2021  Kalpesh.Thakur@HumanAppeal.co.uk   Initial Version
**/
global class HA_BatchDataUpdateBulk implements Database.Batchable<sObject>{

    public String query = 'SELECT Id,Name,npsp__Primary_Contact__r.Regional_Office_Code__c,Regional_office_code__c FROM Opportunity';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {

        List<Opportunity> lstOpportunity= (List<Opportunity>)scope;

        List<Opportunity> lstOppUpdate = new List<Opportunity>();

        for (Opportunity objOpp : lstOpportunity) {
            
            if (objOpp.npsp__Primary_Contact__r.Regional_Office_Code__c != null) {

                lstOppUpdate.add(new Opportunity(Id=objOpp.Id,Regional_office_code__c=objOpp.npsp__Primary_Contact__r.Regional_Office_Code__c));
            }
        }

        if (!lstOppUpdate.isEmpty()) {
            
            update lstOppUpdate;
        }
    }
    global void finish(Database.BatchableContext BC) {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new String[] {'Kalpesh.Thakur@HumanAppeal.org.uk'});
        mail.setReplyTo('Kalpesh.Thakur@HumanAppeal.org.uk');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Completed');
        mail.setPlainTextBody('Batch Process has completed');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}