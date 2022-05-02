public with sharing class HA_selectOption {
    @AuraEnabled public string label {get;set;}
    @AuraEnabled public string value {get;set;}
    @AuraEnabled public string apiName {get;set;}
    @AuraEnabled public string description {get;set;}
    @AuraEnabled public Boolean defaultValue {get;set;}
    public HA_selectOption(){
        this.label = '-None-';
        this.value = '';
        this.apiName = ''; 
        this.defaultValue = false;
        this.description ='';
    }
    public HA_selectOption(String label,String value){
        this.label = label;
        this.value = value;
    }
    public HA_selectOption(String label,String value,string apiName){
        this.label = label;
        this.value = value;
        this.apiName = apiName;
    }
    public HA_selectOption(String label,String value,string apiName,Boolean defaultValue){
        this.label = label;
        this.value = value;
        this.apiName = apiName;
        this.defaultValue = defaultValue;
    }
    public HA_selectOption(String label,String value,Boolean defaultValue){
        this.label = label;
        this.value = value;
        this.defaultValue = defaultValue;
    }
}