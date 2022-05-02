/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 12-22-2021
 * @last modified by  : Iamsfdeveloper
**/
public with sharing class DirectDebitConfiguartion {
    public final static string WAIT_PEROID_NEW_INSTRUCTION = '5';
    public static final String MESSAGE_CALLOUTERROR = 'Error Calling SmarterPay Service.';    
    public static SmarterPay_Direct_Debit_Settings__c directDebitConfig = SmarterPay_Direct_Debit_Settings__c.getInstance();
    @Future(callout=true)
    public static void updateCollectionDate(set<Id> newRecordIds){
        List<Income_Direct_Debit__c> newRecords = [SELECT Id,DD_Next_Collection_Date__c,DD_First_Collection_Date__c,DD_Collection_Day__c,DD_Collection_Period__c,DD_Collection_Stretch__c,DD_Start_Date__c FROM Income_Direct_Debit__c Where ID IN: newRecordIds];
        //{"StartDate":"2021-12-06","NumberOfDaysToWaitFromNewInstruction":"5","CollectionPeriod":"Monthly","CollectionDay":"1"}
        String endpointURL = '';
    for(Integer i=0;i<100 && i<newRecords.size();i++){
        SMP_DDServiceNextCollectionModel parsedResponse = new SMP_DDServiceNextCollectionModel();
        try{
            endpointURL = string.valueOf(directDebitConfig.Calculate_Next_Collection_Date_Endpoint__c);
            
        }catch(Exception e){
            System.debug('#### Couldn\'t find setup records!');
            System.debug('#### Exception: ' + e);
        }
        try{
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('StartDate', newRecords[i].DD_Start_Date__c.year()+'-'+newRecords[i].DD_Start_Date__c.month()+'-'+newRecords[i].DD_Start_Date__c.day());
                gen.writeStringField('NumberOfDaysToWaitFromNewInstruction', WAIT_PEROID_NEW_INSTRUCTION);
                gen.writeStringField('CollectionPeriod', newRecords[i].DD_Collection_Period__c);
                gen.writeStringField('CollectionDay', newRecords[i].DD_Collection_Day__c);
                gen.writeEndObject();
                gen.close();
                endpointURL = endpointURL + EncodingUtil.urlEncode(gen.getAsString(), 'UTF-8');
               
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                req.setMethod('GET'); 
                req.setEndPoint(endpointURL);      
                HttpResponse resp;
                resp = http.send(req);
                if(resp.getStatusCode() == 200)
                {
                    parsedResponse = SMP_DDServiceNextCollectionModel.parse(resp.getBody());
                  
                    newRecords[i].DD_First_Collection_Date__c = Date.valueof(parsedResponse.ProcessNewDDFirstCollectionDateResult.FirstCollectionDate);
                    newRecords[i].DD_Next_Collection_Date__c = Date.valueof(parsedResponse.ProcessNewDDFirstCollectionDateResult.FirstCollectionDate);
            }
                else
                {
                    newRecords[i].Failed_Reason__c=MESSAGE_CALLOUTERROR + ' ' + resp.getStatusCode() + ' ' + resp.getStatus();
                    newRecords[i].DD_Status__c ='Failed';
                    parsedResponse.ProcessNewDDFirstCollectionDateResult.Error = MESSAGE_CALLOUTERROR + ' ' + resp.getStatusCode() + ' ' + resp.getStatus();
                }

                
                
        }
        catch(Exception e)
        {
            newRecords[i].DD_Status__c ='Failed';
            system.debug('Exception Occurred===>'+e);
            system.debug('parsedResponse Occurred===>'+parsedResponse);

        }
        if(newRecords.size()>0)
        update newRecords;
    }
}
   
}