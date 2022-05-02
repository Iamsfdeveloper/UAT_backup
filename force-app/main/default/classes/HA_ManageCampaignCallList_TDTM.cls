/**
 * @description       : Run ManageCampaignCallListBatch
 * @author            : Kalpesh.Thakur@HumanAppeal.co.uk
 * @group             : 
 * @last modified on  : 08-03-2021
 * @last modified by  : Kalpesh.Thakur@HumanAppeal.co.uk
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   08-03-2021   Kalpesh.Thakur@HumanAppeal.co.uk   Initial Version
**/
global class HA_ManageCampaignCallList_TDTM extends npsp.TDTM_Runnable  {

    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                             List<SObject> oldlist,
                                             npsp.TDTM_Runnable.Action triggerAction,
                                             Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        List<Contact> newConList = (List<Contact>) newlist;
        List<Contact> oldConList = (List<Contact>) oldlist;
        Map<Id,Contact> oldContactMap = new Map<Id,Contact>(oldConList);

        if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate) {
            
            
        }
    	
        return dmlWrapper;
    }
}