/**
 * @description       :
 * @author            : agentgill
 * @group             :
 * @last modified on  : 07-10-2020
 * @last modified by  : agentgill
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   07-10-2020   agentgill   Initial Version
 **/
@isTest
public class BatchSchedulerTest {
    /**
     * @description Test Universal Scheduler
     * @author agentgill | 07-10-2020
     **/
    @isTest
    private static void testBatchSchedule() {
        Test.startTest();

        NewRecurringDonationService myBatch = new NewRecurringDonationService();

        // Instantiate the scheduler
        BatchScheduler myScheduler = new BatchScheduler();

        // Assign the batch class to the variable within the scheduler
        myScheduler.batchClass = (Database.Batchable<SObject>) myBatch;

        // Run every day at 1pm
        String sch = '0 0 0 3 9 ? 2022';

        String jobId = System.schedule(
            'MyBatch - Everyday at 1pm',
            sch,
            myScheduler
        );

        // Get the information from the CronTrigger API object
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE id = :jobId
        ];

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered, 'Something went wrong');

        // Verify the next time the job will run
        System.assertEquals(
            '2022-09-03 00:00:00',
            String.valueOf(ct.NextFireTime),
            'Something went wrong'
        );

        Test.stopTest();
    }
}