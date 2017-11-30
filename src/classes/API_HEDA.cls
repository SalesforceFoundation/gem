global with sharing class API_HEDA /**extends hed.TDTM_Adapter**/ {

    /**
     * @description To be called by the HEDA TDTM trigger dispatcher. It returns the combined HEDA+NPSP TDTM configuration
     * as HEDA tokens (since that's what HEDA consumes internally.)
     *
     * @return List<hed.TDTM_Global_API.TdtmToken> The TDTM configuration as HEDA tokens.
     */
    global /** override **/ List<hed.TDTM_Global_API.TdtmToken> getDefaultTdtmConfigTokens() {
        TdtmGlue glue = new TdtmGlue();
        return glue.getDefaultTdtmConfigTokens();
    }

    //@TODO: should this method be here or in its own separate class?
    /**
     * @description Sets the trigger handlers configuration with the data passed as parameter.
     *
     * @param tokens The TDTM configuration as HEDA tokens.

    global override void setTdtmConfig(List<hed.TDTM_Global_API.TdtmToken> tokens) {
        //Deactivate everything in the NPSP Trigger Handler table.
        List<npsp__Trigger_Handler__c> npspRecords = [select npsp__Active__c from npsp__Trigger_Handler__c limit 50000];
        for(npsp__Trigger_Handler__c npspRecord : npspRecords) {
            npspRecord.npsp__Active__c = false;
        }
        update npspRecords;

        //Delegate to the HEDA setTdtmConfig method
        hed.TDTM_Global_API.setTdtmConfig(tokens);
    } */
}