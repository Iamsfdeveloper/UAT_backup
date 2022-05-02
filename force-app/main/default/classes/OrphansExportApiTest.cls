@isTest
public class OrphansExportApiTest {
	@isTest static void TestDoExport() {
        // Test data setup
        // Create orphans test data
        Contact[] orphans = OrphansExportApiDataFactory.createOrphans(10);
        
        // Perform test
        Test.startTest();
        List<OrphansExportApi.OrphanExportItem> results = OrphansExportApi.doExport();
        Test.stopTest();
        // Verify that we got back our orphans.
        System.Debug('orphans size = ' + orphans.size());
        System.Debug('results size = ' + results.size());
        System.assert(results.size() == 10);
        System.assertEquals(orphans.size(), results.size());
    }     
}