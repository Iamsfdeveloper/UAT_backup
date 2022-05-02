/**
 * @File Name          : BatchScheduler.cls
 * @Description        : Universal Batch Scheduling Class
 * @Author             : agentgill
 * @Group              :
 * @Last Modified By   : agentgill
 * @Last Modified On   : 07/06/2020, 17:53:10
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    07/06/2020   agentgill     Initial Version
 * 

 Usage

    // Instantiate the batch class
    MyBatch myBatch = new MyBatch();
    
    // Instantiate the scheduler
    BatchScheduler scheduler = new BatchScheduler();
    
    // Assign the batch class to the variable within the scheduler
    scheduler.batchClass = myBatch;
    
    // Run every day at 1pm
    String sch = '0 0 13 * * ?';
    
    System.schedule('MyBatch - Everyday at 1pm', sch, scheduler);

 * 
 **/
global class BatchScheduler implements Schedulable {
    global Database.Batchable<SObject> batchClass { get; set; }
    global Integer batchSize { get; set; }

    {
        batchSize = 200;
    }

    global void execute(SchedulableContext sc) {
        database.executebatch(batchClass, batchSize);
    }
}