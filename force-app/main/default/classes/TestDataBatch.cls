public class TestDataBatch implements Database.Batchable<sObject>{
String query = 'SELECT Id FROM Opportunity Limit 25';
String email='kalpesh.thakur@humanappeal.org.uk';
Id toUserId;
Id fromUserId;

public Database.querylocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(query);}

public void execute(Database.BatchableContext BC, List<sObject> scope){
	
    TestData.createData();
    
}
public void finish(Database.BatchableContext BC){
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

mail.setToAddresses(new String[] {email});
mail.setReplyTo('batch@acme.com');
mail.setSenderDisplayName('Batch Processing');
mail.setSubject('Batch Process Completed');
mail.setPlainTextBody('Batch Process has completed');

Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
}
}