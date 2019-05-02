@isTest 
public with sharing class OPP_ManageRelatedNPSPRecords_TEST {
    
    @testSetup static void setupTriggers() {
        GEM_Settings__c gemSettings = UTIL_CustomSettingsFacade.getOrgGemSettings();
        gemSettings.Sync_Account_Models__c = true;
        UTIL_CustomSettingsFacade.getOrgGemSettingsForTests(gemSettings);

        //Insert HEDA Trigger Handlers
        List<hed.TDTM_Global_API.TdtmToken> hedaTokens = hed.TDTM_Global_API.getDefaultTdtmConfig();
        hed.TDTM_Global_API.setTdtmConfig(hedaTokens);

        //Insert NPSP Trigger Handlers
        List<npsp__Trigger_Handler__c> npspHandlers = npsp.TDTM_Config_API.getDefaultRecords();
        insert npspHandlers;

        //Set HEDA custom setting
        UTIL_CustomSettingsFacade.setHEDASettingForTest(new hed__Hierarchy_Settings__c(hed__Account_Processor__c = hed.UTIL_Describe_API.getHhAccRecTypeID()));

        //Set the NPSP Contact setting
        UTIL_CustomSettingsFacade.setNPSPContactsSettingsForTests(new npe01__Contacts_and_Orgs_Settings__c (
                npe01__Account_Processor__c = npsp.CAO_Constants_API.HH_ACCOUNT_TYPE,
                npe01__Enable_Opportunity_Contact_Role_Trigger__c = true,
                npe01__Opportunity_Contact_Role_Default_role__c = 'Donor'
        ));

        UTIL_UnitTestData_TEST.insertTDTMForTest();

        List<Contact> newContacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(4);
        insert newContacts;
    }

    /*******************************************************************************************************
    * @description Test creating, then updating, NPSP Affiliation and Relationship records
    * based on existing EDA records
    */ 
    @isTest
    private static void testOppRelatedRecordSync() {
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact];
        System.assertEquals(4, contacts.size(), 'There should be 4 Contacts, there are : ' + contacts.size());

        Contact donorContact1 = contacts[0];
        Contact relatedToContact1 = contacts[1];
        Contact donorContact2 = contacts[2];
        Contact relatedToContact2 = contacts[3];

        final String softCreditRole = 'Soft Credit';
        final String friendType = 'Friend';
        final String statusActive = 'Active';
        final String descriptionNotes = 'notes';

        hed__Relationship__c rel = new hed__Relationship__c(
            hed__Contact__c = donorContact1.id,
            hed__Relatedcontact__c = relatedToContact1.id,
            hed__Status__c = statusActive,
            hed__Type__c = friendType,
            Related_Opportunity_Contact_Role__c = softCreditRole,
            hed__Description__c = descriptionNotes);
        insert rel;

        hed__Affiliation__c affl = new hed__Affiliation__c(
            hed__Contact__c = relatedToContact2.id,
            hed__Account__c = donorContact1.AccountId,
            hed__Status__c = statusActive,
            Related_Opportunity_Contact_Role__c = softCreditRole,
            hed__Description__c = descriptionNotes);
        insert affl;

        Opportunity opp1 = UTIL_UnitTestData_TEST.getTestOpportunity(donorContact1.AccountId, donorContact1.Id);
        insert opp1;

        List<npe4__Relationship__c> newNPSPRelationships = [SELECT Id, 
            npsp__Related_Opportunity_Contact_Role__c, 
            npe4__Contact__c,
            npe4__ReciprocalRelationship__c,
            npe4__RelatedContact__c,
            npe4__Type__c
            FROM npe4__Relationship__c];

        // System.debug(newNPSPRelationships); 

        // A reciprocal relationship is also created
        System.assertEquals(2, newNPSPRelationships.size(), 
            'There should be 2 new Relationships, there are : ' + newNPSPRelationships.size());

        List<npe5__Affiliation__c> newNPSPAffiliations = [SELECT Id, 
            npsp__Related_Opportunity_Contact_Role__c, 
            npe5__Contact__c,
            npe5__Organization__c
            FROM npe5__Affiliation__c
            WHERE npe5__Contact__c =: relatedToContact2.Id];

        // System.debug(newNPSPAffiliations); 

        System.assertEquals(1, newNPSPAffiliations.size(), 
            'There should be 1 new Affiliation, there are : ' + newNPSPAffiliations.size());
    }

}