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
* @date 2017
* @group TDTM
* @group-content ../../ApexDocContent/TDTM.htm
* @description This class is used to override the default behavior of the HEDA Advancement Adapter class.
**/
global with sharing class API_HEDA extends hed.Advancement_Adapter {

    private String ACCT_TDTM_CLASS = 'ACCT_IndividualAccounts_TDTM';

    /*******************************************************************************************************
    * @description To be called by the HEDA TDTM trigger dispatcher
    * It returns the HEDA TDTM tokens with the new one from Adv
    * @return List<TDTM_Global_API.TdtmToken> A list of HEDA tokens
    *******************************************************************************************************/
    global override List<hed.TDTM_Global_API.TdtmToken> getDefaultTdtmConfigTokens() {
        TDTM_Glue glue = new TDTM_Glue();
        return glue.getDefaultTdtmConfigTokens();
    }

    /*******************************************************************************************************
    * @description This method is used to inject the NPSP rollup logic into HEDA Trigger Handler
    * @param listAccountId The list of Account (Id's) that need updating
    * @return void
    *******************************************************************************************************/
    global override void rollupAccounts(list<Id> listAccountId) {
        //We only need to inject the logic if NPSP's ACCT_IndividualAccounts_TDTM is active
        if(TDTM_Glue.getNPSPTriggerActiveMap().get(ACCT_TDTM_CLASS) == true) {
            npsp.ADV_Adapter adapter = new npsp.ADV_Adapter();
            adapter.rollupAccounts(listAccountId);
        }
    }

    /*******************************************************************************************************
    * @description This method is used to inject the NPSP opportunity logic info HEDA Trigger Handler
    * @param mapContactIdAccountIdNew  A map of Contact Id to Account Id, for the Accounts to move opps to
    * @param mapContactIdAccountIdOld A map of Contact Id to Account Id, for the Accounts to move opps from
    * @return void
    *******************************************************************************************************/
    global override void moveOppsToContactAccount(Map<Id,Id> mapContactIdAccountIdNew, Map<Id,Id> mapContactIdAccountIdOld) {
        //We only need to inject the logic if NPSP's ACCT_IndividualAccounts_TDTM is active
        if(TDTM_Glue.getNPSPTriggerActiveMap().get(ACCT_TDTM_CLASS) == true) {
            npsp.ADV_Adapter adapter = new npsp.ADV_Adapter();
            adapter.moveOppsToContactAccount(mapContactIdAccountIdNew, mapContactIdAccountIdOld);
        }
    }

    /*******************************************************************************************************
    * @description This method is used to populate NPSP's primary contact field in HEDA Trigger Handler
    * @param a The Account that need updating
    * @param contactId The id of the primary contact
    * @return void
    *******************************************************************************************************/
    global override void primaryContact(Account a, Id contactId) {
        //We only need to inject the logic if NPSP's ACCT_IndividualAccounts_TDTM is active
        if(TDTM_Glue.getNPSPTriggerActiveMap().get(ACCT_TDTM_CLASS) == true) {
            a.npe01__One2OneContact__c = contactId;
        }
    }

    /*******************************************************************************************************
    * @description This method is used to populate NPSP's system account field in HEDA Trigger Handler
    * @param a The Account that need updating
    * @return void
    *******************************************************************************************************/
    global override void configAccountForContact(Account a) {
        //We only need to inject the logic if NPSP's ACCT_IndividualAccounts_TDTM is active
        if(TDTM_Glue.getNPSPTriggerActiveMap().get(ACCT_TDTM_CLASS) == true) {
            TDTM_Glue.updateNPSPAccountModel();
            npsp.ADV_Adapter adapter = new npsp.ADV_Adapter();
            adapter.configAccountForContact(a);
        }
    }
}