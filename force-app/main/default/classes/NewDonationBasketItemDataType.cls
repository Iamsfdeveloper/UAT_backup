/**
 * @File Name          : NewDonationBasketItemDataType.cls
 * @Description        : 
 * @Author             : agentgill
 * @Group              : 
 * @Last Modified By   : Iamsfdeveloper
 * @Last Modified On   : 03-17-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/10/2020   agentgill     Initial Version
 * 1.1   11/18/2020  Iamsfdeveloper  added donationType property
**/
public with sharing class NewDonationBasketItemDataType {
    @AuraEnabled @InvocableVariable public Decimal amount;
    @AuraEnabled @InvocableVariable public String notes;
    @AuraEnabled @InvocableVariable public String donationItemCode;
    @AuraEnabled @InvocableVariable public String locationCode;
    @AuraEnabled @InvocableVariable public String stipulationCode;
    @AuraEnabled @InvocableVariable public String targetNumber;
    @AuraEnabled @InvocableVariable public String campaignCode;
    @AuraEnabled @InvocableVariable public String cardId;
    @AuraEnabled @InvocableVariable public String donationType;
    @AuraEnabled @InvocableVariable public SchemeData[] schemeData;
    @AuraEnabled @InvocableVariable public PaymentScheduleList[] PaymentScheduleList;
  
    public class SchemeData{
        @AuraEnabled @InvocableVariable public String ParameterCode;
        @AuraEnabled @InvocableVariable public String ParameterName;
        @AuraEnabled @InvocableVariable public String ParameterValue;
    }
    public class PaymentScheduleList{
        @AuraEnabled @InvocableVariable public Integer Index;
        @AuraEnabled @InvocableVariable public Datetime Date_Time;
        @AuraEnabled @InvocableVariable public String Timezone;
        @AuraEnabled @InvocableVariable public Decimal Amount;
    }
    public NewDonationBasketItemDataType() {}
}