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
* @description This class is used to fill in the NPSP system Account fields. We disabled NPSP ACCT_Accounts_TDTM trigger handler since it cause
* HEDA unit test cases failed. However, we need to replicate the logic in it and put it into HEDA TDTM framework, since there are some logic in
* NPSP refers to those fields.
**/
global class NPSP_Account_TDTM extends hed.TDTM_Runnable {
    /*******************************************************************************************************
    * @description Trigger Handler on Accounts that handles ensuring the correct system flags are set on
    * our special accounts (Household, One-to-One), and also detects changes on Household Account that requires
    * name updating
    * @param listNew the list of Accounts from trigger new
    * @param listOld the list of Accounts from trigger old
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.)
    * @param objResult the describe for Accounts
    * @return dmlWrapper always null
    ********************************************************************************************************/
    public override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
            hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp.ADV_Adapter adapter = new npsp.ADV_Adapter();

        if (triggerAction == hed.TDTM_Runnable.Action.BeforeUpdate) {
            configAccountForHouseholdUpdate(newList, oldList);
        }

        adapter.configAccountTDTM(newList, oldList, triggerAction.name());
        return null;
    }

    /*******************************************************************************************************
    * @description Trigger Handler on Accounts to clear two specific fields when switching to a Household
    * record type so the NPSP code can run correctly. 
    * @param newList the list of Accounts from trigger new
    * @param oldList the list of Accounts from trigger old
    * @return void
    ********************************************************************************************************/
    public void configAccountForHouseholdUpdate(List<Sobject> newList, List<Sobject> oldList) {
        Map<Id, Sobject> oldMap = new Map<Id, Sobject>(oldList);
        String householdRecordTypeId = hed.UTIL_Describe_API.getHhAccRecTypeID();
        
        for (SObject accountSobj : newList) {
            Account newAccount = (Account)accountSobj;
            Account oldAccount = (Account)oldMap.get(newAccount.Id);
            
            // If the account's record type is being changed to household, 
            // Clear the two fields so that NPSP's code will execute. 
            if (oldAccount.RecordTypeId != newAccount.RecordTypeId) {
                newAccount.npe01__SYSTEM_AccountType__c = null;
                newAccount.npe01__SYSTEMISINDIVIDUAL__c = false;
                newAccount.Type = null;
            }
        }
    }
}