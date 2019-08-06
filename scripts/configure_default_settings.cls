/**
* @description Configure all default NPSP Custom Settings by calling each of the "get..." methods in the
* CustomSettingsFacade. In addition, this retrieves the Opportunity.Membership record type Id and populates
* that in the HouseholdSettings object.
* @author Michael Smith and Luke Parrott
* @date 2018-07-26
*/
String adminEmail = 'testing@example.com';
String giftEntryPS = 'Gift Entry';
String giftProfileName = 'Gift Processor';

private static %%%NAMESPACE%%%GEM_Settings__c orgGemSettings;

public static void setupGEMDefaultsForTrial(){
    initializeHEDASettingsForGEM();
    initializeNPSPSettingsForGEM();
    enablePaymentAllocationsDefaultGAU();
    initializeGEMSettings();
}

public static void setupGEMDefaultsForInstaller(){
    initializeNPSPSettingsForGEM();
    enablePaymentAllocationsDefaultGAU();
    initializeGEMSettings();
}

public static void enablePaymentAllocationsDefaultGAU() {
    npsp__Allocations_Settings__c stgAllo = npsp.UTIL_CustomSettings_API.getAllocationsSettings();
    stgAllo.npsp__Payment_Allocations_Enabled__c = true;
    stgAllo.npsp__Default_Allocations_Enabled__c = true;
    if(stgAllo.npsp__Default__c == null){
        // There is no default GAU set, create one and assign it
        String defaultGAUName = 'Default GAU';
        npsp__General_Accounting_Unit__c defaultGau = new npsp__General_Accounting_Unit__c(
            Name = defaultGAUName,
            npsp__Active__c = true
        );
        insert defaultGau;
        stgAllo.npsp__Default__c = defaultGau.Id;
    }
    upsert stgAllo;
}

public static void initializeNPSPSettingsForGEM() {
    insertGiftEntrySettings();
    npsp.UTIL_CustomSettings_API.getContactsSettings();
    npsp.UTIL_CustomSettings_API.getRelationshipSettings();
    npsp.UTIL_CustomSettings_API.getAffiliationsSettings();
    npsp.UTIL_CustomSettings_API.getHouseholdNamingSettings();
    npsp.UTIL_CustomSettings_API.getErrorSettings();
    //npsp.UTIL_CustomSettings_API.getAddressVerificationSettings(); // Not available to the global API
    //npsp.UTIL_CustomSettings_API.getBDESettings(); // Handled by our own function
    npsp.UTIL_CustomSettings_API.getAllocationsSettings();
    npsp.UTIL_CustomSettings_API.getDataImportSettings();

    npo02__Households_Settings__c hs = npsp.UTIL_CustomSettings_API.getHouseholdsSettings();
    hs.npo02__Advanced_Household_Naming__c = false;
    upsert hs;

    hed__Hierarchy_Settings__c hedaOrgSettings = hed__Hierarchy_Settings__c.getOrgDefaults();

    npe01__Contacts_And_Orgs_Settings__c cos = npsp.UTIL_CustomSettings_API.getContactsSettings();
    cos.npsp__Honoree_Opportunity_Contact_Role__c = 'Honoree Contact';
    cos.npsp__Notification_Recipient_Opp_Contact_Role__c = 'Notification Contact';
    cos.npsp__Payments_Auto_Close_Stage_Name__c = getClosedWonStage();
    cos.npsp__Household_Account_Addresses_Disabled__c = true;
    
    cos.npe01__One_to_One_RecordTypeID__c = hedaOrgSettings.hed__Administrative_Account_Record_Type__c;
    cos.npe01__HH_Account_RecordTypeID__c = hedaOrgSettings.hed__Household_Addresses_RecType__c;
    upsert cos;

    Id donationRtId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Donation' LIMIT 1].Id;
    npe03__Recurring_Donations_Settings__c rds = npsp.UTIL_CustomSettings_API.getRecurringDonationsSettings();
    rds.npe03__Record_Type__c = donationRtId;
    upsert rds;
}

public static void initializeHEDASettingsForGEM() {
    hed__Hierarchy_Settings__c orgSettings = hed__Hierarchy_Settings__c.getOrgDefaults();
    orgSettings.hed__Automatic_Household_Naming__c = true;
    orgSettings.hed__Account_Processor__c = hed.UTIL_Describe_API.getHhAccRecTypeID();
    orgSettings.hed__Accounts_to_Delete__c = hed.UTIL_Describe_API.getHhAccRecTypeID();
    upsert orgSettings;
}

public static void initializeGEMSettings() {
    %%%NAMESPACE%%%GEM_Settings__c gemSettings = getOrgGemSettingsDefault();
    upsert gemSettings;
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

        Profile standardUserProfile = [
            SELECT Id
            FROM Profile
            WHERE Name =: 'Standard User'
            LIMIT 1
        ];

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Label =: giftEntryPS];
        
        List<User> giftProcessors = [SELECT Id FROM User WHERE ProfileId = :standardUserProfile.Id AND IsActive = true];
        if(giftProcessors.size() == 0) {
            String randomPad = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).subString(0, 8);

            User goUser = new User(
                Username = generateContactEmail(adminEmail,'giftprocessor'+randomPad),
                FirstName = 'Gary',
                LastName = 'Gift-Officer',
                Email = generateContactEmail(adminEmail,'giftprocessor'),
                Alias = 'ggift',
                TimeZoneSidKey = 'America/Chicago',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'utf-8',
                ProfileId = standardUserProfile.Id,
                LanguageLocaleKey = 'en_US'
            );
            users.add(goUser);
            insert users;

            insert new PermissionSetAssignment(AssigneeId = users[0].Id, PermissionSetId = ps.Id);
        }
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

private static %%%NAMESPACE%%%GEM_Settings__c getOrgGemSettingsDefault() {
    if(orgGemSettings == null) {
        orgGemSettings = %%%NAMESPACE%%%GEM_Settings__c.getOrgDefaults();
    }
    orgGemSettings.%%%NAMESPACE%%%Sync_Account_Models__c = true;
    return orgGemSettings;
}
