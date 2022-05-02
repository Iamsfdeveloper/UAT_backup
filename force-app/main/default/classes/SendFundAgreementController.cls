public class SendFundAgreementController {
    
    @AuraEnabled
    public static String sendAgreements(String conceptNoteId) {
        
        Concept_Note__c objConceptNote = EversignConnection.createAgreementFODocument(Label.Field_Office_Funding_Agreement_Template,conceptNoteId);
        List<Fund_Allocation__c> lstFundAllo = EversignConnection.createAgreementPartnerDocument(Label.Partner_Funding_Agreement_Template,conceptNoteId);
        
        update objConceptNote;
        update lstFundAllo;
        
        return 'Agreements sent Sucessfully';
    }
    
    @AuraEnabled
    public static String getAgreementStatus(String conceptNoteId) {
        
        EversignConnection.getDocuments(conceptNoteId);
        
        return 'Agreement Status Updated Successfully';
    }
    
    @AuraEnabled
    public static String isStatusCheck(String conceptNoteId) {
        
        Concept_Note__c objConceptNote  = [SELECT Id,Eversign_FO_Document_Id__c,Field_Office_Agreement_Status__c FROM Concept_Note__c WHERE Id=:conceptNoteId];
        
        List<Fund_Allocation__c> lstFundAllo = [SELECT Id,Eversign_Partner_Document_Id__c ,Concept_Note__c,Partner_Agreement_Signature_Status__c  FROM Fund_Allocation__c WHERE Concept_Note__c=:conceptNoteId];
        
        Set<Id> setCompleted = new Set<Id>();
        Set<Id> setInProgress = new Set<Id>();
        
        for (Fund_Allocation__c objFundAllocation : lstFundAllo) {
                                                          
            if (objFundAllocation.Partner_Agreement_Signature_Status__c == 'Completed') {
                    
            	setCompleted.add(objFundAllocation.Id);
            } 
            else if (objFundAllocation.Partner_Agreement_Signature_Status__c == 'In Progress') {
                    
                setInProgress.add(objFundAllocation.Id);
            }
            else if (objFundAllocation.Partner_Agreement_Signature_Status__c == 'Cancelled') {
                    
                return 'Cancelled';
            } 
        }
        
        if (setCompleted.size() == lstFundAllo.size() && objConceptNote.Field_Office_Agreement_Status__c == 'Completed') {
            
            objConceptNote.Stage__c = 'FA-signed';
            update objConceptNote;
            
            return 'Completed';
            
        }
        else if (objConceptNote.Field_Office_Agreement_Status__c == 'Cancelled') {
            
            return 'Cancelled';
        }
        else if (setInProgress.size() > 0 || objConceptNote.Field_Office_Agreement_Status__c == 'In Progress') {
            
            return 'In Progress';
        }
        
        return 'Draft';
    }

}