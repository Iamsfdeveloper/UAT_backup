<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_Unique_Id</fullName>
        <field>UniqueIdentifier__c</field>
        <formula>Campaign__c &amp;&apos;-&apos;&amp; Item__c&amp;&apos;-&apos;&amp; Text(CurrencyIsoCode)</formula>
        <name>Populate_Unique_Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Populate Unique Identifier</fullName>
        <actions>
            <name>Populate_Unique_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.IsActive</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
