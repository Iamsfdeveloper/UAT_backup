@isTest(seeAllData = true)
public class RDSetPercentOnAllocationBatchTest {

    @isTest
    public static void setTestPercentConversion() {
        database.executeBatch(new RDSetPercentOnAllocationBatch());
    }
    
    
}