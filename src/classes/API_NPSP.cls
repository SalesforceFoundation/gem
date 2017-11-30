global with sharing class API_NPSP {

    /**
     * @description To be called by the NPSP TDTM trigger dispatcher. It returns the combined HEDA+NPSP TDTM configuration
     * as NPSP records (since that's what NPSP consumes internally.)
     *
     * @return List<npsp__Trigger_Handler__c> The TDTM configuration as NPSP Trigger_Handler__c records.
     */
    global static List<npsp__Trigger_Handler__c> getDefaultTdtmConfigNpspRecords() {
        TDTM_Glue glue = new TDTM_Glue();
        return glue.getDefaultTdtmConfigRecords();
    }
}