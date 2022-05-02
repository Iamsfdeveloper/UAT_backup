public class Audit_2020_csv {
    
    Map<Id,List<Income_Card_Payment_History__c>> OppMap2CardHistory = new Map<Id,List<Income_Card_Payment_History__c>>();
    Decimal TotalItemAmount = 0.00;
    Decimal CardAmount = 0.00;
    Integer b = 0;
    Integer c = 0;
    String csvData = 'Donation_Id,transactionDate,Item Name,Country,Stipulation,Program category,Donation name,Donation Amount,Item Amount,Total_Card_Amount,Individual_Card_Amount,CurrencyIsoCode,Gift Aid Declaration,Gift Aid Value,Stripe CH number,Donor Name,Donor ID';
    
    public Audit_2020_csv(){    
        for(Income_Card_Payment_History__c temp : [SELECT Amount__c,Id,Income_Card_Payment__c,Income_Card_Payment__r.Opportunity__c,Income_Card_Payment__r.Opportunity__r.Amount,Income_Card_Payment__r.Opportunity__r.Gift_Aid_Eligible_Status__c,Income_Card_Payment__r.Opportunity__r.Gift_Aid_Value__c,Income_Card_Payment__r.Opportunity__r.CurrencyIsoCode,Order_ID__c,Transaction_Date__c,Income_Card_Payment__r.Total_Amount_Taken__c,Income_Card_Payment__r.Opportunity__r.Name,CurrencyIsoCode,Income_Card_Payment__r.Opportunity__r.Donor_Name__c,Income_Card_Payment__r.Opportunity__r.Donor_ID__c FROM Income_Card_Payment_History__c Where  Amount__c>0 and Payment_Status__c !='Failed' and CreatedDate >= 2020-05-23T00:00:00z and CreatedDate <= 2020-05-30T23:59:59z]){
            CardAmount += temp.Amount__c;
            b++;
            List<Income_Card_Payment_History__c> tempList = (OppMap2CardHistory.keyset().contains(temp.Income_Card_Payment__r.Opportunity__c))?OppMap2CardHistory.get(temp.Income_Card_Payment__r.Opportunity__c): new List<Income_Card_Payment_History__c>();
            tempList.add(temp);   
            OppMap2CardHistory.put(temp.Income_Card_Payment__r.Opportunity__c,tempList);
        }
       
        
        
        for(npsp__Allocation__c alloc:[SELECT GAU_Name__c,npsp__Amount__c,npsp__Opportunity__r.Amount,npsp__Opportunity__r.Name,Country__c,npsp__Opportunity__c,npsp__General_Accounting_Unit__r.Stipulation__c ,npsp__Opportunity__r.CloseDate,npsp__Opportunity__r.Donation_Type__c,npsp__Opportunity__r.Gift_Aid_Value__c,npsp__Opportunity__r.CurrencyIsoCode,CurrencyIsoCode,npsp__Opportunity__r.Gift_Aid_Eligible_Status__c,npsp__General_Accounting_Unit__r.Programme_Category__c FROM npsp__Allocation__c Where npsp__Opportunity__c IN:OppMap2CardHistory.keyset() and npsp__Opportunity__c !=null ]){
            // Percentage of Item Amount with Donation Amount
            c++;           
            if(alloc.npsp__Amount__c != null){
                TotalItemAmount +=alloc.npsp__Amount__c;
                for(Income_Card_Payment_History__c tempCard:OppMap2CardHistory.get(alloc.npsp__Opportunity__c)){
                    //TotalCardAmount = Percentage Item Amount
                    csvData +='\n'+alloc.npsp__Opportunity__c+','+tempCard.Transaction_Date__c+','+alloc.GAU_Name__c+','+alloc.Country__c+','+alloc.npsp__General_Accounting_Unit__r.Stipulation__c+','+ alloc.npsp__General_Accounting_Unit__r.Programme_Category__c +','+tempCard.Income_Card_Payment__r.Opportunity__r.Name +','+alloc.npsp__Opportunity__r.Amount +','+alloc.npsp__Amount__c+','+tempCard.Income_Card_Payment__r.Total_Amount_Taken__c+','+ tempCard.Amount__c +','+alloc.CurrencyIsoCode+','+alloc.npsp__Opportunity__r.Gift_Aid_Eligible_Status__c+','+alloc.npsp__Opportunity__r.Gift_Aid_Value__c+','+tempCard.Order_ID__c+','+tempCard.Income_Card_Payment__r.Opportunity__r.Donor_Name__c+','+tempCard.Income_Card_Payment__r.Opportunity__r.Donor_ID__c;
        		}  
            }
            
        }
	
        System.debug(System.LoggingLevel.ERROR, 'times first query is run'+b);
        System.debug(System.LoggingLevel.ERROR, 'times second query is run'+c);
        System.debug(System.LoggingLevel.ERROR, 'Total OppMap2CardHistory Map Size ==>'+OppMap2CardHistory.size());
        System.debug(System.LoggingLevel.ERROR, 'testDuring');
        
        
        //System.debug('TotalItemAmount ==>'+TotalItemAmount);
        
        //System.debug('CardAmount ==>'+CardAmount);
        
        //Todo attach csvData to Attachment
        
        // Todo Verify Data (TotalItemAmount) and CardAmount => Compare Total History Amount with CSV item Amount
        Attachment att = new Attachment(Name='Audit_23_05_20__30_05_20_Data-'+System.now().format()+'.csv',Body=Blob.valueOf(csvData),parentId='0014J00000ZpT1FQAV');
        insert att;
		
    }
	@Future
    Public Static void MakeFutureCall(){
        Audit_2020_csv temp = new Audit_2020_csv();
        System.debug(System.LoggingLevel.ERROR, 'testAfter');
    }

}