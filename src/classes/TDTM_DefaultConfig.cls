
public with sharing class TDTM_DefaultConfig {

    /**
     * @description Returns the default TDTM configuration for advancement, which is the combination of the NPSP and
     * HEDA configurations, after some manipulation.
     *
     * We do the retrieval and manipulation in this method to avoid having to hardcode and manually keep up to date the
     * configuration from each package.
     *
     * @return
     */

    //Sets the Default TDTM configuration. @TODO: Should we store it here in code, or get it from Glue class?
    //-->for the tests, we retrieve the default one from HEDA, the default one from NPSP, and we merge them.
    //-->for user functionality, the post-install script will have combined it. This way we preserve user modification,
    //and also bring custom TDTM records along.
    //
    //We could have a setting that tells us whether this merging has been done for user functionality, so we can check
    //in this method wether we need to do it. Just in case the Advancement post-install script failed.

    public List<hed.TDTM_Global_API.TdtmToken> getDefaultTdtmConfigTokens() {
        //Get HEDA TDTM tokens
        List<hed.TDTM_Global_API.TdtmToken> hedaTokens = hed.TDTM_Global_API.getDefaultTdtmConfig();

        //Get NPSP TDTM records
        List<npsp__Trigger_Handler__c> npspRecords = npsp.TDTM_Config_API.getDefaultRecords();

        //Transform NPSP TDTM records to tokens
        List<hed.TDTM_Global_API.TdtmToken> npspTokens = this.npspRecordsToTokens(npspRecords);

        //Deactivate those NPSP tokens that have equivalent HEDA tokens
        this.deactivateNpspDupes(npspTokens);

        //Combine them
        hedaTokens.addAll(npspTokens);
        return hedaTokens;
    }

    /**
     * @description Deactivate those NPSP tokens that have equivalent HEDA tokens.
     */
    public void deactivateNpspDupes(List<hed.TDTM_Global_API.TdtmToken> npspTokens) {
        for(hed.TDTM_Global_API.TdtmToken npspToken : npspTokens) {
            if(
                    npspToken.className == 'ACCT_IndividualAccounts_TDTM' && npspToken.targetObject == 'Contact'
                            || npspToken.className == 'ADDR_Account_TDTM' && npspToken.targetObject == 'Account'
                            || npspToken.className == 'ADDR_Addresses_TDTM' && npspToken.targetObject == 'Address__c'
                            || npspToken.className == 'ADDR_Contact_TDTM' && npspToken.targetObject == 'Contact'
                            || npspToken.className == 'ADDR_Validator_TDTM' && npspToken.targetObject == 'Address__c'
                            || npspToken.className == 'AFFL_Affiliations_TDTM' && npspToken.targetObject == 'Account'
                            || npspToken.className == 'AFFL_Affiliations_TDTM' && npspToken.targetObject == 'Contact'
                            || npspToken.className == 'AFFL_Affiliations_TDTM' && npspToken.targetObject == 'npe5__Affiliation__c'
                            || npspToken.className == 'REL_Relationships_Con_TDTM' && npspToken.targetObject == 'Contact'
                            || npspToken.className == 'REL_Relationships_TDTM' && npspToken.targetObject == 'npe4__Relationship__c'
                    ) {
                npspToken.active = false;
            }
        }
    }

    public List<npsp__Trigger_Handler__c> getDefaultTdtmConfigRecords() {
        return this.tokensToNpspRecords(this.getDefaultTdtmConfigTokens());
    }

    public List<npsp__Trigger_Handler__c> tokensToNpspRecords(List<hed.TDTM_Global_API.TdtmToken> tokens) {
        List<npsp__Trigger_Handler__c> records = new List<npsp__Trigger_Handler__c>();
        for (hed.TDTM_Global_API.TdtmToken token : tokens) {
            records.add(
                    new npsp__Trigger_Handler__c(
                            npsp__Active__c = token.active,
                            npsp__Asynchronous__c = token.async,
                            npsp__Class__c = token.className,
                            npsp__Load_Order__c = token.loadOrderDec,
                            npsp__Object__c = token.targetObject,
                            //@TODO: field hed__Owned_by_Namespace__c and its related logic needs to be added to NPSP.
                            npsp__Trigger_Action__c = token.actions,
                            npsp__User_Managed__c = token.userManaged
                            //@TODO: field npsp__Usernames_to_Exclude__c and its related logic needs to be added to HEDA.
                    ));
        }
        return records;
    }

    public List<hed.TDTM_Global_API.TdtmToken> npspRecordsToTokens(List<npsp__Trigger_Handler__c> records) {
        List<hed.TDTM_Global_API.TdtmToken> tokens = new List<hed.TDTM_Global_API.TdtmToken>();
        for (npsp__Trigger_Handler__c record : records) {
            tokens.add(
                    new hed.TDTM_Global_API.TdtmToken(
                            record.npsp__Class__c,
                            record.npsp__Object__c,
                            record.npsp__Trigger_Action__c,
                            record.npsp__Load_Order__c,
                            record.npsp__Active__c,
                            record.npsp__Asynchronous__c,
                            '', //@TODO: field hed__Filter_Field__c and its related logic needs to be added to NPSP.
                            '', //@TODO: field hed__Filter_Value__c and its related logic needs to be added to NPSP.
                            record.npsp__User_Managed__c,
                            'npsp' //@TODO: field hed__Owned_by_Namespace__c and its related logic needs to be added to NPSP.
                            //@TODO: field npsp__Usernames_to_Exclude__c and its related logic needs to be added to HEDA.
                    ));
        }
        return tokens;
    }

    public List<hed.TDTM_Global_API.TdtmToken> hedaRecordsToHedaTokens(List<hed__Trigger_Handler__c> records) {
        List<hed.TDTM_Global_API.TdtmToken> tokens = new List<hed.TDTM_Global_API.TdtmToken>();
        for(hed__Trigger_Handler__c record : records) {
            tokens.add(
                new hed.TDTM_Global_API.TdtmToken(
                    record.hed__Class__c,
                    record.hed__Object__c,
                    record.hed__Trigger_Action__c,
                    record.hed__Load_Order__c,
                    record.hed__Active__c,
                    record.hed__Asynchronous__c,
                    record.hed__Filter_Field__c,
                    record.hed__Filter_Value__c,
                    record.hed__User_Managed__c,
                    record.hed__Owned_by_Namespace__c));
        }
        return tokens;
    }
}