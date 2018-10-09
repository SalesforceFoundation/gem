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
    * @description Hold active/inactive NPSP Trigger Hanlder in a map, to avoid repetitive soql calls
    *********************************************************************************************************/
    @TestVisible
    private static Map<String, Boolean> npspTriggerHandlerActiveMap;

    /*******************************************************************************************************
   * @description Hold HEDA's Administrative Account Record Type Id
   *********************************************************************************************************/
    @TestVisible
    private static String adminAccountRecTypeId;

    /*******************************************************************************************************
   * @description Hold HEDA's Household Account Record Type Id
   *********************************************************************************************************/
    @TestVisible
    private static String hhAccountRecTypeId;

    /*******************************************************************************************************
    * @description Returns the default TDTM configuration for HEDA
    * Inject any additional TDTM trigger handler if needed
    * @return List<TDTM_Global_API.TdtmToken> A list of HEDA tokens
    *******************************************************************************************************/
    public List<hed.TDTM_Global_API.TdtmToken> getDefaultTdtmConfigTokens() {
        List<hed.TDTM_Global_API.TdtmToken> hedaTokens = new List<hed.TDTM_Global_API.TdtmToken>();
        List<hed__Trigger_Handler__c> tdtmConfig = [select hed__Class__c, hed__Object__c, hed__Trigger_Action__c, hed__Load_Order__c, hed__Active__c,
                hed__Asynchronous__c, hed__Filter_Field__c, hed__Filter_Value__c, hed__User_Managed__c, hed__Owned_by_Namespace__c, hed__Usernames_to_Exclude__c from hed__Trigger_Handler__c];
        if(tdtmConfig.size() == 0) {
            hedaTokens = hed.TDTM_Global_API.getDefaultTdtmConfig();
        }

        for(hed__Trigger_Handler__c handler : tdtmConfig) {
            hedaTokens.add(new hed.TDTM_Global_API.TdtmToken(handler.hed__Class__c, handler.hed__Object__c, handler.hed__Trigger_Action__c,
                    handler.hed__Load_Order__c, handler.hed__Active__c, handler.hed__Asynchronous__c,
                    handler.hed__Filter_Field__c, handler.hed__Filter_Value__c, handler.hed__User_Managed__c, handler.hed__Owned_by_Namespace__c, handler.hed__Usernames_to_Exclude__c));
        }

        //Check if NPSP ACCT_Accounts_TDTM is active in database, we do not want to inject the logic if it is inactive
        if(getNPSPTriggerActiveMap().get('ACCT_Accounts_TDTM') == true) {
            //We disabled NPSP ACCT_Account_TDTM to avoid conflict. Since the logic in ACCT_Account_TDTM is needed for NPSP, we need to add equivalent trigger handler to HEDA.
            String npspAccountTrigger = UTIL_Namespace.getNamespace()  == '' ? 'NPSP_Account_TDTM' : UTIL_Namespace.getNamespace()  + '.' + 'NPSP_Account_TDTM';
            hedaTokens.add(new hed.TDTM_Global_API.TdtmToken(npspAccountTrigger, 'Account', 'BeforeInsert;BeforeUpdate;AfterUpdate', 1.0, true, false, null, null, false, 'adv', null));
        }


        return hedaTokens;
    }

    /*******************************************************************************************************
    * @description Returns the default TDTM configuration for NPSP
    * Deactivate some trigger handlers if it conflicts with HEDA(cause HEDA test cases to fail)
    * @param listTH The list of Trigger handler record for further processing
    * @return List<Trigger_Handler__c> The list of Trigger Handler record for TDTM to use
    *******************************************************************************************************/
    public List<npsp__Trigger_Handler__c> getDefaultTdtmConfigRecords(List<npsp__Trigger_Handler__c> listTH) {
        //Do the similar thing as NPSP token logic:
        // If the cached Trigger handler is empty, then query the database. otherwise just return the cached one.
        if(listTH == null) {
            listTH = [select npsp__Asynchronous__c, npsp__Class__c, npsp__Load_Order__c, npsp__Object__c, npsp__Active__c, npsp__Usernames_to_Exclude__c,
                    npsp__Trigger_Action__c, npsp__User_Managed__c from npsp__Trigger_Handler__c order by npsp__Load_Order__c];

        }

        //deactivate the Trigger Handler that conflict with HEDA
       for(npsp__Trigger_Handler__c th : listTH) {
            if(
                    th.npsp__Class__c == 'ACCT_Accounts_TDTM' && th.npsp__Object__c == 'Account'
                              || th.npsp__Class__c == 'ACCT_IndividualAccounts_TDTM' && th.npsp__Object__c == 'Contact'
                              || th.npsp__Class__c == 'ADDR_Contact_TDTM' && th.npsp__Object__c == 'Contact'
                            || th.npsp__Class__c == 'ADDR_Account_TDTM' && th.npsp__Object__c == 'Account'
                ) {
                th.npsp__Active__c = false;
            }
        }

        return listTH;
    }

    /********************************************************************************************************
    * @description Returns a map of all NPSP trigger handlers and its corresponding status
    * from database (active or inactive)
    * @return Map<String, Boolean> List of trigger handler tokens with the default values
    *********************************************************************************************************/
    public static Map<String, Boolean> getNPSPTriggerActiveMap() {
        if (npspTriggerHandlerActiveMap != null && npspTriggerHandlerActiveMap.size() > 0) {
            return npspTriggerHandlerActiveMap;
        }
        npspTriggerHandlerActiveMap = new Map<String, Boolean>();
        List<npsp__Trigger_Handler__c> listTH = [select npsp__Asynchronous__c, npsp__Class__c, npsp__Load_Order__c, npsp__Object__c, npsp__Active__c, npsp__Usernames_to_Exclude__c,
                npsp__Trigger_Action__c, npsp__User_Managed__c from npsp__Trigger_Handler__c order by npsp__Load_Order__c];
        if(listTH != null && listTH.size() > 0) {
            for(npsp__Trigger_Handler__c th: listTH) {
                npspTriggerHandlerActiveMap.put(th.npsp__Class__c, th.npsp__Active__c);
            }
        }
        return npspTriggerHandlerActiveMap;
    }

    /********************************************************************************************************
    * @description Update the NPSP Account Model setting based on the HEDA Account model when needed
    * @return Boolean Determine if we need to populate the NPSP Account fields, if the current model is not Admin or HH
    *         then the Account fields should all be empty
    *********************************************************************************************************/
    public static Boolean updateNPSPAccountModel() {

        //If adminAccountRecTypeId is empty, try to populate it
        if(String.isBlank(adminAccountRecTypeId)) {
            adminAccountRecTypeId = hed.UTIL_Describe_API.getAdminAccRecTypeID();
        }

        //If hhAccountRecTypeId is empty, try to populate it
        if(String.isBlank(hhAccountRecTypeId)) {
            hhAccountRecTypeId = hed.UTIL_Describe_API.getHhAccRecTypeID();
        }

        hed__Hierarchy_Settings__c hedaOrgSettings = hed.UTIL_CustomSettings_API.getOrgSettings();

        npe01__Contacts_And_Orgs_Settings__c npspOrgSettings = npsp.UTIL_CustomSettings_API.getContactsSettings();

        if(hedaOrgSettings == null || npspOrgSettings == null) {
            return false;
        }

        if(hedaOrgSettings.hed__Account_Processor__c == adminAccountRecTypeId) {
            if (npspOrgSettings.npe01__Account_Processor__c != npsp.CAO_Constants_API.ONE_TO_ONE_ORGANIZATION_TYPE ||
                    npspOrgSettings.npe01__One_to_One_RecordTypeID__c != hedaOrgSettings.hed__Account_Processor__c) {
                npspOrgSettings.npe01__Account_Processor__c = npsp.CAO_Constants_API.ONE_TO_ONE_ORGANIZATION_TYPE;
                npspOrgSettings.npe01__One_to_One_RecordTypeID__c = hedaOrgSettings.hed__Account_Processor__c;
                UTIL_CustomSettingsFacade.setNPSPOrgContactsSettings(npspOrgSettings);
            }
            return true;
        } else if(hedaOrgSettings.hed__Account_Processor__c == hhAccountRecTypeId) {
            if(npspOrgSettings.npe01__Account_Processor__c != npsp.CAO_Constants_API.HH_ACCOUNT_TYPE ||
                    npspOrgSettings.npe01__HH_Account_RecordTypeID__c != hedaOrgSettings.hed__Account_Processor__c) {
                npspOrgSettings.npe01__Account_Processor__c = npsp.CAO_Constants_API.HH_ACCOUNT_TYPE;
                npspOrgSettings.npe01__HH_Account_RecordTypeID__c = hedaOrgSettings.hed__Account_Processor__c;
                UTIL_CustomSettingsFacade.setNPSPOrgContactsSettings(npspOrgSettings);
            }
            return true;
        } else {
            return false;
        }
    }
}