// This needs to be in a separate file for cases when ADV is installed without Abacus
public static void initializeAbacusSettings(){
    abacus.Post_Install_Script.insertLedgerEntryTDTM();
    updateLedgerEntrySettings();
}

public static void updateLedgerEntrySettings(){
    abacus__Ledger_Entry_Settings__c stgLedg = abacus__Ledger_Entry_Settings__c.getOrgDefaults();
    stgLedg.abacus__Enable_Hard_Activation_If_Finalized_Won__c = true;
    stgLedg.abacus__Enable_Ledger_Entry_Creation__c = true;
    stgLedg.abacus__Storage_Levels__c = '2. Near maximum storage requirement';
    upsert stgLedg;
}
