/**
 * @File Name          : NewDonationSupporterDataType.cls
 * @Description        : 
 * @Author             : agentgill
 * @Group              : 
 * @Last Modified By   : agentgill
 * @Last Modified On   : 3/10/2020, 10:54:34 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/10/2020   agentgill     Initial Version
**/
public with sharing class NewDonationSupporterDataType {
    @AuraEnabled @InvocableVariable public String supporterId;
    @AuraEnabled @InvocableVariable public String title;
    @AuraEnabled @InvocableVariable public String firstName;
    @AuraEnabled @InvocableVariable public String lastName;
    @AuraEnabled @InvocableVariable public String organisationName;
    @AuraEnabled @InvocableVariable public String addressLine1;
    @AuraEnabled @InvocableVariable public String addressLine2;
    @AuraEnabled @InvocableVariable public String addressLine3;
    @AuraEnabled @InvocableVariable public String townCity;
    @AuraEnabled @InvocableVariable public String state;
    @AuraEnabled @InvocableVariable public String postalCode;
    @AuraEnabled @InvocableVariable public String countryCode;
    @AuraEnabled @InvocableVariable public String telephone;
    @AuraEnabled @InvocableVariable public String email;
    @AuraEnabled @InvocableVariable public String giftAidDelcared;
    @AuraEnabled @InvocableVariable public Boolean subscribeEmailList;
    @AuraEnabled @InvocableVariable public Boolean subscribeSmsList;
    @AuraEnabled @InvocableVariable public Boolean receiptViaEmail;
    @AuraEnabled @InvocableVariable public Boolean receiptViaPost;
    @AuraEnabled @InvocableVariable public String nationalIdentificationNumber;
    
    public NewDonationSupporterDataType(){
      
    }
}