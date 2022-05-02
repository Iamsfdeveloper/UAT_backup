({
	getRecurringDonationDetails : function(component, helper){		
		var action = component.get("c.getRecurringDonation");

		action.setParams({ donationId: component.get("v.recordId") });
		action.setCallback(this, function(response) {

			component.set("v.recurringDonation", response.getReturnValue());
			component.set("v.paymentType", response.getReturnValue().npsp__PaymentMethod__c);

			if(component.get("v.paymentType") == 'Card Payment')
			{
				helper.getPaymentURL(component, helper);
			}
		});
		$A.enqueueAction(action);
	},
	getPaymentURL : function(component, helper){		

		var action = component.get("c.getAuthPaymentURL");

		action.setParams({ donation: component.get("v.recurringDonation") });
		action.setCallback(this, function(response) {
			console.log(response.getReturnValue());
			component.set("v.paymentURL", response.getReturnValue());

		});
		$A.enqueueAction(action);


	},
	modulusCheckDirectDebit : function (component, helper)
    {
		var directDebit = component.get('v.directDebit');

        if(!$A.util.isEmpty(directDebit.DD_Bank_Account_Number__c) && 
            !$A.util.isEmpty(directDebit.DD_Bank_Sort_Code__c) &&
            directDebit.DD_Bank_Account_Number__c.length == 8 && 
            directDebit.DD_Bank_Sort_Code__c.length == 6)
        {
            var modulusCheckDirectDebitAction = component.get('c.modulusCheckDirectDebit');
            modulusCheckDirectDebitAction.setParams({pDirectDebit : directDebit});
            modulusCheckDirectDebitAction.setBackground();

            modulusCheckDirectDebitAction.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
					var checkedDirectDebit = response.getReturnValue();
                    component.set('v.directDebit', checkedDirectDebit);

					if (checkedDirectDebit.DD_Sort_Code_OK__c == true && 
						checkedDirectDebit.DD_Account_Number_OK__c == true &&
						checkedDirectDebit.DD_Start_Date__c != null ) {

						component.set('v.disabled', false);
					
	
					}

                }
            });
            $A.enqueueAction(modulusCheckDirectDebitAction);
        }
        else
        {
            directDebit.DD_Sort_Code_OK__c = false;
			directDebit.DD_Account_Number_OK__c = false;
            directDebit.DD_OK__c = false;
            component.set('v.directDebit', directDebit);
        }        
	},
	createDirectDebit : function(component, helper) {
		helper.toggleSpinner(component, true);
		component.set('v.disabled', true);

		// component.set('v.navigationDisabled', true);
		var directDebit = component.get("v.directDebit");
		var donation =  component.get("v.recurringDonation") ;

		var action = component.get("c.saveDirectDebit");
		action.setParams({ pDirectDebit : directDebit, pDonation : donation});
		action.setCallback(this, function(response)
		{
			var state = response.getState();
			if (state === "SUCCESS")
			{
				var returnedDirectDebit = response.getReturnValue();
				component.set('v.directDebit', returnedDirectDebit);
				if(returnedDirectDebit.Id != null)
				{
					component.set('v.completed', true);
				}
			}
			else if (state === "ERROR") 
			{
				var errors = response.getError();
				helper.handleException(errors, helper);
			}

			component.set('v.disabled', false);
			helper.toggleSpinner(component, false);
			component.set('v.navigationDisabled', false);
		});

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
		var toastEvent = $A.get("e.force:showToast");

		toastEvent.setParams({
			"type" : "error",
			"title": "Error!",
			"message": message
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
    }

})