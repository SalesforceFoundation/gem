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
* @description This class is used to override the default behavior of the HEDA Advancement Adapter class.
**/
global with sharing class API_HEDA extends heda2.Advancement_Adapter {

    /**
     * @description To be called by the HEDA TDTM trigger dispatcher. It returns the HEDA TDTM tokens with the new one from Adv.
     *
     * @return A list of HEDA tokens.
     */
    global override List<heda2.TDTM_Global_API.TdtmToken> getDefaultTdtmConfigTokens() {
        TDTM_Glue glue = new TDTM_Glue();
        return glue.getDefaultTdtmConfigTokens();
    }

    /**
    *  @description This method is used to inject the NPSP rollup logic into HEDA Trigger Handler.
    */
    global override void rollupAccount(list<Id> listAccountId) {
        npsp3c.Advancement_Adapter.rollupAccounts(listAccountId);
    }

    /**
     * @description This method is used to inject the NPSP opportunity logic info HEDA Trigger Handler.
     */
    global override void moveOppsToContactAccount(map<Id,Id> mapContactIdAccountIdNew, map<Id,Id> mapContactIdAccountIdOld) {
        set<Id> setConId = mapContactIdAccountIdNew.keySet();
        list<Id> listAccIdOld = mapContactIdAccountIdOld.values();
        list<Opportunity> listOpp = new list<Opportunity>();
        set<Id> setOppId = new set<Id>();

        // query changed to also include Role = default role, because Contact Merge scenarios were clearing isPrimary (not by our code)!
        npe01__Contacts_and_Orgs_Settings__c cs = npsp3c.UTIL_CustomSettings_API.getContactsSettings();

        list<OpportunityContactRole> listOCR = [select ContactId, OpportunityId, Opportunity.isClosed, Opportunity.AccountId, IsPrimary, Role
        from OpportunityContactRole where IsPrimary = true and Opportunity.AccountId in :listAccIdOld and ContactId in :setConId];
        //system.debug('****DJH: moveOpps listOCR: ' + listOCR);

        for (OpportunityContactRole ocr : listOCR) {
            if (mapContactIdAccountIdOld.get(ocr.ContactId) == ocr.Opportunity.AccountId) {
                if (setOppId.add(ocr.OpportunityId)) {
                    listOpp.add(new Opportunity(Id = ocr.OpportunityId, AccountId = mapContactIdAccountIdNew.get(ocr.ContactId)));
                }
            }
        }
        //system.debug('****DJH: moveOpps listOpp: ' + listOpp);

        if (listOpp.size() > 0) {
            // since our rollup code isn't using dmlWrapper, some callers want us to commit now
            update listOpp;
        }
    }

    /**
     * @description This method is used to populate NPSP's primary contact field in HEDA Trigger Handler
     */
    global override void primaryContact(Account a, Id contactId) {
        a.npe01__One2OneContact__c = contactId;
    }

    /**
     * @description This method is used to populate NPSP's system account field in HEDA Trigger Handler
     */
    global override void accountFields(Account a, String defaultRecTypeID) {
        ID rtIdAccountHH  = NPSP_Account_TDTM.rtIdForAccountModel(true);
        ID rtIdAccountOne2One = NPSP_Account_TDTM.rtIdForAccountModel(false);

        if(defaultRecTypeID == rtIdAccountHH) {
            a.npe01__SYSTEM_AccountType__c  = Adv_Constants.HH_ACCOUNT_TYPE;
            a.Type = Adv_Constants.HH_TYPE;
        } else if(defaultRecTypeID == rtIdAccountOne2One) {
            a.npe01__SYSTEM_AccountType__c  = Adv_Constants.ONE_TO_ONE_ORGANIZATION_TYPE;
        }

        a.npe01__SYSTEMISINDIVIDUAL__c = true;
    }
}