/**
 * @description       : Update the Name 
 * @author            : Kalpesh.Thakur@HumanAppeal.co.uk
 * @group             : 
 * @last modified on  : 11-03-2021
 * @last modified by  : Kalpesh.Thakur@HumanAppeal.co.uk
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-03-2021  Kalpesh.Thakur@HumanAppeal.co.uk   Initial Version
**/
global class HA_UpdateConceptNoteName_TDTM extends npsp.TDTM_Runnable  {

    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                             List<SObject> oldlist,
                                             npsp.TDTM_Runnable.Action triggerAction,
                                             Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper(); 
        

        if (triggerAction == npsp.TDTM_Runnable.Action.BeforeInsert 
            && objResult.getSObjectType() == Concept_Note__c.sObjectType) {
			
            List<Concept_Note__c> newConNoteList = (List<Concept_Note__c>) newlist;
                
            Id standardRTId = Schema.SObjectType.Concept_Note__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
            Id institutional_ProposalRTId = Schema.SObjectType.Concept_Note__c.getRecordTypeInfosByName().get('Institutional Proposal').getRecordTypeId();
            Id institutional_Concept_NoteRTId = Schema.SObjectType.Concept_Note__c.getRecordTypeInfosByName().get('Institutional Concept Note').getRecordTypeId();

            Map<String,String> mapCountryMapping = new Map<String,String>();

            for (Country_Mapping__mdt objCountryMapping : [SELECT Id,DeveloperName,Country_Code_alpha_2__c FROM Country_Mapping__mdt]) {

                mapCountryMapping.put(objCountryMapping.DeveloperName,objCountryMapping.Country_Code_alpha_2__c);
            }

            Set<String> keyNamesFilter = new Set<String>();
            Set<String> keyNames = new Set<String>();
            Map<Id,String> mapIdByName = new Map<Id,String>();
            Map<Id,String> mapIdByProjectName = new Map<Id,String>();

            for (Concept_Note__c objConceptNote : newConNoteList) {

                String keyName = '';
                String yearCode = String.valueOf(Date.today().year()).right(2);
                if (objConceptNote.RecordTypeId == standardRTId) {

                    keyName = 'PCN'+mapCountryMapping.get(objConceptNote.Country__c)+yearCode+'-'+objConceptNote.Project_Code__c;
                }
                else if (objConceptNote.RecordTypeId == institutional_Concept_NoteRTId) {

                    keyName = 'ICN'+mapCountryMapping.get(objConceptNote.Country__c)+yearCode+'-'+objConceptNote.Project_Code__c;
                }
                else if (objConceptNote.RecordTypeId == institutional_ProposalRTId) {
                    
                    keyName = 'IPP'+mapCountryMapping.get(objConceptNote.Country__c)+yearCode+'-'+objConceptNote.Project_Code__c;
                }

                mapIdByName.put(objConceptNote.Id, keyName);
                mapIdByProjectName.put(objConceptNote.Id, mapCountryMapping.get(objConceptNote.Country__c)+yearCode+'-'+objConceptNote.Project_Code__c);
                keyNamesFilter.add('%'+keyName+'%');
                keyNames.add(keyName);
            } 

            Map<String,Integer> mapNameBySeqNo = new Map<String,Integer>();

            List<Concept_Note__c> lstConceptNote = [SELECT Id,Name FROM Concept_Note__c WHERE Name Like : keyNamesFilter];
            System.debug('***lstConceptNote**'+lstConceptNote);

            for (Concept_Note__c objConceptNote : lstConceptNote) {

                String keyName = objConceptNote.Name.left(11);
                System.debug('***keyName**'+keyName);
                Integer intSeqNo = Integer.valueOf(objConceptNote.Name.right(2));
                System.debug('***intSeqNo**'+intSeqNo);
                if (mapNameBySeqNo.containsKey(keyName) && mapNameBySeqNo.get(keyName) < intSeqNo) {

                    mapNameBySeqNo.put(keyName,intSeqNo);
                }
                else if (!mapNameBySeqNo.containsKey(keyName)) {

                    mapNameBySeqNo.put(keyName,intSeqNo);
                }

            }
            
            System.debug('****mapNameBySeqNo**:--'+mapNameBySeqNo);
                
            for (Concept_Note__c objConceptNote : newConNoteList) {
                
				System.debug('****objConceptNote.Id**:--'+objConceptNote.Id);
                System.debug('****mapIdByName**:--'+mapIdByName);
				System.debug('****mapIdByNameget**:--'+mapIdByName.get(objConceptNote.Id));       
                System.debug('******:--'+mapNameBySeqNo.containsKey(mapIdByName.get(objConceptNote.Id)));  
                if (mapNameBySeqNo.containsKey(mapIdByName.get(objConceptNote.Id))) {
					System.debug('INSIDE 1');
                    Integer intSeqNo = mapNameBySeqNo.get(mapIdByName.get(objConceptNote.Id)) + 1;
                    System.debug('intSeqNo 1'+intSeqNo);
                    String strSeq = String.valueOf(intSeqNo);
                    if (intSeqNo < 10) {

                        strSeq = '0'+strSeq;  
                    }

                    objConceptNote.Name = mapIdByName.get(objConceptNote.Id)+strSeq;
                    objConceptNote.Project_Reference__c = mapIdByProjectName.get(objConceptNote.Id)+strSeq;
                    mapNameBySeqNo.put(mapIdByName.get(objConceptNote.Id), intSeqNo);
                }
                else {
					System.debug('INSIDE 2');
                    objConceptNote.Name = mapIdByName.get(objConceptNote.Id)+'01';
                    objConceptNote.Project_Reference__c = mapIdByProjectName.get(objConceptNote.Id)+'01';
                }
                System.debug('***objConceptNote*Update:--'+objConceptNote);
            }
        }

      return dmlWrapper;
    }
}