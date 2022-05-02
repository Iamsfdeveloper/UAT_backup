@RestResource(urlMapping='/OrphansExportApi/*')
global with sharing class OrphansExportApi {
 
    @HttpGet
    global static List<OrphanExportItem> doExport() {
        List<OrphanExportItem> orphans = new List<OrphanExportItem>();
        
        // The sObject list format executes the for loop once per returned batch of 200 records
            for (Contact con : [SELECT Id, Sponsoree_ID__c,Orphan_Profile_URL__c,
                              	DMS_SupporterID__c, FirstName, LastName, Birthdate, Country__c, Gender__c, PhotoUrl, Sponsorship_Status__c
                              , Sponsoree_Is_Zakah_Eligible__c, Sponsoree_Favourite_Subject__c, Orphan_Fathers_Date_Of_Death__c, Orphan_Means_Of_Support__c, LastModifiedDate
                              FROM Contact WHERE RecordType.developerName ='Orphan' AND Is_Active__c=true AND Sponsoree_ID__c !='DefaultOrphan' AND Sponsorship_Status__c != 'sponsored' and  Sponsoree_Is_Reserved__c=false   Order By Sponsorship_Status__c desc limit 3000 ]) {
            	OrphanExportItem orphan = new OrphanExportItem();
        
                orphan.Id = con.Id;
                orphan.LegacyOrphanId = con.Sponsoree_ID__c;
                orphan.FirstName = con.FirstName;
                orphan.LastName = con.LastName;
                orphan.DateOfBirth = con.Birthdate;
                orphan.Location = con.Country__c;
                orphan.Gender = con.Gender__c == 'Male' ? 'M' : 'F';
                orphan.PhotoUrl = (con.Orphan_Profile_URL__c !=null)? con.Orphan_Profile_URL__c:'';
                orphan.ZakatEligible = con.Sponsoree_Is_Zakah_Eligible__c;
                orphan.FatherDateOfDeath = con.Orphan_Fathers_Date_Of_Death__c;
                orphan.MeansOfSupport = con.Orphan_Means_Of_Support__c;
                
                orphan.Languages = '';
                orphan.Aspirations = '';
                orphan.Hobbies = con.Sponsoree_Favourite_Subject__c;
                

                orphan.LastUpdated  = con.LastModifiedDate;
        		
                // add to the export
                orphans.Add(orphan);
            } 
       
    
        return orphans;
    }
 
    global class OrphanExportItem {
        String Id;
        String LegacyOrphanId;
        string FirstName;
        string LastName;
        DateTime DateOfBirth;
        string Location;
        string Gender;
        string PhotoUrl;
        boolean ZakatEligible;
        // missing things 
        // Means of support
        // Languages
        // Aspirations
        // Hobbies
        // father date of death
        string MeansOfSupport;
        string Languages;
        string Aspirations;
        string Hobbies;
        DateTime FatherDateOfDeath;
        DateTime LastUpdated;

    }    
}