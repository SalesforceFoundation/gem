/**
* @description Configure all default NPSP Custom Settings by calling each of the "get..." methods in the
* CustomSettingsFacade. In addition, this retrieves the Opportunity.Membership record type Id and populates
* that in the HouseholdSettings object.
* @author Michael Smith
* @date 2018-06-07
*/
public static void initializeNPSPSettingsForADV() {

    insertGiftEntrySettings();
    npsp.UTIL_CustomSettings_API.getContactsSettings();
    npsp.UTIL_CustomSettings_API.getHouseholdsSettings();
    npsp.UTIL_CustomSettings_API.getRecurringDonationsSettings();
    npsp.UTIL_CustomSettings_API.getRelationshipSettings();
    npsp.UTIL_CustomSettings_API.getAffiliationsSettings();
    npsp.UTIL_CustomSettings_API.getHouseholdNamingSettings();
    npsp.UTIL_CustomSettings_API.getErrorSettings();
    //npsp.UTIL_CustomSettings_API.getAddressVerificationSettings(); // Not available to the global API
    //npsp.UTIL_CustomSettings_API.getBDESettings(); // Handled by our own function
    npsp.UTIL_CustomSettings_API.getAllocationsSettings();
    npsp.UTIL_CustomSettings_API.getDataImportSettings();

    Id rtId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Membership' LIMIT 1].Id;

    npo02__Households_Settings__c hs = npsp.UTIL_CustomSettings_API.getHouseholdsSettings();
    hs.npo02__Membership_Record_Types__c = rtId;
    upsert hs;

    npe01__Contacts_And_Orgs_Settings__c cos = npsp.UTIL_CustomSettings_API.getContactsSettings();
    cos.npsp__Honoree_Opportunity_Contact_Role__c = 'Honoree Contact';
    cos.npsp__Notification_Recipient_Opp_Contact_Role__c = 'Notification Contact';
    cos.npsp__Payments_Auto_Close_Stage_Name__c = getClosedWonStage();
    upsert cos;

    // Setup default scheduled jobs
    npsp.STG_InstallScript stg = new npsp.STG_InstallScript();
    stg.runNewOrgScript();
    // Not global, but might need for recurring donations?
    //database.executeBatch(new RD_InstallScript_BATCH(), 10); 
}

private static String getClosedWonStage(){
    OpportunityStage closedWonStage = [SELECT MasterLabel FROM OpportunityStage
        WHERE IsActive = true AND IsWon = true LIMIT 1];
    return closedWonStage.MasterLabel;
}

private static void insertGiftEntrySettings() {
    List<npsp__Data_Import_Settings__c> diSettings = [select ID from npsp__Data_Import_Settings__c];
    if(diSettings.size() == 0) {
        diSettings.add(
            new npsp__Data_Import_Settings__c(
                npsp__Donation_Matching_Behavior__c = npsp.BDI_DataImport_API.ExactMatchOrCreate,
                npsp__Donation_Matching_Rule__c = 'npsp__donation_date__c;npsp__donation_name__c'
            )
        );
        insert diSettings;
    }
}