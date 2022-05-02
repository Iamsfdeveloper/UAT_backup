global with sharing class SMP_DDServiceHandler {

    public static final String MESSAGE_CALLOUTERROR = 'Error Calling SmarterPay Service.';    
    public static SmarterPay_Direct_Debit_Settings__c directDebitConfig = SmarterPay_Direct_Debit_Settings__c.getInstance();

    public static SMP_DDServiceNextCollectionModel getNextCollectionDate(SingleCollectionDateWrapper dateWrapper)
    {
        System.debug('#### getNextCollectionDate Started');
        System.debug('#### collectionDayIn: ' + dateWrapper.CollectionDay);
        System.debug('#### startDateIn: ' + dateWrapper.StartDate);
        System.debug('#### collectionPeriodIn: ' + dateWrapper.CollectionPeriod);
        System.debug('#### numberOfDaysToWaitFromNewInstructionIn: ' + dateWrapper.NumberOfDaysToWaitFromNewInstruction);

        SMP_DDServiceNextCollectionModel parsedResponse;
        String endpointURL = '';
       
        try{
            endpointURL = string.valueOf(directDebitConfig.Calculate_Next_Collection_Date_Endpoint__c);
            
        }catch(Exception e){
            System.debug('#### Couldn\'t find setup records!');
            System.debug('#### Exception: ' + e);
        }

        String dateString = '';

        System.debug('startDate' + dateString);

        String jsonString = JSON.serialize(dateWrapper);
        System.Debug('#### jsonString: ' + jsonString);

        jsonString = jsonString.replaceAll('DateWrapper', 'Date');     
        jsonString = jsonString.replaceAll('(\\s+)', ' ');        
        
        endpointURL = endpointURL + EncodingUtil.urlEncode(jsonString, 'UTF-8');
        
        System.debug('#### endpointURL: ' + endpointURL);

        try{
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setMethod('GET'); 
            req.setEndPoint(endpointURL);      
            HttpResponse resp;
            resp = http.send(req);
            
            System.debug('#### Response Body: ' + resp.getBody());
            System.debug('#### Response Status: ' + resp.getStatus());
            System.debug('#### Response Status Code: ' + resp.getStatusCode());
            
            if(resp.getStatusCode() == 200)
            {
                parsedResponse = SMP_DDServiceNextCollectionModel.parse(resp.getBody());
                System.debug(parsedResponse);
            }
            else
            {
                parsedResponse = new SMP_DDServiceNextCollectionModel();
                parsedResponse.ProcessNewDDFirstCollectionDateResult.Error = MESSAGE_CALLOUTERROR + ' ' + resp.getStatusCode() + ' ' + resp.getStatus();
            }

            System.debug('#### parsedResponse: ' + parsedResponse);

            return parsedResponse;
        }
        catch(Exception e)
        {
            parsedResponse = new SMP_DDServiceNextCollectionModel();
            parsedResponse.ProcessNewDDFirstCollectionDateResult.Error = MESSAGE_CALLOUTERROR + ' ' + e.getMessage();

            System.debug('#### parsedResponse: ' + parsedResponse);
            System.debug('#### debug e: ' + e);

            return parsedResponse;
        }                
    }

    public static SMP_DDServiceNextCollectionModelList getNextCollectionDate(ListCollectionDateBaseWrapper dateWrapper)
    {
        System.debug('#### getNextCollectionDate Started');
        System.debug('#### dateWrapper: ' + dateWrapper);

        SMP_DDServiceNextCollectionModelList parsedResponse;
        String endpointURL = '';
       
        try{
            endpointURL = string.valueOf(directDebitConfig.List_Next_Collection_Date_Endpoint__c);
            
        }catch(Exception e){
            System.debug('#### Couldn\'t find setup records!');
            System.debug('#### Exception: ' + e);
        }

        String jsonString = JSON.serialize(dateWrapper);
        System.debug('#### jsonString before replace: ' + jsonString);
     
        jsonString = jsonString.replaceAll('(\\s+)', ' ');      

        System.debug('#### jsonString after replace: ' + jsonString);
        
        endpointURL = endpointURL + EncodingUtil.urlEncode(jsonString, 'UTF-8');
        
        System.debug('#### endpointURL: ' + endpointURL);

        try{
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setMethod('GET'); 
            req.setEndPoint(endpointURL);      
            HttpResponse resp;
            resp = http.send(req);
            
            System.debug('#### Response Body: ' + resp.getBody());
            System.debug('#### Response Status: ' + resp.getStatus());
            System.debug('#### Response Status Code: ' + resp.getStatusCode());
            
            if(resp.getStatusCode() == 200)
            {
                parsedResponse = SMP_DDServiceNextCollectionModelList.parse(resp.getBody());
                System.debug(parsedResponse);
            }
            else
            {
                parsedResponse = new SMP_DDServiceNextCollectionModelList();
                parsedResponse.Error = MESSAGE_CALLOUTERROR + ' ' + resp.getStatusCode() + ' ' + resp.getStatus();
            }

            System.debug('#### parsedResponse: ' + parsedResponse);

            return parsedResponse;
        }
        catch(Exception e)
        {            
            System.debug('#### parsedResponse: ' + parsedResponse);
            System.debug('#### debug e: ' + e);
            parsedResponse = new SMP_DDServiceNextCollectionModelList();
            parsedResponse.Error = MESSAGE_CALLOUTERROR + ' ' + e.getMessage();

            return parsedResponse;
        }                
    }

    webservice static SMP_DDServiceNextCollectionModel getNextCollectionDate(String collectionDayIn, Date startDateIn, String collectionPeriodIn, String numberOfDaysToWaitFromNewInstructionIn)
    {
        System.debug('#### getNextCollectionDate Started');
        System.debug('#### collectionDayIn: ' + collectionDayIn);
        System.debug('#### startDateIn: ' + startDateIn);
        System.debug('#### collectionPeriodIn: ' + collectionPeriodIn);
        System.debug('#### numberOfDaysToWaitFromNewInstructionIn: ' + numberOfDaysToWaitFromNewInstructionIn);

        String dateString = '';

        if(startDateIn != null){
            dateString = startDateIn.year() + '-' + startDateIn.month() + '-' + startDateIn.day();
        }
        System.debug('startDate' + dateString);

        SingleCollectionDateWrapper dateWrapper = new SingleCollectionDateWrapper();
        dateWrapper.CollectionDay = collectionDayIn;
        dateWrapper.StartDate = dateString;
        dateWrapper.CollectionPeriod = collectionPeriodIn;
        dateWrapper.NumberOfDaysToWaitFromNewInstruction = numberOfDaysToWaitFromNewInstructionIn;

        return getNextCollectionDate(dateWrapper);
    }

    public static SMP_DDServiceBankAccountModel getBankDetails(AccountCheckerWrapper bankDetailsWrapper)
    {
        System.debug('#### getBankDetails');
        System.debug('#### bankDetailsWrapper: ' + bankDetailsWrapper);

        SMP_DDServiceBankAccountModel parsedResponse;    
        String endpointURL = '';
        String userId = '';
       
        try{
            endpointURL = string.valueOf(directDebitConfig.Bank_Account_Checker_Endpoint__c);
            userId = string.valueOf(directDebitConfig.User_Id__c);            
        }
        catch(Exception e){
            System.debug('#### Couldn\'t find setup records!');
            System.debug('#### Exception: ' + e);
        }

        bankDetailsWrapper.UserID = userId;

        String jsonString = JSON.serialize(bankDetailsWrapper);
        jsonString = jsonString.replaceAll('(\\s+)', ' ');

        System.debug('#### jsonString: ' + jsonString);
        
        endpointURL = endpointURL + EncodingUtil.urlEncode(jsonString, 'UTF-8');

        System.debug('#### endpointURL: ' + endpointURL);
        
        try{
            HttpRequest req = new HttpRequest();

            Http http = new Http();
            req.setMethod('GET'); 
            req.setEndPoint(endpointURL);

            HttpResponse resp;
            resp = http.send(req);

            System.debug('#### Response Body: ' + resp.getBody());
            System.debug('#### Response Status: ' + resp.getStatus());
            System.debug('#### Response Status Code: ' + resp.getStatusCode());
                    
            if(resp.getStatusCode() == 200)
            {        
                parsedResponse = SMP_DDServiceBankAccountModel.parse(resp.getBody());            
            }
            else
            {
                parsedResponse = new SMP_DDServiceBankAccountModel();
                parsedResponse.ProcessMessageResult.Error = MESSAGE_CALLOUTERROR + ' ' + resp.getStatusCode() + ' ' + resp.getStatus();    
            }
            
            System.debug('#### Result: ' + parsedResponse);
            return parsedResponse; 
        }
        catch(Exception e)
        {
            parsedResponse = new SMP_DDServiceBankAccountModel();
            parsedResponse.ProcessMessageResult.Error = MESSAGE_CALLOUTERROR + ' ' + e.getMessage();

            return parsedResponse; 
        }
    }

    /**
    * @description Handles calling the Income Systems Bank Account Checker service.
    * @param sortCode Bank account sort code.
    * @param accountNo Bank account number.
    * @return SMP_DDServiceBankAccountModel Model/Wrapper that encapsulates the response from the Income Systems Bank Account Checker.
    */
    webservice static SMP_DDServiceBankAccountModel getBankDetails(String sortCode, String accountNo)
    {        
        System.debug('#### getBankDetailsWebservice Started');
        System.debug('#### sortCode: ' + sortCode);
        System.debug('#### accountNo: ' + accountNo);

        AccountCheckerWrapper accountWrapper = new AccountCheckerWrapper();
        accountWrapper.SortCode = sortCode;
        accountWrapper.AccountNo = accountNo;

        return getBankDetails(accountWrapper);
    }

    public class AccountCheckerWrapper{
        public String SortCode {get; set;}
        public String AccountNo {get; set;}
        public String UserID {get; set;}        
    }

    public class SingleCollectionDateWrapper{
        public String CollectionDay {get; set;}
        public String StartDate {get; set;}
        public String CollectionPeriod {get; set;}
        public String NumberOfDaysToWaitFromNewInstruction{get; set;}
    }
        
    public class ListCollectionDateBaseWrapper{
        public String cp {get; set;} // CollectionPeriod
        public String nodtw{get; set;} // NumberOfDaysToWaitFromNewInstruction
        public String cd {get; set;} // CollectionDay
        public List<ListCollectionDateWrapper> CDWrapper {get; set;} // List of dates

        public ListCollectionDateBaseWrapper(List<ListCollectionDateWrapper> cdwrapperIn, String cpIn, String nodtwIn, String cdIn){
            cp = cpIn;
            nodtw = nodtwIn;
            cd = cdIn;
            CDWrapper = cdwrapperIn;
        }
    }

    public class ListCollectionDateWrapper{
        public String sd {get; set;} //StartDate
    }
}