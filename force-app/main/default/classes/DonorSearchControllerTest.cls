/**
 * @File Name          : DonorSearchControllerTest.cls
 * @Description        :
 * @Author             : agentgill
 * @Group              :
 * @Last Modified By   : agentgill
 * @Last Modified On   : 05/04/2020, 11:29:44
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    05/04/2020   agentgill     Initial Version
 **/

@isTest
public with sharing class DonorSearchControllerTest {
    @TestSetup
    static void makeData() {
        List<Contact> contacts = new List<Contact>();

        for (Integer i = 1; i <= 10; i++) {
            contacts.add((Contact)TestFactory.createSObject(
                new Contact(
                    FirstName = 'First' + i,
                    LastName = 'Last' + i,
                    Email = i + 'first.last@test.com',
                    MailingCity = 'London',
                    MailingCountry = 'UK',
                    MailingPostalCode = 'TW33UJ', 
                    MailingStreet = 'Test'
                )
            ));
        }

        insert contacts;
    }

    /**
     * @description Test Contacts are found
     * @author agentgill | 05/04/2020
     * @return void
     **/
    @isTest
    private static void testFindContacts() {
        Test.startTest();
        String searchKey = 'first';
        List<Contact> contacts = DonorSearchController.findContacts(searchKey);
        Test.stopTest();
        System.assertEquals(10, contacts.size(), 'Contacts not found');
    }

    /**
     * @description Test no contacts are not found
     * @author agentgill | 05/04/2020
     * @return void
     **/
    @isTest
    private static void testDoNotFindContacts() {
        Test.startTest();
        String searchKey = 'zzz';
        List<Contact> contacts = DonorSearchController.findContacts(searchKey);
        Test.stopTest();
        System.assertEquals(0, contacts.size(), 'Contacts found');
    }
}