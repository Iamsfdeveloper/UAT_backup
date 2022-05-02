/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 04-07-2022
 * @last modified by  : Iamsfdeveloper
**/
({
	init : function(component, event, helper) {
		helper.getOpportunityDetails(component, helper);
        var timezone = $A.get("$Locale.timezone");
        // Returns the date string in the format "2015-11-25"
        $A.localizationService.getToday(timezone, function(today){
            component.set('v.today', today);
        });
        
	},

	nextStepClicked: function(component, event, helper) {		
		helper.nextStep(component, helper);
	},	

	previousStepClicked: function(component, event, helper) {
		helper.lastStep(component);
	},

	cancelClicked: function(component, event, helper) {
		helper.cancel(component);
	},

	finishClicked: function(component, event, helper) {
		helper.cancel(component);
	},
	handleSubmit: function (component, event, helper) {

		event.preventDefault();
		var checkout = component.get("v.checkout"); 
		helper.toggleSpinner(component, true);
		var fields = event.getParam('fields');
		fields.CurrencyIsoCode = checkout.theOpportunity.CurrencyIsoCode;
		fields.npe01__Opportunity__c = component.get("v.recordId");
		fields.npe01__Paid__c = true;
        fields.npe01__Payment_Amount__c = parseFloat(checkout.amount);
        fields.npe01__Payment_Method__c = component.get("v.paymentType");
        fields.Payment_Reference__c = component.get("v.paymentType");
        fields.Status__c = 'SD';
        fields.npsp__Type__c = 'Sale';
        fields.Transaction_Type__c = 'Sale';
        component.find('cardTerminal').submit(fields);

	},
	handleSuccess: function (component, event, helper) {
		helper.toggleSpinner(component, false);
		$A.get("e.force:closeQuickAction").fire();
		$A.get("e.force:refreshView").fire();
	},
	doCancel: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
	handleDirectDebitChanged: function (component, event, helper) {
        var checkout = component.get('v.checkout');
        helper.modulusCheckDirectDebit(component, helper, checkout);
	},
    closeClicked: function(component, event, helper) {
		helper.close(component);
	},
	iframeLoaded: function(component, event, helper){
		helper.toggleSpinner(component, false);
	}
})