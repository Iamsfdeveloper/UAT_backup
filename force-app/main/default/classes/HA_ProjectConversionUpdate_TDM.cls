/**
 * @description       : update Related records
 * @author            : Kalpesh.Thakur@HumanAppeal.co.uk
 * @group             : 
 * @last modified on  : 02-08-2022
 * @last modified by  : Kalpesh.Thakur@HumanAppeal.co.uk
 * Modifications Log 
 * Ver   Date         Author                             Modification 
 * 1.0   07-22-2021   Kalpesh.Thakur@HumanAppeal.co.uk   Initial Version
**/
global class HA_ProjectConversionUpdate_TDM extends npsp.TDTM_Runnable {
    
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                             List<SObject> oldlist,
                                             npsp.TDTM_Runnable.Action triggerAction,
                                             Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
        List<Project__c> oldProjectList = (List<Project__c>)oldlist;
        List<Project__c> newProjectList = (List<Project__c>)newlist;
		List<Fund_Allocation__c> updateFundAllocations = new List<Fund_Allocation__c>();
        List<Beneficiaries__c> updateBeneficiaries = new List<Beneficiaries__c>();
        List<Report_Schedule__c> updateReportSchedules = new List<Report_Schedule__c>();
        List<Fund_Transfer_Schedule__c> updateFundTransfers = new List<Fund_Transfer_Schedule__c>();
        List<Donor_Payment_Schedule__c> updateDonorPayments = new List<Donor_Payment_Schedule__c>();
                                                
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {

            Map<Id,Project__c> mapNewProject = new Map<Id,Project__c>(newProjectList);
            Map<Id,Id> mapProjectIdConceptNoteId = new Map<Id,Id>();

            for (Project__c objPro : newProjectList) {

                mapProjectIdConceptNoteId.put(objPro.Concept_Note__c,objPro.Id);
            }

            System.debug('****mapProjectIdConceptNoteId'+mapProjectIdConceptNoteId);

            for (Fund_Allocation__c objFundAll : [SELECT Id,Project__c,Concept_Note__c FROM Fund_Allocation__c WHERE Concept_Note__c=:mapProjectIdConceptNoteId.keySet()]) {

                if (mapProjectIdConceptNoteId.containsKey(objFundAll.Concept_Note__c)) {

                    objFundAll.Project__c = mapProjectIdConceptNoteId.get(objFundAll.Concept_Note__c);
                    System.debug('**objFundAll**:--'+objFundAll);
                    updateFundAllocations.add(objFundAll);
                }
            }

            

            for (Beneficiaries__c objBene : [SELECT Id,Project__c,Concept_Note__c FROM Beneficiaries__c WHERE Concept_Note__c=:mapProjectIdConceptNoteId.keySet()]) {

                if (mapProjectIdConceptNoteId.containsKey(objBene.Concept_Note__c)) {

                    objBene.Project__c = mapProjectIdConceptNoteId.get(objBene.Concept_Note__c);
                    System.debug('**objBene**:--'+objBene);
                    updateBeneficiaries.add(objBene);
                }
            }

            

            for (Report_Schedule__c objReportSch : [SELECT Id,Project__c,Concept_Note__c FROM Report_Schedule__c WHERE Concept_Note__c=:mapProjectIdConceptNoteId.keySet()]) {

                if (mapProjectIdConceptNoteId.containsKey(objReportSch.Concept_Note__c)) {

                    objReportSch.Project__c = mapProjectIdConceptNoteId.get(objReportSch.Concept_Note__c);
                    System.debug('**objReportSch**:--'+objReportSch);
                    updateReportSchedules.add(objReportSch);
                }
            }

            

            for (Fund_Transfer_Schedule__c objFundTransfer : [SELECT Id,Project__c,Concept_Note__c FROM Fund_Transfer_Schedule__c WHERE Concept_Note__c=:mapProjectIdConceptNoteId.keySet()]) {

                if (mapProjectIdConceptNoteId.containsKey(objFundTransfer.Concept_Note__c)) {

                    objFundTransfer.Project__c = mapProjectIdConceptNoteId.get(objFundTransfer.Concept_Note__c);
                    System.debug('*objFundTransfer*:--'+objFundTransfer);
                    updateFundTransfers.add(objFundTransfer);
                }
            }

            

            for (Donor_Payment_Schedule__c objDonorPayment : [SELECT Id,Project__c,Concept_Note__c FROM Donor_Payment_Schedule__c WHERE Concept_Note__c=:mapProjectIdConceptNoteId.keySet()]) {

                if (mapProjectIdConceptNoteId.containsKey(objDonorPayment.Concept_Note__c)) {

                    objDonorPayment.Project__c = mapProjectIdConceptNoteId.get(objDonorPayment.Concept_Note__c);
                    System.debug('**objDonorPayment**:--'+objDonorPayment);
                    updateDonorPayments.add(objDonorPayment);
                }
            }


        }
                                                 
        if (!updateFundAllocations.isEmpty()) {
           
             dmlWrapper.objectsToUpdate.addAll(updateFundAllocations);
        }     
        
        if (!updateBeneficiaries.isEmpty()) {
           
            dmlWrapper.objectsToUpdate.addAll(updateBeneficiaries);
       }  
       
       if (!updateReportSchedules.isEmpty()) { 
           
            dmlWrapper.objectsToUpdate.addAll(updateReportSchedules);
        } 

        if (!updateFundTransfers.isEmpty()) {
                
            dmlWrapper.objectsToUpdate.addAll(updateFundTransfers);
        } 

        if (!updateDonorPayments.isEmpty()) {
                
            dmlWrapper.objectsToUpdate.addAll(updateDonorPayments);
        } 
        
        System.debug('****dmlwrapper**:-'+dmlWrapper.objectsToUpdate);                                        
      
      return dmlWrapper;
    }

}