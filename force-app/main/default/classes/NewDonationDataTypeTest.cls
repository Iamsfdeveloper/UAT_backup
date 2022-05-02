/**
 * @File Name          : NewDonationDataTypeTest.cls
 * @Description        :
 * @Author             : agentgill
 * @Group              :
 * @Last Modified By   : agentgill
 * @Last Modified On   : 05/04/2020, 09:40:14
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    05/04/2020   agentgill     Initial Version
 **/
@isTest
public with sharing class NewDonationDataTypeTest {
    /**
     * @description Test Apex Defined Data Type (NewDonationDataType)
     * @author agentgill | 05/04/2020
     * @return void
     **/
    @isTest
    private static void testNewDonationDataType() {
        Test.startTest();
        NewDonationBasketDataType ndbp = new NewDonationBasketDataType();
        NewDonationSupporterDataType nsdt = new NewDonationSupporterDataType();
        NewDonationBasketItemDataType ndbItem = new NewDonationBasketItemDataType();
        NewDonationDataType ndon = new NewDonationDataType();
        Test.stopTest();
        System.assert(ndon != null, 'Something went wrong');
    }
}