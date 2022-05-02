/**
 * MergeDuplicateCampaigns
 * Steps:
 *  1. Get Campaigns by Fundraising_page_url__c with %justgiving%
 *  2. Determine duplicates: 
 *      a. Compare amount raised and add smaller into larger?
 *  3. Merge duplicates: 
 *      a. Add/copy duplicate campaign data to the main campaign data
 *      b. Copy Donations from duplicate campaign to the main campaign data
 */
 public class MergeDuplicateCampaigns {
    public static void sayBsmA() {
        System.debug('BsmA');
    }

    public static List<Campaign> getCampaignsLike(String url) {
        return [
            SELECT Id, name, Fundraising_page_url__c
            FROM Campaign
            WHERE Fundraising_page_url__c != NULL
            AND Fundraising_page_url__c LIKE :url
        ];
    }

    /**
     * Groups the duplicate(s) of a main campaign.
     * Creates a map of `Fundraising_page_url__c` to a `Campaign[]` (list) of duplicate campaigns.
     * Then, groups campaigns whose URLs are the same by putting them in the same List mapped to the URL.
     * @param campaigns — the list of campaigns to search duplicates for.
     */
    public static Map<String, Campaign[]> groupDuplicate(Campaign[] campaigns) {
        // Create a map of Fundraising_page_url__c to a list of duplicate campaigns.
        Map<String, Campaign[]> campaignsMap = new Map<String, Campaign[]>();
        for (Integer i = 0; i < campaigns.size(); i++) {
            if (campaignsMap.containsKey(campaigns[i].Fundraising_page_url__c)) {
                // Update the existing duplicate campaigns list to also have this other duplicate campaign 
                Campaign[] duplicateCampaigns = campaignsMap.get(campaigns[i].Fundraising_page_url__c);
                duplicateCampaigns.add(campaigns[i]);
            } else {
                campaignsMap.put(campaigns[i].Fundraising_page_url__c, new Campaign[]{campaigns[i]});
            }
        }
    
        // Remove key, value pairs where the value's length is < 2 (Campaign[].size() < 2) 
        for (String url: campaignsMap.keySet()) {
            if (campaignsMap.get(url).size() < 2) {
                campaignsMap.remove(url);
            }
        }
    
        return campaignsMap;
    }

    /**
     * Takes in a list of campaigns who share the same page URL and returns the main campaign.
     * Determines the main one by comparing the amounts raised in `Campaign.AmountAllOpportunities`.
     * Used to decide which of the campaigns with duplicates will be merged into.
     * By deafult the first campaign in the list is returned if none match the criterion.
     * @param campaigns - The campaigns to be searched for the main one.
     * @return the main `Campaign`. Default is `campaigns[0]`.
     */
    Campaign getMainOf(Campaign[] campaigns) {
        Campaign mainCampaign = campaigns[0];
        for (Campaign campaign: campaigns) {
            if (campaign.AmountAllOpportunities > mainCampaign.AmountAllOpportunities)
                mainCampaign = campaign;
        }

        return mainCampaign;
    }

    /**
     * Combines several important attributes of the duplicate and main campaign together.
     * Basically runs `main.<insert attribute> += duplicate.<insert attribute>` for each (numerical) attribute, namely 
     * `Campaign.AmountAllOpportunities`, and `Campaign.AmountWonOpportunities`
     */
    void combineCampaignDataOf(Campaign main, Campaign duplicate) {
        /* Error: these fields are not writeable */
        // main.AmountAllOpportunities += duplicate.AmountAllOpportunities;
        // main.AmountWonOpportunities += duplicate.AmountWonOpportunities;

        // main.HierarchyAmountAllOpportunities += duplicate.HierarchyAmountAllOpportunities;
        // main.HierarchyAmountWonOpportunities += duplicate.HierarchyAmountWonOpportunities;

        // Parent campaign is also not writeable
    }


    /**
     * Gets duplicate JustGiving campaign(s) and returns them.
     * Does this by grouping campaigns by URL, and then only displaying
     * it when the COUNT(Id) > 1. Ordered from highest to lowest number of duplicates.
     */
    public static List<AggregateResult> getDuplicates() {
        List<AggregateResult> campaigns = [
            SELECT COUNT(Id), Fundraising_page_url__c
            FROM Campaign
            WHERE Fundraising_page_url__c != NULL
            AND Fundraising_page_url__c LIKE '%justgiving%'
            GROUP BY Fundraising_page_url__c
            HAVING COUNT(Id) > 1
            ORDER BY COUNT(ID) DESC 
        ];

        return campaigns;
    }
}