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
private class API_NPSP_TEST {
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
    * @description Test if TDTM_Glue disabled ACCT_Accounts_TDTM, ACCT_IndividualAccounts_TDTM,
    * ADDR_Contact_TDTM, ADDR_Account_TDTM
    */
    @isTest
    static void testGetDefaultTdtmConfigTokens() {
        API_NPSP apiNPSP = new API_NPSP();
        List<npsp__Trigger_Handler__c> triggerHandlers = apiNPSP.getDefaultTdtmConfigNpspRecords(null);
        Map<String, Boolean> activeMap = new Map<String, Boolean>();
        Map<String, Decimal> loadOrderMap = new Map<String, Decimal>();
        for(npsp__Trigger_Handler__c th : triggerHandlers) {
            activeMap.put(th.npsp__Class__c, th.npsp__Active__c);
            loadOrderMap.put(th.npsp__Class__c, th.npsp__Load_Order__c);
        }

        system.assertEquals(false, activeMap.get('ACCT_Accounts_TDTM'));
        system.assertEquals(false, activeMap.get('ACCT_IndividualAccounts_TDTM'));
        system.assertEquals(false, activeMap.get('ADDR_Contact_TDTM'));
        system.assertEquals(false, activeMap.get('ADDR_Account_TDTM'));
        system.assertEquals(1, loadOrderMap.get('OPP_OpportunityContactRoles_TDTM'));
    }
}