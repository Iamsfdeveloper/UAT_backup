<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Campaign_Response_Owner_Alert</fullName>
        <description>Campaign Response Owner Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Donor_Care_UK/Campaign_Response_Percentage</template>
    </alerts>
    <alerts>
        <fullName>When_Pledge_target_achieved_to_90_then_notify</fullName>
        <ccEmails>shagufta.humayun@humanappeal.org.uk</ccEmails>
        <description>When Pledge target achieved to 90% then notify</description>
        <protected>false</protected>
        <recipients>
            <recipient>Donor_Care_Advisor_UK</recipient>
            <type>role</type>
        </recipients>
        <recipients>
            <field>Fundraiser_Person__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>customercare@humanappeal.org.uk</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Pledge_Target_reached_90</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Campaign_Unique_Name</fullName>
        <field>Unique_Name__c</field>
        <formula>Name</formula>
        <name>Set Campaign Unique Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Department_to_Comms</fullName>
        <field>Department__c</field>
        <literalValue>Comms</literalValue>
        <name>Set Department to Comms</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Department_to_Donor_Care</fullName>
        <field>Department__c</field>
        <literalValue>Donor Care</literalValue>
        <name>Set Department to Donor Care</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Department_to_Fundraising</fullName>
        <field>Department__c</field>
        <literalValue>Fundraising</literalValue>
        <name>Set Department to Fundraising</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Fundraiser_Code</fullName>
        <field>Fundraiser_Code__c</field>
        <formula>CASE(Fundraiser__c,
      &quot;Haitham Aboshady&quot;, &quot;HAA&quot;,
      &quot;Abdul Malik&quot;, &quot;ABM&quot;,
      &quot;Inam Malik&quot;,&quot;INM&quot;,
      &quot;Aamilah Begum&quot;,&quot;AAB&quot;,
      &quot;Ebrahem Ettoubi&quot;,&quot;EBE&quot;,
      &quot;Zainab Siddiqui​&quot;,&quot;ZAS&quot;,
      &quot;Abdullah Saheb​&quot;,&quot;ABS&quot;,
&quot;Ahmed Osman&quot;, &quot;AHO&quot;,
      &quot;Mahmoud Yousif​&quot;,&quot;MAY&quot;,
      &quot;Mohammed Kalam&quot;,&quot;MOK&quot;,
      &quot;Heshmatullah Tajik​&quot;,&quot;HET&quot;,
      &quot;Adnan Iqbal&quot;,&quot;ADI&quot;,
      &quot;Shahzaib Aqil&quot;,&quot;SHA&quot;,
      &quot;Sefyan Abdulmula&quot;,&quot;SEA&quot;,
      &quot;Junaid Afzal&quot;,&quot;JUA&quot;,
      &quot;Sibbat Noor&quot;,&quot;SIN&quot;,
      &quot;Ubaidah Omar&quot;,&quot;UBO&quot;,
&quot;Fahad Khan&quot;,&quot;FAK&quot;,
&quot;Khalil Benkhalil&quot;,&quot;KHB&quot;,
&quot;Mohammed Abid Shah&quot;,&quot;MAS&quot;,
&quot;Ausba Zanib&quot;,&quot;AUZ&quot;,
&quot;FR LEAVER&quot;,&quot;FRX&quot;,
       &quot;&quot; )</formula>
        <name>Set Fundraiser Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Source_to_Affiliate_partner_market</fullName>
        <description>Set Source to: Affiliate / partner marketing (including sponsorship)</description>
        <field>Source__c</field>
        <literalValue>Affiliate / partner marketing (including sponsorship)</literalValue>
        <name>Set Source to Affiliate / partner market</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Source_to_Call_Centre</fullName>
        <field>Source__c</field>
        <literalValue>Call Centre</literalValue>
        <name>Set Source to Call Centre</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Source_to_Collection</fullName>
        <field>Source__c</field>
        <literalValue>Collection – street, mosques</literalValue>
        <name>Set Source to Collection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Source_to_Comedy_Tour</fullName>
        <field>Source__c</field>
        <literalValue>Comedy Tour</literalValue>
        <name>Set Source to Comedy Tour</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Source_to_Dinner_Tea</fullName>
        <field>Source__c</field>
        <literalValue>Dinner / Tea</literalValue>
        <name>Set Source to Dinner / Tea</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Source_to_Events_Tours_etc</fullName>
        <description>Set Source to Events – Tours, Dinners, Challenges, Stall</description>
        <field>Source__c</field>
        <literalValue>Events – Tours, Dinners, Challenges, Stalls</literalValue>
        <name>Set Source to Events  – Tours, etc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Source_to_Post_direct_mail_door</fullName>
        <description>Set Source to: Post – direct mail, door drops</description>
        <field>Source__c</field>
        <literalValue>Post – direct mail, door drops</literalValue>
        <name>Set Source to 	Post – direct mail, door</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Source_to_Radio_Appeal</fullName>
        <field>Source__c</field>
        <literalValue>Radio Appeal</literalValue>
        <name>Set Source to Radio Appeal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Source_to_TV_Appeal</fullName>
        <field>Source__c</field>
        <literalValue>TV Live Appeal</literalValue>
        <name>Set Source to TV Appeal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Source_to_Website</fullName>
        <field>Source__c</field>
        <literalValue>Website (appeal / product landing page)</literalValue>
        <name>Set Source to Website</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Year_to_2012</fullName>
        <field>Year__c</field>
        <literalValue>2012</literalValue>
        <name>Set Year to 2012</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Year_to_2013</fullName>
        <field>Year__c</field>
        <literalValue>2013</literalValue>
        <name>Set Year to 2013</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Year_to_2014</fullName>
        <field>Year__c</field>
        <literalValue>2014</literalValue>
        <name>Set Year to 2014</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Year_to_2015</fullName>
        <field>Year__c</field>
        <literalValue>2015</literalValue>
        <name>Set Year to 2015</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Year_to_2016</fullName>
        <field>Year__c</field>
        <literalValue>2016</literalValue>
        <name>Set Year to 2016</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Year_to_2017</fullName>
        <field>Year__c</field>
        <literalValue>2017</literalValue>
        <name>Set Year to 2017</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Year_to_2018</fullName>
        <field>Year__c</field>
        <literalValue>2018</literalValue>
        <name>Set Year to 2018</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Year_to_2019</fullName>
        <field>Year__c</field>
        <literalValue>2019</literalValue>
        <name>Set Year to 2019</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_custom_Created_Date_Time_field</fullName>
        <field>Created_Date_Time__c</field>
        <formula>CreatedDate</formula>
        <name>Set custom Created Date:Time field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Campaign Name Set Or Edited</fullName>
        <actions>
            <name>Set_Campaign_Unique_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sets a unique name which is used in validation to ensure no duplicates</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Campaign is Call Centre</fullName>
        <actions>
            <name>Set_Department_to_Donor_Care</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Source_to_Call_Centre</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Call Centre</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Campaign is Collection</fullName>
        <actions>
            <name>Set_Department_to_Fundraising</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Source_to_Collection</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 or 2</booleanFilter>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Collection</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Event_Type_Code__c</field>
            <operation>contains</operation>
            <value>-SC-,-TC-,-MC-</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Campaign is Comedy Tour</fullName>
        <actions>
            <name>Set_Department_to_Fundraising</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Source_to_Comedy_Tour</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 or 2</booleanFilter>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Comedy Tour</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Event_Type_Code__c</field>
            <operation>contains</operation>
            <value>CT</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Campaign is Events %E2%80%93 Tours%2C Dinners%2C Challenges%2C Stalls</fullName>
        <actions>
            <name>Set_Department_to_Fundraising</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Source_to_Events_Tours_etc</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 or 2 or 3 or 4 or 5 or 6</booleanFilter>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Event,Expo,Seminar,Talk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Open Day,Auction,Concert,Show,Conference</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Festival,Fun Day,Fete,Bazaar,Bazzar,Bazar,Party</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Dinner,Tea,Tour,Iftar</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Trek,Walk,Run,Marathon,Challenge,Snowden,Snowdon,Climb,Jump,Cycling</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Ben Nevis,Skydive,Sky Dive,Challenge</value>
        </criteriaItems>
        <description>Event,Expo,Seminar,Talk,Open Day,Auction,Concert,Show,Conference,Festival,Fun Day,Fete,Bazaar,Bazzar,Bazar,Party,Dinner,Tea,Tour,Iftar,Trek,Walk,Run,Marathon,Challenge,Snowden,Snowdon,Climb,Jump,Cycling,Ben Nevis,Skydive,Sky Dive,Challenge</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Campaign is Mailer%2C Mail Campaign</fullName>
        <actions>
            <name>Set_Department_to_Comms</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Source_to_Post_direct_mail_door</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Mailer,Mailing,Mail Campaign,Direct Mail,Door Drop</value>
        </criteriaItems>
        <description>Mailer,Mailing,Mail Campaign, Direct Mail, Door Drop</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Campaign is Radio Appeal</fullName>
        <actions>
            <name>Set_Department_to_Comms</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Source_to_Radio_Appeal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Radio Appeal,Radio,Inspire FM,InspireFM</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Campaign is Sponsorship%2FPartnership%2Fpersonal contact</fullName>
        <actions>
            <name>Set_Department_to_Fundraising</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Source_to_Affiliate_partner_market</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Event_Type_Code__c</field>
            <operation>contains</operation>
            <value>SP,PC,Personal Contact,Sponsorship</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Campaign is TV Live Appeal</fullName>
        <actions>
            <name>Set_Department_to_Comms</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Source_to_TV_Appeal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 or 2 or 3 or 4 or 5</booleanFilter>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>TV Live Appeal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Islam Channel Appeal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>TV Appeal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Live Appeal,Channel</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Islam Channel,Channel S Appeal</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Campaign is Website</fullName>
        <actions>
            <name>Set_Department_to_Comms</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Source_to_Website</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Name</field>
            <operation>contains</operation>
            <value>Website</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Fundraiser is newly set</fullName>
        <actions>
            <name>Set_Fundraiser_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Fundraiser__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Is Fundraising</fullName>
        <actions>
            <name>Set_Department_to_Fundraising</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Fundraiser__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Year__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Region__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Long Campaign Name contacts Islam Uddin</fullName>
        <active>false</active>
        <booleanFilter>1 or 2</booleanFilter>
        <criteriaItems>
            <field>Campaign.Long_Name_Field__c</field>
            <operation>contains</operation>
            <value>Islam Uddin</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.Fundraiser_Code__c</field>
            <operation>equals</operation>
            <value>IU</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
