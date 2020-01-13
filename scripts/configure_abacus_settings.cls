// This needs to be in a separate file for cases when ADV is installed without Abacus
public static void initializeAbacusSettings(){
    updateLedgerEntrySettings();
    initializeNPSPSettingsForAbacus();
}

public static void updateLedgerEntrySettings(){
    abacus__Ledger_Entry_Settings__c stgLedg = abacus__Ledger_Entry_Settings__c.getOrgDefaults();
    stgLedg.abacus__Allocations_Before_LIFO_for_Paid_Refunds__c = true;
    upsert stgLedg;
}

public static void initializeNPSPSettingsForAbacus() {
    npe01__Contacts_And_Orgs_Settings__c cos = npsp.UTIL_CustomSettings_API.getContactsSettings();
    cos.npsp__Enforce_Accounting_Data_Consistency__c = true;
    upsert cos;
}