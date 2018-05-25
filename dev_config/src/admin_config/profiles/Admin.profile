<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
	<applicationVisibilities>
        <application>%%%NAMESPACE%%%Gift_Entry</application>
        <visible>true</visible>
    </applicationVisibilities>

    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Do_Not_Automatically_Create_Payment__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Donation_Honoree_Contact__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Donation_Honoree_Name__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Donation_Matching_Gift__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Donation_Matching_Gift_Account__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Donation_Matching_Gift_Employer__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Donation_Matching_Gift_Status__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Donation_Primary_Campaign__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Notification_Recipient_Name__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Post_Process_Object_JSON__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%Advancement Organization Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%Advancement Organization Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%Academic_Program</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%Advancement Organization Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%Administrative</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%Advancement Organization Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%Business_Organization</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%Advancement Organization Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%Educational_Institution</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%Advancement Household Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%HH_Account</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%Advancement Organization Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%Organization</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%Advancement Organization Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%Sports_Organization</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%Advancement Organization Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%University_Department</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Contact-%%%NAMESPACE%%%Advancement Contact Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Opportunity-%%%NAMESPACE%%%Advancement Gift Layout</layout>
    </layoutAssignments>
    
    <tabVisibilities>
        <tab>%%%NAMESPACE%%%Gift_Entry</tab>
        <visibility>DefaultOn</visibility>
    </tabVisibilities>
</Profile>
