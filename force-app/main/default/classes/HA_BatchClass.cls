/**
* @description       : 
* @author            : Iamsfdeveloper
* @group             : 
* @last modified on  : 08-03-2021
* @last modified by  : Iamsfdeveloper
* Modifications Log 
* Ver   Date         Author           Modification
* 1.0   05-02-2021   Iamsfdeveloper   Initial Version
* description 		  : Update ItemCode to All legacy donations
**/


public with sharing class HA_BatchClass implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    Public String query = 'Select Id,npsp__Opportunity__c,npsp__Opportunity__r.npsp__Primary_Contact__c, Donation_Item_Code__c  From Npsp__Allocation__c WHERE npsp__Opportunity__r.npsp__Primary_Contact__r.Contact_Type__c=\'Donor\' and npsp__Opportunity__c != null and Stage__c =\'Paid\' and (npsp__Opportunity__r.Donation_Type__c =\'SD\' OR npsp__Opportunity__r.Type=\'Payment Plan - Source\') ';
    public Integer recordsUpsert = 0;
    public String executeContext ='Pardot';
    public string guid = HA_Utility.generateGUID();
    public Date dueDate;
    public static String ORPHAN = 'Orphan';
    
    /************************
//CopyGAUAllocation
HA_BatchClass batch = new HA_BatchClass();
batch.query = 'Select Id,(Select Id,npsp__Opportunity__c,npsp__General_Accounting_Unit__c, npsp__Amount__c, Stipulation_Type__c, Receipt_Note__c, Country__c,Orphan__c From npsp__Allocations__r) From Opportunity Where LastModifiedBy.alias=\'kthak\'  and Transaction_Id__c != null AND Id In (Select npsp__Opportunity__c FROM npsp__Allocation__c ) and Basket_Collection_Id__c =null';
batch.executeContext = 'CopyGAUAllocation';
Database.executebatch(batch,1);
*************************/
    
    /************************
//InsertRecurringDonation
HA_BatchClass batch = new HA_BatchClass();
batch.query = 'Select Id,Name,Website_Code__c,Type,Basket_Collection_Id__c,Medium__c,Recurring_Type__c,Source__c,Donation_Type__c,CurrencyIsoCode,CloseDate,npsp__Primary_Contact__c,Amount,campaignId,AccountId,(Select Id,CurrencyISOCode,npsp__Opportunity__c,npsp__General_Accounting_Unit__c,npsp__Amount__c,Stipulation_Type__c,Country__c, Receipt_Note__c,Orphan__c  From npsp__Allocations__r)From Opportunity WHERE Donation_Type__c=\'RD\'and Regional_Office_Code__c=\'ES\' and Recurring_Setup__c = 1 and Contact_Record_Type__c = \'Organization\'  and Basket_Collection_Id__c = null and Id Not in (Select Opportunity__c From npe03__Recurring_donation__c Where Opportunity__c != null)';  
batch.executeContext = 'InsertRecurringDonation';
Database.executebatch(batch,5);
*************************/
    
    /************************
//Default block - Pardot
HA_BatchClass batch = new HA_BatchClass();
Database.executebatch(batch,1);

*************************/
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc,List<Sobject> scope){
        switch on executeContext{
            when 'InsertRecurringDonation'{
                
                List<Opportunity> paymentPlanList = (List<Opportunity>)scope;
                List<npe03__Recurring_Donation__c> rdlist = new List<npe03__Recurring_Donation__c>();
                Map<Id,npe03__Recurring_Donation__c> oppIdMap2RD = new Map<Id,npe03__Recurring_Donation__c>();
                Map<String,List<Npsp__Allocation__c>> guidMap2ListofAllocation = new Map<String,List<Npsp__Allocation__c>>();
                List<Npsp__Allocation__c> allocationToInsert = new List<Npsp__Allocation__c>();
                for(Opportunity opp:paymentPlanList){
                    List<Npsp__Allocation__c> tempallocationToInsert = new List<Npsp__Allocation__c>();
                   // String dataGUID = HA_Utility.generateGUID();
                    npe03__Recurring_Donation__c rd = new npe03__Recurring_Donation__c(Regional_Office_Code__c = opp.Website_Code__c,Name='RD',Donation_Type__c = opp.Donation_Type__c, 
                                                                                       Opportunity__c = opp.Id,npe03__Contact__c = opp.npsp__Primary_Contact__c,
                                                                                       npsp__StartDate__c = opp.closeDate,npsp__Day_of_Month__c = String.valueOf(opp.closeDate.Month()),
                                                                                       npsp__InstallmentFrequency__c = 1,npe03__Installment_Period__c = 'Monthly',
                                                                                       npe03__Recurring_Donation_Campaign__c = opp.campaignId,npe03__Amount__c = opp.Amount,
                                                                                       npe03__Organization__c = opp.AccountId,Medium__c = opp.Medium__c,Source__c = opp.Source__c,
                                                                                       npsp__LastElevateEventPlayed__c=guid,npsp__RecurringType__c = opp.Recurring_Type__c,
                                                                                       CurrencyIsoCode = opp.CurrencyIsoCode);
                    rd.npsp__Status__c = (opp.StageName =='Paid')?'Active':'Closed';
                    opp.Basket_Collection_Id__c = guid;
                    oppIdMap2RD.put(opp.Id,rd);
                    
                    
                    for(Integer i=0;i<opp.npsp__Allocations__r.size();i++){
                        tempallocationToInsert.add(new Npsp__Allocation__c(npsp__General_Accounting_Unit__c = opp.npsp__Allocations__r[i].npsp__General_Accounting_Unit__c,npsp__Amount__c = opp.npsp__Allocations__r[i].npsp__Amount__c,Stipulation_Type__c = opp.npsp__Allocations__r[i].Stipulation_Type__c,Receipt_Note__c = opp.npsp__Allocations__r[i].Receipt_Note__c,Orphan__c = opp.npsp__Allocations__r[i].Orphan__c,CurrencyISOCode =opp.npsp__Allocations__r[i].CurrencyISOCode));
                    }
                    if(tempallocationToInsert.size()>0)
                        guidMap2ListofAllocation.put(opp.Id,tempallocationToInsert);
                }
                System.debug(oppIdMap2RD.keyset());
                if(oppIdMap2RD.size()>0)
                    insert oppIdMap2RD.values();
                
                for(npe03__Recurring_Donation__c rd : oppIdMap2RD.values()){
                    for(Npsp__Allocation__c alloc:guidMap2ListofAllocation.get(rd.Opportunity__c)){
                        alloc.npsp__Recurring_Donation__c = rd.id;
                        allocationToInsert.add(alloc);
                    }
                    
                }
                if(allocationToInsert.size()>0)
                    insert allocationToInsert;
                
                recordsUpsert +=allocationToInsert.size();
                update paymentPlanList;
            }
            when 'CopyGAUAllocation'{
                
                Map<Id,Opportunity> sourceOppMap = new Map<Id,Opportunity>((List<Opportunity>)scope);
                List<Npsp__Allocation__c> allocationToInsert = new List<Npsp__Allocation__c>();
                Map<Id,Id> sourceOppMapToRDId  = new Map<Id,ID>();
                for(npe03__Recurring_Donation__c rd :[Select Id,Name,Opportunity__c FROM npe03__Recurring_Donation__c Where npsp__Status__c ='Closed' and Opportunity__c IN: sourceOppMap.keyset()]){
                    sourceOppMapToRDId.put(rd.Opportunity__c,rd.Id);
                }
                for(Opportunity opp : sourceOppMap.values()){
                    if(sourceOppMapToRDId.keySet().contains(opp.Id)){
                        for(Integer i=0;i<opp.npsp__Allocations__r.size();i++){
                            allocationToInsert.add(new Npsp__Allocation__c(npsp__Recurring_Donation__c = sourceOppMapToRDId.get(opp.Id),npsp__General_Accounting_Unit__c = opp.npsp__Allocations__r[i].npsp__General_Accounting_Unit__c,npsp__Amount__c = opp.npsp__Allocations__r[i].npsp__Amount__c,Stipulation_Type__c = opp.npsp__Allocations__r[i].Stipulation_Type__c,Receipt_Note__c = opp.npsp__Allocations__r[i].Receipt_Note__c,Orphan__c = opp.npsp__Allocations__r[i].Orphan__c));
                        }
                        opp.Basket_Collection_Id__c = guid;
                    }
                }
                if(allocationToInsert.size()>0)
                    insert allocationToInsert;
                if(sourceOppMap.values().size()>0)
                    update sourceOppMap.values();
                
                System.debug('sourceOppMap '+sourceOppMap);
                recordsUpsert +=allocationToInsert.size();
            }
            when 'CreateOrphanVisitRecord'{// added by @Nishtha to create new Orphan Visit Records on 17-11-21
                
                List<Contact> listContacts = (List<Contact>)scope;
                Datetime visitDate = Datetime.now();
                List<Orphan_Visit__c> listOrphanVisits = new List<Orphan_Visit__c>();
                for(Contact eachContact: listContacts){
                    if(eachContact.First_Sponsorship_Date__c!=null){
                        if(eachContact.First_Sponsorship_Date__c.month()>6){
                        	Integer month = Math.mod(eachContact.First_Sponsorship_Date__c.month()+6,12);
                        	dueDate = Date.newInstance(eachContact.First_Sponsorship_Date__c.year(),month,eachContact.First_Sponsorship_Date__c.day());

                    	}else{
                        	dueDate = Date.newInstance(eachContact.First_Sponsorship_Date__c.year(),eachContact.First_Sponsorship_Date__c.month()+6,eachContact.First_Sponsorship_Date__c.day());
                    	}
                    }else{
                        dueDate = Date.today();
                    }
                    
                    Orphan_Visit__c newOV = new Orphan_Visit__c();
                    newOV.Orphan__c = eachContact.Id;
                    newOV.Location_of_Visit__c = 'Home';
                    newOV.Purpose_of_Visit__c = 'General';
                    newOV.Visit_Date__c = visitDate;
                    newOV.Status__c = 'In Progress';
                    newOV.Due_Date__c = dueDate;
                    listOrphanVisits.add(newOV);
                }
                if(!listOrphanVisits.isEmpty()){
                    
                    insert listOrphanVisits;
                    recordsUpsert +=listOrphanVisits.size();
                }
			
            }
            /*when 'UpdateSponsorshipAnnualReportEmailSent'{
                List<Sponsorship__c> listSponsorships = (List<Sponsorship__c>)scope;
                List<String> listRecordIds = new List<String>();
                Integer year = Date.today().year();
                for(Sponsorship__c eachSponsorship: listSponsorships){
                    listRecordIds.add(eachSponsorship.Id);
                }
                List<EmailMessage> listEmailMessages = new List<EmailMessage>();
                listEmailMessages = [Select id,MessageDate from EmailMessage where RelatedToId IN:listRecordIds AND Message_Date_Year__c!=:year AND Subject = 'Annual Orphan Report'];
                
                
                
            }*/
            /*when 'CreateTaskForSingleDonation'{
                List<Task> listTasksToInsert = new List<Task>();
                for(npsp__Allocation__c eachAllocation: (List<npsp__Allocation__c>)scope){
                    Task newTask = new Task();
                    newTask.ActivityDate = Date.today() + 15;
                    newTask.Description = 'Special Request from '+eachAllocation.npsp__Opportunity__r.Donor_Name__c+' forItem'+eachAllocation.GAU_Name__c;
                    newTask.GAU_Allocation__c = eachAllocation.Id;
                    newTask.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Special_Instructions').getRecordTypeId();
                    newTask.Priority = 'Normal';
                    newTask.Status = 'Open';
                    newTask.Subject = eachAllocation.npsp__General_Accounting_Unit__r.Name+'-'+eachAllocation.npsp__General_Accounting_Unit__r.Donation_Item_Code__c;
                    newTask.TaskSubtype = 'Task';
                    newTask.WhatId = eachAllocation.npsp__Opportunity__c;
                    listTasksToInsert.add(newTask);
                }
                if(!listTasksToInsert.isEmpty()){
                    insert listTasksToInsert;
                }
            }*/
            when else{
                set<Id> contactIds = new set<Id>();
                for(Npsp__Allocation__c allo : (List<Npsp__Allocation__c>)scope){
                    contactIds.add(allo.npsp__Opportunity__r.npsp__Primary_Contact__c);
                }
                Map<Id,Contact> contactToUpdate = new Map<Id,Contact>([Select Id,Products_purchased__c FROM Contact Where Id IN: contactIds]);
                
                for(Npsp__Allocation__c allo : (List<Npsp__Allocation__c>)scope){
                    
                    if(contactToUpdate.get(allo.npsp__Opportunity__r.npsp__Primary_Contact__c) != null){
                        recordsUpsert++;
                        Contact temp =  contactToUpdate.get(allo.npsp__Opportunity__r.npsp__Primary_Contact__c);
                        if(temp.Products_purchased__c != null){  
                            if(!temp.Products_purchased__c.containsIgnoreCase(allo.Donation_Item_Code__c))
                                temp.Products_purchased__c +=';'+allo.Donation_Item_Code__c;
                        }else
                            temp.Products_purchased__c = allo.Donation_Item_Code__c;
                        
                        contactToUpdate.put(temp.Id,temp);
                        
                    }
                }
                if(contactToUpdate.size()>0){
                    recordsUpsert += contactToUpdate.keyset().size();
                    update contactToUpdate.values();
                }
            }
        }
        
        
        
    }
    public void finish(Database.BatchableContext bc){
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =
                          :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email,'iamsfdeveloper@gmail.com'};
            mail.setToAddresses(toAddresses);
        
        switch on executeContext{
            when 'InsertRecurringDonation'{
                 mail.setSubject('Insert Recurring Donation ' + a.Status);
                mail.setPlainTextBody
                    ('The batch Apex job processed ' + a.TotalJobItems +
                     '\n Failed batches with '+ a.NumberOfErrors+
                     '\n ItemAllocationInserted '+recordsUpsert+
                    '\n Data Identifier used for this DML Operation '+guid);
        
            }
            when 'CopyGAUAllocation'{
                mail.setSubject('GAU Copied to Recurring Donation ' + a.Status);
                mail.setPlainTextBody
                    ('The batch Apex job processed ' + a.TotalJobItems +
                     '\n Failed batches with '+ a.NumberOfErrors+'\n ItemAllocationInserted '+recordsUpsert);
        
            }
            when 'CreateOrphanVisitRecord'{
                mail.setSubject('Orphan Visit Created ' + a.Status);
                mail.setPlainTextBody
                    ('The batch Apex job processed ' + a.TotalJobItems +
                     '\n Failed batches with '+ a.NumberOfErrors+
                     '\n Total Visit Inserted '+recordsUpsert);
        
            }
            when else{
                mail.setSubject('Donors Update with Product Purchased ' + a.Status);
                mail.setPlainTextBody
                    ('The batch Apex job processed ' + a.TotalJobItems +
                     '\n Failed batches with '+ a.NumberOfErrors+'\n recordsUpsert '+recordsUpsert+
                     ' \n Data Identifier used for this DML Operation '+guid); 
            }
        }
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        } catch(System.EmailException ex){
            
        }
    }
    
    
}