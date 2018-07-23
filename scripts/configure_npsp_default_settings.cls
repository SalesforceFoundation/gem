/**
* @description Configure all default NPSP Custom Settings by calling each of the "get..." methods in the
* CustomSettingsFacade. In addition, this retrieves the Opportunity.Membership record type Id and populates
* that in the HouseholdSettings object.
* @author Michael Smith
* @date 2018-06-07
*/
public static void initializeNPSPSettings() {
    npsp.UTIL_CustomSettings_API.getContactsSettings();
    npsp.UTIL_CustomSettings_API.getHouseholdsSettings();
    npsp.UTIL_CustomSettings_API.getRecurringDonationsSettings();
    npsp.UTIL_CustomSettings_API.getRelationshipSettings();
    npsp.UTIL_CustomSettings_API.getAffiliationsSettings();
    npsp.UTIL_CustomSettings_API.getHouseholdNamingSettings();
    npsp.UTIL_CustomSettings_API.getErrorSettings();
    //npsp.UTIL_CustomSettings_API.getAddressVerificationSettings(); // Not available to the global API
    npsp.UTIL_CustomSettings_API.getBDESettings();
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
}

private static String getClosedWonStage(){
    OpportunityStage closedWonStage = [SELECT MasterLabel FROM OpportunityStage
        WHERE IsActive = true AND IsWon = true LIMIT 1];
    return closedWonStage.MasterLabel;
}

