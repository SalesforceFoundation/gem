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
* @group Settings
* @group-content ../../ApexDocContent/Settings.htm
* @description Test Class for the Install Script for the ADV package.
*/
@isTest
public with sharing class Post_Install_Script_TEST {

    @isTest
    static void onInstall() {
        //Set HEDA Account Model to Administrative
        hed__Hierarchy_Settings__c hedaOrgSettings = hed.UTIL_CustomSettings_API.getOrgSettings();
        hedaOrgSettings.hed__Account_Processor__c = hed.UTIL_Describe_API.getAdminAccRecTypeID();
        hed.UTIL_CustomSettings_API.getSettingsForTests(hedaOrgSettings);

        //Set NPSP Account Model to Household
        npe01__Contacts_And_Orgs_Settings__c npspOrgSettings = npsp.UTIL_CustomSettings_API.getContactsSettings();
        npspOrgSettings.npe01__Account_Processor__c = npsp.CAO_Constants_API.HH_ACCOUNT_TYPE;

        Test.startTest();
        //Run the install script
        Test.testInstall(new Post_Install_Script(), null);
        Test.stopTest();

        //Verify that the NPSP Account Model now becomes One-to-One
        npspOrgSettings = npsp.UTIL_CustomSettings_API.getContactsSettings();
        system.assertEquals(npsp.CAO_Constants_API.ONE_TO_ONE_PROCESSOR,
          npspOrgSettings.npe01__Account_Processor__c);
        system.assertEquals(hedaOrgSettings.hed__Account_Processor__c,
          npspOrgSettings.npe01__One_to_One_RecordTypeID__c);
    }
}