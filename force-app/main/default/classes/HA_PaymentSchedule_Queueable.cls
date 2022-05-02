/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 04-06-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   04-06-2021   Iamsfdeveloper   Initial Version
**/
public class HA_PaymentSchedule_Queueable implements Queueable {
public  NewDonationBasketItemDataType Item;
public Opportunity Donation;
    public void populatePaymentScheduleList(Opportunity Donation,NewDonationBasketItemDataType  Item){
        this.Donation = Donation;
        this.Item = Item;
    }
    public void execute(QueueableContext context) {
        ContentVersion conVer = new ContentVersion(Donation__c =Donation.Id,ContentLocation = 'S',PathOnClient = 'Payment_Schedule_List.txt',Title = 'Payment_Schedule_List',VersionData = Blob.valueOf(JSON.serialize(Item.PaymentScheduleList)));
        insert conVer;
		Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();
        cdlToInsert.add(New ContentDocumentLink(LinkedEntityId = Donation.Id,ContentDocumentId = conDoc,shareType = 'V'));
        String GrpName = (Test.isRunningTest())?'Integration_Users_Test':'Integration_Users';
        cdlToInsert.add(New ContentDocumentLink(LinkedEntityId = [SELECT Id FROM CollaborationGroup Where Name =:GrpName].Id,ContentDocumentId = conDoc,shareType = 'V'));
        insert cdlToInsert;
        
             
    }
}