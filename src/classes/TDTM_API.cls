
global with sharing class TDTM_API {

    // @TODO: what do we do with existing custom TDTM records stored in NPSP's or HEDA's Trigger Handler tables?
    // --> We need to migrate them to the HEDA Trigger Handler table, and make that table match the default combined config
    // (excluding custom entries).

    // @TODO: if we are just returning in-memory records, how is this going to affect the setTdtmConfig and getTdtmConfig API methods?
    // --> The setTdtmConfig and getTdtmConfig in BOTH packages have to return the combined configuration, and work with the
    // records in the Trigger Handler table, not just the in-memory records.

    global List<hed.TDTM_Global_API.TdtmToken> getDefaultTdtmConfigTokens() {
        TDTM_DefaultConfig config = new TDTM_DefaultConfig();
        return config.getDefaultTdtmConfigTokens();
    }

    global List<npsp__Trigger_Handler__c> getDefaultTdtmConfigRecords() {
        TDTM_DefaultConfig config = new TDTM_DefaultConfig();
        return config.getDefaultTdtmConfigRecords();
    }
}