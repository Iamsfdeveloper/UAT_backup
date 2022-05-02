<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_quality_manager_about_the_forwarded_complaint_request_from_relevant_depar</fullName>
        <description>Notify quality manager about the forwarded complaint request from relevant department.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>customercare@humanappeal.org.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Notification_of_complaint_to_Quality_Manager</template>
    </alerts>
    <alerts>
        <fullName>Relevant_assigned_user_notification_through_the_email</fullName>
        <description>Relevant assigned user notification through the email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>customercare@humanappeal.org.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Notify_dpt_assigned_user_of_complaint_received</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_webmail_once_task_is_complete_or_resolved</fullName>
        <description>Send email to webmail once task is complete or resolved</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>servicerequests@humanappeal.org.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Case_Resolved_Notification</template>
    </alerts>
    <alerts>
        <fullName>When_new_Case_created_then_send_acknowledgment_email</fullName>
        <description>When new Case created then send acknowledgment email</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>servicerequests@humanappeal.org.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Acknowledgement_of_case_created</template>
    </alerts>
    <alerts>
        <fullName>When_new_Complaint_Case_created_not_through_email_then_send_acknowledgment_email</fullName>
        <description>When new Complaint Case created (not through email) then send acknowledgment email</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>customercare@humanappeal.org.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Web_Complaint_Acknowledgement_of_case_created</template>
    </alerts>
    <alerts>
        <fullName>When_new_HR_Request_Case_created_then_send_acknowledgment_email</fullName>
        <description>When new HR Request Case created then send acknowledgment email</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>pnc.uk@humanappeal.org.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Acknowledgement_of_HR_query_case_created</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Case_owner_to_QM</fullName>
        <description>When relevant department entered the response then update the Case owner to Quality Manager</description>
        <field>OwnerId</field>
        <lookupValue>jahed.mubin@humanappeal.org.uk</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Case owner to QM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_of_case_to_submitted</fullName>
        <description>When relevant department entered the response then update the status field to Submitted Response</description>
        <field>Status</field>
        <literalValue>Response Submitted</literalValue>
        <name>Update Status of case to submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Acknowledgement of HR request case created</fullName>
        <actions>
            <name>When_new_HR_Request_Case_created_then_send_acknowledgment_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>HR Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email,Phone,Web,In Person</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notEqual</operation>
            <value>pnc.uk@humanappeal.org.uk</value>
        </criteriaItems>
        <description>Acknowledgement to user when  HR request/query case created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Close Notification</fullName>
        <actions>
            <name>Send_email_to_webmail_once_task_is_complete_or_resolved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Resolved</value>
        </criteriaItems>
        <description>Send email to web email once task is complete/ closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Complaint Assignment Notification</fullName>
        <actions>
            <name>Relevant_assigned_user_notification_through_the_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Assigned</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint</value>
        </criteriaItems>
        <description>When a complaint is assigned to relevant user then notify the user through email.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IT help desk Acknowledgement of case created</fullName>
        <actions>
            <name>When_new_Case_created_then_send_acknowledgment_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IT Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email,Phone,Web,In Person,Post</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notEqual</operation>
            <value>servicerequests@humanappeal.org.uk</value>
        </criteriaItems>
        <description>When case creates then contact will be notified for acknowledgment</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Relevant department filled then send to QM</fullName>
        <actions>
            <name>Update_Case_owner_to_QM</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Status_of_case_to_submitted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>When case/complaint is updated by relevant department user then send back to quality Manager to check</description>
        <formula>NOT(LEN(Action_Taken_To_Resolve__c) =0 ) &amp;&amp; NOT( ISBLANK( Date_action_taken__c ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Web Complaint Acknowledgement of case created</fullName>
        <actions>
            <name>When_new_Complaint_Case_created_not_through_email_then_send_acknowledgment_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.Type</field>
            <operation>equals</operation>
            <value>Customer Complaint,Feedback/Suggestion,Refund Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email,Phone,Web,In Person</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notEqual</operation>
            <value>feedback@humanappeal.org.uk</value>
        </criteriaItems>
        <description>When compliant case creates through web only then contact/donor will be notified for acknowledgment</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
