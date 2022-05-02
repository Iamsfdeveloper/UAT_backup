/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 01-24-2022
 * @last modified by  : Iamsfdeveloper
**/
global without Sharing class BasketTriggerHandler_TDTM extends npsp.TDTM_RunnableMutable  {
   
    global override void run(List<SObject> newlist,
                             List<SObject> oldlist,
                             npsp.TDTM_Runnable.Action triggerAction,
                             Schema.DescribeSObjectResult objResult,npsp.TDTM_Runnable.DmlWrapper dmlWrapper) {
                                 
                                 
                                 if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
                                     BasketTriggerHandler_Queueable queueable = new BasketTriggerHandler_Queueable(( List<Basket__c> )newlist);
                                     System.enqueueJob(queueable);
                                     
                                 } 
                                 
     
    }

}