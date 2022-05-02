/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 02-25-2022
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   11-19-2020   Iamsfdeveloper   Initial Version
**/
import { LightningElement, wire, track, api } from 'lwc';
import doInit from '@salesforce/apex/HA_newDonationController.doInit';
import getItems from '@salesforce/apex/HA_newDonationController.getItems';
import paymentSchedules from '@salesforce/apex/HA_Utility.getPaymentSchedules';
import saveAllocation from '@salesforce/apex/HA_newDonationController.saveAllocation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class NewDonation extends NavigationMixin(LightningElement) {

    /**Public Properties */
    @api
    showContactField;
    @api
    showAccountField;
    @api regionalOfficeCode;


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
    minimumDonationAmount = 0.00;
    ramadanstartDate;
    ramadanEndDate;
    @track itemList;
    @track itemAllocations = [];
    @track paymentRecordTypeId = '';
    @track recurringDonationList = [];
    get totalAmount(){
        let totalDonationAmount = 0.00;
        
        this.itemAllocations.forEach(function(item){
            totalDonationAmount += item.npsp__Amount__c
        });
        return parseFloat(totalDonationAmount).toFixed(2);
    }
    donationType ='SD';
    searchKey ='';
    queryFilter;
    __paymentScheduleId;
    donationSingleRecordTypeId ;
    stipulationOptions = [];
    stipulationType = '';
    countryList=[];
    currencyISOCode;
    selectedCountry ='';
    today;
    unAllocatedAmount=0.00;
    __campaignId;
    showSchedule=false;
    loadedSpinner = true;
    donationStartDate;
    showRecurringDonationType = false;
    showNumberOfInstallments = false;
    showNightSettings = false;
    startDateOptions =[];
    hideXFactor = false;
    disabledSave = true;

    /* xFactor Multiplies Specific Day with selected value */
    @track xFactor_1 = {label:'27th Night',helpText:'Multiple Donation on 27th Night',value:0};
    @track xFactor_2 = {label:'Odd Night',helpText:'Multiple Donation on Odd Nights',value:0};
    @track startDateObj = {label:'Ramadhan Start Date',helpText:'Crescent Moon Sightning'};
    
    xFactor1Options = [...this.generateXFactorOptions()];
    xFactor2Options = [...this.generateXFactorOptions()];

    startDate;
    get disabledSaveBtn(){
         return this.disabledSave;
    }
    @api 
    get paymentScheduleId(){
        return this.__paymentScheduleId;
    }
    set paymentScheduleId(value){
        this.__paymentScheduleId = value;
        this.__campaignId = '';
    }
    @api 
    get recordId(){
        return this.__recordId;
    }
    set recordId(value){
        if(value.startsWith('003')){
            this.__recordId = value;
            this.contactId = value;
        }else if(value.startsWith('001')){
            this.__recordId = value;
            this.accountId = value;
        }else{
            this.__recordId = value;
            this.opportunityId = value;
        }
    }
   
   
   @api 
   get campaignId(){
       return this.__campaignId;
   }
   set campaignId(value){
       if(value != null){
            this.__campaignId = value;
       
    }
   }
   
   handleCampaignChange(event){
      let campaignId =  event.detail.value[0];
      this.__campaignId = (campaignId !=undefined)?campaignId:'';
   }
   handleCloseDateChange(event){
       let closeDate = event.detail.value;
       console.log('closeDate '+closeDate);
    if(this.template.querySelector("lightning-input-field[data-id=Effective_Date__c]")){
            let eDate = new Date(closeDate);
             eDate.setDate(eDate.getDate()+1);
            this.template.querySelector("lightning-input-field[data-id=Effective_Date__c]").value = this.formatDate(eDate);
        }
    
   }   
    renderedCallback(){
       if(this.__initRender)return;
       this.__initRender = true;
        let campaignField = this.template.querySelector("lightning-input-field[data-id=CampaignId]");
        if(!this.__initRender && campaignField !=  null && this.__campaignId != undefined){
            
            campaignField.value = this.__campaignId;
            this.template.querySelector("lightning-input-field[data-id=Medium__c]").value='Telephone';
            
            
        }
        
        if(this.template.querySelector("lightning-input-field[data-id=CloseDate]")){
            let d = new Date(Date.parse(this.today));
            this.template.querySelector("lightning-input-field[data-id=CloseDate]").value=this.formatDate(d);
            if(this.template.querySelector("lightning-input-field[data-id=Effective_Date__c]")){
                let eDate = new Date(Date.parse(this.today));
                 eDate.setDate(d.getDate()+1);
                this.template.querySelector("lightning-input-field[data-id=Effective_Date__c]").value = this.formatDate(eDate);
            }
        }
        if (this.__paymentScheduleId != undefined && this.paymentSchedulesMap.data[this.__paymentScheduleId].Code__c == 'EMI' && this.template.querySelector("lightning-input-field[data-id=Recurring_Type__c]")) {
            this.template.querySelector("lightning-input-field[data-id=Recurring_Type__c]").value = 'Fixed';
            this.showNumberOfInstallments = true;
            this.showNightSettings = false;
          }else if (this.__paymentScheduleId != undefined && this.template.querySelector("lightning-input-field[data-id=Number_of_Installments__c]") && (this.paymentSchedulesMap.data[this.__paymentScheduleId].Code__c == '10N' || this.paymentSchedulesMap.data[this.__paymentScheduleId].Code__c == '30N')) {
            this.xFactor_1 ={label:'27th Night',helpText:'Multiple Donation on 27th Night',value:0};
            this.xFactor_2={label:'Odd Night',helpText:'Multiple Donation on Odd Nights',value:0};
            this.template.querySelector("lightning-input-field[data-id=Recurring_Type__c]").value ='Fixed';
            this.template.querySelector("lightning-input-field[data-id=Number_of_Installments__c]").value =this.numberofDonations;
        } else if (this.__paymentScheduleId != undefined && this.template.querySelector("lightning-input-field[data-id=Number_of_Installments__c]") && this.paymentSchedulesMap.data[this.__paymentScheduleId].Code__c == '10D' ) {
            this.xFactor_1 ={label:'Day of Arafat',helpText:'Multiple Donation on Day of Arafat',value:0};
            this.xFactor_2 ={label:'Eid al-Adha',helpText:'Multiple Donation on Eid al-Adha',value:0};
            this.startDateObj ={label:'Dhul-Hijjah Start Date',helpText:'Crescent Moon Sightning'};
            this.template.querySelector("lightning-input-field[data-id=Recurring_Type__c]").value ='Fixed';
            this.template.querySelector("lightning-input-field[data-id=Number_of_Installments__c]").value =this.numberofDonations;
        } else {
            this.showNightSettings = false;
            this.showNumberOfInstallments = false;
          }
       
   }
   get showEMI(){
       return (this.__paymentScheduleId != undefined && this.paymentSchedulesMap.data[this.__paymentScheduleId].Code__c == 'EMI');
   }
    get EMIAmt(){
    if (this.showEMI && this.template.querySelector("lightning-input-field[data-id=Number_of_Installments__c]")){
        return this.roundNumber(this.totalAmount / this.template.querySelector("lightning-input-field[data-id=Number_of_Installments__c]").value,1);
    }
    return 0.00;
        
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
   get _xMultiplyFactorValue_1(){
    return this.xFactor_1.value;
    
   }
   get _xMultiplyFactorValue_2(){
    return this.xFactor_2.value;  
   }
   get _xDivideFactorValue_1(){
    return (this.xFactor_1.value)?parseInt(this.xFactor_1.value-1):0;
}
get _xDivideFactorValue_2(){
    return (this.xFactor_2.value)?parseInt(this.xFactor_2.value-1):0;  
}
  
   
   handleXFactorChange(event){
       if(event.target.name=='xFactor_1')
       this.xFactor_1.value = parseInt(event.detail.value,10);
       else
       this.xFactor_2.value = parseInt(event.detail.value,10);
   this.generateRecurringDonations();
    
   }
   get oddNights(){
       let oddDates=[];
       if(this._xMultiplyFactorValue_2>1){
        let _10NStartDate = new Date(this.startDate);
        _10NStartDate.setDate(_10NStartDate.getDate()+20);
        let _10NEndDate =  new Date(this.startDate);
        _10NEndDate.setDate(_10NEndDate.getDate()+30);
        for(let x=0;x<10;x++){
        let startDate =  new Date(_10NStartDate);
        startDate.setDate(startDate.getDate()+x);
            if(x%2==0 && startDate >= new Date(this.today)){
                oddDates.push(Date.parse(startDate));
            }
        }
       }
       return oddDates;
   }
   get _27Night(){
    let _27nights=[];
    if(this.DonationCode =='30N' || this.DonationCode =='10N'){
        let startDate =  new Date(this.startDate);
        startDate.setDate(startDate.getDate()+26);
        _27nights.push(Date.parse(startDate));
    }
    return _27nights;
}
   get numberofDonations(){
       if(this.DonationCode =='30N'){
        if(new Date(this.today)>new Date(this.startDate))
         return parseInt(30-this.getDaysDiff(new Date(this.startDate),new Date(this.today)));
         
         return 30;
       }
       else if(this.DonationCode =='10N'){
        let endDate = new Date(this.startDate);
        endDate.setDate(endDate.getDate()+30);

        let days = this.getDaysDiff(endDate,new Date(this.today));

        return (days>10)?10:days;
       }else if(this.DonationCode =='10D'){
            let endDate = new Date(this.startDate);
            endDate.setDate(endDate.getDate()+9);
            let days = this.getDaysDiff(endDate,new Date(this.today));
            return (days>10)?10:days;
       }else{
           return 0;
       }
    
   }
   generateRecurringDonations(){
        let today= new Date(this.today);
        let donationStartDate = today;
        let numberofDonations = this.numberofDonations;
        this.recurringDonationList = [];
        this.disabledSave = false;
        this.minimumDonationAmount = 0.00;
        //Manually Manage Donations
        //if(this.hideXFactor)
        this.unAllocatedAmount = this.totalAmount;
        //GenerateRecurringDonations upon changes 
        if(this.itemAllocations.length > 0 && parseInt(this.totalAmount/numberofDonations)>=1){ 
            /**
             * xFactor_1 => 27thNight 
             * xFactor_2 => oddNights
             */
            if(this.DonationCode == '10N' || this.DonationCode == '30N'){
             //default donation Counter 
             let donationCount = 1;
             //temporary List
             let recurringDonationList = [];
             let totalAmount = parseFloat(this.totalAmount);
             let ramadanstartDate = new Date(this.startDate);
             let ramadanEndDate = new Date(this.startDate);
                 ramadanEndDate.setDate(ramadanEndDate.getDate()+30);
              this.ramadanstartDate =ramadanstartDate;
              this.ramadanEndDate = ramadanEndDate;
              
             let tenNightStartDate  = new Date(this.startDate);
                tenNightStartDate.setDate(tenNightStartDate.getDate()+20);
            if(this.DonationCode =='10N'){
                donationCount = (numberofDonations == 10)?21:parseInt(1+30-numberofDonations);
                if(today<tenNightStartDate)
                donationStartDate = new Date(tenNightStartDate);
                
            }else if(this.DonationCode =='30N'){
                donationCount = (numberofDonations == 30)?1:parseInt(1+30-numberofDonations);
                if(today<ramadanstartDate)
                donationStartDate = new Date(ramadanstartDate);
            }
            this.donationStartDate = donationStartDate;
            let oddDate = this.oddNights;
            let _27Night = this._27Night;
            let _27MultFactor = this._xMultiplyFactorValue_1;
            let _27NightDivFactor = this._xDivideFactorValue_1;

            let _OddMulNightFactor = this._xMultiplyFactorValue_2;
            let _oddNightDivFactor = this._xDivideFactorValue_2;
            let oddNightslength = oddDate.length;
            if(_27MultFactor>1&& new Date(_27Night[0])<today)
            _27NightDivFactor = 0;
            //Reducing 27thNight, if both factors are selected , 27th Night Prefernce wins precedence 
            if(_27NightDivFactor>1 && _OddMulNightFactor>1){
               // _27NightDivFactor  =  _27NightDivFactor * _27MultFactor;
               oddNightslength = oddNightslength - 1;
            }
            _oddNightDivFactor = (this._xDivideFactorValue_2)?parseInt((oddNightslength *_oddNightDivFactor),10):this._xDivideFactorValue_2;
            
            if(_27MultFactor>1&& new Date(_27Night[0])<today)
            _27NightDivFactor = 0;

            let numberofDonations_divisor= parseInt(numberofDonations+_27NightDivFactor+_oddNightDivFactor);
           
            let donationAmount = parseFloat(totalAmount/numberofDonations_divisor).toFixed(2);
            this.minimumDonationAmount = donationAmount;
            
            let allocatedDonationAmount = 0.00;
            for(let x = 0;x<numberofDonations;x++){
                let desc = 'Night-'+parseInt(donationCount+x);
                let closeDate = new Date(donationStartDate);
                closeDate.setDate(closeDate.getDate()+x);
                let amount = parseFloat(donationAmount).toFixed(2);
                if(oddDate.includes(Date.parse(closeDate)) && _OddMulNightFactor>1)
                    amount = parseFloat(donationAmount * _OddMulNightFactor).toFixed(2);
                if(_27Night.includes(Date.parse(closeDate)) && _27MultFactor >1)
                    amount = parseFloat(donationAmount * _27MultFactor).toFixed(2);
                if(x==numberofDonations-1)
                    amount =parseFloat(totalAmount - allocatedDonationAmount).toFixed(2);
                    recurringDonationList.push({
                        Payment_Reference__c:'donation-'+x,
                        npe01__Payment_Date__c:this.formatDate(closeDate),
                        npe01__Payment_Amount__c:amount,
                        Contact__c:this.contactId,
                        Payment_Description__c:desc

                    });
                allocatedDonationAmount=  parseFloat(allocatedDonationAmount) + parseFloat(amount);
            }
            
            this.recurringDonationList = [...recurringDonationList];
         }else if(this.DonationCode == '10D'){
            let endDate  = new Date(this.startDate);
           
            if(today<new Date(this.startDate)){
                donationStartDate = new Date(this.startDate);
                endDate.setDate(endDate.getDate() + 9);
            }else{
                donationStartDate.setDate(donationStartDate.getDate() + 1);
                endDate.setDate(endDate.getDate() + 10);
            }

            this.donationStartDate = donationStartDate;

            let _9Day = new Date(endDate);
            _9Day.setDate(_9Day.getDate() - 1);
            let _10Day = new Date(endDate);
            let numberofDonations_divisor= parseInt(numberofDonations+this._xDivideFactorValue_1+this._xDivideFactorValue_2);
           
            let donationAmount = parseFloat(totalAmount/numberofDonations_divisor).toFixed(2);
            let allocatedDonationAmount = 0.00;
            for(let x = 0;x<numberofDonations;x++){
                let desc = 'Day-'+parseInt(donationCount+x);
                let closeDate = new Date(donationStartDate);
                closeDate.setDate(closeDate.getDate()+x);
                let amount = parseFloat(donationAmount).toFixed(2);;
                if(Date.parse(_10Day)==Date.parse(closeDate) && this._xMultiplyFactorValue_2 >0)
                    amount = parseFloat(donationAmount * this._xMultiplyFactorValue_2).toFixed(2);
                if(Date.parse(_9Day) == Date.parse(closeDate) && this._xMultiplyFactorValue_1 >0)
                    amount = parseFloat(donationAmount * this._xMultiplyFactorValue_1).toFixed(2);
                    recurringDonationList.push({
                        Payment_Reference__c:'donation-'+x,
                        npe01__Payment_Date__c:this.formatDate(closeDate),
                        npe01__Payment_Amount__c:amount,
                        Contact__c:this.contactId,
                        Payment_Description__c:desc

                    });
                allocatedDonationAmount=  parseFloat(allocatedDonationAmount) + parseFloat(amount);
            }
            
            this.recurringDonationList = [...recurringDonationList];
         }
     }
       
   }
   toggleShowDonationSchedule(){
        this.showSchedule = (!this.showSchedule)?true:false;
        this.generateRecurringDonations();
   }
   updateDonationSchedule(){
       console.log(this.recurringDonationList);
   }
    @wire(doInit,{regOfficeCode:'$regionalOfficeCode'})
    paymentType({error,data}){
        if(data){
            this.donationSingleRecordTypeId = data['single']; 
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
            console.log('***this.currencyISOCode***'+this.currencyISOCode );
            this.today = data['today']
            this.queryFilter = '';
            this.__campaignId = '';
        }
        console.log('error--'+JSON.stringify(error));
    };
    @wire(paymentSchedules)
    paymentSchedulesMap;

    get DonationCode(){
       return (this.__paymentScheduleId != undefined && this.paymentSchedulesMap != undefined)? this.paymentSchedulesMap.data[this.__paymentScheduleId].Code__c:'SD';
    }
    set DonationCode(value){
        if(this.paymentSchedulesMap.data != undefined)
        this.donationCode = this.paymentSchedulesMap.data[value].Code__c;
    }
    @wire(getItems,{queryFilter:'$queryFilter',currencyISOCode:'$currencyISOCode',paymentScheduleId:'$__paymentScheduleId',campaignId:'$__campaignId',regOfficeCode:'$regionalOfficeCode'})
    buildItems({error,data}){
        if(data){
            let items = data['items'];
            let campaignItemPrice = data['campaignItemPrice'];
            let tempDataList = [];
            let selectedList = this.itemAllocations;
            let paymentSchedulesMap = this.paymentSchedulesMap;
            let __paymentScheduleId = this.__paymentScheduleId;
            let donationCode = paymentSchedulesMap.data[__paymentScheduleId].Code__c;
            items.forEach(item=>{
                
                    let tempObj = Object.assign({},item);
                    let unitPrice = (tempObj.Price_Book_Entries__r)?(paymentSchedulesMap.data[__paymentScheduleId].Frequency__c =='Yearly')?tempObj.Price_Book_Entries__r[0].Annual_Price__c:tempObj.Price_Book_Entries__r[0].UnitPrice:(campaignItemPrice != undefined && campaignItemPrice[item.Id] != undefined)?campaignItemPrice[item.Id]:1;
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
    getDaysDiff(sourceDate,targetDate){
    let diffTime;
    diffTime =  Math.abs(targetDate - sourceDate);
    let diffDays =  Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
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
            this.itemAllocations.push(selectedItem);
        }
        if(this.itemAllocations.length)
            this.disabledSave =  false;
    }
    get disabledAddBtn(){
        return (this.itemAllocations.length == 50);
           
    }
    handleStartDateChange(event){
        this.startDate = event.detail.value;
        this.recurringDonationList = [];
        this.generateRecurringDonations();
    }
    handleChange(event){
        let searchFilters  = this.template.querySelectorAll(".searchFilter");
        let queryFilters = [];
        searchFilters.forEach(item=>{
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
        }else if(item.fieldName !='Payment_Schedule__c'){
                queryFilters.push(item.fieldName+'=\''+item.value+'\'');
        }
        });
        this.currencyISOCode = this.template.querySelector("lightning-input-field[data-id=CurrencyIsoCode]").value;
        this.queryFilter = queryFilters.join(' AND ');
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
                }else if(item.fieldName !='Payment_Schedule__c'){
                    queryFilters.push(item.fieldName+'=\''+item.value+'\'');
                }
        });
            this.searchKey = event.target.value;
            let queryFilter = queryFilters.join(' AND ');
            this.queryFilter = queryFilter + 'AND ( Name like \'%'+this.searchKey+'%\' OR  Donation_Item_Code__c Like \'%'+this.searchKey+'%\')';
            this.currencyISOCode = this.template.querySelector("lightning-input-field[data-id=CurrencyIsoCode]").value;
        }else{
            this.handleChange();
        }
    }
    saveAndNext(event){
        //let this.template.querySelector('lightning-record-edit-form');
        const btn = this.template.querySelector( ".hidden" );

        if( btn ){ 
           btn.click();
        }
    }
    handleSubmit(event){
        this.loadedSpinner =false;
        
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        console.log(fields.CloseDate);
        if(fields.CloseDate == undefined)
        fields.CloseDate = this.today;
        fields.EMIAmount__c = this.EMIAmt;
        
        fields.Name='System Generated';
        fields.Amount = this.totalAmount;
        let donationCode = this.paymentSchedulesMap.data[this.__paymentScheduleId].Code__c;
        fields.StageName = 'Awaiting Payment Details';
        fields.RecordTypeId = this.donationSingleRecordTypeId;
        fields.Type=(donationCode =='SD')?'Donation':'Payment Plan - Source';

        if(donationCode =='30N' || donationCode =='10N' || donationCode =='10D'){
            //fields.XFactor_1__c = (this.xFactor_1.value)?'':this.xFactor_1.value;
            //fields.XFactor_2__c = (this.xFactor_1.value)?'':this.xFactor_2.value;
            if(this.donationStartDate != undefined)
            fields.Effective_Date__c = Date.parse(this.donationStartDate);
            if(this.itemAllocations.length == 0)
                this.generateRecurringDonations();
            if(this.minimumDonationAmount < 1){
                this.showToast('Minimum Donation Error','error','Minimum Donation Per Day 1 '+this.currencyISOCode);
                this.loadedSpinner =true;
                this.disabledSave = true;
                return;
            }
            if(new Date(this.today)>this.ramadanEndDate){
                this.disabledSave = true;
                this.loadedSpinner =true;
                this.showToast("Ramadhan Ended","error",'Donation can\'t be processed');
                return;
            }  
            if(this.hideXFactor && this.totalUnAllocatedAmount != 0.00){
                this.loadedSpinner =true;
                this.showToast("Schedule Donations Mismatch!","error",'The Unallocated Amount must be 0.00!!');
                return;
            }
        }
        fields.Donation_Type__c = this.paymentSchedulesMap.data[this.__paymentScheduleId].Code__c ;
        if(this.contactId)
        fields.npsp__Primary_Contact__c	 = this.contactId;
        if(this.accountId)
        fields.accountId = this.accountId;
        fields.Payment_Schedule__c = this.__paymentScheduleId;
        if(this.opportunityId)fields.Id = this.opportunityId;
        if(this.validateAllocations()){
            this.handleSuccess(fields)
        }else{
            this.loadedSpinner =true;
            this.showToast("Error Occurred!","error",'Please Enter Required Information !!');
        }
    }
    handleSuccess(fields){
        try{
        this.disabledSave = true;
        let tempList = Array.from(this.itemAllocations);
        let tempSpecialList = [];
        let specialInt = 0;
        this.itemAllocations.forEach(function(item,ind){
            let obj = Object.assign({},tempList[ind]);
            if(obj.specialInstructions != undefined && Object.keys(obj.specialInstructions).length != 0){
                obj.specialInstructions.specialIndex = specialInt;
                tempSpecialList.push(Object.assign({},obj.specialInstructions));
                obj.Special_Instruction_Index__c = specialInt;
                specialInt = specialInt + 1;
            }
            delete obj.npsp__General_Accounting_Unit__r;
            delete obj.specialInstructions;
            tempList[ind]=obj;

        });
        
        
        saveAllocation({opportunityDetail:JSON.stringify(fields),itemAllocation:JSON.stringify(tempList),  specialInstruction:'', recurringDonations:JSON.stringify(this.recurringDonationList),regOfficeCode:this.regionalOfficeCode}).then((result) => {
           
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
            this.showToast("Error Occurred!","error",error.body.message+' !');
            this.loadedSpinner = true;
        });
    }catch(error){
        this.disabledSave = false;
        this.showToast("Error Occurred!","error",error.body.message+' !');
        this.loadedSpinner =true;
    }
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
       this.generateRecurringDonations();
    }
    handleItemChange(event){
        const updateIndex = event.detail.index;
        const changeItem = event.detail.change;
        this.itemAllocations[updateIndex] = changeItem;
        if(changeItem.Orphan__c){
            this.selectedOrphan.push(changeItem.Orphan__c);
        }
        if(!this.hideXFactor)
          this.generateRecurringDonations();
    }
    handleDonationTypeChange(event){
        this.__paymentScheduleId = event.detail;
        this.DonationCode = event.detail;
        this.itemAllocations = [];
        this.recurringDonationList = [];
        let donationCode =this.donationCode;
        this.showRecurringDonationType = (donationCode != undefined && donationCode !='SD');
        if(donationCode =='EMI' ){
            this.showNumberOfInstallments = true;
            if(this.template.querySelector("lightning-input-field[data-id=Recurring_Type__c]"))
                this.template.querySelector("lightning-input-field[data-id=Recurring_Type__c]").value ='Fixed';
           
        }else if(donationCode =='10N' || donationCode =='30N' || donationCode =='10D'){
            this.showNightSettings = true;
            this.showNumberOfInstallments = true;
            if(this.template.querySelector("lightning-input-field[data-id=Recurring_Type__c]"))
            this.template.querySelector("lightning-input-field[data-id=Recurring_Type__c]").value ='Fixed';
           this.generateStartDates();
        }else{
            if(this.template.querySelector("lightning-input-field[data-id=Recurring_Type__c]"))
                this.template.querySelector("lightning-input-field[data-id=Recurring_Type__c]").value ='Open';
            this.showNumberOfInstallments = false;
            this.showNightSettings = false;
        }
        this.__initRender = false;
    }
    generateStartDates(){
       let paymentScheduleData =  this.paymentSchedulesMap.data[this.__paymentScheduleId];
        let Options = [];
        this.startDate = paymentScheduleData.Start_Date__c;
        if(paymentScheduleData.Start_Date__c !=undefined)
        Options.push({label:paymentScheduleData.Start_Date__c,value:paymentScheduleData.Start_Date__c});
        if(paymentScheduleData.Start_Date_2__c != undefined)
        Options.push({label:paymentScheduleData.Start_Date_2__c,value:paymentScheduleData.Start_Date_2__c});
        if(paymentScheduleData.Start_Date_3__c !=undefined)
        Options.push({label:paymentScheduleData.Start_Date_3__c,value:paymentScheduleData.Start_Date_3__c});
        this.startDateOptions =[...Options];
        return;
    }
    handleRecurringTypeChange(event){
        this.showNumberOfInstallments = (event.detail.value != 'Open');
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
    handleCloneRequest(event){
        const cloneIndex = event.detail.index;
        let selectedItem = this.itemAllocations[cloneIndex];
        let cloneItem = Object.assign({},this.itemAllocations[cloneIndex]);
        let unitPrice = (selectedItem.npsp__General_Accounting_Unit__r.Price_Book_Entries__r)?selectedItem.npsp__General_Accounting_Unit__r.Price_Book_Entries__r[0].UnitPrice:3;
        cloneItem.Receipt_Note__c = '';
        cloneItem.Quantity__c = 1;
        cloneItem.Orphan__c=undefined;
        cloneItem.UnitPrice = unitPrice;
        cloneItem.npsp__Amount__c = parseFloat(cloneItem.Quantity__c * unitPrice);
        cloneItem.specialInstructions = {};
        this.itemAllocations.push(cloneItem);
    }
    showToast(_title,_variant,_message) {
        const evt = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
        });
        this.dispatchEvent(evt);
    }
    handleCancel(event){
        this.showCancelConfirm= true;

    }
    handleCancelYes(event){
        const cancelDonation = new CustomEvent('canceldonation');
        this.dispatchEvent(cancelDonation);
    }
    handleCancelNo(event){
        this.showCancelConfirm= false;
    }
    handleManualScheduleDonations(event){
        if(event.detail.checked){
            this.xFactor_1.value = 0;
            this.xFactor_2.value = 0;
            if(this.template.querySelector("lightning-combobox[data-id=xFactor_1]")){
                this.template.querySelector("lightning-combobox[data-id=xFactor_1]").value =0;
                
            }
            if(this.template.querySelector("lightning-combobox[data-id=xFactor_2]")){
                this.template.querySelector("lightning-combobox[data-id=xFactor_2]").value =0;
               
            }
        }
        this.hideXFactor = event.detail.checked;
        this.recurringDonationList = [];
        this.unAllocatedAmount = this.totalAmount;
        this.generateRecurringDonations();
        
    }
    handleScheduleDonations(event){
            this.recurringDonationList = event.detail.donations;
            this.unAllocatedAmount = parseFloat(event.detail.totalUpdatedAmount).toFixed(2);
            this.showSchedule = false;
    }
    get totalUnAllocatedAmount(){
        let total_unAllocatedAmount = parseFloat(0.00);
        total_unAllocatedAmount= parseFloat(this.unAllocatedAmount-this.totalAmount).toFixed(2);
        if(this.unAllocatedAmount == 0.00) 
            total_unAllocatedAmount = parseFloat(0.00);
        return total_unAllocatedAmount;
    }
    generateXFactorOptions(){
        return [{label:'--None',value:0},{label:'2',value:2},{label:'3',value:3},
                {label:'4',value:4},{label:'5',value:5}];
        
    }
}