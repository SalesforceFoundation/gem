/*
    Copyright (c) 2017, Salesforce.org
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
* @date 2017
* @group
* @group-content
* @description Helper class that retrieves custom settings and sets defaults for NPSP
**/
public with sharing class Adv_UtilCustomSettingsFacade {
    static npe01__Contacts_And_Orgs_Settings__c contactsSettings;

    static npe01__Contacts_And_Orgs_Settings__c orgContactsSettings;

    /*******************************************************************************************************
    * @description Returns the default Contacts and Orgs settings.
    * @return npe01__Contacts_And_Orgs_Settings__c Custom settings record for Contacts and Orgs configuration.
    * At the org level, if no user level settings are defined. The ID field should be checked to determine if
    * the returned record already exists or doesn't exist in the database.
    */
    public static npe01__Contacts_And_Orgs_Settings__c getContactsSettings() {
        if(Test.isRunningTest() && contactsSettings == null) {
            contactsSettings = new npe01__Contacts_And_Orgs_Settings__c();
            configContactsSettings(contactsSettings);
        } else if (contactsSettings == null) {
            contactsSettings = npe01__Contacts_And_Orgs_Settings__c.getInstance();
            if(contactsSettings.Id == null)
                contactsSettings = getOrgContactsSettings();
        }
        return contactsSettings;
    }

    /*******************************************************************************************************
     * Private methods that will configure the default org-level custom settings.
     **/
    private static void configContactsSettings(npe01__Contacts_And_Orgs_Settings__c cs) {
        //this setting does nothing, but needs to be extracted from the tests before removing
        cs.npe01__Enable_Opportunity_Contact_Role_Trigger__c = false;
        cs.npe01__Payments_Enabled__c  = true;
        cs.npe01__Opportunity_Contact_Role_Default_role__c = 'Donor';
        cs.npe01__Account_Processor__c = Adv_Constants.HH_ACCOUNT_PROCESSOR;
        cs.npsp3c__Opp_RecTypes_Excluded_for_Payments__c = null;
        cs.npsp3c__Opp_Types_Excluded_for_Payments__c = null;
        Recordtypeinfo householdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Adv_Constants.HH_ACCOUNT_PROCESSOR);
        if(householdAccount != null)
            cs.npe01__HH_Account_RecordTypeID__c = householdAccount.getRecordTypeId();
    }

    /*******************************************************************************************************
    * @description Returns the org-level Contacts and Orgs settings. Default org-level settings will be created
    * if none exist. Meant to be called only from settings page and install script.
    * @return npe01__Contacts_And_Orgs_Settings__c Org-level settings for Contacts and Orgs.
    */
    public static npe01__Contacts_And_Orgs_Settings__c getOrgContactsSettings() {
        if(orgContactsSettings == null) {
            orgContactsSettings = npe01__Contacts_And_Orgs_Settings__c.getOrgDefaults();
            if(orgContactsSettings.Id == null) {
                configContactsSettings(orgContactsSettings);
                orgContactsSettings.Setupownerid = UserInfo.getOrganizationId();
                if(!Test.isRunningTest())
                    upsert orgContactsSettings;
            }
        }
        return orgContactsSettings;
    }
}