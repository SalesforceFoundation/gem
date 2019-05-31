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
* @group TDTM
* @group-content ../../ApexDocContent/TDTM.htm
* @description Testing the enhanced TDTM functionality, which applies only to certain records
* depending on their field values.
*/
@isTest
private class NPSP_Account_TDTM_TEST {
    @testSetup
    static void setupTriggerHandlers() {
        //Insert HEDA Trigger Handlers
        List<hed.TDTM_Global_API.TdtmToken> hedaTokens = hed.TDTM_Global_API.getDefaultTdtmConfig();
        hed.TDTM_Global_API.setTdtmConfig(hedaTokens);

        //Insert NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> npspHandlers = npsp.TDTM_Config_API.getDefaultRecords();
        insert npspHandlers;

    }

    /*******************************************************************************************************
    * @description Test if system updates npsp fields when Account record type changes
    */
    @isTest
    static void testAccountTDTM() {
        Account acc = UTIL_UnitTestData_TEST.getAccount(hed.UTIL_Describe_API.getAdminAccRecTypeID());

        insert acc;

        acc = [Select Type, npe01__SYSTEM_AccountType__c, npe01__SYSTEMISINDIVIDUAL__c from Account where Id =: acc.Id];

        system.assertNotEquals(npsp.CAO_Constants_API.HH_TYPE, acc.Type);
        system.assertNotEquals(npsp.CAO_Constants_API.HH_ACCOUNT_TYPE, acc.npe01__SYSTEM_AccountType__c);
        system.assertNotEquals(true, acc.npe01__SYSTEMISINDIVIDUAL__c);

        acc.RecordTypeId = hed.UTIL_Describe_API.getHhAccRecTypeID();

        Test.startTest();
        update acc;
        Test.stopTest();

        acc = [Select Type, npe01__SYSTEM_AccountType__c, npe01__SYSTEMISINDIVIDUAL__c from Account where Id =: acc.Id];

        system.assertEquals(npsp.CAO_Constants_API.HH_TYPE, acc.Type);
        system.assertEquals(npsp.CAO_Constants_API.HH_ACCOUNT_TYPE, acc.npe01__SYSTEM_AccountType__c);
        system.assertEquals(true, acc.npe01__SYSTEMISINDIVIDUAL__c);
    }

    /*******************************************************************************************************
    * @description Test if system does not update npsp fields when Account sync is turned off
    */
    @isTest
    static void testNoSyncAccountTDTM() {
        GEM_Settings__c gemSettings = UTIL_CustomSettingsFacade.getOrgGemSettings();
        gemSettings.Sync_Account_Models__c = false;
        UTIL_CustomSettingsFacade.getOrgGemSettingsForTests(gemSettings);

        Boolean updateModel = TDTM_Glue.updateNPSPAccountModel();
        System.assertEquals(false, updateModel, 'The setting is turned off, there should be no udpate');

        gemSettings.Sync_Account_Models__c = true;
        UTIL_CustomSettingsFacade.getOrgGemSettingsForTests(gemSettings);

        updateModel = TDTM_Glue.updateNPSPAccountModel();
        System.assertEquals(true, updateModel, 'The setting is turned on, there should be an udpate');
    }

    /**
     * @description Test situation when gem namespace not correctly configured. Should catch an exception.
     */
    @isTest
    static void tdtmRunnableTest() {
        Account acc = UTIL_UnitTestData_TEST.getAccount(hed.UTIL_Describe_API.getAdminAccRecTypeID());
        NPSP_Account_TDTM tdtm = new NPSP_Account_TDTM();
        try {
            tdtm.run(new List<Account>{acc}, new List<Account>(), hed.TDTM_Runnable.Action.BeforeInsert, Schema.Account.SObjectType.getDescribe());
        } catch(Exception ex) {
            // always throws adapter exception if namespace not correctly detected.
            System.assertEquals('npsp.ADV_Adapter.AdapterException', ex.getTypeName(), 'Got wrong type of exception');
        }
    }
}