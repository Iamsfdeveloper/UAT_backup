<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Case_Reason_update_to_Complaint</fullName>
        <field>Case_Reason__c</field>
        <literalValue>Complaints</literalValue>
        <name>Case Reason update to Complaint</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Reason_update_to_General_Queries</fullName>
        <field>Case_Reason__c</field>
        <literalValue>General HR Queries</literalValue>
        <name>Case Reason update to General Queries</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Reason_update_to_Recruitment</fullName>
        <field>Case_Reason__c</field>
        <literalValue>Recruitment</literalValue>
        <name>Case Reason update to Recruitment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Type_update_to_IT_Support</fullName>
        <description>When the email contains &apos;IT support&apos; keywords then Case Type update to IT Support</description>
        <field>Type</field>
        <literalValue>IT Support</literalValue>
        <name>Case Type update to IT Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Type_update_to_Systems_Support</fullName>
        <description>When the email contains &apos;Systems&apos; keywords then Case Type update to System/software Support</description>
        <field>Type</field>
        <literalValue>Systems/Software Support</literalValue>
        <name>Case Type update to Systems Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Type_update_to_Website_Support</fullName>
        <description>When the email contains &apos;Website&apos; keyword then Case Type update to Website Support</description>
        <field>Type</field>
        <literalValue>Website Support</literalValue>
        <name>Case Type update to Website Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_reason_update_to_Payroll</fullName>
        <description>Case Type update to Payroll</description>
        <field>Case_Reason__c</field>
        <literalValue>Payroll</literalValue>
        <name>Case Reason update to Payroll</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Type_to_HR_Query</fullName>
        <field>Type</field>
        <literalValue>UK P&amp;C Query</literalValue>
        <name>Update Case Type to HR Query</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Type_to_HR_Query_payrol</fullName>
        <field>Type</field>
        <literalValue>UK P&amp;C Query</literalValue>
        <name>Update Case Type to HR Query-payrol</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Type_to_HR_Query_recruit</fullName>
        <field>Type</field>
        <literalValue>UK P&amp;C Query</literalValue>
        <name>Update Case Type to HR Query-recruit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Type_to_HR_pnc_Query</fullName>
        <field>Type</field>
        <literalValue>UK P&amp;C Query</literalValue>
        <name>Update Case Type to HR pnc Query</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>HR Request - Email received - Complaints</fullName>
        <actions>
            <name>Case_Reason_update_to_Complaint</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Case_Type_to_HR_Query</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 5 AND (2 OR 3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.HtmlBody</field>
            <operation>contains</operation>
            <value>Complaint,Complaints</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Subject</field>
            <operation>contains</operation>
            <value>Complaint,Complaints</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>Complaint,Complaints</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>equals</operation>
            <value>pnc.uk@humanappeal.org.uk</value>
        </criteriaItems>
        <description>This workflow rule will search for Complaints keyword in incoming email and then assign Reason  to Complaints</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>HR Request - Email received - General HR Queries</fullName>
        <actions>
            <name>Case_Reason_update_to_General_Queries</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Case_Type_to_HR_pnc_Query</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 5 AND (2 OR 3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.HtmlBody</field>
            <operation>contains</operation>
            <value>General HR Queries,Query</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Subject</field>
            <operation>contains</operation>
            <value>General HR Queries,Query</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>General HR Queries,Query</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>equals</operation>
            <value>pnc.uk@humanappeal.org.uk</value>
        </criteriaItems>
        <description>HR Request - Email received - General HR Queries</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>HR Request - Email received - Payroll</fullName>
        <actions>
            <name>Case_reason_update_to_Payroll</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Case_Type_to_HR_Query_payrol</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 5 AND (2 OR 3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.HtmlBody</field>
            <operation>contains</operation>
            <value>Payroll,payroll</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Subject</field>
            <operation>contains</operation>
            <value>Payroll,payroll</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>Payroll,payroll</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>equals</operation>
            <value>pnc.uk@humanappeal.org.uk</value>
        </criteriaItems>
        <description>This workflow rule will search for Payroll keyword in incoming email and then assign Type to Payroll</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>HR Request - Email received - Recruitment</fullName>
        <actions>
            <name>Case_Reason_update_to_Recruitment</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Case_Type_to_HR_Query_recruit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 5 AND (2 OR 3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.HtmlBody</field>
            <operation>contains</operation>
            <value>recruit,recruitment</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Subject</field>
            <operation>contains</operation>
            <value>recruit,recruitment</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>recruit,recruitment</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>equals</operation>
            <value>pnc.uk@humanappeal.org.uk</value>
        </criteriaItems>
        <description>This workflow rule will search for keyword recruit ,recruitment in incoming email and then assign Type to recruitment</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IT Help - Email received- IT support keyword</fullName>
        <actions>
            <name>Case_Type_update_to_IT_Support</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 5 AND (2 OR 3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.HtmlBody</field>
            <operation>contains</operation>
            <value>Printer,network,internet,print,outlook</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Subject</field>
            <operation>contains</operation>
            <value>Printer,network,internet,print,outlook</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>Printer,network,internet,print,outlook</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>equals</operation>
            <value>servicerequests@humanappeal.org.uk</value>
        </criteriaItems>
        <description>This workflow rule will search for IT support keyword in incoming email and then assign Type to IT support</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IT Help - Email received- Systems support keyword</fullName>
        <actions>
            <name>Case_Type_update_to_Systems_Support</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 5 AND (2 OR 3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.HtmlBody</field>
            <operation>contains</operation>
            <value>DMS,AMS,PMS,NAV,Salesforce,sharepoint</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Subject</field>
            <operation>contains</operation>
            <value>DMS,AMS,PMS,NAV,Salesforce,sharepoint</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>DMS,AMS,PMS,NAV,Salesforce,sharepoint</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>equals</operation>
            <value>servicerequests@humanappeal.org.uk</value>
        </criteriaItems>
        <description>This workflow rule will search for Systems support keyword in incoming email and then assign Type to Systems support</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IT Help - Email received- website keyword</fullName>
        <actions>
            <name>Case_Type_update_to_Website_Support</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 5 AND (2 OR 3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.HtmlBody</field>
            <operation>contains</operation>
            <value>Website,web,website</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.Subject</field>
            <operation>contains</operation>
            <value>Website,web,website</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.TextBody</field>
            <operation>contains</operation>
            <value>Website,web,website</value>
        </criteriaItems>
        <criteriaItems>
            <field>EmailMessage.ToAddress</field>
            <operation>equals</operation>
            <value>servicerequests@humanappeal.org.uk</value>
        </criteriaItems>
        <description>This workflow rule will search for website keyword in incoming email and then assign Type to Website support</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
