/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 01-10-2022
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   12-11-2020   Iamsfdeveloper   Initial Version
**/
public class HA_Utility {
    public static Boolean IsSandbox = true;
    static{
        IsSandbox =  [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        
    }

    @AuraEnabled
    public static String getProfilePhotoURL(String recordId){
      try{
          String contentDocumentLinkId =  [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink Where LinkedEntityId=:recordId].ContentDocumentId;
          String contentVersionId = [SELECT Id, ContentDocumentId, IsLatest, ContentUrl, Type__c, FileType FROM ContentVersion WHERE Type__c='Profile Photo' AND ContentDocumentId=:contentDocumentLinkId].Id;
          return contentVersionId;
        }catch(QueryException qe){
            return [Select Gender__c From Contact Where Id =:recordId].Gender__c;
        }catch(Exception ex){ 
            return '';
        }
    }
    @AuraEnabled
    public static Map<String,Object> getContactDetailsFromCallList(String recordId){
        Map<String,Object> returnValue = new Map<String,Object>();
        try{
            List<CampaignMember> CampaignMemberDetails = [SELECT Id, ContactId, Call_List_Id__c FROM CampaignMember Where Call_List_Id__c=:recordId AND ContactId != null and CampaignMember.Contact.RecordType.DeveloperName='Donor'];
            if(CampaignMemberDetails.size()>0){
                returnValue.put('contactId',CampaignMemberDetails[0].ContactId);
            }
        }catch(Exception ex){
        }
        return returnValue;
    }
    @AuraEnabled
    public static Map<String,Object> getAddress(String postalCode){
        List<HA_SelectOption> availableAddress = new List<HA_SelectOption>();
        Map<String,Object> returnVal = new Map<String,Object>();
        String payload = findAddressPayload(postalCode,null);
        System.debug(payload);
        String findAddressresponse = getResponse('https://api.addressy.com/Capture/Interactive/Find/v1.1/json3ex.ws',payload);
        System.debug('findAddressresponse '+findAddressresponse);
        JSONParser parser = JSON.createParser(findAddressresponse);
        String responseId = '';
        String responseType = '';
        
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY){
                HA_SelectOption tempObject = new HA_SelectOption();
                while (parser.nextToken() != null){
                    if(parser.getCurrentToken()== System.JSONToken.FIELD_NAME && parser.getText()=='Id'){
                        parser.nextToken();
                        responseId = parser.getText();
                        tempObject.value = parser.getText();
                    }
                    if(parser.getCurrentToken()== System.JSONToken.FIELD_NAME && parser.getText()=='Type'){
                        parser.nextToken();
                        responseType = parser.getText();     
                    }
                    if(parser.getCurrentToken()== System.JSONToken.FIELD_NAME && parser.getText()=='Text'){
                        parser.nextToken();
                        tempObject.label = parser.getText();   
                    }
                    if(parser.getCurrentToken()== System.JSONToken.FIELD_NAME && parser.getText()=='Description'){
                        parser.nextToken();
                        tempObject.description = parser.getText();   
                    }
                    if(responseType =='Address' && parser.getCurrentToken() == JSONToken.END_ARRAY){
                        availableAddress.add(tempObject);
                        break;
                    }
                }
            }
        }
        if(responseId != null && responseType =='Postcode' ){
            availableAddress = new List<HA_SelectOption>();
            payload = findAddressPayload(postalCode,responseId);
            System.debug(payload);
            findAddressresponse = getResponse('https://api.addressy.com/Capture/Interactive/Find/v1.1/json3ex.ws',payload);
            System.debug('findAddressresponse '+findAddressresponse);
            
            parser = JSON.createParser(findAddressresponse);
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY){
                    while (parser.nextToken() != null){ 
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT){ 
                            HA_SelectOption tempObject = new HA_SelectOption(); 
                            while (parser.nextToken() != null){
                                if(parser.getCurrentToken()== System.JSONToken.FIELD_NAME && parser.getText() == 'Id'){
                                    parser.nextToken();
                                    tempObject.value=parser.getText();
                                    tempObject.apiName=parser.getText();
                                }
                                if(parser.getCurrentToken()== System.JSONToken.FIELD_NAME && parser.getText() == 'Text'){
                                    parser.nextToken();
                                    tempObject.label = parser.getText();
                                    
                                }
                                if(parser.getCurrentToken()== System.JSONToken.FIELD_NAME && parser.getText() == 'Description'){
                                    parser.nextToken();
                                    tempObject.description =parser.getText();
                                    
                                }
                                
                                if (parser.getCurrentToken() == JSONToken.END_OBJECT){
                                    availableAddress.add(tempObject);
                                    break;
                                }
                            }   
                        }
                        if (parser.getCurrentToken() == JSONToken.END_ARRAY)
                            break;
                    }
                } 
            }  
        } 
        if(responseId != null && responseType =='Address'){
            returnVal.put('formateddAddress',getFormattedAddress(responseId));
        }
        returnVal.put('addressList',availableAddress);
        return returnVal;
    }
    
    @AuraEnabled
    public static Map<String,Object> getFormattedAddress(String Id){
        Map<String,Object> returnVal =new Map<String,Object>();
        String idPayload ='&Id='+EncodingUtil.urlEncode(Id,'UTF-8');
        System.debug(idPayload);
        String formatAddress = getResponse(
                        		'https://api.addressy.com/Capture/Interactive/Retrieve/v1.00/json3ex.ws',
                        		idPayload
                    		   );
        System.debug('formatAddress '+formatAddress);
        JSONParser parser = JSON.createParser(formatAddress);
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken()== System.JSONToken.FIELD_NAME){
                string fieldName = parser.getCurrentName();
                parser.nextToken();
                returnVal.put(fieldName,parser.getText());
            }
        }
        return returnVal;
    }
    Public static String findAddressPayload(String text,String containerText){
        String payload = '';
        if(String.isBlank(containerText))
            payload = '&Text='+EncodingUtil.urlEncode(text,'UTF-8')+'&Limit='+EncodingUtil.urlEncode('1','UTF-8')+'&Origin='+EncodingUtil.urlEncode('','UTF-8')+'&Countries='+EncodingUtil.urlEncode('GBR','UTF-8');
         else
            payload = '&Text='+EncodingUtil.urlEncode(text,'UTF-8')+'&Container='+EncodingUtil.urlEncode(containerText,'UTF-8')+'&Limit='+EncodingUtil.urlEncode('10','UTF-8')+'&Origin='+EncodingUtil.urlEncode('','UTF-8')+'&Countries='+EncodingUtil.urlEncode('GBR','UTF-8');
        return payload;
    }
    Public static String  getResponse(String endPoint,String payload){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('content-Type','application/x-www-form-urlencoded');
        payload = 'key='+EncodingUtil.urlEncode('EZ71-RP35-PD27-EH99','UTF-8')+payload;
        req.setBody(payload);
        HttpResponse res = h.send(req);
        return res.getBody();
    }
    @AuraEnabled(cacheable=true)
    public static Map<Id,HA_Payment_Schedule__c> getPaymentSchedules(){
        return new Map<Id,HA_Payment_Schedule__c>([SELECT Processing_Time__c, Start_Date__c, Is_Active__c, Type__c, Is_External__c, Start_Date_2__c, Schedule__c, Start_Date_3__c, End_Date_1__c, End_Date_2__c, End_Date_3__c, Payment_Methods__c, End_Date__c, Frequency__c, Code__c, Name, Id FROM HA_Payment_Schedule__c Where Is_Active__c = true and Is_Internal__c =true]);
    }
    
    public static String generateGUID() {
        Blob b = Crypto.GenerateAESKey(128);String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0, 8) +'-' +h.SubString(8, 12) + '-' +h.SubString(12, 16) +'-' +h.SubString(16, 20) +'-' + h.substring(20);
    }
    public Static String getCountryISOCode(String CountyName){
        return [SELECT Id,DeveloperName,Label,Country_Code_alpha_2__c FROM Country_Mapping__mdt Where  Label=:CountyName]?.Country_Code_alpha_2__c;

    }
    public static Id getUserInfoAccountId(){
        return [SELECT AccountId From User WHERE Id=:UserInfo.getUserId()]?.AccountId;
    } 
    public static Id getUserInfoContactId(){
        return [SELECT ContactId From User WHERE Id=:UserInfo.getUserId()]?.ContactId;
    } 
    public static String getUserInfoRegionalCode(){
        
        return [select Payment_Country_Code__c From user where Payment_Country_Code__c != null AND Id=:UserInfo.getUserId()]?.Payment_Country_Code__c;
    }

    public static String getContactRegionalCode(Id contactId){
        
        return [SELECT Regional_Office_Code__c From Contact WHERE Id =:contactId ]?.Regional_Office_Code__c;
    }
}