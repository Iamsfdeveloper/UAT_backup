trigger GiftAidDeclarationTrigger on Gift_Aid_Declaration__c (After Insert) {
    
    If(Trigger.isAfter && Trigger.isInsert){
       Map<Id,Gift_Aid_Declaration__c> donorIdMap2EffectiveDate = new Map<Id,Gift_Aid_Declaration__c>();
        for(Gift_Aid_Declaration__c gad : Trigger.new){
            if(gad.Gift_Aid_Status__c =='Yes'){
                   donorIdMap2EffectiveDate.put(gad.Donor__c,gad);
            }    
        }
         System.debug('donorIdMap2EffectiveDate===> '+donorIdMap2EffectiveDate);
        if(donorIdMap2EffectiveDate.size()>0){
           
            List<Opportunity> DoonaitonsToUdpate = new List<Opportunity>();
            for(Opportunity opp:[Select Id, CloseDate,Gift_Aid_declaration__c,npsp__primary_contact__c From Opportunity Where Gift_Aid_declaration__c = null AND npsp__primary_contact__c IN: donorIdMap2EffectiveDate.keyset() AND Iswon=true AND Recurring_Setup__c = 0]){
                if(opp.CloseDate >= donorIdMap2EffectiveDate.get(opp.npsp__primary_contact__c).Gift_Aid_Start_Date__c){
                    opp.Gift_Aid_declaration__c = donorIdMap2EffectiveDate.get(opp.npsp__primary_contact__c).Id;DoonaitonsToUdpate.add(opp);
                
                }
            
            }
        if(DoonaitonsToUdpate.size()>0)update DoonaitonsToUdpate;
        }
    }
}