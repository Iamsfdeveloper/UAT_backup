public class ConceptNoteClone {
    
	@AuraEnabled
    public static String  cloneConceptNote(String conceptNoteId) {
        

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        List<String> conceptNotefields = new List<String>(schemaMap.get('Concept_Note__c').getDescribe().fields.getMap().keySet());
        List<String> beneficiariesfields = new List<String>(schemaMap.get('Beneficiaries__c').getDescribe().fields.getMap().keySet());
        List<String> fundAllocationfields = new List<String>(schemaMap.get('Fund_Allocation__c').getDescribe().fields.getMap().keySet());
        List<String> donorPaymentSchedulefields = new List<String>(schemaMap.get('Donor_Payment_Schedule__c').getDescribe().fields.getMap().keySet());
        List<String> fundTransferSchedulefields = new List<String>(schemaMap.get('Fund_Transfer_Schedule__c').getDescribe().fields.getMap().keySet());
        List<String> reportSchedulefields = new List<String>(schemaMap.get('Report_Schedule__c').getDescribe().fields.getMap().keySet());
        
		String conceptNQuery = 'SELECT '+String.join(conceptNotefields, ',')+' FROM Concept_Note__c WHERE Id=\''+conceptNoteId+'\'';
        String beneficiariesQuery = 'SELECT '+String.join(beneficiariesfields, ',')+' FROM Beneficiaries__c WHERE Concept_Note__c=\''+conceptNoteId+'\'';
        String fundAlloQuery = 'SELECT '+String.join(fundAllocationfields, ',')+' FROM Fund_Allocation__c WHERE Concept_Note__c=\''+conceptNoteId+'\'';
        String donorPayQuery = 'SELECT '+String.join(donorPaymentSchedulefields, ',')+' FROM Donor_Payment_Schedule__c WHERE Concept_Note__c=\''+conceptNoteId+'\'';
        String fundTransQuery = 'SELECT '+String.join(fundTransferSchedulefields, ',')+' FROM Fund_Transfer_Schedule__c WHERE Concept_Note__c=\''+conceptNoteId+'\'';
        String reportSchQuery = 'SELECT '+String.join(reportSchedulefields, ',')+' FROM Report_Schedule__c WHERE Concept_Note__c=\''+conceptNoteId+'\'';
        
        Savepoint sp;
        Concept_Note__c cnCloneCopy;
        try {
        	
            sp = Database.setSavepoint();
            
            Concept_Note__c objConceptNote = Database.query(conceptNQuery);
            
            cnCloneCopy  = objConceptNote.clone(false, true, false, false);
            cnCloneCopy.Stage__c = 'Draft';
            cnCloneCopy.Eversign_FO_Document_Id__c ='';
            cnCloneCopy.Field_Office_Agreement_Status__c = '';
            insert cnCloneCopy;
            
            List<Fund_Allocation__c> newFundAllocations = new List<Fund_Allocation__c>();
            
            Map<Id,Integer> mapFundAllSeq = new Map<Id,Integer>();
            
            Map<Id,Fund_Allocation__c> mapFundAll = new Map<Id,Fund_Allocation__c>((List<Fund_Allocation__c>)Database.query(fundAlloQuery));
            
            integer i = 0;
            for (Fund_Allocation__c objfundAll : mapFundAll.values()) {
                
                mapFundAllSeq.put(objfundAll.Id,i);
                
                Fund_Allocation__c fundAllCloneCopy  = objfundAll.clone(false, true, false, false);
                fundAllCloneCopy.Concept_Note__c = cnCloneCopy.Id;
                fundAllCloneCopy.Project__c =null;
                fundAllCloneCopy.Eversign_Partner_Document_Id__c = '';
                fundAllCloneCopy.Partner_Agreement_Signature_Status__c  = '';
                newFundAllocations.add(fundAllCloneCopy);
                i++;
            }
            
            if (!newFundAllocations.isEmpty()) {
                
                insert newFundAllocations;
                
                List<Donor_Payment_Schedule__c> newDonorPayments = new List<Donor_Payment_Schedule__c>();
            
                for (Donor_Payment_Schedule__c objDonorPay : Database.query(donorPayQuery)) {
                
                    Donor_Payment_Schedule__c donorPayCloneCopy  = objDonorPay.clone(false, true, false, false);
                    donorPayCloneCopy.Concept_Note__c = cnCloneCopy.Id;
                    donorPayCloneCopy.Project__c =null;
                    donorPayCloneCopy.Fund_Allocation__c = newFundAllocations.get(mapFundAllSeq.get(objDonorPay.Fund_Allocation__c)).Id;
                    newDonorPayments.add(donorPayCloneCopy); 
                } 
                
                 if (!newDonorPayments.isEmpty()) {
                    
                     insert newDonorPayments;
                 } 
            }
            
           
            
            List<Beneficiaries__c> newBeneficiaries = new List<Beneficiaries__c>();
            
            for (Beneficiaries__c objBene : Database.query(beneficiariesQuery)) {
                
                Beneficiaries__c beneCloneCopy  = objBene.clone(false, true, false, false);
                beneCloneCopy.Concept_Note__c = cnCloneCopy.Id;
                beneCloneCopy.Project__c =null;
                newBeneficiaries.add(beneCloneCopy); 
            }
            
            if (!newBeneficiaries.isEmpty()) {
                    
                insert newBeneficiaries;
            } 
            
            
            List<Fund_Transfer_Schedule__c> newFundTransfers = new List<Fund_Transfer_Schedule__c>();
            
            for (Fund_Transfer_Schedule__c objFundTrans : Database.query(fundTransQuery)) {
                
                Fund_Transfer_Schedule__c fundTransCloneCopy  = objFundTrans.clone(false, true, false, false);
                fundTransCloneCopy.Concept_Note__c = cnCloneCopy.Id;
                fundTransCloneCopy.Project__c =null;
                newFundTransfers.add(fundTransCloneCopy); 
            }
            
            if (!newFundTransfers.isEmpty()) {
                    
                insert newFundTransfers;
            } 
            
            List<Report_Schedule__c> newReportSchedules = new List<Report_Schedule__c>();
            
            for (Report_Schedule__c objReportSch : Database.query(reportSchQuery)) {
                
                Report_Schedule__c reportSchCloneCopy  = objReportSch.clone(false, true, false, false);
                reportSchCloneCopy.Concept_Note__c = cnCloneCopy.Id;
                reportSchCloneCopy.Project__c =null;
                newReportSchedules.add(reportSchCloneCopy); 
            }
            
            if (!newReportSchedules.isEmpty()) {
                    
                insert newReportSchedules;
            } 
        }
        catch(Exception exe) {
        	
            Database.rollback(sp);
        }

        return cnCloneCopy.Id;
    }
}