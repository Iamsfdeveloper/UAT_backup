public without sharing class CheckoutRouterController 
{
    public PageReference redirect()
    {
        System.debug('#### CheckoutRouterController.Redirect');

        String websiteCode = '';

        String result = ApexPages.currentpage().getparameters().get('res');
        Id resId = ApexPages.currentpage().getparameters().get('id');

        System.debug('#### result: ' + result);
        System.debug('#### resId: ' + resId);        
                
        try 
        {
            Schema.sObjectType entityType = resId.getSObjectType();  

            if(entityType == Income_Card_Payment__c.sObjectType)
            {
                Income_Card_Payment__c cardPayment = [SELECT Id, Opportunity__c, Opportunity__r.Website_Code__c FROM Income_Card_Payment__c WHERE Id =:resId];
                websiteCode = cardPayment.Opportunity__r.Website_Code__c;
            }
            else if(entityType == Income_Direct_Debit__c.sObjectType)
            {
                Income_Direct_Debit__c directDebit = [SELECT Id, Opportunity__c, Opportunity__r.Website_Code__c FROM Income_Direct_Debit__c WHERE Id =:resId];
                websiteCode = directDebit.Opportunity__r.Website_Code__c;
            }            
        } 
        catch (Exception e) {
            
        }        

        if(String.isBlank(websiteCode))
        {
            websiteCode = 'UK';
        }

        System.debug('#### websiteCode: ' + websiteCode);

        Payment_Country_Setting__mdt setting = [SELECT Success_Url__c, Failed_Url__c, Cancel_Url__c FROM Payment_Country_Setting__mdt WHERE DeveloperName = :websiteCode];
        System.debug('#### setting: ' + setting);

        if(result == 's')
        {
            return new Pagereference(setting.Success_Url__c);
        }
        else if(result == 'f')
        {
            return new Pagereference(setting.Failed_Url__c);
        }
        else if(result == 'c')
        {
            return new Pagereference(setting.Cancel_Url__c);
        }
        else
        {
            return new Pagereference(setting.Failed_Url__c);
        }
    }
}