/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_InstructionTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_InstructionTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Instruction__c());
    }
}