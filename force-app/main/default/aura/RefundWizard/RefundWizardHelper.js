({
    fetchPayments : function (component, event, helper)
	{	
		//alert(':---BEFORE');
		var action = component.get('c.getDonationPayments');
		var recordId = component.get('v.recordId');

		action.setParams({donationId: recordId}); 
		action.setBackground();

		action.setCallback(this, $A.getCallback(function (response) {
			var state = response.getState();
			console.log(state);
            if (state === "SUCCESS") {
				var result = response.getReturnValue();
                component.set('v.donationWrapper', result);

			}else if (state === "ERROR") {
                var errors = response.getError();
				helper.handleException(errors, helper);
			}

			helper.toggleSpinner(component, false);
        }));
        $A.enqueueAction(action);
	},
    fetchReasons : function (component, event, helper)
	{	
		//alert(':---BEFORE');
		var action = component.get('c.getPickListValuesIntoList');

        action.setParams({objectType: 'npe01__OppPayment__c',selectedField: 'Reason_for_Refund__c'});

		action.setCallback(this, $A.getCallback(function (response) {
			var state = response.getState();
			console.log(state);
            if (state === "SUCCESS") {
				var result = response.getReturnValue();
                console.log(JSON.stringify(result));
                component.set('v.refundReasonOptions', result);
                console.log('****'+component.get("v.refundReasonOptions"));

			}else if (state === "ERROR") {
                var errors = response.getError();
				helper.handleException(errors, helper);
			}

			helper.toggleSpinner(component, false);
        }));
        $A.enqueueAction(action);
	},

	calculateRefundAmount : function(component, event, helper)
	{
		var rows = component.get('v.donationWrapper.refunds');
		
		var amount = 0.00;
		
		if(!$A.util.isEmpty(rows) && rows.length > 0)
		{
			for(var i = 0; i < rows.length; i++)
			{				
				if(rows[i].checked == true)
				{
					amount += parseFloat(rows[i].refundAmount);
				}				
			}
        }
        
		component.set('v.refundAmount', amount);
	},

	validateRefund : function(component, event, helper) {	

		var wrapper = component.get('v.donationWrapper');
		
		var refundAmount = component.get('v.refundAmount');
   
		var allValid = true;
        if(component.get('v.wizardStep') =='1'){
            if($A.util.isEmpty(wrapper.refundType))
            {
                allValid = false;
                component.find('refundMethodSelection').showHelpMessageIfInvalid(); 
            }
            else if(wrapper.refundType == 'Card Payment')
            {
                var refundMethodError;
                
                if(!$A.util.isEmpty(wrapper.refunds) && wrapper.refunds.length > 0)
                {
                    for(var i = 0; i < wrapper.refunds.length; i++)
                    {				
                        if(wrapper.refunds[i].checked == true && $A.util.isEmpty(wrapper.refunds[i].payment.Card_Payment_History__c))
                        {
                            allValid = false;
                            refundMethodError = 'Please select a payment record with card payment history to refund.';
                        }
                    }
                }
                
                component.find('refundMethodSelection').setCustomValidity(refundMethodError);
                component.find('refundMethodSelection').reportValidity();
            }
        }
        //Wizard with step2
        else{
                let totalAllocationAmount = 0.00;
                let allocateRefundFieldsValid = true;
            if(component.find('allocateRefundField').length){
                 allocateRefundFieldsValid = component.find('allocateRefundField').reduce(function (validSoFar, inputCmp){
                    inputCmp.reportValidity();
                    totalAllocationAmount = totalAllocationAmount + parseFloat(inputCmp.get('v.value'));
                    return validSoFar && inputCmp.checkValidity();
                }, true);
            }
            else{
                totalAllocationAmount = parseFloat(component.find('allocateRefundField').get('v.value'));
            }
            /*If totalAmount is Allocated, Ignore other allocaations*/
            
            if(totalAllocationAmount == refundAmount)
                allocateRefundFieldsValid = true;       
                
            if(!allocateRefundFieldsValid || totalAllocationAmount != refundAmount){
                allValid = false;
                if(totalAllocationAmount != refundAmount)
                    this.fireErrorMessage('Please adjusted allocations to Refund Amount');
                
                
            }
            
        }

        
        if($A.util.isEmpty(refundAmount) || refundAmount <= 0 || component.get('v.refundReason') == '' || component.get('v.giftAidPrecludedValue') == '') 
        {
            allValid = false;
        }
		component.set('v.refundButtonDisabled', !allValid);

		return allValid;
	},
    validateTransactionId : function(component, event, helper) {	

		var wrapper = component.get('v.donationWrapper');
		
		var transactionId = component.get('v.transactionId');
        
        component.find('TransactionId').setCustomValidity("");
        component.find('TransactionId').reportValidity();
		var allValid = true;
        if(component.get('v.wizardStep') =='1') {
            
                var transactionIdError;
                
                if(!$A.util.isEmpty(wrapper.refunds) && wrapper.refunds.length > 0) {
                    
                    for(var i = 0; i < wrapper.refunds.length; i++) { 
                        
                        if(wrapper.refunds[i].checked == true && wrapper.refunds[i].refundPaid == true && transactionId === "") {
                            
                            allValid = false;
                            transactionIdError = 'Please enter the Transaction Id.';
                        }
                    }
                    
                    if (allValid == false) {
                        
                        component.find('TransactionId').setCustomValidity(transactionIdError);
                		component.find('TransactionId').reportValidity();
                    }
                    
                }
        }
		component.set('v.refundButtonDisabled', !allValid);
	
		return allValid;
	},
     validateReason: function(component, event, helper) {	

		var wrapper = component.get('v.donationWrapper');
		
		var reasonRefund = component.get('v.refundReason');

        component.find('refundReasonSelection').setCustomValidity("");
        component.find('refundReasonSelection').reportValidity();
        var reasonError;
		var allValid = true;
        if(component.get('v.wizardStep') =='1') {
                
                if(!$A.util.isEmpty(wrapper.refunds) && wrapper.refunds.length > 0) {
                    
                    for(var i = 0; i < wrapper.refunds.length; i++) { 
                        
                        if(wrapper.refunds[i].checked == true && reasonRefund === "") {
                            
                            allValid = false;
                            reasonError = 'Please select the Reason for Refund.';
                        }
                    }
                    
                    if (allValid == false) {
                        
                        component.find('refundReasonSelection').setCustomValidity(reasonError);
                		component.find('refundReasonSelection').reportValidity();
                    }
                    
                }
        }
		component.set('v.refundButtonDisabled', !allValid);
	
		return allValid;
	},
    validategiftAidPrecluded: function(component, event, helper) {	

		var wrapper = component.get('v.donationWrapper');
		
		var giftAidPrecluded = component.get('v.giftAidPrecludedValue');

        component.find('refundReasonSelection').setCustomValidity("");
        component.find('refundReasonSelection').reportValidity();
		var allValid = true;
        var giftAidPrecludedError;
        if(component.get('v.wizardStep') =='1') {
                
                if(!$A.util.isEmpty(wrapper.refunds) && wrapper.refunds.length > 0) {
                    
                    for(var i = 0; i < wrapper.refunds.length; i++) { 
                        
                        if(wrapper.refunds[i].checked == true && giftAidPrecluded === "") {
                            
                            allValid = false;
                            giftAidPrecludedError = 'Please select Gift Aid Precluded.';
                        }
                    }
                    
                    if (allValid == false) {
                        
                        component.find('refundReasonSelection').setCustomValidity(giftAidPrecludedError);
                		component.find('refundReasonSelection').reportValidity();
                    }
                    
                }
        }
		component.set('v.refundButtonDisabled', !allValid);
	
		return allValid;
	},

	doRefund : function(component, event, helper) {
		helper.toggleSpinner(component, true);
		var donationWrapper = component.get('v.donationWrapper');
        var transacId = component.get('v.transactionId');
		var refundReason = component.get('v.refundReason');
        var giftAidPrecludedVal = component.get('v.giftAidPrecludedValue');
		var action = component.get('c.insertRefunds');
		
        action.setParams({donationWrapperIn: donationWrapper,transactionId: transacId,refundReason: refundReason,giftAidPrecluded: giftAidPrecludedVal}); 

		action.setCallback(this, $A.getCallback(function (response) {
			var state = response.getState();
			console.log(state);
            if (state === "SUCCESS") {
				var results = response.getReturnValue();
				var resultList = [];
				if(results.hasError == true){
					helper.fireErrorMessage(results.errorMessage);
				}
				
				if(!$A.util.isEmpty(results.paymentsList) && results.paymentsList.length > 0)
				{                    
					if(results.paymentsList.length == 1)
					{
                        if(results.hasError == true){
                            helper.fireErrorMessage(results.errorMessage);
                        }else{
						   //helper.navigateToRecord(component, 'npe01__OppPayment__c', results.paymentsList[0].Id);
						    var record = results.paymentsList[0];
							
							record.paymentLink = '/'+record.Id;	
							record.oppLink = '/'+record.npe01__Opportunity__c;
							record.oppName = record.npe01__Opportunity__r.Name;
		
							resultList.push(record);
            
                            component.set('v.results', resultList); 
            
                            component.set('v.wizardStep', '3');
                        }
					}
					else if(results.paymentsList.length > 1)
					{
						
						for(var i = 0; i < results.paymentsList.length; i++)
						{
							var record = results.paymentsList[i];
							
							record.paymentLink = '/'+record.Id;	
							record.oppLink = '/'+record.npe01__Opportunity__c;
							record.oppName = record.npe01__Opportunity__r.Name;
		
							resultList.push(record);
						}
		
						component.set('v.results', resultList);
		
						component.set('v.wizardStep', '3');

                        if(results.hasError == true){
                            helper.fireErrorMessage(results.errorMessage);
                        }
					}
				}
				
			}
			else if (state === "ERROR") {
                var errors = response.getError();
				helper.handleException(errors, helper);
			}
			helper.toggleSpinner(component, false);
        }));
        $A.enqueueAction(action);
    }, 
    
    handleException : function(errors, helper)
	{
		console.log(errors);

		for(var i = 0; i < errors.length; i++)
		{
			if(!$A.util.isEmpty(errors[i].message))
			{
				helper.fireErrorMessage(errors[i].exceptionType + ' - ' + errors[i].message + ' - ' + errors[i].stackTrace);
			}
			else if(!$A.util.isEmpty(errors[i].pageErrors) && errors[i].pageErrors.length > 0)
			{
				for(var j = 0; j < errors[i].pageErrors.length; j++)
				{
					helper.fireErrorMessage(errors[i].pageErrors[j].message);
				}						
			}
			else if(!$A.util.isEmpty(errors[i].fieldErrors))
			{
				var errorText = '';
				
				for(var key in errors[i].fieldErrors) 
				{
					for(var j = 0; j < errors[i].fieldErrors[key].length; j++)
					{
						helper.fireErrorMessage(errorText += errors[i].fieldErrors[key][j].message);
					}					
				}				
			}
		}
	},

	fireErrorMessage : function(message)
	{
        debugger;;
		var toastEvent = $A.get("e.force:showToast");

		toastEvent.setParams({
			"type" : "error",
			"title": "Error!",
			"message": message,
			"mode": "sticky"
		});

		toastEvent.fire();
	},
	
	toggleSpinner : function (component, show)
    {
        var spinner = component.find("loadingSpinner");

        if(show)
        {
            $A.util.removeClass(spinner, "slds-hide");
        }
        else
        {
            $A.util.addClass(spinner, "slds-hide");
        }        
	},
	
	navigateToRecord : function(component, objectAPI, pRecordId)
    {		
		var navService = component.find("navService");
		var pageReference = {
            type: 'standard__recordPage',
            attributes: {
				recordId: pRecordId,
                objectApiName: objectAPI,
                actionName: 'view'
            }
        };
        navService.navigate(pageReference);
	},
})