({
	init : function(component, event, helper) {
		helper.getRecurringDonationDetails(component, helper);
	},
	handleDirectDebitChanged: function (component, event, helper) {
        helper.modulusCheckDirectDebit(component, helper);
	},
	processDirectDebit: function (component, event, helper) {
        helper.createDirectDebit(component, helper);
	}
})