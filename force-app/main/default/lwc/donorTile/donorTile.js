/**
 * @File Name          : DonorTile.js
 * @Description        :
 * @Author             : agentgill
 * @Group              :
 * @Last Modified By   : agentgill
 * @Last Modified On   : 17/03/2020, 08:00:47
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    17/03/2020   agentgill     Initial Version
 **/

import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class DonorTile extends NavigationMixin(LightningElement) {
  @api contact;

  navigateToContact() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.contact.Id,
        objectApiName: "Contact",
        actionName: "view"
      }
    });
  }
}