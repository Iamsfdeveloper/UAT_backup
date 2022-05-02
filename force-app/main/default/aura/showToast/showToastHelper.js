/**
 * @File Name          : showToastHelper.js
 * @Description        : 
 * @Author             : agentgill
 * @Group              : 
 * @Last Modified By   : agentgill
 * @Last Modified On   : 3/12/2020, 9:18:09 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/12/2020   agentgill     Initial Version
**/
({
  showToast: function(type, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      messageText: message,
      type: type,
      duration: 10000,
      mode: "dismissible"
    });
    toastEvent.fire();
  }
});