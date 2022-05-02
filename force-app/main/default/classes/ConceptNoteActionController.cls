public class ConceptNoteActionController {
	
    @AuraEnabled
    public static String  cloneConceptNote(String conceptNoteId) {
        	
        String recCNId = ConceptNoteClone.cloneConceptNote(conceptNoteId);
        
        return recCNId;
    }
    
    @AuraEnabled
    public static String submitApproval(String conceptNoteId) {
		
        
       return 'Submitted Successfully for Approval';
    }
}