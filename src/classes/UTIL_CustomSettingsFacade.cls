/*
    Copyright (c) 2018, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2018
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description Helper class that retrieves custom settings and sets defaults.
* Needs to be "without sharing" so that the Install Script can run it.
*/

public without sharing class UTIL_CustomSettingsFacade {

    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests
    * @param mySettings Settings instance with the values to set
    *******************************************************************************************************/
    public static void setHEDASettingForTest(hed__Hierarchy_Settings__c mySettings) {

        hed__Hierarchy_Settings__c hedaSettings = new hed__Hierarchy_Settings__c();

        //create our own based on what's passed in from the test
        hedaSettings.hed__Account_Processor__c = mySettings.hed__Account_Processor__c;
        hedaSettings.hed__Accounts_Addresses_Enabled__c = mySettings.hed__Accounts_Addresses_Enabled__c;
        hedaSettings.hed__Contacts_Addresses_Enabled__c = mySettings.hed__Contacts_Addresses_Enabled__c;
        hedaSettings.hed__Simple_Address_Change_Treated_as_Update__c = mySettings.hed__Simple_Address_Change_Treated_as_Update__c;
        hedaSettings.hed__Household_Addresses_RecType__c = mySettings.hed__Household_Addresses_RecType__c;
        hedaSettings.hed__Reciprocal_Method__c = mySettings.hed__Reciprocal_Method__c;
        hedaSettings.hed__Error_Notifications_On__c = mySettings.hed__Error_Notifications_On__c;
        hedaSettings.hed__Error_Notifications_To__c = mySettings.hed__Error_Notifications_To__c;
        hedaSettings.hed__Store_Errors_On__c = mySettings.hed__Store_Errors_On__c;
        hedaSettings.hed__Async_Error_Check_Last_Run__c = mySettings.hed__Async_Error_Check_Last_Run__c;
        hedaSettings.hed__Affl_ProgEnroll_Del__c = mySettings.hed__Affl_ProgEnroll_Del__c;
        hedaSettings.hed__Affl_ProgEnroll_Del_Status__c = mySettings.hed__Affl_ProgEnroll_Del_Status__c;
        hedaSettings.hed__Accounts_to_Delete__c =  mySettings.hed__Accounts_to_Delete__c;
        hedaSettings.hed__Enable_Course_Connections__c = mySettings.hed__Enable_Course_Connections__c;
        hedaSettings.hed__Faculty_RecType__c = mySettings.hed__Faculty_RecType__c;
        hedaSettings.hed__Student_RecType__c = mySettings.hed__Student_RecType__c;
        hedaSettings.hed__Disable_Preferred_Email_Enforcement__c = mySettings.hed__Disable_Preferred_Email_Enforcement__c;
        hedaSettings.hed__Household_Account_Naming_Format__c = mySettings.hed__Household_Account_Naming_Format__c;
        hedaSettings.hed__Automatic_Household_Naming__c = mySettings.hed__Automatic_Household_Naming__c;

        insert hedaSettings;

    }

    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests
    * @parameter mySettings Settings instance with the values to set
    *******************************************************************************************************/
    public static void setNPSPContactsSettingsForTests(npe01__Contacts_And_Orgs_Settings__c mySettings) {

        npe01__Contacts_And_Orgs_Settings__c contactsSettings = new npe01__Contacts_And_Orgs_Settings__c();

        //create our own based on what's passed in from the test
        contactsSettings.npe01__One_to_One_RecordTypeID__c = mySettings.npe01__One_to_One_RecordTypeID__c;
        contactsSettings.npe01__HH_Account_RecordTypeID__c = mySettings.npe01__HH_Account_RecordTypeID__c;
        contactsSettings.npe01__Account_Processor__c = mySettings.npe01__Account_Processor__c;
        contactsSettings.npe01__Enable_Opportunity_Contact_Role_Trigger__c = mySettings.npe01__Enable_Opportunity_Contact_Role_Trigger__c;
        contactsSettings.npe01__Opportunity_Contact_Role_Default_role__c = mySettings.npe01__Opportunity_Contact_Role_Default_role__c;
        contactsSettings.npe01__Disable_Account_Model_Trigger__c = mySettings.npe01__Disable_Account_Model_Trigger__c;
        contactsSettings.npe01__Payments_Enabled__c = mySettings.npe01__Payments_Enabled__c;
        contactsSettings.npsp__Opp_RecTypes_Excluded_for_Payments__c = mySettings.npsp__Opp_RecTypes_Excluded_for_Payments__c;
        contactsSettings.npsp__Opp_Types_Excluded_for_Payments__c = mySettings.npsp__Opp_Types_Excluded_for_Payments__c;
        contactsSettings.npsp__Automatic_Campaign_Member_Management__c = mySettings.npsp__Automatic_Campaign_Member_Management__c;
        contactsSettings.npsp__Campaign_Member_Responded_Status__c = mySettings.npsp__Campaign_Member_Responded_Status__c;
        contactsSettings.npsp__Campaign_Member_Non_Responded_Status__c = mySettings.npsp__Campaign_Member_Non_Responded_Status__c;
        contactsSettings.npsp__Organizational_Account_Addresses_Enabled__c = mySettings.npsp__Organizational_Account_Addresses_Enabled__c;
        contactsSettings.npsp__Simple_Address_Change_Treated_as_Update__c = mySettings.npsp__Simple_Address_Change_Treated_as_Update__c;
        contactsSettings.npsp__Household_Account_Addresses_Disabled__c = mySettings.npsp__Household_Account_Addresses_Disabled__c;
        contactsSettings.npsp__Payments_Auto_Close_Stage_Name__c = mySettings.npsp__Payments_Auto_Close_Stage_Name__c;
        contactsSettings.npsp__Honoree_Opportunity_Contact_Role__c = mySettings.npsp__Honoree_Opportunity_Contact_Role__c;
        contactsSettings.npsp__Notification_Recipient_Opp_Contact_Role__c = mySettings.npsp__Notification_Recipient_Opp_Contact_Role__c;

        insert contactsSettings;
    }

    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests
    * @parameter mySettings Settings instance with the values to set
    *******************************************************************************************************/
    public static void setNPSPHouseholdsSettingsForTests(npo02__Households_Settings__c mySettings) {

        npo02__Households_Settings__c householdsSettings = new npo02__Households_Settings__c();

        //create our own based on what's passed in from the test
        householdsSettings.npo02__Household_Rules__c = mySettings.npo02__Household_Rules__c;
        householdsSettings.npo02__Household_Contact_Roles_On__c = mySettings.npo02__Household_Contact_Roles_On__c;
        householdsSettings.npo02__Household_Member_Contact_Role__c = mySettings.npo02__Household_Member_Contact_Role__c;
        householdsSettings.npo02__Always_Rollup_to_Primary_Contact__c = mySettings.npo02__Always_Rollup_to_Primary_Contact__c;
        householdsSettings.npo02__Enable_Opp_Rollup_Triggers__c = mySettings.npo02__Enable_Opp_Rollup_Triggers__c;
        householdsSettings.npo02__Excluded_Account_Opp_Rectypes__c = mySettings.npo02__Excluded_Account_Opp_Rectypes__c;
        householdsSettings.npo02__Excluded_Account_Opp_Types__c = mySettings.npo02__Excluded_Account_Opp_Types__c;
        householdsSettings.npo02__Excluded_Contact_Opp_Rectypes__c = mySettings.npo02__Excluded_Contact_Opp_Rectypes__c;
        householdsSettings.npo02__Excluded_Contact_Opp_Types__c = mySettings.npo02__Excluded_Contact_Opp_Types__c;
        householdsSettings.npo02__Membership_Grace_Period__c = mySettings.npo02__Membership_Grace_Period__c;
        householdsSettings.npo02__Rollup_N_Day_Value__c = mySettings.npo02__Rollup_N_Day_Value__c;
        householdsSettings.npo02__Membership_Record_Types__c = mySettings.npo02__Membership_Record_Types__c;
        householdsSettings.npo02__Advanced_Household_Naming__c = mySettings.npo02__Advanced_Household_Naming__c;
        householdsSettings.npo02__Enable_Soft_Credit_Rollups__c = mySettings.npo02__Enable_Soft_Credit_Rollups__c;
        householdsSettings.npo02__Soft_Credit_Roles__c = mySettings.npo02__Soft_Credit_Roles__c;
        householdsSettings.npsp__Matched_Donor_Role__c = mySettings.npsp__Matched_Donor_Role__c;
        householdsSettings.npo02__Household_OCR_Excluded_Recordtypes__c = mySettings.npo02__Household_OCR_Excluded_Recordtypes__c;
        householdsSettings.npo02__Household_Creation_Excluded_Recordtypes__c = mySettings.npo02__Household_Creation_Excluded_Recordtypes__c;
        householdsSettings.npo02__Household_Mailing_List_ID__c = mySettings.npo02__Household_Mailing_List_ID__c;
        householdsSettings.npo02__Schedule_Job_Limit__c = 25;

        insert householdsSettings;
    }

    /*******************************************************************************************************
    * @description Updates the provided Contacts and Orgs settings if not running tests
    * @return void
    ********************************************************************************************************/
    public static void setNPSPOrgContactsSettings(npe01__Contacts_And_Orgs_Settings__c orgContactsSettings) {
         if (!Test.isRunningTest()) {
            update orgContactsSettings;
        }
    }

}