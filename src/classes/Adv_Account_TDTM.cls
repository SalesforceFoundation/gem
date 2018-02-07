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
* @description This class is used to fill in the NPSP system Account fields. We disabled NPSP ACCT_Accounts_TDTM trigger handler since it cause
* HEDA unit test cases failed. However, we need to replicate the logic in it and put it into HEDA TDTM framework, since there are some logic in
* NPSP refers to those fields.
**/
global class NPSP_Account_TDTM extends heda2.TDTM_Runnable {
    /*******************************************************************************************************
    * @description Trigger Handler on Accounts that handles ensuring the correct system flags are set on
    * our special accounts (Household, One-to-One), and also detects changes on Household Account that requires
    * name updating.
    * @param listNew the list of Accounts from trigger new.
    * @param listOld the list of Accounts from trigger old.
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
    * @param objResult the describe for Accounts
    * @return dmlWrapper
    ********************************************************************************************************/
    public override heda2.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
            heda2.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

        heda2.TDTM_Runnable.DmlWrapper dmlWrapper = new heda2.TDTM_Runnable.DmlWrapper();

        ID rtIdAccountHH;
        ID rtIdAccountOne2One;

        if (triggerAction == heda2.TDTM_Runnable.Action.BeforeInsert || triggerAction == heda2.TDTM_Runnable.Action.BeforeUpdate) {
            rtIdAccountHH = rtIdForAccountModel(true);
            rtIdAccountOne2One = rtIdForAccountModel(false);
        }
        integer i = 0;
        for (SObject so : newlist) {
            Account acc = (Account)so;

            if (triggerAction == heda2.TDTM_Runnable.Action.BeforeInsert || triggerAction == heda2.TDTM_Runnable.Action.BeforeUpdate) {
                if (acc.RecordTypeId == rtIdAccountHH && acc.RecordTypeId != null) {
                    if (acc.npe01__SYSTEM_AccountType__c == null || acc.npe01__SYSTEMISINDIVIDUAL__c != true) {
                        acc.npe01__SYSTEM_AccountType__c = Adv_Constants.HH_ACCOUNT_TYPE;
                        acc.Type = Adv_Constants.HH_TYPE;
                        acc.npe01__SYSTEMISINDIVIDUAL__c = true;
                    }
                } else if (acc.RecordTypeId == rtIdAccountOne2One && acc.RecordTypeId != null) {
                    if (acc.npe01__SYSTEM_AccountType__c == null || acc.npe01__SYSTEMISINDIVIDUAL__c != true) {
                        acc.npe01__SYSTEM_AccountType__c = Adv_Constants.ONE_TO_ONE_ORGANIZATION_TYPE;
                        acc.npe01__SYSTEMISINDIVIDUAL__c = true;
                    }
                } else if (!(Adv_Constants.isBucketModel() && acc.Name == Adv_Constants.BUCKET_ACCOUNT_NAME)) {
                    if (triggerAction == heda2.TDTM_Runnable.Action.BeforeUpdate && acc.RecordTypeId != oldlist[i].get('RecordTypeId')) {
                        acc.npe01__SYSTEMISINDIVIDUAL__c = false;
                        acc.npe01__SYSTEM_AccountType__c = null;
                    }
                }
            }
            i++;
        }

        return null;
    }

    /*******************************************************************************************************
    * @description utility to return the recordtypeId for a new account, given the account model.
    * @return Id. if none is explicitly specified, returns null.
    */
    public static ID rtIdForAccountModel(boolean isHHAccountModel) {
        npe01__Contacts_and_Orgs_Settings__c ContactsSettings = Adv_UtilCustomSettingsFacade.getContactsSettings();
        Schema.Recordtypeinfo rtById = null;
        // check if recordtypes are enabled, and if it matches the existing setting
        // we go thru describe to validate that it is a valid recordType ID.
        ID rtId = isHHAccountModel ? ContactsSettings.npe01__HH_Account_RecordTypeID__c : ContactsSettings.npe01__One_to_One_RecordTypeID__c;
        if (rtId != null) {
            Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
            Map<Id,Schema.RecordTypeInfo> rtMapById = r.getRecordTypeInfosById();
            rtById = rtMapById.get(rtId);
            return (rtById == null ? null : rtById.getRecordTypeID());
        }
        return null;
    }
}