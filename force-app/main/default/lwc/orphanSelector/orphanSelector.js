/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 06-30-2021
 * @last modified by  : Iamsfdeveloper
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   01-14-2021   Iamsfdeveloper   Initial Version
**/
import { LightningElement, api, wire, track} from 'lwc';
import getOrphanByNameOrId from '@salesforce/apex/HA_newDonationController.getOrphanByNameOrId';
import getCountryList from '@salesforce/apex/HA_newDonationController.getCountryList';
import getOrphanList from '@salesforce/apex/HA_newDonationController.getOrphanList';

const columns = [
    {
        label: 'Name',
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Name' }, 
        target: '_blank'},
        sortable: true
    },
    { label: 'Age', fieldName: 'Current_Age__c', type: 'text',sortable: true },
    { label: 'Gender', fieldName: 'Gender__c', type: 'picklist' },
    { label: 'Status', fieldName: 'Sponsorship_Status__c', type: 'picklist' },
    { label: 'Country', fieldName: 'Country__c', type: 'picklist' },
    {label:'Mother Alive',fieldName:'Orphan_Is_Mother_Alive__c',type: 'picklist'}
];
export default class OrphanSelector extends LightningElement {
    @api selectedCountry;
    @api showsponsoredOrphansonly;
    @api recordId;
    @track orphanList = [];
    @track selectedRows = [];

    countryList=[];
    loaded =true;

    selected_Country='General';
    selectedAge = '';
     _recordId='';
     selectedGender = '';
    selectedStatus = '';
    columns = columns;
    query_Filter = '';
    searchParam = '';
    selectedRowIds = [];
    genderOptions =[{label:'All',value:''},{label:'Female',value:'Female'},{label:'Male',value:'Male'}];
    ageOptions =[{label:'All',value:''},{label:'0 - 5',value:'0,5'},{label:'5 - 10',value:'5,10'},{label:'>10',value:'10,50'}];
    statusOption =[{label:'All',value:''},{label:'Sponsored By HA',value:'Sponsored By HA'},{label:'Unsponsored',value:'Unsponsored'}];
    @wire(getCountryList)
    buildCountry({error,data}){
      if(data){
      let countryList = [...data];
      countryList.unshift({defaultValue: true,label:'All',value:'General'});
      this.countryList = countryList;
      }
    };
    connectedCallback(){
      if(this.showsponsoredOrphansonly){
        this._recordId= this.recordId;
        this.selectedRowIds = [...this.excludedData];
      }
    }
    @wire(getOrphanList,{selectedCountry:'$selected_Country',recordId:'$_recordId',selectedAge:'$query_Filter',selectedGender:'$selectedGender',searchParam:'$searchParam',selectedRowIds:'$selectedRowIds',selectedStatus:'$selectedStatus'})
    buildOrphanData({error,data}){
      if(data){
        let tempData = [];
      data.forEach(item=>{
        if(!this.excludedData.includes(item.Id) || this.selectrow.includes(item.Id) || this.showsponsoredOrphansonly){
            let obj = Object.assign({},item);
            obj.nameUrl = '/'+item.Id;
            tempData.push(obj);
        }
      });
      this.orphanList = tempData;
      this.selectedRows = this.selectrow;
      this.loaded = false;
    }else if(error){
      this.loaded = false;  
      console.log('OrphanSelector==getOrphanList==>'+JSON.stringify(error));
    }
  };
    handleChange(event){
    if(event.target.name=='Country')
        this.selected_Country = event.detail.value;
    else if(event.target.name=='Gender')
        this.selectedGender = event.detail.value;
    else if(event.target.name=='Age'){
        this.selectedAge = event.detail.value;
        let ageGroup = event.detail.value.split(',');
        if(ageGroup.length>1)
          this.query_Filter = ' Current_Age__c >= '+ageGroup[0]+' AND Current_Age__c <= '+ageGroup[1];
        else
        this.query_Filter = '';
        
    }
    else if(event.target.name=='Status')
        this.selectedStatus = event.detail.value;
    }
    @api excludedData;
    @api  selectrow;
    /*
    @api get selectrow(){
        return this.selectedRows;
    }
    set selectrow(value){
        this.selectedRows = [...value];
    }
    */
    getSelectedRow(event){
        if(event.detail && event.detail.selectedRows.length>0)
        this.selectedRows = [event.detail.selectedRows[0].Id];
        this.notifyParent(event);
    }
    notifyParent(event){
        this.dispatchEvent(new CustomEvent('selected',{detail:{selectedRows:this.selectedRows}}));
    }
    
    handleKeyUp(event) {
        if (event.target.value && event.target.value.length>2) 
            this.searchParam = event.target.value;
        else
            this.searchParam = '';
    }
}