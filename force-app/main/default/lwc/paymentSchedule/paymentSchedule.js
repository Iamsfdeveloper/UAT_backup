/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   01-07-2021   Iamsfdeveloper   Initial Version
**/
import { LightningElement,wire,api,track} from 'lwc';
import paymentSchedules from '@salesforce/apex/HA_Utility.getPaymentSchedules';
export default class PaymentSchedule extends LightningElement {
@wire(paymentSchedules)
paymentSchedules({ error, data }){
    if(data){
        Object.values(data).forEach(item => {
            const options= { label: item.Name, value: item.Id };
                if(item.Code__c == this.defaultDonationType){
                        this.value = item.Id;
                        this.dispatchEvent(new CustomEvent('typechange',{ detail: this.value }));
                }
                this.__options = [ ...this.__options,options]; 
        });
        
    }
}

    __options =[];
    value;
    @api
    defaultDonationType;
    handleChange(event) {
        this.value = event.detail.value;
        this.dispatchEvent(new CustomEvent('typechange',{ detail: this.value }));
    }
}