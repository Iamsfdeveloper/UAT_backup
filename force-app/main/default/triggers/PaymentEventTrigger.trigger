/**
 * @File Name          : PaymentEventTrigger.trigger
 * @Description        :
 * @Author             : agentgill
 * @Group              :
 * @Last Modified By   : agentgill
 * @Last Modified On   : 23/06/2020, 14:15:53
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    12/06/2020   agentgill     Initial Version
 **/
trigger PaymentEventTrigger on Payment_Event__e(after insert) {
    new PaymentEventTriggerHandler().run();
}