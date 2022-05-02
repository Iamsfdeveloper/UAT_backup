/**
 * @description       : Check if three profile photos have been uploaded then only allow to activate the orphan contact 
 * @author            : Kalpesh.Thakur@HumanAppeal.co.uk
 * @group             : 
 * @last modified on  : 10-05-2021
 * @last modified by  : Kalpesh.Thakur@HumanAppeal.co.uk
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   10-05-2021   Kalpesh.Thakur@HumanAppeal.co.uk   Initial Version 
**/
global class HA_ValidateOrphanProfileActive_TDTM extends npsp.TDTM_Runnable  {

    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                             List<SObject> oldlist,
                                             npsp.TDTM_Runnable.Action triggerAction,
                                             Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        List<Contact> newConList = (List<Contact>) newlist;
 
                                                 
        Id recordTypeOrphanId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Orphan').getRecordTypeId();

        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            
            List<Contact> oldConList = (List<Contact>) oldlist;
            Map<Id,Contact> oldContactMap = new Map<Id,Contact>(oldConList);
            Set<Id> setContactIds =  new Set<Id>();

            for (Contact objCon : newConList) {

                if (objCon.RecordTypeId == recordTypeOrphanId && objCon.Is_Active__c == true 
                    && oldContactMap.get(objCon.Id).Is_Active__c != objCon.Is_Active__c) {

                        setContactIds.add(objCon.Id);
                }
            }

            if (!setContactIds.isEmpty()) {
				
                Set<Id> contactIdsWithProfilePhoto = new Set<Id>();
                
                for (sharinpix__SharinPixImage__c objSharinPix : [SELECT Id,sharinpix__Tags__c,Contact__c  
                                                                   FROM sharinpix__SharinPixImage__c 
                                                                   WHERE Contact__c =:setContactIds AND sharinpix__Tags__c ='#ProfilePhoto#']) {
                    contactIdsWithProfilePhoto.add(objSharinPix.Contact__c);
                }

                for (Contact objCon : newConList) {

                    if (!contactIdsWithProfilePhoto.contains(objCon.Id)){

                       objCon.addError(Label.HA_ErrorMessage_OrphanProfilePhotoRequired);
                    }
                }
            }

        }
        else if (triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert) { 
            for (Contact objCon : newConList) {
				
                if (objCon.RecordTypeId == recordTypeOrphanId && objCon.Is_Active__c == true) {

                	objCon.addError(Label.HA_ErrorMessage_OrphanProfilePhotoRequired);
                }
            }
		
        }
      
      return dmlWrapper;
    }
}