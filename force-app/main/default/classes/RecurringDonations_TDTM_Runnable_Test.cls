/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 04-06-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   04-06-2021   Iamsfdeveloper   Initial Version
**/
@isTest
public with sharing class RecurringDonations_TDTM_Runnable_Test {
   
    @IsTest
    static void unit1(){
 
 
        Test.startTest();
		RecurringDonations_TDTM_Runnable demo = new RecurringDonations_TDTM_Runnable();
		HA_CreateDonations demo2 = new HA_CreateDonations();
		HA_CreateDonations_Queueable demo3 = new HA_CreateDonations_Queueable();        
        Test.stopTest();
        
    }
    
}