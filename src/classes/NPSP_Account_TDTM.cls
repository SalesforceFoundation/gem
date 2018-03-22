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
    * @return dmlWrapper always null
    ********************************************************************************************************/
    public override heda2.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
            heda2.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        npsp3c.Advancement_Adapter adapter = new npsp3c.Advancement_Adapter();
        adapter.configAccountTDTM(newList, oldList, triggerAction.name());
        return null;
    }
}