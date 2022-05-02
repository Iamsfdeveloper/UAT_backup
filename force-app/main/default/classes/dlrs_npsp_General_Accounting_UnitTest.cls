/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_npsp_General_Accounting_UnitTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_npsp_General_Accounting_UnitTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new npsp__General_Accounting_Unit__c());
    }
}