/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_npe03_Recurring_DonationTest
{
    @IsTest
    private static void testTrigger()
    {
        Contact con = (Contact)TestFactory.createSObject(new Contact(),true);
        
        SavePoint sp = Database.setSavepoint();
        dlrs.RollupService.testHandler(new npe03__Recurring_Donation__c(npe03__Contact__c = con.id));
        Database.rollback(sp);
    }
}