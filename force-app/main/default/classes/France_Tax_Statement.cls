public class France_Tax_Statement {
    private Contact contactRecord;
    private ApexPages.StandardController sctrl;
    public Date startDate                 {get;set;}
    public Date endDate                   {get;set;}
    public Boolean showEmailSent          {get; set;}
    public Boolean showLogo               {get; set;}
    public String contactId               {get;set;}
    public France_Tax_Statement(ApexPages.StandardController sstdController) {
        this.sctrl = sstdController;
        this.contactID = sstdController.getId();
        this.contactRecord = [select FirstName,LastName,MailingPostalCode,Id,Name,MailingStreet,MailingState,MailingCountry,Email,Donor_Id__c From Contact Where Id=:sstdController.getId()];
        this.showLogo = true;
        this.startDate = Date.newInstance(2021,1,1);
        this.endDate = Date.newInstance(2021,12,31);  
    }
    
   
        public pageReference show_SendEmail(){
          showEmailSent = false;
         return null;
        }
    public PageReference back()
    {
        PageReference cancel = sctrl.cancel();
        return cancel;
    }
    public pageReference sendEmail(){
        String subject = 'Tax Statement From '+startDate.format()+' To '+endDate.format();
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        PageReference pref = page.FRDonationStatement; 
        pref.getParameters().put('Id',(String)this.contactRecord.Id);
        pref.getParameters().put('sDate',startDate.format());
        pref.getParameters().put('eDate',endDate.format());
        pref.setRedirect(true);
        Blob b = (Test.isRunningTest())?Blob.valueOf('This is the Test Class'):pref.getContent();
        attach.setFileName(subject +'.pdf');
        attach.setBody(b);
        semail.setToAddresses(new String[] { this.contactRecord.Id});
        semail.setSubject(subject);   
        //semail.setTargetObjectId(this.contactId);
        //semail.setTemplateId(Label.Generate_Donation_Template_Id);
        
 	        String messageBody = '<html><body>Chère '+this.contactRecord.FirstName+',<br/><br/> Au nom de toute l’équipe Human Appeal, je tiens à vous remercier chaleureusement pour votre générosité et votre soutien aux populations en difficulté. C’est grâce à votre confiance en nous que nous pouvons mener à bien nos projets sur le terrain.<br/><br/>'+
            +'J’ai le plaisir de vous adresser votre reçu fiscal à joindre à votre déclaration d’impôts.<br/><br/>'+
            +'Ensemble, nous pouvons œuvrer face à la pauvreté, aux injustices sociales, et venir en aide aux populations touchées à travers le monde.<br/><br/>'+
            +'Je vous prie d’agréer nos sincères salutations<br/><br/><b>Mohamad Yousef<br/>Président</b>'+
            +'<b>Human Appeal Customer Care</b><br/>Email: customercare@humanappeal.org.uk<br/>'+
            +'HUMAN APPEAL • Cheadle Point, Carrs Road, Cheadle, SK8 2BL, UK <br/>'+
            +'humanappeal.org.uk • info@humanappeal.org.uk • 0161 225 0225 <br/>'+
            +'Charity Reg No. 1154288 • Company Reg No. 8553893 • Scottish Reg No. SC056481 <br/>'+
        +'</body>  </html>';
        semail.setHTMLBody(messageBody); 
        
        semail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}, true);
        showEmailSent = true;
        return null;
    }
     
    
    
    
    
}