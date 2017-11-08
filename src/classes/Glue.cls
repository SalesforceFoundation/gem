
public with sharing class Glue {

    /**
     * @description Copies NPSP's TDTM records to HEDA's TDTM object, and deactivates those in NPSP.
     */
    public void tdtmTransfer() {
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

        TDTM_DefaultConfig config = new TDTM_DefaultConfig();

        //Transform them into tokens
        List<hed.TDTM_Global_API.TdtmToken> npspTokens = config.npspRecordsToTokens(npspRecords);

        //Turn off those handlers that are not needed because we are using the equivalent ones from the other package.
        config.deactivateNpspDupes(npspTokens);

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
        List<hed.TDTM_Global_API.TdtmToken> tokens = config.hedaRecordsToHedaTokens(hedaRecords);

        //Combine NPSP's and HEDA's tokens
        tokens.addAll(npspTokens);

        //Move everything into HEDA's Trigger Handler table
        TDTM_API.setTdtmConfig(tokens);
    }

}