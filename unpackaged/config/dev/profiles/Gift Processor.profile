<?xml version="1.0" encoding="UTF-8"?>
<Profile xmlns="http://soap.sforce.com/2006/04/metadata">
    <applicationVisibilities>
        <application>%%%NAMESPACE%%%Gift_Entry</application>
        <default>true</default>
        <visible>true</visible>
    </applicationVisibilities>
    <applicationVisibilities>
        <application>npsp__Nonprofit_CRM</application>
        <default>false</default>
        <visible>false</visible>
    </applicationVisibilities>

    <classAccesses>
        <apexClass>DynamicFieldDisplayController</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    <classAccesses>
        <apexClass>GiftEntryFormController</apexClass>
        <enabled>true</enabled>
    </classAccesses>
    
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%GEM Organization Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%GEM Organization Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%Academic_Program</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%GEM Organization Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%Administrative</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%GEM Organization Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%Business_Organization</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%GEM Organization Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%Educational_Institution</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%GEM Household Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%HH_Account</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%GEM Organization Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%Sports_Organization</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Account-%%%NAMESPACE%%%GEM Organization Layout</layout>
        <recordType>Account.%%%NAMESPACED_ORG%%%University_Department</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Contact-%%%NAMESPACE%%%GEM Contact Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>hed__Affiliation__c-GEM Affiliation Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>hed__Relationship__c-GEM Relationship Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Opportunity-%%%NAMESPACE%%%GEM Gift Layout</layout>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Opportunity-%%%NAMESPACE%%%GEM Gift Layout</layout>
        <recordType>Opportunity.%%%NAMESPACED_ORG%%%Donation</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Opportunity-%%%NAMESPACE%%%GEM Gift Layout</layout>
        <recordType>Opportunity.%%%NAMESPACED_ORG%%%InKindGift</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>Opportunity-%%%NAMESPACE%%%GEM Gift Layout</layout>
        <recordType>Opportunity.%%%NAMESPACED_ORG%%%MatchingGift</recordType>
    </layoutAssignments>
    <layoutAssignments>
        <layout>npsp__DataImport__c-%%%NAMESPACE%%%GEM Gift Layout</layout>
    </layoutAssignments>

    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Account.HH_Account</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Account.Organization</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Account.Academic_Program</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Account.Administrative</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>true</default>
        <recordType>Account.Business_Organization</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Account.Educational_Institution</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Account.Sports_Organization</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Account.University_Department</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>hed__Course_Enrollment__c.Faculty</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>true</default>
        <recordType>hed__Course_Enrollment__c.Student</recordType>
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
        <recordType>Opportunity.InKindGift</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Opportunity.MatchingGift</recordType>
        <visible>true</visible>
    </recordTypeVisibilities>
    <recordTypeVisibilities>
        <default>false</default>
        <recordType>Opportunity.NPSP_Default</recordType>
        <visible>false</visible>
    </recordTypeVisibilities>

    <tabVisibilities>
        <tab>npe01__Contact_Merge</tab>
        <visibility>Hidden</visibility>
    </tabVisibilities>
    <tabVisibilities>
        <tab>npsp__Contact_Merge</tab>
        <visibility>Hidden</visibility>
    </tabVisibilities>
    <tabVisibilities>
        <tab>%%%NAMESPACE%%%Single_Gift_Entry</tab>
        <visibility>DefaultOn</visibility>
    </tabVisibilities>
</Profile>
