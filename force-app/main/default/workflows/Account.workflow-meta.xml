<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Organization_Donor_Id</fullName>
        <field>AccountNumber</field>
        <formula>Text(Regional_Office_Code__c)&amp;&apos;E&apos;&amp;If(ISBLANK(Donor_Id__c), External_ID_From_DMS__c,Donor_Id__c)</formula>
        <name>Set Organization Donor Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Set Donor Id</fullName>
        <actions>
            <name>Set_Organization_Donor_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.DeveloperName =&apos;Organization&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
