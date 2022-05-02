/**
 * @File Name          : NewDonationBasketDataType.cls
 * @Description        :
 * @Author             : agentgill
 * @Group              :
 * @Last Modified By   : agentgill
 * @Last Modified On   : 4/12/2020, 11:27:43 AM
 * @Modification Log   :
 * Ver       Date            Author                 Modification
 * 1.0    3/10/2020   agentgill     Initial Version
 **/
public with sharing class NewDonationBasketDataType {
    @AuraEnabled
    @InvocableVariable
    public String id;

    @AuraEnabled
    @InvocableVariable
    public String currencyId; // Currency ISO Code

    @AuraEnabled
    @InvocableVariable
    public List<NewDonationBasketItemDataType> items;

    @AuraEnabled
    @InvocableVariable
    public String notes;

    public NewDonationBasketDataType() {
    }
}