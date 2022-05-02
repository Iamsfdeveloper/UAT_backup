/**
 * @File Name          : donorSearch.js
 * @Description        :
 * @Author             : agentgill
 * @Group              :
 * @Last Modified By   : Iamsfdeveloper
 * @Last Modified On   : 02-02-2022
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    17/03/2020   agentgill     Initial Version
 **/
import { LightningElement } from "lwc";
import findContacts from "@salesforce/apex/DonorSearchController.findContacts";

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 350;

export default class CompositionContactSearch extends LightningElement {
  contacts;
  error;
 
  handleKeyChange(event) {
    // Debouncing this method: Do not actually invoke the Apex call as long as this function is
    // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
    window.clearTimeout(this.delayTimeout);
    const searchKey = event.target.value;
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.delayTimeout = setTimeout(() => {
      findContacts({ searchKey })
        .then(result => {
          this.contacts = result;
          this.error = undefined;
        })
        .catch(error => {
          this.error = error;
          this.contacts = undefined;
        });
    }, DELAY);
  }
}