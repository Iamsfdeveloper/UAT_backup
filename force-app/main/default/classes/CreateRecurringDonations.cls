/**
* @description       : 
* @author            : Iamsfdeveloper
* @group             : 
* @last modified on  : 12-24-2021
* @last modified by  : Iamsfdeveloper
**/
public Inherited sharing class CreateRecurringDonations {
    //@Future
    public static void CreateRD(Set<Id> oppIds){
        string DONATION_TYPE = 'Donation';
        string OPP_NAME = 'System Generated';
        string OPP_STAGE = 'Pledged';
        List<npe03__Recurring_Donation__c> recurringDonationList = new List<npe03__Recurring_Donation__c>();
        List<Opportunity> firstOpportunity = new List<Opportunity>();
        List<npsp__Allocation__c> allocationsToInset= new List<npsp__Allocation__c>(); 
        Map<Id,String> OppIdMapToGuid = new Map<Id,String>();
        Map<Id,Income_Direct_Debit__c> oppIdDirectDebitMap = new Map<Id,Income_Direct_Debit__c>();
        Map<Id,npe01__OppPayment__c> oppIdCardPaymentMap = new Map<Id,npe01__OppPayment__c>();
        Map<Id,npe03__Recurring_Donation__c> oppIdMap2Rd = new Map<Id,npe03__Recurring_Donation__c>();
        List<npsp__Allocation__c> allocToInsert = new List<npsp__Allocation__c>();
        String guid = HA_Utility.generateGUID();
        //Source Opportunity Direct Debits only
        
        List<Income_Direct_Debit__c> DirectDebitList = [SELECT Id,Opportunity__r.Basket__c,Opportunity__r.npsp__Primary_Contact__c,Opportunity__r.Transaction_Id__c,DD_Next_Collection_Date__c,DD_First_Collection_Date__c,DD_Collection_Day__c,DD_Collection_Period__c,DD_Collection_Stretch__c,DD_Start_Date__c,Opportunity__c,Opportunity__r.Name,Opportunity__r.Donation_Type__c,Opportunity__r.EMIAmount__c,Opportunity__r.Amount,Opportunity__r.Regional_office_code__c,Opportunity__r.CurrencyIsoCode,Opportunity__r.Medium__c,Opportunity__r.Source__c,Opportunity__r.campaignId,Opportunity__r.Donation_Frequency__c,Opportunity__r.AccountId,Opportunity__r.ContactId,Opportunity__r.Number_of_Installments__c,Opportunity__r.Recurring_Type__c FROM Income_Direct_Debit__c Where  Opportunity__c  IN: oppIds and Recurring_Donation__c =null and DD_First_Collection_Date__c != null];
        if(DirectDebitList.size()>0){
            for(Income_Direct_Debit__c dd:DirectDebitList){
                oppIdDirectDebitMap.put(dd.Opportunity__c,dd);
                OppIdMapToGuid.put(dd.Opportunity__c,dd.Opportunity__r.Transaction_Id__c);
                
            }
            if(oppIdDirectDebitMap.size()>0){
                for(Income_Direct_Debit__c  dd:oppIdDirectDebitMap.values()){
                    recurringDonationList.add(new npe03__Recurring_Donation__c(External_Id__c =OppIdMapToGuid.get(dd.Opportunity__c), Name =dd.Opportunity__r.Name,
                                                                               npsp__StartDate__c = date.newinstance(dd.DD_First_Collection_Date__c.year(), dd.DD_First_Collection_Date__c.month(), 1) ,
                                                                               npsp__Status__c ='Active',
                                                                               Basket__c = dd.Opportunity__r.Basket__c,
                                                                               Opportunity__c = dd.Opportunity__c, 
                                                                               Direct_Debit_Detail__c = dd.Id,
                                                                               npe03__Amount__c = (dd.Opportunity__r.Donation_Type__c =='EMI')?dd.Opportunity__r.EMIAmount__c: dd.Opportunity__r.Amount,
                                                                               npe03__Contact__c=dd.Opportunity__r.npsp__Primary_Contact__c,
                                                                               Regional_Office_code__c = dd.Opportunity__r.Regional_Office_code__c,
                                                                               CurrencyIsoCode=dd.Opportunity__r.CurrencyIsoCode,
                                                                               Source__c=dd.Opportunity__r.Source__c,
                                                                               Medium__c=dd.Opportunity__r.Medium__c,
                                                                               Donation_type__c = dd.Opportunity__r.Donation_Type__c,
                                                                               npe03__Organization__c = (dd.Opportunity__r.npsp__Primary_Contact__c == null)?dd.Opportunity__r.AccountId:null,
                                                                               npe03__Installments__c = dd.Opportunity__r.Number_of_Installments__c,
                                                                               npsp__RecurringType__c = dd.Opportunity__r.Recurring_Type__c,
                                                                               npsp__Day_of_Month__c = '1',
                                                                               npsp__PaymentMethod__c = 'Direct Debit',
                                                                               npe03__Recurring_Donation_Campaign__c = dd.Opportunity__r.CampaignId,
                                                                               npe03__Installment_Period__c = dd.Opportunity__r.Donation_Frequency__c));
                    
                }
            }
        }
        else{
            
            List<npe01__OppPayment__c> setupPaymentList = [SELECT Id,npe01__Opportunity__r.Guid__c,npe01__Opportunity__r.npsp__Primary_Contact__c,npe01__Opportunity__r.Effective_Date__c, npe01__Opportunity__r.Basket__c,npe01__Opportunity__c,Card_details__r.Payment_Method_Type__c,Card_details__r.First_Payment_Taken__c,npe01__Opportunity__r.Gift_Aid_Eligible_Status__c,Card_details__c,npe01__Opportunity__r.closeDate,npe01__Opportunity__r.Name,npe01__Opportunity__r.Transaction_Id__c ,npe01__Opportunity__r.Donation_Type__c,npe01__Opportunity__r.EMIAmount__c,npe01__Opportunity__r.Amount,npe01__Opportunity__r.Regional_office_code__c,npe01__Opportunity__r.CurrencyIsoCode,npe01__Opportunity__r.Medium__c,npe01__Opportunity__r.Source__c,npe01__Opportunity__r.campaignId,npe01__Opportunity__r.Donation_Frequency__c,npe01__Opportunity__r.AccountId,npe01__Opportunity__r.ContactId,npe01__Opportunity__r.Number_of_Installments__c,npe01__Opportunity__r.Recurring_Type__c From npe01__OppPayment__c Where npe01__Opportunity__c IN :oppIds and Transaction_Type__c='Setup' AND Payment_Status__c='succeeded'];
            if(setupPaymentList.size()>0){
                for(npe01__OppPayment__c payment:setupPaymentList){
                    oppIdCardPaymentMap.put(payment.npe01__Opportunity__c,payment);
                    string extId= (payment.npe01__Opportunity__r.Transaction_Id__c !=null)?payment.npe01__Opportunity__r.Transaction_Id__c:payment.npe01__Opportunity__r.Guid__c;
                    OppIdMapToGuid.put(payment.npe01__Opportunity__c,extId);
                    
                }
                if(oppIdCardPaymentMap.size()>0){
                    for(npe01__OppPayment__c cp:oppIdCardPaymentMap.values()){
                        npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c( External_Id__c =OppIdMapToGuid.get(cp.npe01__Opportunity__c),Name =cp.npe01__Opportunity__r.Name,
                                                                                           npsp__StartDate__c = (cp.Card_details__r.First_Payment_Taken__c)?cp.npe01__Opportunity__r.closeDate:cp.npe01__Opportunity__r.Effective_Date__c,
                                                                                           npsp__Status__c ='Active',
                                                                                           Opportunity__c = cp.npe01__Opportunity__c,
                                                                                           Basket__c = cp.npe01__Opportunity__r.Basket__c,
                                                                                           Card_Payment_Detail__c = cp.Card_details__c,
                                                                                           npe03__Amount__c = (cp.npe01__Opportunity__r.Donation_Type__c =='EMI')?cp.npe01__Opportunity__r.EMIAmount__c: cp.npe01__Opportunity__r.Amount,
                                                                                           npe03__Contact__c=cp.npe01__Opportunity__r.npsp__Primary_Contact__c,
                                                                                           Regional_Office_code__c = cp.npe01__Opportunity__r.Regional_Office_code__c,
                                                                                           CurrencyIsoCode=cp.npe01__Opportunity__r.CurrencyIsoCode,
                                                                                           Source__c=cp.npe01__Opportunity__r.Source__c,
                                                                                           Medium__c=cp.npe01__Opportunity__r.Medium__c,
                                                                                           Donation_type__c = cp.npe01__Opportunity__r.Donation_Type__c,
                                                                                           npe03__Organization__c = (cp.npe01__Opportunity__r.npsp__Primary_Contact__c ==null)?cp.npe01__Opportunity__r.AccountId:null,
                                                                                           npe03__Installments__c = cp.npe01__Opportunity__r.Number_of_Installments__c,
                                                                                           npsp__RecurringType__c = cp.npe01__Opportunity__r.Recurring_Type__c,
                                                                                           npsp__Day_of_Month__c = (cp.Card_details__r.First_Payment_Taken__c)?String.valueOf(cp.npe01__Opportunity__r.closeDate.day()):String.valueOf((cp.npe01__Opportunity__r.Effective_Date__c.day())),
                                                                                           npsp__PaymentMethod__c = (cp.Card_details__r.Payment_Method_Type__c != null && cp.Card_details__r.Payment_Method_Type__c =='sepa_debit')?'SEPA':'Card Payment',
                                                                                           npe03__Recurring_Donation_Campaign__c = cp.npe01__Opportunity__r.CampaignId,
                                                                                           npe03__Installment_Period__c = cp.npe01__Opportunity__r.Donation_Frequency__c);
                        
                        if(cp.Card_details__c != null && cp.Card_details__r.First_Payment_Taken__c){
                            rd.npsp__DisableFirstInstallment__c  = true;
                            firstOpportunity.add(new Opportunity(Guid__c = guid,npsp__Primary_Contact__c = rd.npe03__Contact__c,
                                                                 AccountId = rd.npe03__Organization__c,Amount = rd.npe03__Amount__c,
                                                                 CampaignId = cp.npe01__Opportunity__r.CampaignId,
                                                                 Type=DONATION_TYPE,CloseDate = cp.npe01__Opportunity__r.closeDate,
                                                                 Name =OPP_NAME, Gift_Aid_Eligible_Status__c = cp.npe01__Opportunity__r.Gift_Aid_Eligible_Status__c,
                                                                 Medium__c =cp.npe01__Opportunity__r.Medium__c,StageName = OPP_STAGE,CurrencyIsoCode = rd.currencyIsoCode,
                                                                 Donation_Type__c=rd.Donation_Type__c,website_code__c = rd.Regional_Office_Code__c,
                                                                 Regional_Office_Code__c=rd.Regional_Office_Code__c,
                                                                 npe03__Recurring_Donation__r= new npe03__Recurring_Donation__c( External_Id__c = OppIdMapToGuid.get(cp.npe01__Opportunity__c))));
                        }
                        recurringDonationList.add(rd);
                    }
                }
            }
        }
        if(recurringDonationList.size()>0){
            insert recurringDonationList;
            for(npe03__Recurring_Donation__c rd:recurringDonationList){
                if(limits.getQueries()<100){
                    Decimal TotalPercentage = 100.000000;
                    Decimal allocatedPercentage = 0;
                    
                    for(npsp__Allocation__c alloc : [select Name__c,currencyIsoCode,npsp__General_Accounting_Unit__c,Orphan__c,Stipulation_Type__c,npsp__Amount__c,npsp__Percent__c,npsp__Opportunity__c,npsp__Opportunity__r.EMIAmount__c,npsp__Opportunity__r.Donation_Type__c,npsp__Opportunity__r.Amount From npsp__Allocation__c Where npsp__Opportunity__c =:rd.Opportunity__c]){
                        
                        npsp__Allocation__c tempAlloc = new npsp__Allocation__c(currencyIsoCode = alloc.currencyIsoCode,Name__c = alloc.Name__c,Orphan__c=alloc.Orphan__c,npsp__Recurring_Donation__c = rd.Id,npsp__General_Accounting_Unit__c = alloc.npsp__General_Accounting_Unit__c, Stipulation_Type__c=alloc.Stipulation_Type__c);
                        
                        Decimal ItemPercentage  = ((alloc.npsp__Amount__c/alloc.npsp__Opportunity__r.Amount)*100).setScale(6); //(alloc.npsp__Opportunity__r.Donation_Type__c =='EMI')?((alloc.npsp__Amount__c/alloc.npsp__Opportunity__r.EMIAmount__c)*100).setScale(6):((alloc.npsp__Amount__c/alloc.npsp__Opportunity__r.Amount)*100).setScale(6);
                        if(ItemPercentage != null){
                            if((allocatedPercentage+ItemPercentage)>TotalPercentage)
                                ItemPercentage = (TotalPercentage - (allocatedPercentage)).setScale(6);	
                            else
                                allocatedPercentage +=ItemPercentage;
                        }
                       tempAlloc.npsp__Percent__c = ItemPercentage;
                        tempAlloc.npsp__Amount__c = null;
                        allocToInsert.add(tempAlloc);
                        if(firstOpportunity.size()>0){
                            npsp__Allocation__c oppAlloc = tempAlloc.clone();
                            oppAlloc.npsp__opportunity__r = new Opportunity( Guid__c = guid);
                            oppAlloc.npsp__Recurring_Donation__c = null;
                            oppAlloc.npsp__Percent__c = null;
                            oppAlloc.npsp__Amount__c = (rd.npe03__Amount__c * alloc.npsp__Percent__c *0.01).setScale(2);
                            allocToInsert.add(oppAlloc);
                            
                        }
                    }
                    
                }
            }
            if(allocToInsert.size()>0){
                List<sObject> sObjectList= new List<sObject>();
                if(firstOpportunity.size()>0)
                    sObjectList.addAll(firstOpportunity);
                sObjectList.addAll(allocToInsert);
                Database.SaveResult[] srlist =  Database.Insert(sObjectList,false);
                List<Recurring_Donation_Batch_Errors__c> errorList = new List<Recurring_Donation_Batch_Errors__c>();
                Integer index =0;
                for(Database.SaveResult sr:srlist){
                    String errMessage = 'CreateRecurringDonations.createRD=>';
                    if(!sr.isSuccess()){
                        for(Database.Error err:sr.getErrors()){
                            errMessage += err.getMessage()+'Status Code'+err.getStatusCode();
                        }
                        
                        errorList.add(HA_Logger.CreateErrorLog(JSON.serialize(sObjectList[index]),JSON.serialize(oppIds), errMessage));
                    }
                    index++;
                }
                if(errorList.size()>0)
                    insert errorList;
            }
            
        }
        
    }
}