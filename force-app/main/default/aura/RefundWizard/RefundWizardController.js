({
    init : function(component, event, helper) {
        var options = [
            { value: 'Cash', label: 'Cash' },
            { value: 'Cheque', label: 'Cheque' },
            { value: 'Card Payment', label: 'Card Payment' },
            { value: 'Direct Debit', label: 'Direct Debit' },
            { value: 'Bank Transfer', label: 'Bank Transfer' },
            { value: 'Facebook Giving', label: 'Facebook Giving' },
            { value: 'JustGiving', label: 'JustGiving' }
        ];
        component.set("v.refundTypeOptions", options);
        
        var giftAidOptions = [
            { value: 'Yes', label: 'Yes' },
            { value: 'No', label: 'No' }
        ];
        component.set("v.giftAidPrecludedOptions", giftAidOptions);
       
        component.set('v.resultsColumns', [            
            {label: 'Opportunity', fieldName: 'oppLink', type: 'url', typeAttributes: {label: { fieldName: 'oppName' }, target: '_blank'}},
			{label: 'Refund Record', fieldName: 'paymentLink', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Refund Amount', fieldName: 'npe01__Payment_Amount__c', type: 'text', wrapText: true}
		]);
		helper.fetchReasons(component, event, helper);		
		helper.fetchPayments(component, event, helper);		
        
        console.log('****'+component.get("v.refundReasonOptions"));
        
    },
    giftAidPrecludedChanged : function(component, event, helper)
    {   
       helper.validateRefund(component, event, helper);
    },
    refundReasonChanged : function(component, event, helper)
    {   
       helper.validateRefund(component, event, helper);
    },

    refundMethodChanged : function(component, event, helper)
    {
        helper.validateRefund(component, event, helper);
        
        if (component.find('refundMethodSelection').get('v.value') == 'Card Payment') {
            
            component.set("v.refundPaidDisabled", true);
        }
        else {
            component.set("v.refundPaidDisabled", false);
        }
    },

    refundAmountChanged : function(component, event, helper)
	{        
        helper.calculateRefundAmount(component, event, helper);
        helper.validateRefund(component, event, helper);
    },
    
    paymentSelected : function(component, event, helper)
	{        
        helper.calculateRefundAmount(component, event, helper);   
        helper.validateRefund(component, event, helper);
    },
    
    onRefundClick : function(component, event, helper){
		var isValid = helper.validateRefund(component, event, helper);

		if(isValid)
		{
			helper.doRefund(component, event, helper);
		}
	},

    nextStep : function(component, event, helper){
		var isValid = helper.validateRefund(component, event, helper);
    	var isValidTrans = helper.validateTransactionId(component, event, helper);  
		var isReasonEntered = helper.validateReason(component, event, helper);       

        if(isValid && isValidTrans && isReasonEntered) {
            component.set('v.wizardStep', '2');
        }
        
	},
    backStep : function(component, event, helper){

        component.set('v.wizardStep', '1');
	},

    allocateRefundAmountChanged : function(component, event, helper){
		component.set('v.refundButtonDisabled',false);
        component.set('v.wizardStep', '2');
	},
    navigateToPaymentRecord: function(component, event, helper){
        let results = component.get("v.results");
        helper.navigateToRecord(component, 'npe01__OppPayment__c', results[0].Id);

    },
    transactionChanged: function(component, event, helper){
    
        helper.validateTransactionId(component, event, helper);  

    },
    refundPaidChanged: function(component, event, helper) {
       var isValid = helper.validateRefund(component, event, helper);
    	var isValidTrans = helper.validateTransactionId(component, event, helper);  
		var isReasonEntered = helper.validateReason(component, event, helper);  
    }
    
})