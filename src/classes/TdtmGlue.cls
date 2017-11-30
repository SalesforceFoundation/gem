public with sharing class TdtmGlue {

    /**
     * @description Returns the default TDTM configuration for Advancement, which is the combination of the NPSP and
     * HEDA configurations after some manipulation, as tokens.
     *
     * We do the retrieval and manipulation in this method to avoid having to hardcode and manually keep up to date the
     * configuration from each package.
     *
     * @return
     */
    public List<hed.TDTM_Global_API.TdtmToken> getDefaultTdtmConfigTokens() {
        // Get HEDA TDTM tokens
        List<hed.TDTM_Global_API.TdtmToken> hedaTokens = hed.TDTM_Global_API.getDefaultTdtmConfig();

        // Get NPSP TDTM records
        List<npsp__Trigger_Handler__c> npspRecords = npsp.TDTM_Config_API.getDefaultRecords();

        // Transform NPSP TDTM records to tokens
        List<hed.TDTM_Global_API.TdtmToken> npspTokens = this.npspRecordsToTokens(npspRecords);

        //Add npsp prefix to NPSP classes
        for(hed.TDTM_Global_API.TdtmToken npspToken : npspTokens) {
            npspToken.className = 'npsp.' + npspToken.className;
            npspToken.ownedByNamespace = 'npsp';
        }

        //Deactivate those NPSP tokens that have equivalent HEDA tokens
        this.deactivateNpspDupes(npspTokens);

        // Combine them
        hedaTokens.addAll(npspTokens);
        return hedaTokens;
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
    public List<npsp__Trigger_Handler__c> getDefaultTdtmConfigRecords() {
        return this.tokensToNpspRecords(this.getDefaultTdtmConfigTokens());
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
        List<npsp__Trigger_Handler__c> npspRecords = [
                select
                        npsp__Active__c,
                        npsp__Asynchronous__c,
                        npsp__Class__c,
                        npsp__Load_Order__c,
                        npsp__Object__c,
                        npsp__Trigger_Action__c,
                        npsp__User_Managed__c,
                        npsp__Usernames_to_Exclude__c
                from npsp__Trigger_Handler__c
                limit 50000];

        //Transform them into tokens
        List<hed.TDTM_Global_API.TdtmToken> npspTokens = this.npspRecordsToTokens(npspRecords);
        for(hed.TDTM_Global_API.TdtmToken npspToken : npspTokens) {
            //@TODO this is not correct for custom tokens! How do we identify those? Do we need to compare with the default
            //@TODO NPSP TDTM config?
            npspToken.className = 'npsp.' + npspToken.className;

            //@TODO this will help tracking the origin of the tokens, but what about those that are custom?
            npspToken.ownedByNamespace = 'npsp';
        }

        //Turn off those handlers that are not needed because we are using the equivalent ones from the other package.
        this.deactivateNpspDupes(npspTokens);

        //Get HEDA's TDTM records
        List<hed__Trigger_Handler__c> hedaRecords = [
                select
                        hed__Active__c,
                        hed__Asynchronous__c,
                        hed__Class__c,
                        hed__Filter_Field__c,
                        hed__Filter_Value__c,
                        hed__Load_Order__c,
                        hed__Object__c,
                        hed__Owned_by_Namespace__c,
                        hed__Trigger_Action__c,
                        hed__User_Managed__c
                from hed__Trigger_Handler__c
                limit 50000];

        //Transform them into tokens
        List<hed.TDTM_Global_API.TdtmToken> tokens = this.hedaRecordsToHedaTokens(hedaRecords);

        //Combine NPSP's and HEDA's tokens
        tokens.addAll(npspTokens);

        //Move everything into HEDA's Trigger Handler table
        TdtmAPI.setTdtmConfig(tokens);
    }

    /**
     * @description Deactivate those NPSP tokens that have equivalent HEDA tokens.
     */
    private void deactivateNpspDupes(List<hed.TDTM_Global_API.TdtmToken> npspTokens) {
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

    private List<npsp__Trigger_Handler__c> tokensToNpspRecords(List<hed.TDTM_Global_API.TdtmToken> tokens) {
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

    private List<hed.TDTM_Global_API.TdtmToken> npspRecordsToTokens(List<npsp__Trigger_Handler__c> records) {
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

    private List<hed.TDTM_Global_API.TdtmToken> hedaRecordsToHedaTokens(List<hed__Trigger_Handler__c> records) {
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