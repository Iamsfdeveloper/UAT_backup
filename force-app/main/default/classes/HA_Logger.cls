/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 01-16-2022
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   02-08-2021   Iamsfdeveloper   Initial Version
**/
public with sharing class HA_Logger {

    public static Recurring_Donation_Batch_Errors__c CreateErrorLog(String requestDetails,String basketId,String ErrorContext){
        Recurring_Donation_Batch_Errors__c error=  new Recurring_Donation_Batch_Errors__c(basketId__c = basketId,EventDetails__c =requestDetails,Error_Context__c=ErrorContext);
       return error;
    }
}