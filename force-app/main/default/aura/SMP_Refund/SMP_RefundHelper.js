({	
	fetchIncomeCardPaymentHistory : function (component, event, helper)
	{
		var action = component.get('c.fetchIncomeCardPaymentHistory');
		var recordId = component.get('v.recordId');

		action.setParams({incomeCardPaymentId: recordId});
		action.setBackground();

		action.setCallback(this, $A.getCallback(function (response) {
			var state = response.getState();
			console.log(state);
            if (state === "SUCCESS") {
				var results = response.getReturnValue();

				results.forEach(function(record){
					record.linkName = '/'+record.Id;	
				});

				component.set('v.histories', results);

			}else if (state === "ERROR") {
                var errors = response.getError();
				console.log(errors);
				
				for(var i = 0; i < errors.length; i++)
				{
					helper.fireError(errors[i].exceptionType + ' - ' + errors[i].message + ' - ' + errors[i].stackTrace);
				}
			} else if (state === "INCOMPLETE")
			{
				console.log("Incomplete");
			}

			helper.toggleSpinner(component, false);
        }));
        $A.enqueueAction(action);
	},

	validateRefund : function(component, event, helper) {
		var gateway = component.get('v.paymentGateway');
		var histories = component.get('v.selectedHistories');
		var refundAmount = component.get('v.refundAmount');
	
		var maxAmount = 0.00;	
				
		var refundField = component.find('refundField');
		refundField.showHelpMessageIfInvalid();

		var allValid = refundField.get('v.validity').valid;
					
		for(var i = 0; i < histories.length; i++)
		{
			maxAmount += histories[i].Amount__c;
		}

		if(refundAmount > maxAmount)
		{
			helper.fireError("The refund amount must not exceed the amount of the transaction.");
			allValid = false;
		}
		
		return allValid;
	},

	doRefund : function(component, event, helper) {
		helper.toggleSpinner(component, true);
		
		var action = component.get('c.executeRefundByHistory');
		var refundAmount = component.get('v.refundAmount');
		var histories = component.get('v.selectedHistories');
		var refunds = {};
		
		histories.forEach(function(record){
			if(histories.length > 1){
				refunds[record.Id] = record.Amount__c;
			}
			else{
				refunds[record.Id] = refundAmount;
			}
		});

		action.setParams({refundsByHistory: refunds});

		action.setCallback(this, $A.getCallback(function (response) {
			var state = response.getState();
			console.log(state);
            if (state === "SUCCESS") {
				var results = response.getReturnValue();
				var resultList = [];

				for (var key in results) {
					var record = results[key];
					record.name = key;
					if(!$A.util.isEmpty(record.data) && !$A.util.isEmpty(record.data.incomeCardPaymentHistoryId))
					{
						record.historyLink = '/'+record.data.incomeCardPaymentHistoryId;	
						record.incomeCardPaymentHistoryId = record.data.incomeCardPaymentHistoryId;
					}
					else
					{
						record.historyLink = '#';	
					}

					resultList.push(record);
				}

				component.set('v.results', resultList);

				component.set('v.showResultsPanel', true);
			}else if (state === "ERROR") {
                var errors = response.getError();
				console.log(errors);

				for(var i = 0; i < errors.length; i++)
				{
					helper.fireError(errors[i].exceptionType + ' - ' + errors[i].message + ' - ' + errors[i].stackTrace);
				}				
			} else if (state === "INCOMPLETE")
			{
				console.log("Incomplete");
			}

			helper.toggleSpinner(component, false);
        }));
        $A.enqueueAction(action);
	},

	fireError : function(message)
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