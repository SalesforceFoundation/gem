// This needs to be in a separate file for cases when ADV is installed without Abacus
public static void initializeAbacusSettings(){
    aba1.Post_Install_Script.insertLedgerEntryTDTM();
    aba1__Ledger_Entry_Settings__c stgLedg = aba1__Ledger_Entry_Settings__c.getOrgDefaults();
    stgLedg.aba1__Enable_Ledger_Entry_Creation__c = true;
    stgLedg.aba1__Storage_Levels__c = '2. Near maximum storage requirement';
    upsert stgLedg;
}