/**
 * @File Name          : NewDonationDataType.cls
 * @Description        : 
 * @Author             : agentgill
 * @Group              : 
 * @Last Modified By   : agentgill
 * @Last Modified On   : 15/04/2020, 13:13:14
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/10/2020   agentgill     Initial Version
**/
public with sharing class NewDonationDataType {
    @AuraEnabled @InvocableVariable public Integer paymentMethod;
    @AuraEnabled @InvocableVariable public String webPaymentCardDetails; // null object
    @AuraEnabled @InvocableVariable public String bankTransferDetails;
    @AuraEnabled @InvocableVariable public String snapScanDetails;
    @AuraEnabled @InvocableVariable public String paypalDetails;
    @AuraEnabled @InvocableVariable public String transactionId;
    @AuraEnabled @InvocableVariable public String transactionTimeUtc;
    @AuraEnabled @InvocableVariable public String basketCollectionId;
    @AuraEnabled @InvocableVariable public NewDonationSupporterDataType supporter;
    @AuraEnabled @InvocableVariable public NewDonationBasketDataType basket;
    @AuraEnabled @InvocableVariable public String charityGiftCards;
    @AuraEnabled @InvocableVariable public String analyticsData; // null object
    @AuraEnabled @InvocableVariable public String userIp;
    @AuraEnabled @InvocableVariable public String siteCode;
    @AuraEnabled @InvocableVariable public String donationType;

    public NewDonationDataType() {}

}