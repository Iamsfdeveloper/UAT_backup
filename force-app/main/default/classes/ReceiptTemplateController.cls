public without sharing class ReceiptTemplateController {
    public Id oppId {get; set;} 
    public String lang{get;set;}

    public List<ProdWrap>  getlstProdWrap() {
        
        List<ProdWrap> lstProdWrap = new List<ProdWrap>();
        Set<Id> setItemIds = new Set<Id>(); 
		
        for (npsp__Allocation__c objAllocation : [SELECT Id, npsp__Amount__c, CurrencyIsoCode, Stipulation_Type__c, npsp__General_Accounting_Unit__r.Name, npsp__General_Accounting_Unit__r.Country__c, npsp__General_Accounting_Unit__r.Stipulation__c,
                                                        npsp__General_Accounting_Unit__r.npsp__Description__c, npsp__General_Accounting_Unit__r.Valid_From__c,npsp__General_Accounting_Unit__r.Expiry_Date__c,Receipt_Note__c,
                                                        npsp__General_Accounting_Unit__r.Id, Item_Product_Type__c
                                                    FROM npsp__Allocation__c 
                                                    WHERE npsp__Opportunity__c = : oppId AND npsp__Opportunity__c != null]) {
            
                lstProdWrap.add(new ProdWrap(objAllocation.npsp__General_Accounting_Unit__r.Name,
                                            objAllocation.Stipulation_Type__c,
                                            objAllocation.npsp__General_Accounting_Unit__r.Country__c,
                                            objAllocation.npsp__Amount__c,
                                            objAllocation.CurrencyIsoCode,
                                            objAllocation.npsp__General_Accounting_Unit__r.Id));   
                                
                                            setItemIds.add(objAllocation.npsp__General_Accounting_Unit__r.Id);                
        }

        Map<Id,Translation__c> mapItemIdTranslations = new Map<Id,Translation__c>();
        
        for (Translation__c objTrans : [SELECT Id,Language__c,Item__c,Translated_Text__c FROM Translation__c
                                        WHERE Item__c=:setItemIds and Language__c=:lang]) {
            
            mapItemIdTranslations.put(objTrans.Item__c,objTrans);                                
        }



        for (ProdWrap objProdWrap : lstProdWrap) {

            if (mapItemIdTranslations.containsKey(objProdWrap.gauId)) {

                objProdWrap.name = mapItemIdTranslations.get(objProdWrap.gauId).Translated_Text__c;
            }

        } 
        return lstProdWrap;
    }

    public List<npsp__Allocation__c> getProducts()
    {        
        return [SELECT Id, npsp__Amount__c, CurrencyIsoCode, Stipulation_Type__c, npsp__General_Accounting_Unit__r.Name, npsp__General_Accounting_Unit__r.Country__c, npsp__General_Accounting_Unit__r.Stipulation__c,
                    npsp__General_Accounting_Unit__r.npsp__Description__c, npsp__General_Accounting_Unit__r.Valid_From__c,npsp__General_Accounting_Unit__r.Expiry_Date__c,Receipt_Note__c,Item_Product_Type__c
                FROM npsp__Allocation__c 
                WHERE npsp__Opportunity__c = : oppId AND npsp__Opportunity__c != null];
    }
    public List<npsp__Allocation__c> getParentAllocations()
    {        
        try{return [SELECT Id, npsp__Amount__c, CurrencyIsoCode, Stipulation_Type__c, npsp__General_Accounting_Unit__r.Name, npsp__General_Accounting_Unit__r.Country__c, npsp__General_Accounting_Unit__r.Stipulation__c,
               npsp__General_Accounting_Unit__r.npsp__Description__c, npsp__General_Accounting_Unit__r.Valid_From__c,npsp__General_Accounting_Unit__r.Expiry_Date__c,Receipt_Note__c, Item_Product_Type__c FROM npsp__Allocation__c WHERE npsp__Recurring_Donation__r.Opportunity__c = : oppId AND npsp__Recurring_Donation__c != null];
        }Catch(Exception ex){return new List<npsp__Allocation__c>();}
    }
    public Map<String, Decimal> getBreakdown()
    {
        Map<String, Decimal> breakdown = new Map<String, Decimal>();        
        List<npsp__Allocation__c> prods = getProducts();

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

    public Integer getBreakdownSize()
    {
        Integer breakdownSize = getBreakdown().size();
        
        if(breakdownSize == null)
        {
            breakdownSize = 0;
        }

        return breakdownSize;
    }


    public class ProdWrap {

        public String name{get; set;}
        public String stipulationType{get; set;}
        public String country{get; set;}
        public Decimal amount{get; set;}
        public String currencyCode{get; set;}
        public Id gauId {get; set;}

        public ProdWrap(String strName,String strStipulationType,String strCountry,Decimal decAmount,String strCurrencyCode,Id gau_Id) {

            this.name = strName;
            this.stipulationType = strStipulationType;
            this.country = strCountry;
            this.amount = decAmount;
            this.currencyCode = strCurrencyCode;
            this.gauId = gau_Id;
        }
    }
}