/**
 * @File Name          : redirectToRecordController.js
 * @Description        : 
 * @Author             : agentgill
 * @Group              : 
 * @Last Modified By   : agentgill
 * @Last Modified On   : 3/12/2020, 9:18:55 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/12/2020   agentgill     Initial Version
**/
({
  invoke: function(component, event, helper) {
    // Get the record ID attribute
    var record = component.get("v.recordId");
	//alert('testing123');
    // Get the Lightning event that opens a record in a new tab
    var redirect = $A.get("e.force:navigateToSObject");

    // Pass the record ID to the event
    redirect.setParams({
      recordId: record
    });

    // Open the record
    redirect.fire();
  }
});