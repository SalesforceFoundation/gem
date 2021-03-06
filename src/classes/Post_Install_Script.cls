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
* @group
* @group-content
* @description This is the post install script for Adv.
**/
global without sharing class Post_Install_Script implements InstallHandler{

    static final Integer ACCOUNT_BATCH_SIZE = 200;

    global void onInstall(InstallContext context) {
        //Initial installation.
        if(context.previousVersion() == null) {
            UTIL_CustomSettingsFacade.getOrgGemSettings();
            populateNPSPAccountModel();
            giftSetup();
            insertTdtmDefaults();
        }
    }

    global static void giftSetup(){
        GiftEntryFormController.insertGiftEntrySettings();
    }

    global static void populateNPSPAccountModel() {
        TDTM_Glue.updateNPSPAccountModel();
    }

    /*******************************************************************************************************
    * @description Inserts the default TDTM records. Public just for testing purposes
    * @return void
    */
    global static void insertTdtmDefaults() {
        List<hed__Trigger_Handler__c> gemTDTMTriggers = new List<hed__Trigger_Handler__c>();

        String syncRelRecords = REL_SyncToNPSP_TDTM.class.toString();
        gemTDTMTriggers.add(
            new hed__Trigger_Handler__c(
                hed__Class__c = syncRelRecords, hed__Active__c = true, hed__Object__c = 'Relationship__c',
                hed__Load_Order__c =  0,  hed__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', 
                hed__Asynchronous__c = false,  hed__User_Managed__c = false,  
                hed__Usernames_to_Exclude__c = '', hed__Owned_by_Namespace__c = 'gem'
            )
        );

        String syncAfflRecords = AFFL_SyncToNPSP_TDTM.class.toString();
        gemTDTMTriggers.add(
            new hed__Trigger_Handler__c(
                hed__Class__c = syncAfflRecords, hed__Active__c = true, hed__Object__c = 'Affiliation__c',
                hed__Load_Order__c =  0,  hed__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete', 
                hed__Asynchronous__c = false,  hed__User_Managed__c = false,  
                hed__Usernames_to_Exclude__c = '', hed__Owned_by_Namespace__c = 'gem'
            )
        );

        insert gemTDTMTriggers;    
    }


    /**
     * Starts a new chained queueable account processing job.
     * Used when GEM/NPSP are installed in an org that already has EDA installed.
     *
     * @return  Id of the Queueable
     */
    global static Id queueAccountProcessor() {
        return System.enqueueJob(new NPSP_Account_Processor());
    }

    /**
     * Populate the npe01__SYSTEM_AccountType__c, npe01__SYSTEMIsIndividual__c and Type fields with the correct values
     * for each Account that is Administrative or Household as indicated by record type.
     */
    static void populateNPSPAccountFields() {
        Id adminAccountRecordTypeId = hed.UTIL_Describe_API.getAdminAccRecTypeID();
        Id hhAccountRecordTypeId = hed.UTIL_Describe_API.getHhAccRecTypeID();

        List<Account> accounts = [
                SELECT Id, RecordTypeId, RecordType.Name
                FROM Account
                WHERE (RecordTypeId = :adminAccountRecordTypeId OR RecordTypeId = :hhAccountRecordTypeId)
                    AND npe01__SYSTEM_AccountType__c = null
                    AND Type = null
                    AND npe01__SYSTEMIsIndividual__c = false
                LIMIT :ACCOUNT_BATCH_SIZE
        ];


        for(Account a : accounts) {
            if(a.RecordTypeId == hhAccountRecordTypeId) {
                a.npe01__SYSTEM_AccountType__c = 'Household Account';
                a.Type = 'Household';
            } else if(a.RecordTypeId == adminAccountRecordTypeId) {
                a.npe01__SYSTEM_AccountType__c = 'One-to-One Individual';
            }
            a.npe01__SYSTEMIsIndividual__c = true;
        }

        try {
            update accounts;
            if(accounts.size() == ACCOUNT_BATCH_SIZE) {
                queueAccountProcessor();
            }
        } catch (Exception ex) {
            npsp.ERR_Handler_API.processError(ex, 'NPSP_Account_Processor');
        }
    }


    /**
     * Queueable class for populating NPSP fields on Accounts.
     * Used when NPSP and GEM have been installed in an org that already had EDA.
     */
    public class NPSP_Account_Processor implements Queueable {
        public void execute(System.QueueableContext ctx) {
            populateNPSPAccountFields();
        }
    }

}