/**
 * @File Name          : showToastController.js
 * @Description        : 
 * @Author             : agentgill
 * @Group              : 
 * @Last Modified By   : agentgill
 * @Last Modified On   : 3/12/2020, 9:18:02 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/12/2020   agentgill     Initial Version
**/
({
  invoke: function(component, event, helper) {
    var args = event.getParam("arguments");
    var message = component.get("v.messageText");
    var type = component.get("v.type");
    helper.showToast(type, message);
  }
});