/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 04-27-2022
 * @last modified by  : Iamsfdeveloper
**/
import { api, LightningElement,wire } from 'lwc';
import getDonationDetails from '@salesforce/apex/StripeController.getDonationDetails'
import savePaymentDetails from '@salesforce/apex/StripeController.savePaymentDetails'
import confirmPaymentDetails from '@salesforce/apex/StripeController.confirmPaymentDetails'

import { NavigationMixin } from 'lightning/navigation';
import { showMessage} from 'c/util';
export default class StripeWizard extends NavigationMixin(LightningElement) {
    vfOrigin = "https://humanappeal--uat--c.visualforce.com";
    //vfOrigin = "https://humanappeal--c.um9.visual.force.com";
    @api recordId;
    sObjectId;
    sourceurl;
    loadIframe = false;
    intialize = false;
    donationObject;
    showSpinner = false;
    handle_Message = this.handleMessage.bind(this);
    @wire(getDonationDetails, { recordId: '$sObjectId'})
    wiredRecord({ error, data }) {
        if(data){
            this.donationObject = data['opp'];
            this.loadIframe = true;
        }else if(error){
            console.log('error==>'+error);
            let message = 'Unknown error';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                showMessage(this,'Error!',message,'error');
        }
    }
    
    connectedCallback(){
    window.addEventListener("message", this.handle_Message);
    }
    disconnectedCallback(){
    
    window.removeEventListener("message",this.handle_Message);
            
    }
    renderedCallback(){
        if( this.intialize )return;
         if(this.recordId){
             this.sObjectId = this.recordId;
            this.sourceurl  = '/apex/StripeComponent?Id='+this.recordId;
            this.intialize =true;
         }
         
        
    }
    handleMessage(message){
        if (message.origin !== this.vfOrigin) {
            return;
        }
        let messageData = JSON.stringify(message.data);
        let customerId = message.data.customerId;
        let resultObject = JSON.parse(messageData);
        if (message.origin === this.vfOrigin) {
           console.log(' this.receivedMessage ', resultObject );
            try{
                this.showSpinner = true;
                if(resultObject.type==='confirmSetup'){
                    
                    if(resultObject.data.paymentMethod.id) {
                        confirmPaymentDetails({setupOnly:true,paymentMethodId:resultObject.data.paymentMethod.id,setupInentId:resultObject.setupIntentId,RegionalOfficeCode:this.donationObject.Regional_Office_Code__c}).then((attachresult) => {
                            
                            let setupIntent = JSON.parse(attachresult);
                            console.log('setupIntent==>'+setupIntent);
                            if(setupIntent){
                                switch (setupIntent.status) {
                                    case "succeeded":
                                        showMessage(this,'Success!','Setup is Successful','success');
                                        //this.updateDonation(component,paymentIntent.status,result);
                                        this.updateDonation(setupIntent,customerId);
                                        break;
                                        case "processing":
        
                                        showMessage(this,"Setup processing!",'Your donation Setup is Processing, we will email you once succeeds','info');
                                        this.showSpinner = false;
                                        //this.updateDonation(component,paymentIntent.status,result);
                                        break; 
                                    default:
                                        this.showSpinner = false;
                                        showMessage(this,"Payment Failed!",setupIntent.error.message,'error');
                                        //this.updateDonation(component,paymentIntent.status,result);
                                }
                            }else{
                                this.showSpinner = false;
                                showMessage(this,"Payment Failed!",setupIntent.error.message,'error');
                                // this.updateDonation(component,paymentIntent.status,result);
                                }
                            
                            /*
                                let attachresult = JSON.parse(attachresult);
                                let donationObject = this.donationObject;
                                let createdDate = new Date(Date(attachresult.created));
                                let createdDateStr = createdDate.getFullYear()+'-'+createdDate.getMonth()+'-'+createdDate.getDate();
                                let cardPaymentDetail = {};
                                cardPaymentDetail.Opportunity__c = donationObject.Id;
                                cardPaymentDetail.Authorisation_Date__c = createdDate;
                                cardPaymentDetail.Payment_Method_Id__c = attachresult.payment_method;
                                cardPaymentDetail.Payment_Method_Type__c = 'card';
                                cardPaymentDetail.Payment_Vendor__c = 'Stripe';
                                cardPaymentDetail.Payment_Status__c = attachresult.status;
                                cardPaymentDetail.CurrencyIsoCode = donationObject.CurrencyIsoCode;
                                cardPaymentDetail.Order_ID__c = resultObject.id;
                                cardPaymentDetail.Payment_Reference__c='InternalWizard';
                                cardPaymentDetail.Gateway_Customer_Reference__c = customerId; 
                                cardPaymentDetail.First_Payment_Taken__c = false;
                                cardPaymentDetail.Transaction_Type__c = 'Authorised';
                                cardPaymentDetail.First_Payment_Amount__c = parseFloat(0);     
                                savePaymentDetails({cardPaymentDetail:JSON.stringify(cardPaymentDetail),paymentObject:''}).then((saveresult) => {
                                this.showSpinner = false;
                                console.log('saveresult'+saveresult);
                                this.navigateToRecordViewPage()
                                }).catch(error => {
                                this.showSpinner = false;
                                showMessage(this,"Failed!",'Failed To Save'+error,'error');
                                });
                        */
                        }).catch(error => {
                        this.showSpinner = false;
                        showMessage(this,"Failed!",'Failed To Save'+error,'error');
                        });
                    }
                       
                    // setupIntent = (resultObject.data.setupIntent)?resultObject.data.setupIntent:resultObject.data.error.setup_intent;
                    
                }else{
                    
                        confirmPaymentDetails({setupOnly:false,paymentMethodId:resultObject.data.paymentMethod.id,setupInentId:resultObject.PaymentIntentId,RegionalOfficeCode:this.donationObject.Regional_Office_Code__c}).then((attachresult) => {
                          console.log('paymentIntent==>'+attachresult);
                        let paymentIntent = JSON.parse(attachresult);//(resultObject.data.paymentIntent)?resultObject.data.paymentIntent:resultObject.data.error.payment_intent;
                        if(paymentIntent){
                            switch (paymentIntent.status) {
                            case "succeeded":
                                showMessage(this,'Success!','Payment is Successful','success');
                                this.updateDonation(paymentIntent,customerId);
                                //this.updateDonation(component,paymentIntent.status,result);
                                break;
                                case "processing":
                                showMessage(this,"Payment processing!",'Your donation is Processing, we will email you once succeeds','info');
                                this.showSpinner = false;
                                //this.updateDonation(component,paymentIntent.status,result);
                                break; 
                            default:
                                this.showSpinner = false;
                                showMessage(this,"Payment Failed!",paymentIntent.error.message,'error');

                                //this.updateDonation(component,paymentIntent.status,result);
                            }
                        }else{
                            this.showSpinner = false;
                        showMessage(this,"Payment Failed!",paymentIntent.error.message,'error');
                        // this.updateDonation(component,paymentIntent.status,result);
                        }
                    }).catch(error => {
                        this.showSpinner = false;
                        showMessage(this,"Failed!",'Failed To Save'+error,'error');
                        });
                }
            }catch(err){
                this.showSpinner = false;
                console.log('Error Occurred==>'+err);
            }
        
        }
         
    }
    updateDonation(resultObject,customerId){
        console.log('customerId'+customerId);
        console.log('resultObject'+resultObject);
        let result = this.donationObject;
        let createdDate = new Date(Date(resultObject.created));
        let createdDateStr = createdDate.getFullYear()+'-'+createdDate.getMonth()+'-'+createdDate.getDate();
        let cardPaymentDetail = {};
        cardPaymentDetail.Opportunity__c = result.Id;
        cardPaymentDetail.Authorisation_Date__c = createdDate;
        cardPaymentDetail.Payment_Method_Id__c = resultObject.payment_method;
        cardPaymentDetail.Payment_Method_Type__c = 'card';
        cardPaymentDetail.Payment_Vendor__c = 'Stripe';
        cardPaymentDetail.Payment_Status__c = resultObject.status;
        cardPaymentDetail.CurrencyIsoCode = result.CurrencyIsoCode;
        cardPaymentDetail.Order_ID__c = resultObject.id;
        cardPaymentDetail.Payment_Reference__c='InternalWizard';
        cardPaymentDetail.Gateway_Customer_Reference__c = customerId;
        let paymentObject = {};        

        console.log('donationObject'+JSON.stringify(result));
        let donationCode = result.DonationCode__c;
        switch (donationCode){
            case "SD":
                cardPaymentDetail.First_Payment_Taken__c = true;
                cardPaymentDetail.contact__c = result.npsp__Primary_contact__c;
                cardPaymentDetail.Transaction_Type__c = 'Authorised';//IntentCustomerId;//Authorised & First Collection	//Authenticate	//Sale//Authorised
                cardPaymentDetail.First_Payment_Amount__c = parseFloat(resultObject.amount/100).toFixed(2);
                paymentObject.CurrencyIsoCode = result.CurrencyIsoCode;
                paymentObject.npe01__Opportunity__c =result.Id;
                paymentObject.RecordTypeId='0124J000000UpwgQAC';
                paymentObject.npe01__Payment_Method__c = 'Card Payment';
                paymentObject.npe01__Payment_Date__c= createdDateStr;
                paymentObject.npsp__Gateway_Payment_ID__c =resultObject.payment_method;
                paymentObject.Order_ID__c =resultObject.id;
                paymentObject.Transaction_ID__c =resultObject.id;
                paymentObject.Payment_Status__c = resultObject.status;
                paymentObject.npe01__Payment_Amount__c = parseFloat(resultObject.amount/100).toFixed(2);
                paymentObject.npsp__Type__c='Sale';
                paymentObject.Transaction_Type__c ='Sale';
                paymentObject.npe01__Paid__c=true;
                break;
            case "RD":
            case "RDA":
            case "EMI":
                cardPaymentDetail.First_Payment_Taken__c = true;
                cardPaymentDetail.Transaction_Type__c = 'Authorised';//IntentCustomerId;//	//Authenticate	//Sale//Authorised
                cardPaymentDetail.First_Payment_Amount__c = parseFloat(resultObject.amount/100).toFixed(2);
                paymentObject.CurrencyIsoCode = result.CurrencyIsoCode;
                paymentObject.npe01__Opportunity__c =result.Id;
                paymentObject.RecordTypeId='0124J000000UpwgQAC';
                paymentObject.npe01__Payment_Method__c = 'Card Payment';
                paymentObject.Payment_Status__c = resultObject.status;
                paymentObject.npe01__Payment_Date__c= createdDateStr;
                paymentObject.npsp__Gateway_Payment_ID__c =resultObject.payment_method;
                paymentObject.Order_ID__c =resultObject.id;
                paymentObject.Transaction_ID__c =resultObject.id;
                paymentObject.npe01__Payment_Amount__c = 0;
                paymentObject.npsp__Type__c='Setup';
                paymentObject.Transaction_Type__c ='Setup';
            break;
            case "10N":
            case "30N":
            case "10D":
                paymentObject ='';
                cardPaymentDetail.First_Payment_Taken__c = false;
                cardPaymentDetail.Transaction_Type__c = 'Authorised';
                cardPaymentDetail.First_Payment_Amount__c = parseFloat(0);
                console.log('Setup Complete===>');  
                break;     
                default:
                showMessage(this,"Updated Failed!",'Donation Type Not Found','error');
        }
        console.log('cardPaymentDetail'+JSON.stringify(cardPaymentDetail));  
        console.log('cardPaymentDetail'+JSON.stringify(paymentObject));  
        let payment_Object = (paymentObject != '')?JSON.stringify(paymentObject):'';
    savePaymentDetails({cardPaymentDetail:JSON.stringify(cardPaymentDetail),paymentObject:payment_Object}).then((saveresult) => {
        this.showSpinner = false;
        console.log('saveresult'+saveresult);
        this.navigateToRecordViewPage()
    }).catch(error => {
        this.showSpinner = false;
        showMessage(this,"Failed!",'Failed To Save'+error,'error');
    });
}
navigateToRecordViewPage() {
    // View a custom object record.
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.recordId,
            actionName: 'view'
        }
    });
}
}