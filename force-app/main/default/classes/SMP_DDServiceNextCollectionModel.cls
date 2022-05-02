global with sharing class SMP_DDServiceNextCollectionModel
{
    public class ProcessNewDDFirstCollectionDateResult
    {
        public String Error;
        public String FirstCollectionDate;
    }

    public ProcessNewDDFirstCollectionDateResult ProcessNewDDFirstCollectionDateResult;

    public SMP_DDServiceNextCollectionModel(){
        ProcessNewDDFirstCollectionDateResult = new ProcessNewDDFirstCollectionDateResult();
    }

    public static SMP_DDServiceNextCollectionModel parse(String json)
    {
        return (SMP_DDServiceNextCollectionModel) System.JSON.deserialize(json, SMP_DDServiceNextCollectionModel.class);
    }
}