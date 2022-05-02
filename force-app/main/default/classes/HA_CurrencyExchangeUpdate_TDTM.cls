/**
 * @description       : update currency exchange rate
 * @author            : Kalpesh.Thakur@HumanAppeal.co.uk
 * @group             : 
 * @last modified on  : 02-08-2022
 * @last modified by  : Kalpesh.Thakur@HumanAppeal.co.uk
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   07-22-2021   Kalpesh.Thakur@HumanAppeal.co.uk   Initial Version
**/
global class HA_CurrencyExchangeUpdate_TDTM extends npsp.TDTM_Runnable {
    
    global override npsp.TDTM_Runnable.DmlWrapper run(List<SObject> newlist,
                                             List<SObject> oldlist,
                                             npsp.TDTM_Runnable.Action triggerAction,
                                             Schema.DescribeSObjectResult objResult) {

        npsp.TDTM_Runnable.dmlWrapper dmlWrapper = new npsp.TDTM_Runnable.DmlWrapper();
		Map<String,Decimal> mapCurrencyCon = new Map<String,Decimal>();
                                                 
        for (Currency_Conversion__c objCurr : [SELECT Id, Name, Currency__c, Conversion_Rate__c FROM Currency_Conversion__c Limit 100]) {
            
            mapCurrencyCon.put(objCurr.Currency__c,objCurr.Conversion_Rate__c);
        }
        
        Schema.SObjectField Idfield = objResult.fields.getMap().get('Id');         
        Schema.SObjectField Exchangefield = objResult.fields.getMap().get('Exchange_Rate_to_GBP__c');                                          
        sObject sObjOrg = objResult.sobjecttype.newSObject();                                       
        List<SObject> lstSObjectUpdate = new List<SObject>();
                                                 
        if (triggerAction == npsp.TDTM_Runnable.Action.AfterInsert) {
	    
           for (SObject obj : newlist) {
               System.debug('***:---'+String.valueOf(obj.get('Exchange_Currency__c')));
               if (String.valueOf(obj.get('Exchange_Currency__c')) != null) {
                   
                   sObject sObj = sObjOrg;
                   sObj.put(Idfield , String.valueOf(obj.get('Id')));
                   sObj.put(Exchangefield, mapCurrencyCon.get(String.valueOf(obj.get('Exchange_Currency__c'))));
                   lstSObjectUpdate.add(SObj);
               }

        	}

        }
        else if (triggerAction == npsp.TDTM_Runnable.Action.AfterUpdate){
            
            Map<Id,SObject> oldSObjectMap = new Map<Id,SObject>(oldlist);
            
            for (SObject obj : newlist) {
               
               if (String.valueOf(obj.get('Exchange_Currency__c')) != null && String.valueOf(obj.get('Exchange_Currency__c')) != String.valueOf(oldSObjectMap.get(String.valueOf(obj.get('Id'))).get('Exchange_Currency__c'))) {
                   sObject sObj = sObjOrg;
                   sObj.put(Idfield , String.valueOf(obj.get('Id')));
                   System.debug('***:-'+mapCurrencyCon.get(String.valueOf(obj.get('Exchange_Currency__c'))));
                   sObj.put(Exchangefield ,mapCurrencyCon.get(String.valueOf(obj.get('Exchange_Currency__c'))));
                   lstSObjectUpdate.add(SObj);
               }

        	}
        }  
                                                 
        if (!lstSObjectUpdate.isEmpty()) {
           
             dmlWrapper.objectsToUpdate.addAll(lstSObjectUpdate);
        }                                         
      
      return dmlWrapper;
    }

}