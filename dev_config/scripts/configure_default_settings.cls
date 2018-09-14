/**
* @description Configure all default NPSP Custom Settings by calling each of the "get..." methods in the
* CustomSettingsFacade. In addition, this retrieves the Opportunity.Membership record type Id and populates
* that in the HouseholdSettings object.
* @author Michael Smith and Luke Parrott
* @date 2018-07-26
*/
String adminEmail = 'testing@example.com';
String giftProfileName = 'Gift Processor';
String giftProfileName2 = 'Development Officer';

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

    // Setup default custom settings, might already be done on install?
    //npsp.STG_InstallScript stg = new npsp.STG_InstallScript();
    //stg.runNewOrgScript();

    // Would setup scheduled jobs, but it's not global, go to NPSP Settings page to automatically run
    // UTIL_MasterSchedulableHelper.setScheduledJobs();

    // Not global, but might be needed for recurring donations?
    //database.executeBatch(new RD_InstallScript_BATCH(), 10); 

    initializeHEDASettingsForADV();
}

public static void initializeHEDASettingsForADV() {

    hed__Hierarchy_Settings__c orgSettings = hed__Hierarchy_Settings__c.getOrgDefaults();
    orgSettings.hed__Automatic_Household_Naming__c = true;
    orgSettings.hed__Account_Processor__c = hed.UTIL_Describe_API.getHhAccRecTypeID();
    update orgSettings;

}

public static void AddGiftProcessor() {
    Savepoint sp = Database.setSavepoint();

    try {
        List<User> users = new List<User>();

        // If the user count is maxed out for Dev orgs, leave and continue the flow
        users = [SELECT Id 
            FROM User 
            WHERE Profile.UserLicense.LicenseDefinitionKey = 'SFDC' AND isActive = true];
        if(users.size() >= 2){
            return;
        }

        users.clear();

        Profile giftProfile = [
            SELECT Id
            FROM Profile
            WHERE Name =: giftProfileName
        ];

        User goUser = new User(
            Username = generateContactEmail(adminEmail,'giftprocessor'+Datetime.now().millisecond()),
            FirstName = 'Gary',
            LastName = 'Gift-Officer',
            Email = generateContactEmail(adminEmail,'giftprocessor'),
            Alias = 'ggift',
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'utf-8',
            ProfileId = giftProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        users.add(goUser);
        insert users;

    } catch (System.DmlException e) {
        Database.rollback(sp);
        throw new System.DmlException(e.getMessage());
    }
}

private static String generateContactEmail(String adminEmail, String contactName) {
    List<String> emailParts = adminEmail.split('@');
    return emailParts[0]+'+'+contactName+'@'+emailParts[1];
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
