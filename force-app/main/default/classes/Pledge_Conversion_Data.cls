public class Pledge_Conversion_Data {
    /*Class to transfer Campaigns to Pledges
     * 1) Read in list of campaigns 													[X]
     * 2) Change record type to Pledge from Departmental								[X]
     * 3) Add item allocation based on the Pledge project 								[X]
     * 4) Update description with each donation name and gau's 							[X]
     * 5) change the gau's in each influenced donation to the pledge gau set in step 3) [X]
     */
    public Blob csvFileBody{get;set;}
    public String csvAsString{get;set;}
    public String infDescription{get;set;}
    public String[] csvFileLines{get;set;}
    public String newPledgeGau{get;set;}
    public List<Campaign> campaignlist{get;set;}
    public List<Campaign> fetchCampaigns{get;set;}
    public List<npsp__Allocation__c> gauList{get;set;}
    public List<npsp__Allocation__c> fetchGaus{get;set;}
    
    public Recordtype pledgeRt{get;set;}
    
    
    public Pledge_Conversion_Data(){
        csvFileLines = new String[]{};
         //store campaign before converting record type
        campaignList= New List<Campaign>();
        gauList = New List<npsp__Allocation__c>();
        fetchCampaigns = New List<Campaign>();
        fetchGaus = New List<npsp__Allocation__c>();
        infDescription = '';
        //store objects after converting record type
        pledgeRt = [SELECT ID, Name from RecordType where name = 'Pledge' and SObjectType = 'Campaign'];
    }
    
    public void importCSVFile(){
        try{
            // Read CSV file body and store it in variable
            csvAsString = csvFileBody.toString();
            
            // Split CSV String to lines
            csvFileLines = csvAsString.split('\n');
            
            // Iterate CSV file lines and retrieve one column at a time.
            for(Integer i=1; i < csvFileLines.size(); i++){               
                Campaign camObj = new Campaign();
                npsp__Allocation__c gau = new npsp__Allocation__c();
                String[] csvRecordData = csvFileLines[i].split(',');
                //this is for MG sheet. JG sheet has columns 0 and 5 
                String camName = csvRecordData[9];
                String camItem = csvRecordData[10];
                //camObj.Description = csvRecordData[10];
                fetchCampaigns = [Select id,name,Description,RecordTypeId from Campaign where name = :camName];
                if(fetchCampaigns.size() > 0){
                    camObj = fetchCampaigns[0];
                	//change Campaign record type
                    if(camObj.RecordTypeId != pledgeRt.ID){
                        camObj.RecordTypeId = pledgeRt.ID;
                        update camObj;
                    }
                    //save campaign description to a variable to add to later
                    if(camObj.Description != null){
                      infDescription += camObj.Description;
                    }
                    
                    //fetch gau linked to campaign if present
                    fetchGaus = [SELECT id,npsp__Campaign__c,npsp__Percent__c,npsp__General_Accounting_Unit__c from npsp__Allocation__c where npsp__Campaign__c = :camObj.Id];
                    //insert pledge gau if none found
                    if(fetchGaus.size() == 0){                        
                        gau = new npsp__Allocation__c();
                        //pledge item either orphan or wash in initial spreadsheet, may need more cases later down the line
                        if(camItem.toLowerCase().contains('orphan')){
                            newPledgeGau = 'a0Z0C00000121YLUAY';
                            gau.npsp__General_Accounting_Unit__c = newPledgeGau; //pledge - Orphans and Children
                        }else if(camItem.toLowerCase().contains('dww')){
                            newPledgeGau = 'a0Z0C00000121YNUAY';
                            gau.npsp__General_Accounting_Unit__c = newPledgeGau; // pledge - WASH
                        }else{
                            //in case neither of the above and cannot parse, default to where most needed
                            newPledgeGau = 'a0Z0C00000121YIUAY';
                            gau.npsp__General_Accounting_Unit__c = newPledgeGau;//pledge - Where Most Needed
                        }
                        gau.npsp__Campaign__c = camObj.id;
                        gau.npsp__Percent__c = 100;
                        gauList.add(gau);
                        insert gau;
                    }else{
                        newPledgeGau = fetchGaus[0].npsp__General_Accounting_Unit__c;
                    }
                    //campaign - 0124J000000UpXaQAK
                    ////pledge - 0124J000000UpdeQAC
                    //Find and edit the GAU's on influenced donations and update description of Campaign
                    for (Opportunity infDonation : [SELECT Id,Name from Opportunity where CampaignId = :camObj.Id]){
                        if(infDonation.Id != null && infDonation.Name != null){
                            for(npsp__Allocation__c gauToUpdate : [SELECT GAU_Name__c,npsp__General_Accounting_Unit__c from npsp__Allocation__c where npsp__Opportunity__c = :infDonation.Id]){
                                if(gauToUpdate.GAU_Name__c != null){
                            		infDescription += '\n' + infDonation.Name + ' - ' + gauToUpdate.GAU_Name__c;
                                    gauToUpdate.npsp__General_Accounting_Unit__c = newPledgeGau;
                                    update gauToUpdate;
                                }
                       		}                           
                        }                                                                     
                     }
                                  
                    camObj.Description = infDescription;
                    update camObj;
                    campaignList.add(camObj);
                }                
                          
    		}
            
				
        }catch (Exception e){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data into Salesforce. Please make sure input csv file is correct and see exception: Line '+e.getLineNumber() +') '+ e.getMessage());
            ApexPages.addMessage(errorMessage);
    	}
    }   
    

}