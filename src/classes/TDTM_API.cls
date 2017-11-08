
global with sharing class TDTM_API {

    // @TODO: what do we do with existing custom TDTM records stored in NPSP's or HEDA's Trigger Handler tables?
    // --> We need to migrate them to the HEDA Trigger Handler table, and make that table match the default combined config
    // (excluding custom entries).

    // @TODO: if we are just returning in-memory records, how is this going to affect the setTdtmConfig and
    // getTdtmConfig API methods in HEDA and NPSP?
    // --> The setTdtmConfig and getTdtmConfig in BOTH packages have to return the combined configuration, and work with the
    // records in the Trigger Handler table, not just the in-memory records.

    /**
     * @description To be called by the HEDA TDTM trigger dispatcher. It returns the combined HEDA+NPSP TDTM configuration
     * as HEDA tokens (since that's what HEDA consumes internally.)
     *
     * @return
     */
    global static List<hed.TDTM_Global_API.TdtmToken> getDefaultTdtmConfigTokens() {
        TDTM_DefaultConfig config = new TDTM_DefaultConfig();
        return config.getDefaultTdtmConfigTokens();
    }

    /**
     * @description To be called by the NPSP TDTM trigger dispatcher. It returns the combined HEDA+NPSP TDTM configuration
     * as NPSP records (since that's what NPSP consumes internally.)
     *
     * @return
     */
    global static List<npsp__Trigger_Handler__c> getDefaultTdtmConfigNpspRecords() {
        TDTM_DefaultConfig config = new TDTM_DefaultConfig();
        return config.getDefaultTdtmConfigRecords();
    }

    /**
     * @description Sets the trigger handlers configuration with the data passed as parameter.
     *
     * @param tokens
     */
    global static void setTdtmConfig(List<hed.TDTM_Global_API.TdtmToken> tokens) {
        //Deactivate everything in the NPSP Trigger Handler table.
        List<npsp__Trigger_Handler__c> npspRecords = [select npsp__Active__c from npsp__Trigger_Handler__c limit 50000];
        for(npsp__Trigger_Handler__c npspRecord : npspRecords) {
            npspRecord.npsp__Active__c = false;
        }
        update npspRecords;

        //Delegate to the HEDA setTdtmConfig method
        hed.TDTM_Global_API.setTdtmConfig(tokens);
    }
}