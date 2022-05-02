global with sharing class SMP_DDServiceNextCollectionModelList {

    public List<ProcessListNewDDFirstCollectionDateResult> ProcessListNewDDFirstCollectionDateResult;
    public String Error;

    public class ProcessListNewDDFirstCollectionDateResult {
        public String Error;
        public String FirstCollectionDate;
    }
    
    public static SMP_DDServiceNextCollectionModelList parse(String json) {
        return (SMP_DDServiceNextCollectionModelList) System.JSON.deserialize(json, SMP_DDServiceNextCollectionModelList.class);
    }
}