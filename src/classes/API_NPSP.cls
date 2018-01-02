global with sharing class API_NPSP extends npsp3c.TDTM_Adapter {

    /**
     * @description To be called by the NPSP TDTM trigger dispatcher. It returns the combined HEDA+NPSP TDTM configuration
     * as NPSP records (since that's what NPSP consumes internally.)
     *
     * @return List<npsp__Trigger_Handler__c> The TDTM configuration as NPSP Trigger_Handler__c records.
     */
    global override List<npsp3c__Trigger_Handler__c> getDefaultTdtmConfigNpspRecords() {
        TDTM_Glue glue = new TDTM_Glue();
        return glue.getDefaultTdtmConfigRecords();
    }
}