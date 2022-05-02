public class HA_Donation_Statement_Cmp_Ctrl {

	public List<npsp__Allocation__c> donationList {get;set;}
    public Date sDate                   {get;set;}
    public String donor_ID              {get;set;}
    public Boolean showLogo             {get;set;}
    public Date eDate                   {get;set;}
    public Decimal totalAmount {get;set {totalAmount = value;}}
    public String totalAmountFormatted{get;set;}
    public Decimal totalGiftAid {get;set{totalGiftAid = value;}}
    public Boolean emptyList{get;set{emptyList = value;}}
    public String street {get; set{street = value;}}
    public String totalAmountInWordsFrench {get;set;}
    
    private Double conversionIndex = 1;
    private Contact con;
    
    public String contactId {
        get;
        set{
            contactId = value;
            if (con == null && contactId != null) {
                con = [
                    SELECT Id, Regional_Office_Code__c, CurrencyIsoCode 
                    FROM Contact 
                    WHERE Id = :contactId
                ];
                
                if (con.Regional_Office_Code__c == 'FR') {
                    System.debug('setter:office code '+con.Regional_Office_Code__c );
                    CurrencyType eurCurencyType = [
                        SELECT Id, IsoCode, ConversionRate
                        FROM CurrencyType
                        WHERE isActive = true
                        AND ISOCode = 'EUR'
                    ];
                    
                    System.debug('setter:eurCurencyType '+eurCurencyType );
                    
                    if (eurCurencyType != null) {
                        conversionIndex = eurCurencyType.ConversionRate;
                        System.debug('setter:conversionIndex '+conversionIndex );
                    }
                }
            }
            
            fetchOpportunities(contactId);
            getTotalAmount(contactId);
            getTotalGiftAid(contactId);
            
        }
    }
    
    
    
    public HA_Donation_Statement_Cmp_Ctrl () { 
        showLogo = true;
        totalGiftAid =0.00;
          
        If(ApexPages.currentPage().getParameters().get('sDate') != null && ApexPages.currentPage().getParameters().get('eDate') != null){
            sDate = Date.valueOf(ApexPages.currentPage().getParameters().get('sDate'));//Date.parse(ApexPages.currentPage().getParameters().get('sDate'));
            eDate = Date.valueOf(ApexPages.currentPage().getParameters().get('eDate'));//Date.parse(ApexPages.currentPage().getParameters().get('eDate'));
        }
        
        if(ApexPages.currentPage().getParameters().get('Id') != null) {
        	contactId = ApexPages.currentPage().getParameters().get('Id');
            /*Contact con = [
                SELECT Id, Regional_Office_Code__c, CurrencyIsoCode 
                FROM Contact 
                WHERE Id = :contactId
            ];
            
            if (con.Regional_Office_Code__c == 'FR') {
                System.debug('CONSTRUCTOR:office code '+con.Regional_Office_Code__c );
                CurrencyType eurCurencyType = [
                    SELECT Id, IsoCode, ConversionRate
                    FROM CurrencyType
                    WHERE isActive = true
                    AND ISOCode = 'EUR'
                ];
                
                System.debug('CONSTRUCTOR:eurCurencyType '+eurCurencyType );
                
                if (eurCurencyType != null) {
                    conversionIndex = eurCurencyType.ConversionRate;
                    System.debug('CONSTRUCTOR:conversionIndex '+conversionIndex );
                }
            }*/
        }
    }
    
    
    public Map<String, Decimal> getBreakdown() {
        Map<String, Decimal> breakdown = new Map<String, Decimal>();        
        List<npsp__Allocation__c> prods = donationList;
        
        for(npsp__Allocation__c prod : prods)
        {
            
            if(breakdown.get(prod.Stipulation_Type__c) == null)
            {
                breakdown.put(prod.Stipulation_Type__c, 0.00);
            }
            
            Decimal amount = breakdown.get(prod.Stipulation_Type__c) + prod.npsp__Amount__c;
            breakdown.put(prod.Stipulation_Type__c, amount);

            
        }
        return breakdown;
    }
    
    
    public Integer getBreakdownSize() {
        Integer breakdownSize = getBreakdown().size();
        
        if(breakdownSize == null)
        {
            breakdownSize = 0;
        }
        
        return breakdownSize;
    }
    
    public void getTotalAmount(String contact_Id) {
        
        /*AggregateResult[] groupedResults = [SELECT SUM(npsp__Amount__c )sum FROM npsp__Allocation__c Where  npsp__Opportunity__r.Recurring_Setup__c =0 AND npsp__Opportunity__r.ContactId=:contact_Id AND npsp__Opportunity__r.IsWon = TRUE AND npsp__Opportunity__r.CloseDate>=:sDate AND  npsp__Opportunity__r.CloseDate<=:eDate];
        decimal totalAmountTemp = groupedResults[0].get('sum')==null?0:(decimal)groupedResults[0].get('sum');*/
        decimal totalAmountTemp = 0;
        for (npsp__Allocation__c eachAllocation : [
            SELECT Id, npsp__Amount__c, CurrencyIsoCode 
            FROM npsp__Allocation__c
            WHERE npsp__Opportunity__r.Recurring_Setup__c =0 
            AND npsp__Opportunity__r.ContactId=:contact_Id 
            AND npsp__Opportunity__r.IsWon = TRUE 
            AND npsp__Opportunity__r.CloseDate>=:sDate 
            AND  npsp__Opportunity__r.CloseDate<=:eDate
        ]) {
            
            totalAmountTemp += (eachAllocation.CurrencyIsoCode != 'EUR') ? 
                (eachAllocation.npsp__Amount__c * conversionIndex):
            	eachAllocation.npsp__Amount__c;
        }
        
        System.debug('totalAmountTemp'+totalAmountTemp);
        totalAmount = (totalAmountTemp).setScale(2);
        totalAmountFormatted = String.valueOf(totalAmount).replace('.', ',');
        System.debug('conversionIndex'+conversionIndex);
        
        if (conversionIndex != 1 || Test.isRunningTest()) {
            System.debug('getTotalAmount:inside the wording');
            totalAmountInWordsFrench = NumbersToFrench.convertCurrency(totalAmount);
            System.debug('getTotalAmount:totalAmountInWordsFrench'+totalAmountInWordsFrench);
        }
    }
    
    
    public void getTotalGiftAid(String contact_Id) {
        AggregateResult[] groupedResults = [SELECT SUM(Gift_Aid_Value__c)sum FROM Opportunity Where Recurring_Setup__c =0 AND ContactId=:contact_Id AND CloseDate>=:sDate AND CloseDate<=:eDate AND (Gift_Aid_Eligible_Status__c ='Yes' OR Gift_Aid_Declaration__r.Gift_Aid_Status__c='Yes')];
        if(groupedResults.size() > 0 && groupedResults[0].get('sum') != null){
        	totalGiftAid = (Decimal)(groupedResults[0].get('sum'));
        }else{
        	totalGiftAid = 0.00;
        }
    }
    
    public  void fetchOpportunities(String contact_Id) {
        donationList = new List<npsp__Allocation__c>();        
        donationList = [SELECT Id, npsp__Amount__c,npsp__Opportunity__c,npsp__Opportunity__r.npsp__Primary_Contact__r.Donor_ID__c, npsp__Opportunity__r.Gift_Aid_Eligible_Status__c,npsp__General_Accounting_Unit__c, Gift_Aid_Eligible_Allocation__c, Quantity__c, Stipulation_Type__c, npsp__Opportunity__r.Donation_Type__c,npsp__Opportunity__r.CloseDate, npsp__General_Accounting_Unit__r.Country__c, npsp__General_Accounting_Unit__r.Name, npsp__Opportunity__r.npsp__Primary_Contact__r.MailingStreet, npsp__Opportunity__r.npsp__Primary_Contact__r.MailingCity, npsp__Opportunity__r.npsp__Primary_Contact__r.MailingCountry, npsp__Opportunity__r.npsp__Primary_Contact__r.MailingPostalCode, npsp__Opportunity__r.npsp__Primary_Contact__r.Name,npsp__Opportunity__r.Payment_Method__c, npsp__Opportunity__r.Recurring_Payment_Method__c   FROM npsp__Allocation__c Where npsp__Opportunity__r.Recurring_Setup__c =0 AND npsp__Opportunity__r.ContactId=:contact_Id AND npsp__Opportunity__r.IsWon = TRUE AND npsp__Opportunity__r.CloseDate>=:sDate AND  npsp__Opportunity__r.CloseDate<=:eDate ORDER BY npsp__Opportunity__r.CloseDate];
        if(donationList.size()==0){
            emptyList = True;
        }else{
            emptyList= False;
        }       
    }
    
}