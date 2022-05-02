/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 01-17-2022
 * @last modified by  : Iamsfdeveloper
**/
public class checkoutDataType {

    
    public with sharing class NewDonationDataType {
        public DateTime transactionTimeUtc;
        public String BasketId;
        public NewDonationSupporterDataType supporter;
        public NewDonationBasketDataType basket;
        public List<paymentMethodDataType>PaymentMethods;
        public String userIp;
        public String siteCode;
        public String Status;
        public NewDonationDataType(){
            
        }
    }
    public with sharing class NewDonationBasketDataType {
         public String id;
         public String currencyISOCode; 
         public List<checkoutDataType.donationGroup> ItemGroups;
         public String notes;
        public NewDonationBasketDataType(){
            
        }
        
    }
    public class donationGroup {
        public List<NewDonationBasketItemDataType> Items;
        public Integer GroupIndex;
        public Integer PaymentMethodIndex;
        Public String DonationType;
        Public String GroupId;
        Public Decimal Amount;
        Public String PrimaryCampaignCode;
        public checkoutDataType.PaymentScheduleList[] PaymentScheduleList;
        public donationGroup(){
            
        }
    }    
    public with sharing class NewDonationSupporterDataType {
         public String supporterId;
         public String title;
         public String firstName;
         public String lastName;
         public String organisationName;
         public Boolean IsOrganisation;
         public String addressLine1;
         public String addressLine2;
         public String addressLine3;
         public String townCity;
         public String state;
         public String postalCode;
         public String countryCode;
         public String telephone;
         public String email;
         public String GiftAidDeclared;
         public Boolean subscribeEmailList;
         public Boolean subscribeSmsList;
         public Boolean receiptViaEmail;
         public Boolean receiptViaPost;
         public String nationalIdentificationNumber;
        public NewDonationSupporterDataType(){
            
        }
    }
    public with sharing class NewDonationBasketItemDataType {
         public Integer PaymentMethodIndex;
         public Decimal amount;
         public String notes;
         public String donationItemCode;
         public String locationCode;
         public String stipulationCode;
         public String targetNumber;
         public String SubCampaignCode;
         public String cardId;
         public String donationType;
         public checkoutDataType.SchemeData[] schemeData;
        public NewDonationBasketItemDataType(){
            
        }
    }
    public class SchemeData{
         public String ParameterCode;
         public String ParameterName;
         public String ParameterValue;
        public SchemeData(){
            
        }
    }
    public class PaymentScheduleList{
         public Integer Index;
         public Datetime Date_Time;
         public String Timezone;
         public Decimal Amount;
        public PaymentScheduleList(){
            
        }
    }
    Public Interface PaymentGateway{
    }
    public class TotalProcessing implements PaymentGateway{
        public DateTime DateTimeCreated ;
        public String Status ;
        public String PaymentMethodId ;
        public String Descriptor ;
        public String CurrencyISOCode ;
        public Decimal Amount ;
        public String ExpYear ;
        public String ExpMonth ;
        public String Last4Card ;
        public String CustomerIP ;
        public String PaymentType ;
        public String PaymentIntent ;
        public String Description ;
        public String StatusCode ;
        public String Gateway ;
        public Integer PaymentMethodIndex ;
        public String Id {get;set;}
    }
    public class paymentMethodDataType implements PaymentGateway{
       	 public String Id {get;set;}
          public String currencyISOCode;
          public Decimal Amount;
          public Integer PaymentMethodIndex;
          public Integer BankPaymentDay;
          public Boolean AcceptTerms;
          public Boolean IsValidated;
          public String AccountHolder;
          public String AccountNumber;
          public String SortCode; 
          public String Iban;
          public String Bic;
          public String CustomerId;
          public String PaymentIntent;
          public String SetupIntent;
          public String ChargeId; 
          public String PaymentMethodId;
          public String Status;
          public DateTime DateTimeCreated;
         public ValidationResponse ValidationResponse;
        public paymentMethodDataType(){
            
        }

    }
    public class ValidationResponse{
         public Boolean AccountCodeOK;
         public Integer AccountNumber;
         public String BankAddress1;
         public String BankAddress2;
         public String BankAddress3;
         public String BankAddress4;
         public String BankAddressPostCode;
         public String BankAddressTown;
         public String BankName;
         public String BranchTitle;
         public Boolean CreditsAllowedOK;
         public Boolean DirectDebitInstructionOK;
         public Boolean DirectDebitsOK;
         public String Error;
         public Integer SortCode;
         public Boolean SortCodeOK;
         public String Telephone;
        public ValidationResponse(){
            
        }
    }
}