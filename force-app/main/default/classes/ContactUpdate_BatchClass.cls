/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 12-15-2021
 * @last modified by  : Iamsfdeveloper
**/
public with sharing class ContactUpdate_BatchClass  implements Database.Batchable<Sobject>{
    public String query = 'SELECT Id,MailingStreet,MailingCountry,MailingCity,MailingState,MailingPostalCode From Contact Where Regional_Office_code__c =\'UK\' and MailingCountry =\'United Kingdom\' AND Contact_Type__c=\'Donor\' and GDPR_Delete__c=false';
    private List<contact> ContactUpdateList = new List<Contact>();
    private String guid;
    private Boolean isNpspTriggerDisabled;
    public ContactUpdate_BatchClass(string query,string guid){
        Callable npspApi = (System.Callable)Type.forName('npsp', 'Callable_API').newInstance();
        this.isNpspTriggerDisabled = (Boolean)npspApi.call('TDTM.DisableAllTriggers', new Map<String, Object>());
        this.query =query;
        this.guid = guid;
    }
    public Database.QueryLocator start(Database.batchableContext bc){
        return Database.getQueryLocator(query);
    }
    public void execute(Database.batchableContext bc,List<SObject> scope){
        for(Contact c: (List<Contact>)scope){
            String postcode = c.MailingPostalCode.deleteWhitespace();
            postcode=postcode.toUpperCase();
            if(isValidPostCode(postcode)){
                postcode = formatPostcode(postcode);
            
            String fullAddress = '';
            if(getEscapeValue(c.MailingStreet) !=''){
                fullAddress += getEscapeValue(c.MailingStreet);
            }
            if(getEscapeValue(c.MailingCity) !=''){
                fullAddress += ' '+getEscapeValue(c.MailingCity);
            } 
            if(getEscapeValue(c.MailingState) !=''){
                fullAddress += ' '+getEscapeValue(c.MailingState);
            }  
            ContactUpdateList.add(new Contact(Id = c.Id,MailingPostalCode = postcode,Full_Address__c = fullAddress,Data_Import_Batch_Guid__c=guid));
         
        }
       
    }
     
    if(isNpspTriggerDisabled && ContactUpdateList.size()>0){
        Database.SaveResult[] srList;
        try{
			 srList = Database.update(ContactUpdateList, false);
        }Catch(Exception ex){
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Contact fields that affected this error: ' + err.getFields());
                    }
                }
			}
            
        }
    
}
}
    private Boolean isValidPostCode(String postcode){
    return pattern.matches('([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9][A-Za-z]?))))\\s?[0-9][A-Za-z]{2})', postcode);
    }
    private String  getEscapeValue(String value){
        if(String.isEmpty(value)) return '';
        value = value.trim();
        value = value.escapeCSV();
        //replace any special Characters
        value = value.replaceAll('[^\\dA-Za-z ]',' ');
        
        return value;
    }
    private String formatPostcode(String postcode){
        String startofInwardCode = postcode.right(3);
        postcode = postcode.removeEnd(startofInwardCode); 
        postcode = postcode+' '+startofInwardCode;
        return postcode;
    }
    public void finish(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email,'iamsfdeveloper@gmail.com'};
        mail.setToAddresses(toAddresses);
        try{
            mail.setSubject('Donors Update With Postode and Full Address ' + a.Status);
                mail.setPlainTextBody
                    ('The batch Apex job processed ' + a.TotalJobItems +
                     '\n Failed batches with '+ a.NumberOfErrors+
                     ' \n Data Identifier used for this DML Operation '+guid); 
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        } catch(System.EmailException ex){
            
        }
    }
}