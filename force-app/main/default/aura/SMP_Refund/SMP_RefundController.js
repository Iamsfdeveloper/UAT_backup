({
	init : function(component, event, helper) {
		component.set('v.historyColumns', [
			{label: 'Name', fieldName: 'linkName', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
			{label: 'Amount', fieldName: 'Amount__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, maximumSignificantDigits: 5}},
            {label: 'Type', fieldName: 'Transaction_Type__c', type: 'text'},
            {label: 'Date', fieldName: 'Transaction_Date__c', type: 'date'}
		]);

		component.set('v.resultsColumns', [
			{label: 'Transaction', fieldName: 'name', type: 'text'},
			{label: 'Refund', fieldName: 'historyLink', type: 'url', typeAttributes: {label: 'View', target: '_blank'}},
			{label: 'Status', fieldName: 'status', type: 'text'},
            {label: 'Message', fieldName: 'message', type: 'text', wrapText: true}
		]);
		
		helper.fetchIncomeCardPaymentHistory(component, event, helper);		
	},

	cardPaymentLoad : function(component, event, helper)
	{
		var recordId = component.get('v.recordId');
		var fields = event.getParam('records')[recordId].fields;		
		component.set('v.cardPaymentFields', fields);

		if(!$A.util.isEmpty(fields.Payment_Vendor__c.value))
		{
			component.set('v.paymentGateway', fields.Payment_Vendor__c.value);
		}
		else
		{
			component.set('v.refundButtonDisabled', true);
			helper.fireError("Card payment record does not have an assigned payment gateway. Unable to make refund.");
		}
	},

	refundAmountChanged : function(component, event, helper)
	{
		helper.validateRefund(component, event, helper);
	},

	historySelected : function(component, event, helper)
	{
		var selectedRows = event.getParam('selectedRows');

		component.set('v.selectedHistories', selectedRows);

		var amount = 0.00;				
		
		if(selectedRows.length > 0)
		{
			for(var i = 0; i < selectedRows.length; i++)
			{
				amount += selectedRows[i].Amount__c;
			}

			component.set('v.showRefundPanel', true);
			component.set('v.refundButtonDisabled', false);
		}
		else
		{
			component.set('v.showRefundPanel', false);
		}

		component.set('v.refundAmount', amount);
		
		if(selectedRows.length > 1)
		{
			component.set('v.refundAmountDisabled', true);
		}
		else
		{
			component.set('v.refundAmountDisabled', false);
		}
	},

	onRefundClick : function(component, event, helper){
		var isValid = helper.validateRefund(component, event, helper);

		if(isValid)
		{
			helper.doRefund(component, event, helper);
		}
	}
})