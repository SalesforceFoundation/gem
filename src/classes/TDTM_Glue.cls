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
* @group TDTM
* @group-content ../../ApexDocContent/TDTM.htm
* @description This class is used to control what TDTM configuration will be returned to HEDA and NPSP.
**/
public with sharing class TDTM_Glue {

    /*******************************************************************************************************
    * @description Hold active/inactive NPSP Trigger Hanlder in a map, to avoid repetitive soql calls.
    *********************************************************************************************************/
    @TestVisible
    private static Map<String, Boolean> npspTriggerHandlerActiveMap;

    /*******************************************************************************************************
    * @description Returns the default TDTM configuration for HEDA.
    * Inject any additional TDTM trigger handler if needed.
    * @return List<TDTM_Global_API.TdtmToken> A list of HEDA tokens.
    *******************************************************************************************************/
    public List<heda2.TDTM_Global_API.TdtmToken> getDefaultTdtmConfigTokens() {
        List<heda2.TDTM_Global_API.TdtmToken> hedaTokens = new List<heda2.TDTM_Global_API.TdtmToken>();
        List<heda2__Trigger_Handler__c> tdtmConfig = [select heda2__Class__c, heda2__Object__c, heda2__Trigger_Action__c, heda2__Load_Order__c, heda2__Active__c,
                heda2__Asynchronous__c, heda2__Filter_Field__c, heda2__Filter_Value__c, heda2__User_Managed__c, heda2__Owned_by_Namespace__c, heda2__Usernames_to_Exclude__c from heda2__Trigger_Handler__c];
        if(tdtmConfig.size() == 0) {
            hedaTokens = heda2.TDTM_Global_API.getDefaultTdtmConfig();
            //Check if NPSP ACCT_Accounts_TDTM is active in database, we do not want to inject the logic if it is inactive
            if(getNPSPTriggerActiveMap().get('ACCT_Accounts_TDTM') == true) {
                //We disabled NPSP ACCT_Account_TDTM to avoid conflict. Since the logic in ACCT_Account_TDTM is needed for NPSP, we need to add equivalent trigger handler to HEDA.
                hedaTokens.add(new heda2.TDTM_Global_API.TdtmToken('NPSP_Account_TDTM', 'Account', 'BeforeInsert;BeforeUpdate;AfterUpdate', 1.0, true, false, null, null, false, 'adv'));
            }
        }

        for(heda2__Trigger_Handler__c handler : tdtmConfig) {
            hedaTokens.add(new heda2.TDTM_Global_API.TdtmToken(handler.heda2__Class__c, handler.heda2__Object__c, handler.heda2__Trigger_Action__c,
                    handler.heda2__Load_Order__c, handler.heda2__Active__c, handler.heda2__Asynchronous__c,
                    handler.heda2__Filter_Field__c, handler.heda2__Filter_Value__c, handler.heda2__User_Managed__c, handler.heda2__Owned_by_Namespace__c, handler.heda2__Usernames_to_Exclude__c));
        }


        return hedaTokens;
    }

    /*******************************************************************************************************
    * @description Returns the default TDTM configuration for NPSP.
    * Deactivate some trigger handlers if it conflicts with HEDA(cause HEDA test cases to fail).
    * @param listTH The list of Trigger handler record for further processing.
    * @return List<Trigger_Handler__c> The list of Trigger Handler record for TDTM to use.
    *******************************************************************************************************/
    public List<npsp3c__Trigger_Handler__c> getDefaultTdtmConfigRecords(List<npsp3c__Trigger_Handler__c> listTH) {
        //Do the similar thing as NPSP token logic:
        // If the cached Trigger handler is empty, then query the database. otherwise just return the cached one.
        if(listTH == null) {
            listTH = [select npsp3c__Asynchronous__c, npsp3c__Class__c, npsp3c__Load_Order__c, npsp3c__Object__c, npsp3c__Active__c, npsp3c__Usernames_to_Exclude__c,
                    npsp3c__Trigger_Action__c from npsp3c__Trigger_Handler__c order by npsp3c__Load_Order__c];

        }

        //deactivate the Trigger Handler that conflict with HEDA
       for(npsp3c__Trigger_Handler__c th : listTH) {
            if(
                    th.npsp3c__Class__c == 'ACCT_Accounts_TDTM' && th.npsp3c__Object__c == 'Account'
                              || th.npsp3c__Class__c == 'ACCT_IndividualAccounts_TDTM' && th.npsp3c__Object__c == 'Contact'
                              || th.npsp3c__Class__c == 'ADDR_Contact_TDTM' && th.npsp3c__Object__c == 'Contact'
                            || th.npsp3c__Class__c == 'ADDR_Account_TDTM' && th.npsp3c__Object__c == 'Account'
                ) {
                th.npsp3c__Active__c = false;
            }
        }

        return listTH;
    }

    /********************************************************************************************************
    * @description Returns a map of all NPSP trigger handlers and its corresponding status
    * from database (active or inactive)
    * @return Map<String, Boolean> List of trigger handler tokens with the default values.
    *********************************************************************************************************/
    public static Map<String, Boolean> getNPSPTriggerActiveMap() {
        if (npspTriggerHandlerActiveMap != null && npspTriggerHandlerActiveMap.size() > 0) {
            return npspTriggerHandlerActiveMap;
        }
        npspTriggerHandlerActiveMap = new Map<String, Boolean>();
        List<npsp3c__Trigger_Handler__c> listTH = [select npsp3c__Asynchronous__c, npsp3c__Class__c, npsp3c__Load_Order__c, npsp3c__Object__c, npsp3c__Active__c, npsp3c__Usernames_to_Exclude__c,
                npsp3c__Trigger_Action__c from npsp3c__Trigger_Handler__c order by npsp3c__Load_Order__c];
        if(listTH != null && listTH.size() > 0) {
            for(npsp3c__Trigger_Handler__c th: listTH) {
                npspTriggerHandlerActiveMap.put(th.npsp3c__Class__c, th.npsp3c__Active__c);
            }
        }
        return npspTriggerHandlerActiveMap;
    }
}