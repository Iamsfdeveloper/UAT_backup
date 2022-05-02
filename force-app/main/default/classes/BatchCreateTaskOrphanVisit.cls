public class BatchCreateTaskOrphanVisit implements Database.Batchable<sObject> {
    public static String ORPHAN = 'Orphan';
	public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id from Contact where Contact_Type__c =: ORPHAN limit 1';
      	return Database.getQueryLocator(query);
   	}

   public void execute(Database.BatchableContext BC, List<Contact> listContacts){
       User newUser = new User();
       newUser = [Select Id from User where Name = 'Nishtha Tilloo'];
       List<Task> listTasks = new List<Task>();
       for(Contact eachContact: listContacts){
           Task newTask = new Task();
           newTask.WhoId = eachContact.Id;
           newTask.Subject = 'Orphan visit Due';
           newTask.ActivityDate = Date.newInstance(2021, 11, 30);
           newTask.Priority = 'High';
           newTask.Status = 'Open';
           newTask.OwnerId = newUser.Id;
           listTasks.add(newTask);
       }
       if(!listTasks.isEmpty()){
           insert listTasks;
           System.debug('listTasks'+listTasks);
       }
    }

   public void finish(Database.BatchableContext BC){
   }
}