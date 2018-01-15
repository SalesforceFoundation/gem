public with sharing class TDTM_Glue {

    /**
     * @description Returns the default TDTM configuration for Advancement, which is the combination of the NPSP and
     * HEDA configurations after some manipulation, as tokens.
     *
     * We do the retrieval and manipulation in this method to avoid having to hardcode and manually keep up to date the
     * configuration from each package.
     *
     * @return
     */
    public List<heda2.TDTM_Global_API.TdtmToken> getDefaultTdtmConfigTokens() {
        // Get HEDA TDTM tokens
        List<heda2.TDTM_Global_API.TdtmToken> hedaTokens = heda2.TDTM_Global_API.getDefaultTdtmConfig();

        // Get NPSP TDTM records
        List<npsp3c__Trigger_Handler__c> npspRecords = npsp3c.TDTM_Config_API.getDefaultRecords();

        // Transform NPSP TDTM records to tokens
        List<heda2.TDTM_Global_API.TdtmToken> npspTokens = this.npspRecordsToTokens(npspRecords);

        //Deactivate those NPSP tokens that have equivalent HEDA tokens
        this.deactivateNpspDupes(npspTokens);

        if(packageName == 'heda') {
            return hedaTokens;
        } else if(packageName == 'npsp') {
            return npspTokens;
        } else {
            return new List<heda2.TDTM_Global_API.TdtmToken>();
        }
    }

    /**
     * @description Returns the default TDTM configuration for Advancement, which is the combination of the NPSP and
     * HEDA configurations after some manipulation, as NPSP Trigger Handler records. They are returned in this format
     * for the NPSP trigger dispatcher to be able to consume it.
     *
     * We do the retrieval and manipulation in this method to avoid having to hardcode and manually keep up to date the
     * configuration from each package.
     *
     * @return
     */
    public List<npsp3c__Trigger_Handler__c> getDefaultTdtmConfigRecords(String packageName) {
        return this.tokensToNpspRecords(this.getDefaultTdtmConfigTokens(packageName));
    }

    /**
     * @description Copies NPSP's TDTM records to HEDA's TDTM object, and deactivates those in NPSP. It reads directly
     * from the NPSP and HEDA tables because we don't want to lose any custom records that have been added, or modifications
     * that have been done.
     *
     * This class is separate from TDTM_DefaultConfig because here we are the actual configuration of the system, after
     * merging NPSP's and HEDA'S. TDTM_DefaultConfig merges and returns only the default configuration.
     */
    public void combineTdtmConfig() {
        //Get NPSP's TDTM records
        List<npsp3c__Trigger_Handler__c> npspRecords = [
                select
                        npsp3c__Active__c,
                        npsp3c__Asynchronous__c,
                        npsp3c__Class__c,
                        npsp3c__Load_Order__c,
                        npsp3c__Object__c,
                        npsp3c__Trigger_Action__c,
                        npsp3c__User_Managed__c,
                        npsp3c__Usernames_to_Exclude__c
                from npsp3c__Trigger_Handler__c
                limit 50000];

        //Transform them into tokens
        List<heda2.TDTM_Global_API.TdtmToken> npspTokens = this.npspRecordsToTokens(npspRecords);
        for(heda2.TDTM_Global_API.TdtmToken npspToken : npspTokens) {
            //@TODO this is not correct for custom tokens! How do we identify those? Do we need to compare with the default
            //@TODO NPSP TDTM config?
            npspToken.className = 'npsp3c.' + npspToken.className;

            //@TODO this will help tracking the origin of the tokens, but what about those that are custom?
            npspToken.ownedByNamespace = 'npsp';
        }

        //Turn off those handlers that are not needed because we are using the equivalent ones from the other package.
        this.deactivateNpspDupes(npspTokens);

        //Get HEDA's TDTM records
        List<heda2__Trigger_Handler__c> hedaRecords = [
                select
                        heda2__Active__c,
                        heda2__Asynchronous__c,
                        heda2__Class__c,
                        heda2__Filter_Field__c,
                        heda2__Filter_Value__c,
                        heda2__Load_Order__c,
                        heda2__Object__c,
                        heda2__Owned_by_Namespace__c,
                        heda2__Trigger_Action__c,
                        heda2__User_Managed__c
                from heda2__Trigger_Handler__c
                limit 50000];

        //Transform them into tokens
        List<heda2.TDTM_Global_API.TdtmToken> tokens = this.hedaRecordsToHedaTokens(hedaRecords);

        //Combine NPSP's and HEDA's tokens
        tokens.addAll(npspTokens);

        //Move everything into HEDA's Trigger Handler table
        heda2.TDTM_Global_API.setTdtmConfig(tokens);
    }

    /**
     * @description Deactivate those NPSP tokens that have equivalent HEDA tokens.
     */
    private void deactivateNpspDupes(List<heda2.TDTM_Global_API.TdtmToken> npspTokens) {
        for(heda2.TDTM_Global_API.TdtmToken npspToken : npspTokens) {
            /*if(
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
            }*/

            if(
                    npspToken.className == 'ACCT_Accounts_TDTM' && npspToken.targetObject == 'Account'
                            || npspToken.className == 'ACCT_IndividualAccounts_TDTM' && npspToken.targetObject == 'Contact'
                            || npspToken.className == 'ADDR_Contact_TDTM' && npspToken.targetObject == 'Contact'
                    ) {
                npspToken.active = false;
            }
        }
    }

    private List<npsp3c__Trigger_Handler__c> tokensToNpspRecords(List<heda2.TDTM_Global_API.TdtmToken> tokens) {
        List<npsp3c__Trigger_Handler__c> records = new List<npsp3c__Trigger_Handler__c>();
        for (heda2.TDTM_Global_API.TdtmToken token : tokens) {
            records.add(
                    new npsp3c__Trigger_Handler__c(
                            npsp3c__Active__c = token.active,
                            npsp3c__Asynchronous__c = token.async,
                            npsp3c__Class__c = token.className,
                            npsp3c__Load_Order__c = token.loadOrderDec,
                            npsp3c__Object__c = token.targetObject,
                            //@TODO: field hed__Owned_by_Namespace__c and its related logic needs to be added to NPSP.
                            npsp3c__Trigger_Action__c = token.actions,
                            npsp3c__User_Managed__c = token.userManaged
                            //@TODO: field npsp__Usernames_to_Exclude__c and its related logic needs to be added to HEDA.
                    ));
        }
        return records;
    }

    private List<heda2.TDTM_Global_API.TdtmToken> npspRecordsToTokens(List<npsp3c__Trigger_Handler__c> records) {
        List<heda2.TDTM_Global_API.TdtmToken> tokens = new List<heda2.TDTM_Global_API.TdtmToken>();
        for (npsp3c__Trigger_Handler__c record : records) {
            tokens.add(
                    new heda2.TDTM_Global_API.TdtmToken(
                            record.npsp3c__Class__c,
                            record.npsp3c__Object__c,
                            record.npsp3c__Trigger_Action__c,
                            record.npsp3c__Load_Order__c,
                            record.npsp3c__Active__c,
                            record.npsp3c__Asynchronous__c,
                            '', //@TODO: field hed__Filter_Field__c and its related logic needs to be added to NPSP.
                            '', //@TODO: field hed__Filter_Value__c and its related logic needs to be added to NPSP.
                            record.npsp3c__User_Managed__c,
                            'npsp' //@TODO: field hed__Owned_by_Namespace__c and its related logic needs to be added to NPSP.
                            //@TODO: field npsp__Usernames_to_Exclude__c and its related logic needs to be added to HEDA.
                    ));
        }
        return tokens;
    }

    private List<heda2.TDTM_Global_API.TdtmToken> hedaRecordsToHedaTokens(List<heda2__Trigger_Handler__c> records) {
        List<heda2.TDTM_Global_API.TdtmToken> tokens = new List<heda2.TDTM_Global_API.TdtmToken>();
        for(heda2__Trigger_Handler__c record : records) {
            tokens.add(
                    new heda2.TDTM_Global_API.TdtmToken(
                            record.heda2__Class__c,
                            record.heda2__Object__c,
                            record.heda2__Trigger_Action__c,
                            record.heda2__Load_Order__c,
                            record.heda2__Active__c,
                            record.heda2__Asynchronous__c,
                            record.heda2__Filter_Field__c,
                            record.heda2__Filter_Value__c,
                            record.heda2__User_Managed__c,
                            record.heda2__Owned_by_Namespace__c));
        }
        return tokens;
    }
}