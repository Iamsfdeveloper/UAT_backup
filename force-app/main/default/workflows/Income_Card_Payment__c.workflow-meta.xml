<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Card_Expiry_Date_Expiring_Alert</fullName>
        <description>Card Expiry Date Expiring Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Donor_Care_UK/Donor_Card_Expires</template>
    </alerts>
    <alerts>
        <fullName>Card_Payment_Failed_Alert</fullName>
        <description>Card Payment Failed Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Donor_Care_UK/Donor_Card_Payment_Failed</template>
    </alerts>
    <alerts>
        <fullName>Payment_Receipt</fullName>
        <description>Payment Receipt</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@humanappeal.org.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Payment_Emails/Payment_Receipt</template>
    </alerts>
</Workflow>
