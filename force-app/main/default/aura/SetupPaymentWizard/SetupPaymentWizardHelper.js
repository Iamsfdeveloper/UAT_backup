/**
 * @description       : 
 * @author            : Iamsfdeveloper
 * @group             : 
 * @last modified on  : 04-06-2022
 * @last modified by  : Iamsfdeveloper
**/
({
	getOpportunityDetails : function(component, helper){		
		var action = component.get("c.getOpportunity");
		
		action.setParams({ opportunityId: component.get("v.recordId") });
		action.setCallback(this, function(response) {
			var state = response.getState();
			helper.toggleSpinner(component, false);
			if (state === "SUCCESS") {
				var returnedCheckout = response.getReturnValue();
				component.set("v.checkout", returnedCheckout);

				if(!$A.util.isEmpty(returnedCheckout.error))
				{
					component.set('v.wizardStep', '0');
					component.set('v.wizardError', returnedCheckout.error);
					return;
				}

				if($A.util.isEmpty(returnedCheckout.theOpportunity.npsp__Primary_Contact__c))
				{
					component.set('v.wizardStep', '0');
					component.set('v.wizardError', 'Opportunity must have a Primary Contact.');
					return;
				}

				if($A.util.isEmpty(returnedCheckout.theOpportunity.npsp__Primary_Contact__r.FirstName) || $A.util.isEmpty(returnedCheckout.theOpportunity.npsp__Primary_Contact__r.LastName)
					|| $A.util.isEmpty(returnedCheckout.theOpportunity.npsp__Primary_Contact__r.MailingPostalCode))
				{
					component.set('v.wizardStep', '0');
					component.set('v.wizardError', 'The Primary Contact is missing billing details.');
					return;
				}	
				
				helper.populatePaymentOptions(component);				
			}
			else{
				component.set('v.wizardStep', '0');
				component.set('v.wizardError', 'There was an error loading the payment wizard.');

				var errors = response.getError();
				helper.handleException(errors, helper);

				return;
			}
		});
		$A.enqueueAction(action);
	},

	populatePaymentOptions : function(component){	
		var checkout = component.get('v.checkout');
		
		var paymentTypeOptions = [];		

		if(!$A.util.isEmpty(checkout.paymentTypes) && checkout.paymentTypes.length > 0) {
			for(var i = 0; i < checkout.paymentTypes.length; i++) { 				
				paymentTypeOptions.push({value: checkout.paymentTypes[i], label: checkout.paymentTypes[i]});
			}

			if(checkout.paymentTypes.length == 1)
			{
				component.set("v.paymentType", checkout.paymentTypes[0]);
			}
		}
		
		component.set("v.paymentTypeOptions", paymentTypeOptions);	
	},
	validatePaymentForm : function (component, helper){
		component.find("cardTerminal")
	},
	modulusCheckDirectDebit : function (component, helper, checkout)
    {
        if(!$A.util.isEmpty(checkout.directDebit.DD_Bank_Account_Number__c) && 
            !$A.util.isEmpty(checkout.directDebit.DD_Bank_Sort_Code__c) &&
            checkout.directDebit.DD_Bank_Account_Number__c.length == 8 && 
            checkout.directDebit.DD_Bank_Sort_Code__c.length == 6)
        {
            var modulusCheckDirectDebitAction = component.get('c.modulusCheckDirectDebit');
            modulusCheckDirectDebitAction.setParams({pDirectDebit : checkout.directDebit});
            modulusCheckDirectDebitAction.setBackground();

            modulusCheckDirectDebitAction.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === 'SUCCESS') {
					var checkedDirectDebit = response.getReturnValue();
					checkout = component.get('v.checkout');
					checkout.directDebit = checkedDirectDebit;
                    component.set('v.checkout', checkout);
                }
            });
            $A.enqueueAction(modulusCheckDirectDebitAction);
        }
        else
        {
            checkout.directDebit.DD_Sort_Code_OK__c = false;
			checkout.directDebit.DD_Account_Number_OK__c = false;
            checkout.directDebit.DD_OK__c = false;
            component.set('v.checkout', checkout);
        }        
	},

	nextStep : function(component, helper) {
		var currentStep = component.get("v.wizardStep");

		var checkout = component.get('v.checkout');
		var paymentType = component.get('v.paymentType');

		if(currentStep == '1')
		{
			if($A.util.isEmpty(paymentType))
			{
				return;
			}
			if(paymentType == 'Card Terminal'){
                currentStep = '2';
                component.set("v.navigationDisabled",true);
            }
            else if(paymentType == 'Direct Debit')
			{
				currentStep = '2';
			}
			else if(paymentType == 'Credit/Debit Card')
			{
				if(checkout.theOpportunity.Payment_Schedule__r.Frequency__c == 'Single')
				{
					helper.generatePaymentWrapper(component, helper);
				}
				else
				{
					helper.createRecurringCard(component, helper);
				}				

				currentStep = '3';
			}
			else
			{
				//helper.createAlternativePayment(component, helper);				
				currentStep = '3';
			}
		}
		else if(currentStep == '2')
		{
			if(paymentType == 'Direct Debit')
			{
				if(checkout.directDebit.DD_Bank_Account_Name__c == '' || checkout.directDebit.DD_Bank_Account_Name__c == null|| checkout.directDebit.DD_OK__c == false || checkout.directDebit.DD_Account_Number_OK__c == false || checkout.directDebit.DD_Sort_Code_OK__c == false)
				{
					return;
				}

				helper.createDirectDebit(component, helper);				
			}
			
			
			currentStep = '3';
		}
		
		component.set("v.wizardStep", currentStep);
        
	},

	lastStep : function(component) {
		component.set('v.navigationDisabled', false);
		var currentStep = component.get("v.wizardStep");
		var paymentType = component.get('v.paymentType');

		if(currentStep == '2')
		{
			currentStep = '1';
		}
		else if(currentStep == '3')
		{
			if(paymentType == 'Direct Debit')
			{
				currentStep = '2';
			}
			else
			{
				currentStep = '1';
			}			
		}
		
	    component.set("v.wizardStep", currentStep);	
	},

	cancel : function(component) {
		clearInterval(component.get('v.pollerId'));
		$A.get("e.force:closeQuickAction").fire();
	},

	createAlternativePayment : function(component, helper) {
		helper.toggleSpinner(component, true);
		component.set('v.navigationDisabled', true);
		var checkout =  component.get("v.checkout");
		var paymentType = component.get('v.paymentType');

		var action = component.get("c.createPaymentRecord");
		action.setParams({ opportunityId : checkout.theOpportunity.Id, contactId : checkout.theOpportunity.npsp__Primary_Contact__c, pPaymentType : paymentType, pAmountToPay : checkout.amount});
		action.setCallback(this, function(response)
		{
			var state = response.getState();
			if (state === "SUCCESS")
			{
				this.navigateToRecord(component, 'npe01__OppPayment__c', response.getReturnValue())
                this.close(component);
			}
			else if (state === "ERROR") 
			{
				var errors = response.getError();
				helper.handleException(errors, helper);
				component.set("v.wizardStep", '2');				
			}

			helper.toggleSpinner(component, false);
			component.set('v.navigationDisabled', false);
		});

		$A.enqueueAction(action);	
	},

	createRecurringCard : function(component, helper) {

        helper.generatePaymentWrapper(component, helper);	
	},

	createDirectDebit : function(component, helper) {
		helper.toggleSpinner(component, true);
		component.set('v.navigationDisabled', true);
		var checkout = component.get("v.checkout");

		var action = component.get("c.saveDirectDebit");
		action.setParams({ pDirectDebit : checkout.directDebit});
		action.setCallback(this, function(response)
		{
			var state = response.getState();
			if (state === "SUCCESS")
			{
				var returnedDirectDebit = response.getReturnValue();
				checkout.directDebit = returnedDirectDebit;
				component.set('v.checkout', checkout);
			}
			else if (state === "ERROR") 
			{
				var errors = response.getError();
				helper.handleException(errors, helper);
			}

			helper.toggleSpinner(component, false);
			component.set('v.navigationDisabled', false);
		});

		$A.enqueueAction(action);
	},

	generatePaymentWrapper : function (component, helper)
	{
		helper.toggleSpinner(component, true);		
		component.set('v.navigationDisabled', true);

		var checkout = component.get("v.checkout");
		var isRepeat = checkout.theOpportunity.Payment_Schedule__r.Frequency__c == 'Single' ? false : true;
		var action = component.get("c.generateCardPaymentLink");
		action.setParams({ pOpportunity : checkout.theOpportunity, pAmountToPay : checkout.amount, pRepeatEnabled : isRepeat, pInternalPaymentDescription : checkout.internalPaymentDescription});
		action.setCallback(this, function(response)
		{
			var state = response.getState();
			if (state === "SUCCESS")
			{
				var returnedPayURL = response.getReturnValue();
				component.set('v.paymentURL', returnedPayURL);

				var timer = window.setInterval(
					$A.getCallback(function() {
						helper.pollCardPayment(component);
					}), 5000
				);

				component.set('v.pollerId', timer);

				helper.toggleSpinner(component, true);
			}
			else if (state === "ERROR") 
			{
				var errors = response.getError();
				helper.handleException(errors, helper);
				helper.toggleSpinner(component, false);
			}	
			else
			{
				helper.toggleSpinner(component, false);
			}		
			component.set('v.navigationDisabled', false);
		});

		$A.enqueueAction(action);
	},

	pollCardPayment : function(component)
	{
        
		var checkout = component.get("v.checkout");

		var action = component.get("c.pollForCardPaymentSuccess");
		action.setParams({ pOpportunityId : checkout.theOpportunity.Id, pDescription : checkout.internalPaymentDescription});
		action.setCallback(this, function(response)
		{
			var state = response.getState();
			if (state === "SUCCESS")
			{
                
				var returnedCardPaymentId = response.getReturnValue();
				
				if(!$A.util.isEmpty(returnedCardPaymentId))
				{
					this.navigateToRecord(component, 'Income_Card_Payment__c', returnedCardPaymentId)
					this.close(component);					
				}
			}
			else if (state === "ERROR") 
			{
				var errors = response.getError();
				helper.handleException(errors, helper);
			}
		});

		$A.enqueueAction(action);
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
    },
    close: function (component){
		var checkout = component.get("v.checkout");
		clearInterval(component.get('v.pollerId'));

		var workspaceAPI = component.find("workspace");
		workspaceAPI.isConsoleNavigation().then(function(isConsole) {
			if(isConsole){
				var callOutComeCompleted = $A.get("e.c:callOutcomeCompleted");
				callOutComeCompleted.setParams({
					message: { opportunityId : checkout.theOpportunity.Id, contactId : checkout.theOpportunity.npsp__Primary_Contact__c,callOutCome:'Donation'}
				}).fire();
				workspaceAPI.getFocusedTabInfo().then(function(getFocusedTabResponse) {
					var focusedTabId = getFocusedTabResponse.tabId;
					workspaceAPI.closeTab({tabId: focusedTabId});
				})
				.catch(function(error) {
					this.handleException(error.getError(), helper);
					component.set("v.wizardStep", '2');
					component.set('v.navigationDisabled', false);
				});
			}else{
				$A.get("e.force:closeQuickAction").fire();
			}
		}).catch(function(_err){
			this.handleException(_err.getError(), helper);
			component.set("v.wizardStep", '2');
			component.set('v.navigationDisabled', false);
		});
    }
})