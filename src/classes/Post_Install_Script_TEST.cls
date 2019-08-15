/*
    © 2019, Salesforce.org.
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
        GEM_Settings__c gemSettings = UTIL_CustomSettingsFacade.getOrgGemSettings();
        gemSettings.Sync_Account_Models__c = true;
        UTIL_CustomSettingsFacade.getOrgGemSettingsForTests(gemSettings);

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

        //Verify that Data Import settings have been added
        npsp__Data_Import_Settings__c diSettings = npsp__Data_Import_Settings__c.getOrgDefaults();
        System.assertEquals(npsp.BDI_DataImport_API.ExactMatchOrCreate, diSettings.npsp__Donation_Matching_Behavior__c);
        System.assertEquals('npsp__donation_date__c;npsp__donation_name__c', diSettings.npsp__Donation_Matching_Rule__c);

        //Check that default TDTM triggers were added
        List<hed__Trigger_Handler__c> hedaTriggers = [SELECT hed__Class__c, hed__Object__c,
            hed__Active__c, hed__Load_Order__c
            FROM hed__Trigger_Handler__c
            ORDER BY hed__Class__c ASC];
        hed__Trigger_Handler__c afflSync = hedaTriggers[0];
        hed__Trigger_Handler__c relSync = hedaTriggers[1];
        
        String syncAfflRecords = AFFL_SyncToNPSP_TDTM.class.toString();
        String syncRelRecords = REL_SyncToNPSP_TDTM.class.toString();

        System.assertEquals(2, hedaTriggers.size());

        System.assertEquals('Affiliation__c', afflSync.hed__Object__c);
        System.assertEquals(syncAfflRecords, afflSync.hed__Class__c);
        System.assertEquals(true, afflSync.hed__Active__c);
        System.assertEquals(0, afflSync.hed__Load_Order__c);

        System.assertEquals('Relationship__c', relSync.hed__Object__c);
        System.assertEquals(syncRelRecords, relSync.hed__Class__c);
        System.assertEquals(true, relSync.hed__Active__c);
        System.assertEquals(0, relSync.hed__Load_Order__c);
    }


    /**
     * Do our best to simulate NPSP being installed after HEDA.
     */
    @isTest
    static void adminAccountUpdate() {

        //Insert HEDA Trigger Handlers
        List<hed.TDTM_Global_API.TdtmToken> hedaTokens = hed.TDTM_Global_API.getDefaultTdtmConfig();
        hed.TDTM_Global_API.setTdtmConfig(hedaTokens);

        Post_Install_Script.insertTdtmDefaults();

        //Insert NPSP Trigger Handlers, but deactivated because otherwise NPSP will do this for us when running a test
        List<npsp__Trigger_Handler__c> npspHandlers = npsp.TDTM_Config_API.getDefaultRecords();
        for(npsp__Trigger_Handler__c th : npspHandlers) {
            th.npsp__Active__c = false;
        }
        insert npspHandlers;

        Contact co = new Contact(
            FirstName = 'Test',
            LastName = 'Name'
        );

        insert co;
        co = [SELECT Id, AccountId FROM Contact WHERE Id = :co.Id];

        Account ac = [
                SELECT Id, Type, RecordTypeId, RecordType.Name, npe01__SYSTEM_AccountType__c, npe01__SYSTEMIsIndividual__c
                FROM Account WHERE Id = :co.AccountId
        ];

        // assert initial state
        System.assertEquals(false, ac.npe01__SYSTEMIsIndividual__c);
        System.assertEquals(null, ac.npe01__SYSTEM_AccountType__c);

        // reactivate our trigger handlers to simulate NPSP/GEM being installed
        for(npsp__Trigger_Handler__c th : npspHandlers) {
            th.npsp__Active__c = true;
        }
        update npspHandlers;

        Test.startTest();

        Post_Install_Script.queueAccountProcessor();

        Test.stopTest();

        ac = [
                SELECT Id, Type, RecordTypeId, RecordType.Name, npe01__SYSTEM_AccountType__c, npe01__SYSTEMIsIndividual__c
                FROM Account WHERE Id = :co.AccountId
        ];

        System.assertEquals(true, ac.npe01__SYSTEMIsIndividual__c);
        System.assertEquals('One-to-One Individual', ac.npe01__SYSTEM_AccountType__c);
        System.assertEquals(null, ac.Type);
    }

    @isTest
    static void householdAccountUpdate() {
        //Insert HEDA Trigger Handlers
        List<hed.TDTM_Global_API.TdtmToken> hedaTokens = hed.TDTM_Global_API.getDefaultTdtmConfig();
        hed.TDTM_Global_API.setTdtmConfig(hedaTokens);


        //Insert NPSP Trigger Handlers, but deactivated. Otherwise NPSP creates these records on its own.
        List<npsp__Trigger_Handler__c> npspHandlers = npsp.TDTM_Config_API.getDefaultRecords();
        for(npsp__Trigger_Handler__c th : npspHandlers) {
            th.npsp__Active__c = false;
        }
        insert npspHandlers;

        Post_Install_Script.insertTdtmDefaults();

        Account ac = new Account(
                Name = 'Test Household Acct',
                RecordTypeId = hed.UTIL_Describe_API.getHhAccRecTypeID()
        );

        insert ac;

        ac = [
                SELECT Id, Type, RecordTypeId, RecordType.Name, npe01__SYSTEM_AccountType__c, npe01__SYSTEMIsIndividual__c
                FROM Account WHERE Id = :ac.Id
        ];

        // assert initial state
        System.assertEquals(false, ac.npe01__SYSTEMIsIndividual__c);
        System.assertEquals(null, ac.npe01__SYSTEM_AccountType__c);

        // reactivate our trigger handlers to simulate NPSP/GEM being installed
        for(npsp__Trigger_Handler__c th : npspHandlers) {
            th.npsp__Active__c = true;
        }
        update npspHandlers;

        Test.startTest();

        Post_Install_Script.queueAccountProcessor();

        Test.stopTest();

        ac = [
                SELECT Id, Type, RecordTypeId, RecordType.Name, npe01__SYSTEM_AccountType__c, npe01__SYSTEMIsIndividual__c
                FROM Account WHERE Id = :ac.Id
        ];

        System.assertEquals(true, ac.npe01__SYSTEMIsIndividual__c);
        System.assertEquals('Household Account', ac.npe01__SYSTEM_AccountType__c);
        System.assertEquals('Household', ac.Type);
    }
}