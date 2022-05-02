/**
 * @File Name          : DonorSearchController.cls
 * @Description        : 
 * @Author             : agentgill
 * @Group              : 
 * @Last Modified By   : Iamsfdeveloper
 * @Last Modified On   : 02-02-2022
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    17/03/2020   nkoosi     Initial Version
**/
public with sharing class DonorSearchController {

    /**
    * @description SOQL Search Contacts
    * @author agentgill | 17/03/2020 
    * @param searchKey  
    * @return List<Contact> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Contact> findContacts(String searchKey) {
        String key = '%' + searchKey + '%';
        return [
            SELECT Id, Name, FirstName, LastName, Phone, Email, MailingPostalCode
            FROM Contact
            WHERE Name LIKE :key OR MailingPostalCode LIKE :key OR Email LIKE :key
            WITH SECURITY_ENFORCED
            LIMIT 10
        ];
    }

}