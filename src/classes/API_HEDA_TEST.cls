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
* @group TDTM
* @group-content ../../ApexDocContent/TDTM.htm
* @description Testing the enhanced TDTM functionality, which applies only to certain records
* depending on their field values.
*/
@isTest
private class API_HEDA_TEST {

    @testSetup
    static void setupTriggerHandlers() {
        //Insert HEDA Trigger Handlers
        List<hed.TDTM_Global_API.TdtmToken> hedaTokens = hed.TDTM_Global_API.getDefaultTdtmConfig();
        hed.TDTM_Global_API.setTdtmConfig(hedaTokens);

        //Insert NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> npspHandlers = npsp.TDTM_Config_API.getDefaultRecords();
        insert npspHandlers;

        //Set HEDA custom setting
        UTIL_CustomSettingsFacade.setHEDASettingForTest(new hed__Hierarchy_Settings__c(hed__Account_Processor__c = UTIL_Describe.getHhAccRecTypeID()));

        //Set the NPSP Contact setting
        UTIL_CustomSettingsFacade.setNPSPContactsSettingsForTests(new npe01__Contacts_and_Orgs_Settings__c (
                npe01__Account_Processor__c = 'Household Account',
                npe01__Enable_Opportunity_Contact_Role_Trigger__c = true,
                npe01__Opportunity_Contact_Role_Default_role__c = 'Donor'
        ));

        //Set NPSP Household setting
        UTIL_CustomSettingsFacade.setNPSPHouseholdsSettingsForTests(
                new npo02__Households_Settings__c (
                        npo02__Household_Rules__c = 'All New or Edited Contacts',
                        npo02__Always_Rollup_to_Primary_Contact__c = false,
                        npo02__Enable_Opp_Rollup_Triggers__c = true,
                        npo02__Excluded_Account_Opp_Rectypes__c = null,
                        npo02__Excluded_Account_Opp_Types__c = null,
                        npo02__Excluded_Contact_Opp_Rectypes__c = null,
                        npo02__Excluded_Contact_Opp_Types__c = null,
                        npo02__Membership_Record_Types__c = null
                ));

        Date datClose = System.Today();

        //Create new Contacts
        List<Contact> consToInsert = new List<Contact>();

        Contact con1 = UTIL_UnitTestData_TEST.getContact();
        consToInsert.add(con1);

        Contact con2 = UTIL_UnitTestData_TEST.getContact();
        consToInsert.add(con2);

        insert consToInsert;

        con1 = [SELECT Id, AccountId FROM Contact where Id =: con1.Id];

        con2 = [SELECT Id, AccountId FROM Contact where Id =: con2.Id];

        //Add new Opportunity to Account
        List<Opportunity> oppToInsert = new List<Opportunity>();

        Opportunity newOpp1 =
                new Opportunity (
                        name = 'testopp',
                        accountId = con1.AccountId,
                        stagename=UTIL_UnitTestData_TEST.getClosedWonStage(),
                        closedate=datClose, amount= 10000
                );
        oppToInsert.add(newOpp1);

        Opportunity newOpp2 =
                new Opportunity (
                        name = 'testopp',
                        accountId = con2.AccountId,
                        stagename=UTIL_UnitTestData_TEST.getClosedWonStage(),
                        closedate=datClose, amount= 10000
                );
        oppToInsert.add(newOpp2);

        insert oppToInsert;
    }

    /*******************************************************************************************************
    * @description Test if Adv add NPSP_Account_TDTM into HEDA tokens
    */
    @isTest
    static void testGetDefaultTdtmConfigTokens() {
        testGetDefaultTdtmConfigTokensHelper(false);
    }

    /*******************************************************************************************************
    * @description Test if Adv add NPSP_Account_TDTM into HEDA tokens
    */
    @isTest
    static void testGetDefaultTdtmConfigTokensNegative() {
        //If somehow NPSP's ACCT_Accounts_TDTM is inactive, then we do not want to add NPSP_Account_TDTM into HEDA TDTM
        disableTriggerHandler('ACCT_Accounts_TDTM');

        testGetDefaultTdtmConfigTokensHelper(true);
    }

    /*******************************************************************************************************
    * @description Helper method to test the TDTM Config
    */
    static void testGetDefaultTdtmConfigTokensHelper(Boolean isNegative) {
        API_HEDA apiHEDA = new API_HEDA();

        //System should add the NPSP_Account_TDTM token when HEDA request it
        List<hed.TDTM_Global_API.TdtmToken> tokens = apiHEDA.getDefaultTdtmConfigTokens();

        Map<String, Boolean> activeMap = new Map<String, Boolean>();

        for(hed.TDTM_Global_API.TdtmToken token : tokens) {
            activeMap.put(token.className, token.active);
        }

        String npspAccountTrigger = UTIL_Namespace.getNamespace()  == '' ? 'NPSP_Account_TDTM' : UTIL_Namespace.getNamespace()  + '.' + 'NPSP_Account_TDTM';

        if(!isNegative) {
            system.assertEquals(true, activeMap.get(npspAccountTrigger));
        } else {
            system.assertEquals(null, activeMap.get(npspAccountTrigger));
        }
    }

    /*******************************************************************************************************
    * @description Test if Adv recalculate the Total when moving the primary contact from one account to
    * another account
    */
    @isTest
    static void testRollupAccount() {
        testRollupAccountHelper(false);
    }

    /*******************************************************************************************************
    * @description Test if Adv recalculate the Total when moving the primary contact from one account to
    * another account
    */
    @isTest
    static void testRollupAccountNegative() {
        //If somehow NPSP's ACCT_IndividualAccounts_TDTM is inactive, then we do not recalculate rollup
        disableTriggerHandler('ACCT_IndividualAccounts_TDTM');

        testRollupAccountHelper(true);
    }

    /*******************************************************************************************************
    * @description Helper method to test the rollup
    */
    static void testRollupAccountHelper(Boolean isNegative) {
        List<Contact> cons = [SELECT Id, AccountId FROM Contact];
        system.assertEquals(2, cons.size());

        Account acc1 = [Select npo02__TotalOppAmount__c from Account where Id =: cons[0].AccountId];
        system.assertEquals(10000, acc1.npo02__TotalOppAmount__c);

        Account acc2 = [Select npo02__TotalOppAmount__c from Account where Id =: cons[1].AccountId];
        system.assertEquals(10000, acc2.npo02__TotalOppAmount__c);

        cons[0].AccountId = cons[1].AccountId;

        Test.startTest();
        update cons[0];
        Test.stopTest();

        acc1 = [Select npo02__TotalOppAmount__c, (select Id,name from opportunities) from Account where Id =: acc1.Id];
        if(!isNegative) {
            system.assertEquals(0, acc1.npo02__TotalOppAmount__c);
        } else {
            system.assertEquals(10000, acc1.npo02__TotalOppAmount__c);
        }

        acc2 = [Select npo02__TotalOppAmount__c from Account where Id =: acc2.Id];
        if(!isNegative) {
            system.assertEquals(20000, acc2.npo02__TotalOppAmount__c);
        } else {
            system.assertEquals(10000, acc2.npo02__TotalOppAmount__c);
        }
    }

    /*******************************************************************************************************
    * @description Test if Adv move the opportunity when moving the primary contact from one account to
    * another account
    */
    @isTest
    static void testMoveOppsToContactAccount() {
        testMoveOppsToContactAccountHelper(false);
    }

    /*******************************************************************************************************
    * @description Test if Adv move the opportunity when moving the primary contact from one account to
    * another account
    */
    @isTest
    static void testMoveOppsToContactAccountNegative() {
        //If somehow NPSP's ACCT_IndividualAccounts_TDTM is inactive, then we do not move opportunity
        disableTriggerHandler('ACCT_IndividualAccounts_TDTM');

        testMoveOppsToContactAccountHelper(true);
    }

    /*******************************************************************************************************
    * @description Helper method to test Move Opportunity
    */
    static void testMoveOppsToContactAccountHelper(Boolean isNegative) {
        List<Contact> cons = [SELECT Id, AccountId FROM Contact];
        system.assertEquals(2, cons.size());

        Account acc1 = [Select Id, (select Id,name from opportunities) from Account where Id =: cons[0].AccountId];
        system.assertEquals(1, acc1.opportunities.size());

        Account acc2 = [Select Id, (select Id,name from opportunities) from Account where Id =: cons[1].AccountId];
        system.assertEquals(1, acc2.opportunities.size());

        cons[0].AccountId = cons[1].AccountId;

        Test.startTest();
        update cons[0];
        Test.stopTest();

        acc1 = [Select Id, (select Id,name from opportunities) from Account where Id =: acc1.Id];
        if(!isNegative) {
            system.assertEquals(0, acc1.opportunities.size());
        } else {
            system.assertEquals(1, acc1.opportunities.size());
        }


        acc2 = [Select Id, (select Id,name from opportunities) from Account where Id =: acc2.Id];
        if(!isNegative) {
            system.assertEquals(2, acc2.opportunities.size());
        } else {
            system.assertEquals(1, acc2.opportunities.size());
        }
    }

    /*******************************************************************************************************
    * @description Test if Adv set the primary contact on the Account
    */
    @isTest
    static void testPrimaryContact() {
        reInsertContact();

        Contact con = [SELECT Id, AccountId FROM Contact];

        Account a = [Select npe01__One2OneContact__c from Account where Id =:con.AccountId];
        system.assertEquals(con.Id, a.npe01__One2OneContact__c);
    }

    /*******************************************************************************************************
    * @description Test if Adv set the primary contact on the Account
    */
    @isTest
    static void testPrimaryContactNegative() {
        //If somehow NPSP's ACCT_IndividualAccounts_TDTM is inactive, then we do not fill in primary contact
        disableTriggerHandler('ACCT_IndividualAccounts_TDTM');

        reInsertContact();

        Contact con = [SELECT Id, AccountId FROM Contact];

        Account a = [Select npe01__One2OneContact__c from Account where Id =:con.AccountId];
        system.assertEquals(null, a.npe01__One2OneContact__c);
    }

    /*******************************************************************************************************
    * @description Test if Adv set all the NPSP account fields
    */
    @isTest
    static void testConfigAccountForContact() {
        reInsertContact();

        Contact con = [SELECT Id, AccountId FROM Contact];

        Account a = [Select Type, npe01__SYSTEM_AccountType__c, npe01__SYSTEMISINDIVIDUAL__c from Account where Id =:con.AccountId];
        system.assertEquals('Household', a.Type);
        system.assertEquals('Household Account', a.npe01__SYSTEM_AccountType__c);
        system.assertEquals(true, a.npe01__SYSTEMISINDIVIDUAL__c);
    }

    /*******************************************************************************************************
    * @description Test if Adv set all the NPSP account fields
    */
    @isTest
    static void testConfigAccountForContactNegative() {
        //If somehow NPSP's ACCT_IndividualAccounts_TDTM is inactive, then we do not fill in npsp system fields
        disableTriggerHandler('ACCT_IndividualAccounts_TDTM');

        reInsertContact();

        Contact con = [SELECT Id, AccountId FROM Contact];

        Account a = [Select Type, npe01__SYSTEM_AccountType__c, npe01__SYSTEMISINDIVIDUAL__c from Account where Id =:con.AccountId];
        system.assertEquals(null, a.Type);
        system.assertEquals(null, a.npe01__SYSTEM_AccountType__c);
        system.assertEquals(false, a.npe01__SYSTEMISINDIVIDUAL__c);
    }

    /*******************************************************************************************************
    * @description Helper method to re insert Contact
    */
    static void reInsertContact() {
        delete [Select Id from Contact];
        Contact con = UTIL_UnitTestData_TEST.getContact();
        Test.startTest();
        insert con;
        Test.stopTest();
    }

    /*******************************************************************************************************
    * @description Helper method to disable npsp trigger handler
    */
    static void disableTriggerHandler(String triggerHandler) {
        npsp__Trigger_Handler__c th = [Select npsp__Active__c from npsp__Trigger_Handler__c where npsp__Class__c =:triggerhandler];
        th.npsp__Active__c = false;
        update th;
    }
}