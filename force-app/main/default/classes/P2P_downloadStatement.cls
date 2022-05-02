public class P2P_downloadStatement {
    @AuraEnabled
    public static void downloadAsPDf(String startDate,String endDate){
        Id contactId = '0032500001XMV79AAH';//HA_Utility.getUserInfoContactId();
        PageReference page = new PageReference('/apex/P2P_DownloadStatementPdf?recordid=0032500001Yu0pAAAR&startdate=2021-01-01&enddate=2021-01-07');//new PageReference('/family/Apex/P2P_DownloadStatementPdf?recordId='+contactId+'&startDate='+startDate+'endDate='+endDate);
        page.getHeaders().put('content-disposition', 'attachment; filename=TestPDF.pdf');
        
        //return page;
    }
}