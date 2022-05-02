/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 09-15-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   11-17-2020   Iamsfdeveloper   Initial Version
**/
import { LightningElement,api, track,wire} from 'lwc';
import LOCALE from '@salesforce/i18n/locale';
import getOrphanList from '@salesforce/apex/HA_newDonationController.getOrphanList';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ITEM_ALLOCATION_OBJECT from '@salesforce/schema/npsp__Allocation__c';
import STIPULATION_TYPE from '@salesforce/schema/npsp__Allocation__c.Stipulation_Type__c';

export default class DonationItem extends LightningElement {
@api recordId;
ind;
showReceiptNote =false;
@track hasError = false;
orphanList= [];
specialRequestValidation = false;
@track showModal = false;
@track specialInstructionList = [];
@track specialInstuctionObject = {};
@track selectedRows = [];
@api selectedOrphans;
@api quantityHide;
@track tempAllocationItem ;
@api currencyCode;
@track country;
showDeleteModal = false;
__render = true;
__options = [];
@wire(getObjectInfo, { objectApiName: ITEM_ALLOCATION_OBJECT })
    objectInfo;
  
@wire(getPicklistValues, { recordTypeId:'$objectInfo.data.defaultRecordTypeId',fieldApiName:STIPULATION_TYPE })
stipulationType({error,data}){
  let options = []
  console.log('stipulationType ==>'+JSON.stringify(data));
    if(data){
    let ItemStipulations = this.tempAllocationItem.npsp__General_Accounting_Unit__r.Stipulation__c.split(';');
    data.values.forEach(pke=>{
    if(ItemStipulations.includes(pke.value))
    options.push(pke);
    });
    this.__options = [...options];
    }
}

  
get options(){
  return this.__options;
  }
handleOnChange(event){
  this.tempAllocationItem.Stipulation_Type__c = event.detail.value;
  this.notifyOnchange(event);
}

get ReceiptNote(){
  return this.tempAllocationItem.Receipt_Note__c;
}
get showTextArea(){
 return (this.tempAllocationItem.npsp__General_Accounting_Unit__r.Special_Message__c ==='Name_DateofBirth')?false:true;

}
get showOrphanSelector(){
  return (this.tempAllocationItem.npsp__General_Accounting_Unit__r.Product_Type__c ==='Sponsorship')?true:false;
  
}
get inputReadonly(){
return  !this.tempAllocationItem.npsp__General_Accounting_Unit__r.Price_Editable__c;
}
get quantityReadOnly(){
  return !this.inputReadonly;
}
get showSpecialNote(){
  return this.tempAllocationItem.npsp__General_Accounting_Unit__r.Product_Type__c === 'Qty-based (Special Request)' || this.tempAllocationItem.npsp__General_Accounting_Unit__r.Product_Type__c === 'Sponsorship';
}
@api get allocationItem(){
  return this.tempAllocationItem;
}
set allocationItem(value) {
  this.setAttribute('allocationItem', value);
  this.tempAllocationItem = Object.assign({},value);
  this.country = this.tempAllocationItem.npsp__General_Accounting_Unit__r.Country__c;
  //this.tempAllocationItem.Stipulation_Type__c = 'Sadaqah';
}
@api get index(){
  this.ind;
}
set index(value){
 this.ind = value;
}

showSpecialInstructionModal(event){
  let __recordId = '';
  
  if(this.tempAllocationItem.npsp__General_Accounting_Unit__r.Sponsored_Orphan_Only__c){
    __recordId = this.recordId;
  }
  console.log('recordId '+__recordId);
  if(this.showOrphanSelector){
    this.selectedRows =[this.tempAllocationItem.Orphan__c];
  }
    this.showModal = true; 
}
toggleReceiptNote(event){
  this.showReceiptNote = (this.showReceiptNote)?false:true;
}
hideModal(event){
    this.showModal = false;  
  }
  saveSpecialInstruction(event){
    if(this.showOrphanSelector && this.tempAllocationItem.Orphan__c ==undefined){
        console.log('Select the Orphan');
        return;
    }
    
    let inputVals =this.template.querySelectorAll('.specialInst');
    let tempList = this.specialInstructionList;
    inputVals.forEach(item=>{
    if(item.name =='dob') {
    this.tempAllocationItem.Date_of_Birth__c = item.value;//new Intl.DateTimeFormat(LOCALE).format(new Date(item.value));
    }else{
      this.tempAllocationItem.Name__c = item.value;
    }
      
  });
  //check validation of all the input box 
    this.specialRequestValidation = true;
    //this.specialInstructionList = tempList;
    this.notifyOnchange(event);

    this.hideModal();

  }
  handleChange(event){
    const field = event.target.name;
    if(field==='Quantity__c'){
    let tempList = [];
    for(let x=0;x<event.target.value;x++){
        let obj = (x<this.specialInstructionList.length)?this.specialInstructionList[x]:Object.assign({},this.specialInstuctionObject);
        obj.SR_No= x+1;
        tempList.push(obj);
    }
    this.specialInstructionList  = tempList;
    this.tempAllocationItem.Quantity__c = event.target.value;
    this.tempAllocationItem.npsp__Amount__c = parseFloat(event.target.value * this.tempAllocationItem.UnitPrice);
  }else if (field === 'UnitPrice' && event.target.value >0) {
    this.tempAllocationItem.UnitPrice = event.target.value;
    this.tempAllocationItem.npsp__Amount__c = parseFloat(event.target.value * this.tempAllocationItem.Quantity__c);
  }
  this.notifyOnchange(event);
  }
  deleteItem(event){
    this.dispatchEvent(new CustomEvent('delete',{ detail: this.ind }));
  }
  showDelete(event){
    this.showDeleteModal=true;
  }
  cancelDelete(event){
    this.showDeleteModal=false;
  }
  updateItem(event){
    this.tempAllocationItem.Receipt_Note__c = this.template.querySelector("lightning-textarea").value;
    this.toggleReceiptNote(event);
    this.notifyOnchange(event);
  }
  notifyOnchange(event){
    this.dispatchEvent(new CustomEvent('itemchange',{detail:{index:this.ind,change:this.tempAllocationItem}}));
  }
  cascadeUpdate(event){
    let inputVals =this.template.querySelectorAll('.specialInst');
    let tempList = this.specialInstructionList;
    inputVals.forEach(function(item,ind){
      let index = item.getAttribute('data-ind');
      if(index == 0)
      tempList[index][item.name]= item.value;
      else{
        for (const [key, value] of Object.entries(tempList[0])){
            if(inputVals[index].name ==`${key}`)
               inputVals[index].value = `${value}`;
          }
        }
      
  });
   
  }
  handleSelectedRow(event){
    console.log('selectedRows '+event.detail.selectedRows);
    this.selectedRows = event.detail.selectedRows;
    this.tempAllocationItem.Orphan__c = event.detail.selectedRows[0];
    console.log('selectedRows '+JSON.stringify(event.detail.selectedRows));
    this.notifyOnchange(event);
  }
  @api
  validationCheck(){
    this.hasError = false;
    if(!this.tempAllocationItem.npsp__General_Accounting_Unit__r.Skip_Special_Instruction__c && this.tempAllocationItem.npsp__General_Accounting_Unit__r.Product_Type__c === 'Qty-based (Special Request)'){
        if(!this.specialRequestValidation)this.hasError = true;
        let inputs = this.template.querySelectorAll('lightning-input');
        inputs.forEach(input=>{
          input.checkValidity();
          if(!input.validity.valid){
            this.hasError = true;
            input.reportValidity();
            return;
          }
        });
    }
    if(this.tempAllocationItem.npsp__General_Accounting_Unit__r.Product_Type__c === 'Sponsorship'){
        if(this.tempAllocationItem.Orphan__c===undefined) this.hasError = true;
    }
    return  this.hasError;
  }
  cloneItem(event){        
    this.dispatchEvent(new CustomEvent('clone',{detail:{index:this.ind}}));
  }
  get classname(){
    return this.hasError?'slds-grid slds-align_absolute-center slds-p-top_small slds-p-bottom_small slds-table_bordered hasError':'slds-grid slds-align_absolute-center slds-p-top_small slds-p-bottom_small slds-table_bordered';
  }
}