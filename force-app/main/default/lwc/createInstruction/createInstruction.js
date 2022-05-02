/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 03-30-2022
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   07-18-2021   Iamsfdeveloper   Initial Version
**/
import { LightningElement, wire, track, api } from 'lwc';
import doInit from '@salesforce/apex/createInstruction.doInit';
import getItems from '@salesforce/apex/createInstruction.getItems';
import getCampaignDetails from '@salesforce/apex/createInstruction.getCampaignDetails'
import saveAllocation from '@salesforce/apex/createInstruction.saveAllocation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { generateGUID } from 'c/util';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateInstruction extends LightningElement {



    /*This is copied */

      /**Public Properties */
      @api
      showContactField;
      @api
      showAccountField;
      showFundTransfer = false;
      __initRender = false;
      @track showCancelConfirm;
      @track opportunityId;
      @track __recordId;
      @track contactId;
      @track accountId;
      @track leadId;
      @track hideQuantity;
      @track selectedOrphan = [];
      @track campaignItemPrice={};
     
      @track itemList;
      @track itemAllocations = [];
      @track paymentRecordTypeId = '';
      @track recurringDonationList = [];
      get totalAmount(){
          let totalDonationAmount = 0.00;
          if(this.showFundTransfer){
            this.itemAllocations.forEach(function(item){
                if(item.Type__c =='Credit')
                totalDonationAmount += item.npsp__Amount__c
            });
        }else{
            this.itemAllocations.forEach(function(item){
                totalDonationAmount += item.npsp__Amount__c
            });
        }
          return parseFloat(totalDonationAmount).toFixed(2);
      }
      donationType ='SD';
      searchKey ='';
      queryFilter;
      __paymentScheduleId;
      allowedPaymentOptions=[];
      donationSingleRecordTypeId ;
      donationPaymentPlanRecordTypeId;
      stipulationOptions = [];
      stipulationType = '';
      countryList=[];
      currencyISOCode;
      
      today;
      unAllocatedAmount=0.00;
      __campaignId;
      showSchedule=false;
      selectedCountry = '';    
      loadedSpinner = true;
      donationStartDate;
      showRecurringDonationType = false;
      showNumberOfInstallments = false;
      showNightSettings = false;
      startDateOptions =[];
      hideXFactor = false;
      disabledSave = true;
      @track
     campaignDetail = {Available_Amount__c:0.00};
  
      startDate;
      get disabledSaveBtn(){
        let enableSave = true;
        if(this.showFundTransfer)
        enableSave = (this.itemAllocations.length == 2);
        else
        enableSave =  (this.itemAllocations.length > 0);
        if(enableSave && this.campaignDetail != undefined && (parseFloat(this.campaignDetail.Available_Amount__c) >0))
        return false;

      return true;
      }
      
      @api 
      get recordId(){
          return this.__recordId;
      }
      set recordId(value){
          if(value.startsWith('701')){
              this.__recordId = value;
              this.campaignId = value;
          }
      }
     
     
     get campaignId(){
         return this.__campaignId;
     }
     set campaignId(value){
        if(value != null){
            this.__campaignId = value;
            getCampaignDetails({recordId:value}).then(result=>{
            this.campaignDetail = result;
            }).catch(error=>{
                console.log('getCampaignDetails error occured==>'+error);
                const event = new ShowToastEvent({
                    "title": "Error Occurred!",
                    "variant":"error",
                    "message": 'Please selecte Pledge Campaign only.'
                });
                this.dispatchEvent(event);
            });     
        }
     }
     /*
     @wire(getCampaignDetails,{recordId:'$campaignId'})
     assignCampaignData({error,data}){
         if(data){
             this.campaignDetail = data;
         }
     }
     */

     renderedCallback(){
         if(this.__initRender)return;
         if (this.campaignId != undefined  && this.template.querySelector("lightning-input-field[data-id=Campaign__c]")) {
            this.template.querySelector("lightning-input-field[data-id=Campaign__c]").value = this.campaignId;
            this.__initRender = true; 
        }
         
     }
    roundNumber(num, precision) {
        precision = Math.pow(10, precision)
        return Math.ceil(num * precision) / precision
    }
     formatDate(__d){
          let d = new Date(__d),
              month = '' + (d.getMonth() + 1),
              day = '' + d.getDate(),
              year = d.getFullYear();
      
          if (month.length < 2) 
              month = '0' + month;
          if (day.length < 2) 
              day = '0' + day;
          return [year, month, day].join('-');
      
     }
     
     
      @wire(doInit)
      paymentType({error,data}){
          if(data){
              this.stipulationOptions = data['stipulationType'];
              let defaultStipulationType =[];
              this.stipulationOptions.forEach(function(item){
                   defaultStipulationType.push(item.value);
              });
              this.stipulationType = defaultStipulationType.join(',');
              let countryList = Array.from(data['countryList']);
              countryList.unshift({defaultValue: true,label:'All',value:''});
              this.countryList = countryList;
              this.currencyISOCode = data['currencyISOCode'];
              this.today = data['today']
              this.queryFilter = '';
          }
          console.log('error '+error);
      };
      
      
      
      @wire(getItems,{queryFilter:'$queryFilter',currencyISOCode:'$currencyISOCode'})
      buildItems({error,data}){
          if(data){
              let items = data['items'];
              let tempDataList = [];
              items.forEach(item=>{
                  
                      let tempObj = Object.assign({},item);
                      let unitPrice = (this.showFundTransfer)?0:(tempObj.Price_Book_Entries__r && tempObj.Product_Type__c=='Sponsorship')?tempObj.Price_Book_Entries__r[0].Annual_Price__c:(tempObj.Price_Book_Entries__r)?tempObj.Price_Book_Entries__r[0].UnitPrice:0;
                       let obj = {'minPrice':unitPrice,'npsp__General_Accounting_Unit__c':tempObj.Id,'Stipulation_Type__c':'','Quantity__c':1,'UnitPrice':unitPrice,Name__c:'',Date_of_Birth__c:undefined,'npsp__Amount__c':parseFloat(1*unitPrice),npsp__General_Accounting_Unit__r:tempObj};
                      
                      if(tempObj.Stipulation__c){
                          let ItemStipulations = tempObj.Stipulation__c.split(';');
                          obj.Stipulation_Type__c = ItemStipulations[0];
                      }
                      tempDataList.push(obj);
              });
          
              this.itemList=[...tempDataList];
          }else{
              console.log(error);
          }
              
      }
      addItemAllocation(event){
          
          if(this.itemAllocations.length < 50){
              let selectedIndex ;
              let selectedItem =  this.itemList.find(function(o,ind){
                      if(o.npsp__General_Accounting_Unit__c === event.target.name){
                          selectedIndex = ind;
                          return o;
                      }
                      });
                      selectedItem.Id = generateGUID();
              //this.newDonationOpp.Amount = parseFloat(this.newDonationOpp.Amount + selectedItem.npsp__Amount__c);
              selectedItem.Type__c = 'Credit';
              if(this.showFundTransfer){
              this.itemList.splice(selectedIndex,1);
              selectedItem.npsp__General_Accounting_Unit__r.Price_Editable__c = false;
              if(this.itemAllocations.length>0){
                selectedItem.UnitPrice = this.itemAllocations[0].UnitPrice;
                selectedItem.npsp__Amount__c = this.itemAllocations[0].npsp__Amount__c;
              }
              
            }
              this.itemAllocations.push(selectedItem);
              
              //if(this.itemAllocations.length ==10) 
               //this.disabledAddBtn = true;
          }
          
           
      }
      get disabledAddBtn(){
          if(this.showFundTransfer)
          return (this.itemAllocations.length == 2);
          
          return (this.itemAllocations.length == 50);
        
          
      }
      handleTypeChange(event){
        this.itemAllocations = [];
        if(event.detail.value == 'Fund Transfer'){
            this.showFundTransfer = true;
            this.queryFilter = ' Product_Type__c = \'Fund\'';
            if(this.campaignDetail.npsp__Allocations__r == undefined) return;
            let alloc = JSON.parse(JSON.stringify(this.campaignDetail.npsp__Allocations__r[0]));
            if(parseFloat(this.campaignDetail.Available_Amount__c) >0){
                alloc.UnitPrice = this.campaignDetail.Available_Amount__c;
                alloc.npsp__Amount__c = this.campaignDetail.Available_Amount__c;
                alloc.Quantity__c = 1;
            }else{
                alloc.UnitPrice = 0;
                alloc.npsp__Amount__c = 0;
                alloc.Quantity__c = 1;
            }
            alloc.Type__c = 'Debit';
            alloc.npsp__General_Accounting_Unit__r.Price_Editable__c = true;
            alloc.minPrice=1;
            //let obj = {'minPrice':0,'npsp__General_Accounting_Unit__c':alloc.npsp__General_Accounting_Unit__c,'Stipulation_Type__c':alloc.Stipulation_Type__c,'Quantity__c':1,'UnitPrice':0,Name__c:'',Date_of_Birth__c:undefined,'npsp__Amount__c':parseFloat(1*0),npsp__General_Accounting_Unit__r:}; 
            this.itemAllocations.push(alloc);
        }
         else{
            this.showFundTransfer = false;
            this.handleChange();
         }
      }
      handleChange(event){
        let searchFilters  = this.template.querySelectorAll(".searchFilter");
        let queryFilters = [];
        searchFilters.forEach(function(item){
                    if(item.name){
                    if(item.name==='Stipulation__c' && item.value != ''){
                        let val =[];
                        item.value.toString().split(',').forEach(function(x){
                        val.push('\''+x+'\'');
                        });
                        val ='('+val.join(',')+')';
                        queryFilters.push(item.name+' includes '+val);
                    }else if(item.value != ''){
                        queryFilters.push(item.name+'=\''+item.value+'\'');
                    }
                }
        });
           let queryFilter = queryFilters.join(' AND ');
            if(!this.showFundTransfer)
            queryFilter +=' AND (Product_Type__c = \'Qty-based (Special Request)\' or ( Product_Type__c = \'Sponsorship\' AND Sponsored_Orphan_Only__c = false AND Country__c=\'General\'))' ;
            this.queryFilter = queryFilter;
            
            this.currencyISOCode = this.template.querySelector("lightning-input-field[data-id=CurrencyIsoCode]").value;
      
      }
      handleKeyUp(event){
          
          if (event.target.value)
              this.searchKey = event.target.value.trim();
           if(this.searchKey.length>2) {
              let searchFilters  = this.template.querySelectorAll(".searchFilter");
          let queryFilters = [];
          searchFilters.forEach(function(item){
                      if(item.name){
                      if(item.name==='Stipulation__c' && item.value != ''){
                          let val =[];
                          item.value.toString().split(',').forEach(function(x){
                          val.push('\''+x+'\'');
                          });
                          val ='('+val.join(',')+')';
                          queryFilters.push(item.name+' includes '+val);
                      }else if(item.value != ''){
                          queryFilters.push(item.name+'=\''+item.value+'\'');
                      }
                  }
          });
              this.searchKey = event.target.value;
              let queryFilter = queryFilters.join(' AND ');
              if(!this.showFundTransfer)
              queryFilter +=' AND ( Product_Type__c = \'Qty-based (Special Request)\' or ( Product_Type__c = \'Sponsorship\' AND Sponsored_Orphan_Only__c = false AND Country__c=\'General\'))' ;
              this.queryFilter = queryFilter + 'AND ( Name like \'%'+this.searchKey+'%\' OR  Donation_Item_Code__c Like \'%'+this.searchKey+'%\')';
              
              this.currencyISOCode = this.template.querySelector("lightning-input-field[data-id=CurrencyIsoCode]").value;
          }else{
              this.handleChange();
          }
          
      }
      saveAndNext(event){
        const btn = this.template.querySelector( ".hidden" );

        if( btn ){ 
           btn.click();
        }
      }
      handleSubmit(event){
        this.loadedSpinner =false;
        event.preventDefault();  
        const fields = event.detail.fields;
        fields.campaign__c = this.recordId;
        fields.Donor__c = this.campaignDetail.Donor__c;
        fields.Funds_Allocated__c = this.totalAmount;
        let tempList = Array.from(this.itemAllocations);
        this.itemAllocations.forEach(function(item,ind){
            let obj = Object.assign({},tempList[ind]);
            delete obj.npsp__General_Accounting_Unit__r;
            if(obj.npsp__Campaign__c) delete obj.npsp__Campaign__c;
            if(obj.Id.length)
            delete obj.Id;
            tempList[ind]=obj;
        });
        if(this.totalAmount > this.campaignDetail.Available_Amount__c){
            this.loadedSpinner =true;
            const event = new ShowToastEvent({
                "title": "Error Occurred!",
                "variant":"error",
                "message": ' Allocated amount must be less than or equal to Available Amount!!'
            });
            this.dispatchEvent(event);
            return;
        }
        if(this.validateAllocations()){
            saveAllocation({instructionDetail:JSON.stringify(fields),itemAllocation:JSON.stringify(tempList)}).then((result) => {
             
                this.loadedSpinner =true;
                this.opportunityId = result.Id;
                const OpenDonationEvent = new CustomEvent('opendonation', {
                    detail: { donationId: result.Id}});
                    this.dispatchEvent(OpenDonationEvent);
            
            })
            .catch(error => {
                this.disabledSave = false;
                console.log('error '+error);
                let errorMsg = error.body
                const event = new ShowToastEvent({
                    "title": "Error Occurred!",
                    "variant":"error",
                    "message": error.body.message+' !'
                });
                this.dispatchEvent(event);
                this.loadedSpinner = true;
            });
        }else{
            this.loadedSpinner =true;
            const event = new ShowToastEvent({
                "title": "Error Occurred!",
                "variant":"error",
                "message": ' Please Enter Required Information !!'
            });
            this.dispatchEvent(event);
            console.log('Error occured');
        }
         
      }
      handleSuccess(fields){
          
      }
      handleDelete(event){
         const deleteIndex = event.detail;
         let selectedItem = this.itemAllocations[deleteIndex];
         let unitPrice = (selectedItem.npsp__General_Accounting_Unit__r.Price_Book_Entries__r)?selectedItem.npsp__General_Accounting_Unit__r.Price_Book_Entries__r[0].UnitPrice:3;
         selectedItem.Receipt_Note__c = '';
         selectedItem.Quantity__c = 1;
         selectedItem.UnitPrice = unitPrice;
         selectedItem.npsp__Amount__c = parseFloat(selectedItem.Quantity__c * unitPrice);
         selectedItem.specialInstructions = {};
         this.itemAllocations.splice(deleteIndex,1);
      }
      handleItemChange(event){
          const updateIndex = event.detail.index;
          const changeItem = event.detail.change;
          this.itemAllocations[updateIndex] = changeItem;
          if(this.showFundTransfer){
              for(let i=0;i<this.itemAllocations.length;i++)
              if(i != updateIndex){
                  let obj = JSON.parse(JSON.stringify(this.itemAllocations[i]));
                  obj.UnitPrice = changeItem.UnitPrice;
                  obj.npsp__Amount__c = changeItem.npsp__Amount__c;
                  this.itemAllocations[i] = obj;
              }
          }
          if(changeItem.Orphan__c){
              this.selectedOrphan.push(changeItem.Orphan__c);
          }
          
      }
      validateAllocations(){
          let flag = true;
          let allocationItems = this.template.querySelectorAll('c-donation-item');
          if(allocationItems.length >0)
              allocationItems.forEach(item=>{
                  if(item.validationCheck()){
                      flag = false;
                  }else{
                      item.className= '';
                  }
              });
              return flag;
      }
      
     
      handleCancel(event){
          this.showCancelConfirm= true;
  
      }
      handleCancelYes(event){
          const cancelDonation = new CustomEvent('cancel');
          this.dispatchEvent(cancelDonation);
      }
      handleCancelNo(event){
          this.showCancelConfirm= false;
      }
      
     
}