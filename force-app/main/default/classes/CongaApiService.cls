public class CongaApiService {
    
    public static List<string> exportDataUsingCongaComposer(Id processId,String processName){
        List<String> returnURL = new List<String>();
        String userEmail = userinfo.getUserEmail();
        Conga_Metadata_Batch__c  getCongaDetails = [Select Id,Email_Template_Id__c,fileName__c,Conga_Email_CC__c ,Email_Subject__c,Merge_Record_Id__c ,Last_Run_Date_Time__c ,Second_File_Name__c ,Second_Alias_Id__c,queryAliasId__c , queryId__c , templateId__c, Run_Second_Job__c , Second_Query_ID__c , Second_Template_ID__c    from Conga_Metadata_Batch__c  where Name =:processName];
        String dateString = getCongaDetails.Last_Run_Date_Time__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String sessId = UserInfo.getSessionId();
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/37.0/' + UserInfo.getOrganizationId();
        system.debug('*** sessId ' + sessId);
        system.debug('*** servUrl ' + servUrl);
        String url2 = '/apex/APXTConga4__Conga_Composer';
        url2 += '?id='+getCongaDetails.Merge_Record_Id__c ;
        url2 += '&TemplateId='+getCongaDetails.templateId__c;
		url2 += '&QueryId='+getCongaDetails.queryAliasId__c+getCongaDetails.queryId__c+'?pv0='+dateString;
        url2 += '&SC0=1';
        String salesfilename = EncodingUtil.urlEncode(getCongaDetails.fileName__c, 'UTF-8');
        url2 += '&OFN='+salesfilename ;
        String salesfile = EncodingUtil.urlEncode('Salesforce File', 'UTF-8');
        url2 += '&SC1=SalesforceFile' + 
            '&EmailAdditionalTo='+userEmail+
            '&EmailCC='+getCongaDetails.Conga_Email_CC__c+   
            '&EmailSubject='+getCongaDetails.Email_Subject__c    +
            '&defaultPDF=1' +
            '&APDF=1' +
            '&DS7=12' +
            '&EmailTemplateId='+getCongaDetails.Email_Template_Id__c+
            '&FP0=1';
        returnURL.add(url2);
        
        if(getCongaDetails.Run_Second_Job__c==true){
           String url3 = '/apex/APXTConga4__Conga_Composer';
            url3 += '?id='+getCongaDetails.Merge_Record_Id__c ;
            url3 += '&TemplateId='+getCongaDetails.Second_Template_ID__c;
            url3 += '&QueryId='+getCongaDetails.Second_Alias_Id__c+getCongaDetails.Second_Query_ID__c+'?pv0='+dateString ;
            url3 += '&SC0=1';
            salesfilename = EncodingUtil.urlEncode(getCongaDetails.Second_File_Name__c , 'UTF-8');
            url3 += '&OFN='+salesfilename ;
            salesfile = EncodingUtil.urlEncode('Salesforce File', 'UTF-8');
            url3 += '&SC1=SalesforceFile' + 
                '&EmailAdditionalTo='+userEmail+
                '&EmailCC='+getCongaDetails.Conga_Email_CC__c+   
                '&EmailSubject='+getCongaDetails.Email_Subject__c    +
                '&defaultPDF=1' +
                '&APDF=1' +
                '&DS7=12' +
                '&EmailTemplateId='+getCongaDetails.Email_Template_Id__c+
                '&FP0=1';
            
            System.debug('***URL ' + url3);
            returnURL.add(url3);
            
        }
        
       
        Conga_Batch_Processing_Logs__c temp = new Conga_Batch_Processing_Logs__c(Id = processId);
        temp.Batch_Status__c = 'Success';
        Update temp;      
        
        Conga_Metadata_Batch__c  mdata = new Conga_Metadata_Batch__c (Id=getCongaDetails.Id);
        mdata.Last_Run_Date_Time__c = Datetime.now();
        update mdata;
        return returnURL;
    }
    
    @future(callout=true)
    public static void exportDataUsingConga(Id processId,String processName){
        String userEmail = userinfo.getUserEmail();
        Conga_Metadata_Batch__c  getCongaDetails = [Select Id,fileName__c,Conga_Email_CC__c ,Email_Subject__c,Merge_Record_Id__c ,Last_Run_Date_Time__c ,Second_File_Name__c ,Second_Alias_Id__c,queryAliasId__c , queryId__c , templateId__c, Run_Second_Job__c , Second_Query_ID__c , Second_Template_ID__c    from Conga_Metadata_Batch__c  where Name =:processName];
        String dateString = getCongaDetails.Last_Run_Date_Time__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String sessId = UserInfo.getSessionId();
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/37.0/' + UserInfo.getOrganizationId();
        system.debug('*** sessId ' + sessId);
        system.debug('*** servUrl ' + servUrl);
        String url2 = 'https://composer.congamerge.com/composer8/index.html';
        url2 += '?sessionId='+ sessId;
        
        url2 += '&serverUrl=' + EncodingUtil.urlEncode(servUrl, 'UTF-8');
        url2 += '&id='+getCongaDetails.Merge_Record_Id__c ;
        String template2Id= (getCongaDetails.Run_Second_Job__c==true)?','+getCongaDetails.Second_Template_ID__c:'';
        url2 += '&TemplateId='+getCongaDetails.templateId__c+template2Id;
        string secondJob = (getCongaDetails.Run_Second_Job__c==true)?','+getCongaDetails.Second_Alias_Id__c+getCongaDetails.Second_Query_ID__c+'?pv0='+dateString:'';
        url2 += '&QueryId='+getCongaDetails.queryAliasId__c+getCongaDetails.queryId__c+'?pv0='+dateString+secondJob;
        url2 += '&SC0=1';
        String salesfilename = EncodingUtil.urlEncode(getCongaDetails.fileName__c, 'UTF-8');
        url2 += '&OFN='+salesfilename ;
        String salesfile = EncodingUtil.urlEncode('Salesforce File', 'UTF-8');
        url2 += '&SC1=SalesforceFile' + 
            '&EmailAdditionalTo='+userEmail+
            '&EmailCC='+getCongaDetails.Conga_Email_CC__c+   
            '&EmailSubject='+getCongaDetails.Email_Subject__c    +
            '&defaultPDF=1' +
            '&APDF=1' +/*
            '&DS7=12' +*/
            '&EmailTemplateId=00X0C000000hWLw'+
            '&FP0=1'+
            '&APIMODE=12';
        System.debug('***URL ' + url2);
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url2);
        req.setMethod('GET');
        req.setTimeout(120000);
        HttpResponse res = http.send(req);
        
        System.debug('*** $$$' + res);
        System.debug('*** $$$ getStatus' + res.getStatus());
        System.debug('*** $$$ getBody' + res.getBody());
        /*
        if(!res.getBody().contains('error:') && getCongaDetails.Run_Second_Job__c==false){
            system.debug('*** sessId ' + sessId);
            system.debug('*** servUrl ' + servUrl);
            url2 = 'https://composer.congamerge.com/composer8/index.html' +
                '?sessionId=' + sessId +
                '&serverUrl=' + EncodingUtil.urlEncode(servUrl, 'UTF-8');
            url2 += '&id='+getCongaDetails.Merge_Record_Id__c ;
            url2 += '&TemplateId='+getCongaDetails.Second_Template_ID__c;
            url2 += '&QueryId='+getCongaDetails.Second_Alias_Id__c+getCongaDetails.Second_Query_ID__c+'?pv0='+dateString ;
            url2 += '&SC0=1';
            salesfilename = EncodingUtil.urlEncode(getCongaDetails.Second_File_Name__c , 'UTF-8');
            url2 += '&OFN='+salesfilename ;
            salesfile = EncodingUtil.urlEncode('Salesforce File', 'UTF-8');
            url2 += '&SC1=SalesforceFile' + 
                '&EmailAdditionalTo='+userEmail+
                '&EmailCC='+getCongaDetails.Conga_Email_CC__c+ 
                '&defaultPDF=1' +
                '&APDF=1' +
                '&DS7=12' +
                '&EmailTemplateId=00X0C000000hWLw'+
                '&FP0=1'+
                '&APIMODE=12';
            
            System.debug('***URL ' + url2);
            
            http = new Http();
            req = new HttpRequest();
            req.setEndpoint(url2);
            req.setMethod('GET');
            req.setTimeout(120000);
            // Send the request, and return a response
            res = http.send(req);
            
            System.debug('*** $$$' + res);
            System.debug('*** $$$ getStatus' + res.getStatus());
            System.debug('*** $$$ getBody' + res.getBody());   
            
        }
        */
        Conga_Batch_Processing_Logs__c temp = new Conga_Batch_Processing_Logs__c(Id = processId);
        temp.Batch_Status__c = 'Success';
        if(res.getBody().contains('error:')){
            temp.Batch_Status__c = 'Failure';
            temp.Failure_Reason__c  = res.getBody();
        }
        
        Update temp;      
        
        Conga_Metadata_Batch__c  mdata = new Conga_Metadata_Batch__c (Id=getCongaDetails.Id);
        mdata.Last_Run_Date_Time__c = Datetime.now();
        update mdata;
    }
}