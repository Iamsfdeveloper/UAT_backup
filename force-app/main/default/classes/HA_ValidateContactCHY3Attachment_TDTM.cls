/**
 * @description       : Check if the CHY3 file is attached to the Donor record if CHY3 Form Received field is true
 * @author            : Kalpesh.Thakur@HumanAppeal.co.uk
 * @group             : 
 * @last modified on  : 07-22-2021
 * @last modified by  : Kalpesh.Thakur@HumanAppeal.co.uk
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   07-22-2021   Kalpesh.Thakur@HumanAppeal.co.uk   Initial Version
**/
global class HA_ValidateContactCHY3Attachment_TDTM extends npsp.TDTM_Runnable  {

    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                             List<SObject> oldlist,
                                             npsp.TDTM_Runnable.Action triggerAction,
                                             Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
       List<Contact> newConList = (List<Contact>) newlist;
            List<Contact> oldConList = (List<Contact>) oldlist;
            Map<Id,Contact> oldContactMap = new Map<Id,Contact>(oldConList);

            Set<Id> setContactIds =  new Set<Id>();

        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeUpdate) {
            

            for (Contact objCon : newConList) {

                System.debug('*****:--'+objCon.CHY3_Receive_Date__c);

                if (objCon.CHY3_Form_Received__c == True && objCon.CHY3_Receive_Date__c != null && objCon.CHY3_Expiry_Date__c != null
                    && (oldContactMap.get(objCon.Id).CHY3_Form_Received__c != objCon.CHY3_Form_Received__c
                    || oldContactMap.get(objCon.Id).CHY3_Receive_Date__c != objCon.CHY3_Receive_Date__c
                    || oldContactMap.get(objCon.Id).CHY3_Expiry_Date__c != objCon.CHY3_Expiry_Date__c)) {

                        setContactIds.add(objCon.Id);
                }
            }

            if (!setContactIds.isEmpty()) {

                Map<Id,Set<String>> mapContactIdFileNames = new Map<Id,Set<String>>();

                for (ContentDocumentLink objContent : [SELECT ContentDocumentId, LinkedEntityId,ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId IN:setContactIds]) {

                    if (mapContactIdFileNames.containsKey(objContent.LinkedEntityId)) {

                        mapContactIdFileNames.get(objContent.LinkedEntityId).add(objContent.ContentDocument.Title);
                    }
                    else {

                        mapContactIdFileNames.put(objContent.LinkedEntityId, new Set<String>{objContent.ContentDocument.Title});
                    }
                }


                for (Contact objCon : newConList) {

                    if (objCon.CHY3_Receive_Date__c != null) {

                        String fileName = 'CHY3_'+String.valueOf(objCon.CHY3_Receive_Date__c.year());

                        System.debug('****:--'+fileName);

                        if (!mapContactIdFileNames.containsKey(objCon.Id)) {
                            
                            objCon.addError(Label.HA_Request_to_attach_CHY3_Form);
                        }
                        else if (mapContactIdFileNames.containsKey(objCon.Id) && !mapContactIdFileNames.get(objCon.Id).contains(fileName)) {
                            
                            objCon.addError(Label.HA_Request_to_attach_CHY3_Form);
                        }
                    }
                }
            }

        }
      
      return dmlWrapper;
    }
}