global class SMP_RepeatPaymentScheduler implements schedulable, Database.AllowsCallouts  {

    global void execute(SchedulableContext ctx){
        
        SMP_RepeatPaymentSchedulerBatch repeatPaymentBatch = new SMP_RepeatPaymentSchedulerBatch();        
        Database.executeBatch(repeatPaymentBatch, 1);
    }
}