public class SendFRDonationStatementBatch implements Database.Batchable<sObject> {
    
    public final String query;
    
    public SendFRDonationStatementBatch(String query) {
        
        this.query = String.isNotBlank(query) ? query : 'SELECT Id FROM Contact WHERE Regional_Office_Code__c = \'FR\' AND Donation_Statement_Last_year__c = False AND ContactId IN (SELECT Id FROM Opportunities WHERE Recurring_Setup__c =0 AND IsWon = TRUE AND CloseDate = LAST_YEAR)';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Contact> contactToUpdate = new List<Contact>();
        
        for (Contact eachCon : [
            SELECT Id, Donation_Statement_Last_year__c  
            FROM Contact
            WHERE Id IN :scope
        ]) {
            
            eachCon.Donation_Statement_Last_year__c = true;//this triggers the workflow email alert to send email template
            contactToUpdate.add(eachCon);
        }
        
		database.update(contactToUpdate, false);        
    }
    
    //limitation on sending 5000 emails in a day using single email message class
    /*private void sendEmail(List<Contact> contactIdSet) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Date startDate = Date.newInstance(2021, 1, 1); 
        Date endDate = Date.newInstance(1960, 12, 31);
        String subject = 'Tax Statement From '+startDate.format()+' To '+endDate.format();
        
        for (Contact eachContact : contactIdSet) {
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setFileName(subject +'.pdf');
            
            String messageBody = '<html><body>Chère '+eachContact.FirstName+',<br/><br/> Au nom de toute l’équipe Human Appeal, je tiens à vous remercier chaleureusement pour votre générosité et votre soutien aux populations en difficulté. C’est grâce à votre confiance en nous que nous pouvons mener à bien nos projets sur le terrain.<br/><br/>'+
                +'J’ai le plaisir de vous adresser votre reçu fiscal à joindre à votre déclaration d’impôts.<br/><br/>'+
                +'Ensemble, nous pouvons œuvrer face à la pauvreté, aux injustices sociales, et venir en aide aux populations touchées à travers le monde.<br/><br/>'+
                +'Je vous prie d’agréer nos sincères salutations<br/><br/><b>Mohamad Yousef<br/>Président</b>'+
                +'<b>Human Appeal Customer Care</b><br/>Email: customercare@humanappeal.org.uk<br/>'+
                +'HUMAN APPEAL • Cheadle Point, Carrs Road, Cheadle, SK8 2BL, UK <br/>'+
                +'humanappeal.org.uk • info@humanappeal.org.uk • 0161 225 0225 <br/>'+
                +'Charity Reg No. 1154288 • Company Reg No. 8553893 • Scottish Reg No. SC056481 <br/>'+
                +'</body>  </html>';
            
            PageReference pref = page.FRDonationStatement; 
            pref.getParameters().put('Id', eachContact.Id);
            pref.getParameters().put('sDate',startDate.format());
            pref.getParameters().put('eDate',endDate.format()); 
            pref.setRedirect(true);
            
            
            Blob b = (Test.isRunningTest())?Blob.valueOf('This is the Test Class'):pref.getContent();
            attach.setBody(b);
            semail.setToAddresses(new String[] { eachContact.Id});
            semail.setSubject(subject);
            semail.setHtmlBody(messageBody); 
            semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            
            emails.add(sEmail);
        }
        
        Messaging.sendEmail(emails, true);
    }*/
    
    
    public void finish(Database.BatchableContext BC) {
    }
}