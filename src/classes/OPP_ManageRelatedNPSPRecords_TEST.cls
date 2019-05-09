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
    * @description Create a HEDA Relationship and Affiliation. 
    * Create a Donation with the Primary Contact and Accountas the donor. 
    * Check that NPSP versions of the Relationship and Affiliation were created.
    * Create another donation and make sure that additional copies are not created.
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
        final String solicitorRole = 'Solicitor';
        final String friendType = 'Friend';
        final String statusCurrent = 'Current';
        final String statusFormer = 'Former';
        final String descriptionNotes = 'notes';
        final String descriptionNotes2 = 'notes update';

        hed__Relationship__c rel = new hed__Relationship__c(
            hed__Contact__c = donorContact1.id,
            hed__Relatedcontact__c = relatedToContact1.id,
            hed__Status__c = statusCurrent,
            hed__Type__c = friendType,
            Related_Opportunity_Contact_Role__c = softCreditRole,
            hed__Description__c = descriptionNotes);
        insert rel;

        hed__Affiliation__c affl = new hed__Affiliation__c(
            hed__Contact__c = relatedToContact2.id,
            hed__Account__c = donorContact1.AccountId,
            hed__Status__c = statusCurrent,
            Related_Opportunity_Contact_Role__c = softCreditRole,
            hed__Description__c = descriptionNotes);
        insert affl;

        Test.startTest();
        Opportunity opp1 = UTIL_UnitTestData_TEST.getTestOpportunity(donorContact1.AccountId, donorContact1.Id);
        insert opp1;
        Test.stopTest();

        List<npe4__Relationship__c> newNPSPRelationships = getNPSPRelationships(donorContact1.Id);

        // Note: A reciprocal relationship is also created
        System.assertEquals(1, newNPSPRelationships.size(), 
            'There should be 1 new Relationship for this Contact, there are : ' + newNPSPRelationships.size());

        List<npe5__Affiliation__c> newNPSPAffiliations = getNPSPAffiliations(donorContact1.AccountId);

        System.assertEquals(1, newNPSPAffiliations.size(), 
            'There should be 1 new Affiliation, there are : ' + newNPSPAffiliations.size());


        // Make sure adding another Opportunity doesn't create duplicate Relationship and Affiliation records
        Opportunity opp2 = UTIL_UnitTestData_TEST.getTestOpportunity(donorContact1.AccountId, donorContact1.Id);
        insert opp2;

        newNPSPRelationships = getNPSPRelationships(donorContact1.id);

        // A reciprocal relationship is also created
        System.assertEquals(1, newNPSPRelationships.size(), 
            'There should still be only 1 Relationship, there are : ' + newNPSPRelationships.size());

        newNPSPAffiliations = getNPSPAffiliations(donorContact1.AccountId);

        System.assertEquals(1, newNPSPAffiliations.size(), 
            'There should still be only 1 new Affiliation, there are : ' + newNPSPAffiliations.size());


        // Test update of existing NPSP records
        // One of them will be changed, the other should be deleted and replaced with a new copy
        List<hed__Relationship__c> hedaRels = [SELECT Id, hed__Description__c, hed__Status__c
            FROM hed__Relationship__c
            WHERE hed__Contact__c =: donorContact1.Id];
        System.assertEquals(1, hedaRels.size(), 
            'There should still be only 1 Relationship, there are : ' + hedaRels.size());

        hedaRels[0].hed__Description__c = descriptionNotes2;
        hedaRels[0].hed__Status__c = statusFormer;
        update hedaRels;

        List<hed__Affiliation__c> hedaAffls = [SELECT Id, Related_Opportunity_Contact_Role__c
            FROM hed__Affiliation__c
            WHERE hed__Account__c =: donorContact1.AccountId];
        System.assertEquals(1, hedaAffls.size(), 
            'There should still be only 1 Affiliation, there are : ' + hedaAffls.size());

        // This will break the "sync", causing the existing copy to be deleted and remade
        hedaAffls[0].Related_Opportunity_Contact_Role__c = solicitorRole;
        update hedaAffls;

        Opportunity opp3 = UTIL_UnitTestData_TEST.getTestOpportunity(donorContact1.AccountId, donorContact1.Id);
        insert opp3;

        newNPSPRelationships = getNPSPRelationships(donorContact1.id);

        // A reciprocal relationship is also created
        System.assertEquals(1, newNPSPRelationships.size(), 
            'There should still be only 1 Relationship, there are : ' + newNPSPRelationships.size());

        npe4__Relationship__c updatedRel = newNPSPRelationships[0];
        System.assertEquals(descriptionNotes2, updatedRel.npe4__Description__c);
        System.assertEquals(statusFormer, updatedRel.npe4__Status__c);

        newNPSPAffiliations = getNPSPAffiliations(donorContact1.AccountId);

        System.assertEquals(1, newNPSPAffiliations.size(), 
            'There should still be only 1 new Affiliation, there are : ' + newNPSPAffiliations.size());

    }

    private static List<npe4__Relationship__c> getNPSPRelationships(Id primaryContactId){
        return [SELECT Id, 
            npsp__Related_Opportunity_Contact_Role__c, 
            npe4__Description__c,
            npe4__Status__c,
            npe4__Contact__c,
            npe4__ReciprocalRelationship__c,
            npe4__RelatedContact__c,
            npe4__Type__c
            FROM npe4__Relationship__c
            WHERE npe4__Contact__c =: primaryContactId];
    }

    private static List<npe5__Affiliation__c> getNPSPAffiliations(Id accountId){
        return [SELECT Id, 
            npsp__Related_Opportunity_Contact_Role__c, 
            npe5__Contact__c,
            npe5__Organization__c
            FROM npe5__Affiliation__c
            WHERE npe5__Organization__c =: accountId];
    }

}