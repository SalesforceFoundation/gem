<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
	<applicationVisibilities>
        <application>%%%NAMESPACE%%%Gift_Entry</application>
        <default>true</default>
        <visible>true</visible>
    </applicationVisibilities>

    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Do_Not_Automatically_Create_Payment__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Donation_Acknowledgment_Status__c</field>
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
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Donation_Notification_Message__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Donation_Primary_Campaign__c</field>
        <readable>true</readable>
    </fieldPermissions>
    <fieldPermissions>
        <editable>true</editable>
        <field>npsp__DataImport__c.%%%NAMESPACE%%%Donation_Tribute_Type__c</field>
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
    <layoutAssignments>
        <layout>Opportunity-%%%NAMESPACE%%%Advancement Gift Layout</layout>
        <recordType>Opportunity.%%%NAMESPACED_ORG%%%Donation</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Opportunity-%%%NAMESPACE%%%Advancement Gift Layout</layout>
        <recordType>Opportunity.%%%NAMESPACED_ORG%%%Grant</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Opportunity-%%%NAMESPACE%%%Advancement Gift Layout</layout>
        <recordType>Opportunity.%%%NAMESPACED_ORG%%%In_Kind</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Opportunity-%%%NAMESPACE%%%Advancement Gift Layout</layout>
        <recordType>Opportunity.%%%NAMESPACED_ORG%%%Major_Gift</recordType>
    </layoutAssignments>
        <layoutAssignments>
        <layout>Opportunity-%%%NAMESPACE%%%Advancement Gift Layout</layout>
        <recordType>Opportunity.%%%NAMESPACED_ORG%%%Matching</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Opportunity-%%%NAMESPACE%%%Advancement Gift Layout</layout>
        <recordType>Opportunity.%%%NAMESPACED_ORG%%%Membership</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>npsp__DataImport__c-%%%NAMESPACE%%%Advancement Gift Layout</layout>
    </layoutAssignments>

    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Account.HH_Account</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>true</default>
        <recordType>Account.Organization</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>true</default>
        <recordType>Opportunity.Donation</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Opportunity.Grant</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Opportunity.In_Kind</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Opportunity.Major_Gift</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Opportunity.Matching</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Opportunity.Membership</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Opportunity.NPSP_Default</recordType>
        <visible>false</visible>
    </recordTypeVisibilities>
    
    <tabVisibilities>
        <tab>%%%NAMESPACE%%%Gift_Entry</tab>
        <visibility>DefaultOn</visibility>
    </tabVisibilities>
</Profile>
