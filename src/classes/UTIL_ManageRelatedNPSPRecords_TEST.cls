@isTest 
public with sharing class UTIL_ManageRelatedNPSPRecords_TEST {

    static final String softCreditRole = 'Soft Credit';
    static final String solicitorRole = 'Solicitor';
    static final String friendType = 'Friend';
    static final String familyRole = 'Family Member';
    static final String statusCurrent = 'Current';
    static final String statusFormer = 'Former';
    static final String descriptionNotes = 'notes';
    static final String descriptionNotes2 = 'notes2';
    static final String descriptionNotesUpdate = 'notes update';

    static final String donor1FirstName = 'Donor1';
    static final String donor2FirstName = 'Donor2';
    static final String credit1FirstName = 'Credit1';
    static final String credit2FirstName = 'Credit2';
    static final String donorAccountName = 'DonorAccount1';
    
    /*******************************************************************************************************
    * @description Create a HEDA Relationship and Affiliation. 
    * Create 2 Donations, one that uses the Affiliation Account, one that uses the Primary Relationship Contact
    */ 
    @testSetup static void setupTriggersAndData() {
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

        List<Contact> contacts = UTIL_UnitTestData_TEST.getMultipleTestContacts(4);
        contacts[0].FirstName = donor1FirstName;
        contacts[1].FirstName = donor2FirstName;
        contacts[2].FirstName = credit1FirstName;
        contacts[3].FirstName = credit2FirstName;
        insert contacts;

        // Donor 2 will be our Affiliation Account, it needs to be an Organization
        List<Account> donorAccounts = 
            UTIL_UnitTestData_TEST.getMultipleTestAccounts(1,hed.UTIL_Describe_API.getBizAccRecTypeID());
        donorAccounts[0].Name = donorAccountName;
        insert donorAccounts;
        Account donorAccount = donorAccounts[0];

        Contact donorContact1 = returnContact(donor1FirstName);
        Contact donorContact2 = returnContact(donor2FirstName);
        Contact creditContact1 = returnContact(credit1FirstName);
        Contact creditContact2 = returnContact(credit2FirstName);

        // Create a Soft Credit relationship between Donor1 and Related1
        hed__Relationship__c rel = new hed__Relationship__c(
            hed__Contact__c = donorContact1.Id,
            hed__Relatedcontact__c = creditContact1.Id,
            hed__Status__c = statusCurrent,
            hed__Type__c = friendType,
            Related_Opportunity_Contact_Role__c = softCreditRole,
            hed__Description__c = descriptionNotes);

        // Create a second relationship to make sure syncing still works
        hed__Relationship__c rel2 = new hed__Relationship__c(
            hed__Contact__c = donorContact1.Id,
            hed__Relatedcontact__c = creditContact1.Id,
            hed__Status__c = statusCurrent,
            hed__Type__c = friendType,
            Related_Opportunity_Contact_Role__c = solicitorRole,
            hed__Description__c = descriptionNotes2);

        insert new List<hed__Relationship__c>{rel, rel2};

        // Create a Soft Credit affiliation between Donor2 and Related2
        hed__Affiliation__c affl = new hed__Affiliation__c(
            hed__Contact__c = creditContact2.Id,
            hed__Account__c = donorAccount.Id,
            hed__Role__c = familyRole,
            hed__Status__c = statusCurrent,
            Related_Opportunity_Contact_Role__c = softCreditRole,
            hed__Description__c = descriptionNotes);

        // Create another Affiliation to test syncing edge cases
        hed__Affiliation__c affl2 = new hed__Affiliation__c(
            hed__Contact__c = creditContact2.Id,
            hed__Account__c = donorAccount.Id,
            hed__Role__c = familyRole,
            hed__Status__c = statusCurrent,
            Related_Opportunity_Contact_Role__c = solicitorRole,
            hed__Description__c = descriptionNotes2);

        insert new List<hed__Affiliation__c>{affl, affl2};

        // Add Opportunities to test if the NPSP versions of Relationship and Affiliation get created
        Opportunity oppTestRel1 = UTIL_UnitTestData_TEST.getTestOpportunity(donorContact1.AccountId, donorContact1.Id);
        insert oppTestRel1;

        Opportunity oppTestAffl1 = UTIL_UnitTestData_TEST.getTestOpportunity(donorAccount.Id, null);
        insert oppTestAffl1;

    }

    /*******************************************************************************************************
    * @description Check that NPSP versions of the Relationship and Affiliation were created.
    * Update the EDA Relationship and Affiliation, and make sure the copy stays sycned.
    * Check that multiple copies were not created.
    * Check that the correct Opportunity Contact Roles are created from the NPSP records.
    */ 
    @isTest
    private static void testOppRelatedRecordSync() {

        User testUser = UTIL_UnitTestData_TEST.createNewUserForTests(System.now().getTime() + '@testerson.com');

        List<Contact> contacts = [SELECT Id, AccountId FROM Contact];
        System.assertEquals(4, contacts.size(), 'There should be 4 Contacts, there are : ' + contacts.size());

        Contact donorContact1 = returnContact(donor1FirstName);
        Contact donorContact2 = returnContact(donor2FirstName);
        Contact creditContact1 = returnContact(credit1FirstName);
        Contact creditContact2 = returnContact(credit2FirstName);
        Account donorAccount = [SELECT Id, Name FROM Account WHERE Name = :donorAccountName];

        Opportunity oppTestRel1 = [SELECT Id 
            FROM Opportunity 
            WHERE AccountId = :donorContact1.AccountId];

        Opportunity oppTestAffl1 = [SELECT Id
            FROM Opportunity 
            WHERE AccountId = :donorAccount.Id];

        // Test that NPSP copies of Relationships and Affiliations got created
        List<npe4__Relationship__c> newNPSPRelationships = getNPSPRelationships(donorContact1.Id);

        System.assertEquals(2, newNPSPRelationships.size(), 
            'There should be 2 new Relationships for this Contact, there are : ' + newNPSPRelationships.size());
        npe4__Relationship__c newNPSPRel = newNPSPRelationships[0];
        npe4__Relationship__c newNPSPRel2 = newNPSPRelationships[1];
        System.assertEquals(friendType, newNPSPRel.npe4__Type__c);
        System.assertEquals(softCreditRole, newNPSPRel.npsp__Related_Opportunity_Contact_Role__c);
        System.assertEquals(solicitorRole, newNPSPRel2.npsp__Related_Opportunity_Contact_Role__c);

        List<npe5__Affiliation__c> newNPSPAffiliations = getNPSPAffiliations(donorAccount.Id);

        System.assertEquals(2, newNPSPAffiliations.size(), 
            'There should be 2 new Affiliations, there are : ' + newNPSPAffiliations.size());
        npe5__Affiliation__c newNPSPAffl = newNPSPAffiliations[0];
        npe5__Affiliation__c newNPSPAffl2 = newNPSPAffiliations[1];
        System.assertEquals(familyRole, newNPSPAffl.npe5__Role__c);
        System.assertEquals(softCreditRole, newNPSPAffl.npsp__Related_Opportunity_Contact_Role__c);
        System.assertEquals(creditContact2.Id, newNPSPAffl.npe5__Contact__c);
        System.assertEquals(solicitorRole, newNPSPAffl2.npsp__Related_Opportunity_Contact_Role__c);

        // Test update of existing NPSP Relationship and Affiliation copies
        // One of them will be changed, the other should be deleted and replaced with a new copy
        List<hed__Relationship__c> hedaRels = getEDARElationships(donorContact1.Id);
        System.assertEquals(2, hedaRels.size(), 
            'There should still be only 2 Relationship, there are : ' + hedaRels.size());

        System.runAs(testUser) {
            hedaRels[0].hed__Description__c = descriptionNotesUpdate;
            hedaRels[0].hed__Status__c = statusFormer;
            update hedaRels;
        }

        List<hed__Affiliation__c> hedaAffls = getEDAAffiliations(donorAccount.Id);
        System.assertEquals(2, hedaAffls.size(), 
            'There should still be only 2 Affiliation, there are : ' + hedaAffls.size());

        System.runAs(testUser) {
            // This will break the "sync", causing the existing copy to be deleted and remade
            hedaAffls[0].Related_Opportunity_Contact_Role__c = solicitorRole;
            hedaAffls[0].hed__Description__c = descriptionNotesUpdate;
            update hedaAffls;
        }

        Test.startTest();

        Opportunity oppTestRel2;
        Opportunity oppTestAffl2;
        System.runAs(testUser) {
            // Create new Opportunities to run the copy code again
            oppTestRel2 = UTIL_UnitTestData_TEST.getTestOpportunity(donorContact1.AccountId, donorContact1.Id);
            insert oppTestRel2;

            // Since the Affiliation role was changed, this Opp will create a different OCR Role
            oppTestAffl2 = UTIL_UnitTestData_TEST.getTestOpportunity(donorAccount.Id, null);
            insert oppTestAffl2;
        }

        Test.stopTest();

        // Now test that the NPSP copies reflect the changes made to the HEDA versions
        newNPSPRelationships = getNPSPRelationships(donorContact1.Id);

        System.assertEquals(2, newNPSPRelationships.size(), 
            'There should still be only 2 Relationship, there are : ' + newNPSPRelationships.size());

        npe4__Relationship__c updatedRel = newNPSPRelationships[0];
        System.assertEquals(descriptionNotesUpdate, updatedRel.npe4__Description__c);
        System.assertEquals(statusFormer, updatedRel.npe4__Status__c);


        newNPSPAffiliations = getNPSPAffiliations(donorAccount.Id);

        System.assertEquals(2, newNPSPAffiliations.size(), 
            'There should still be only 2 new Affiliations, there are : ' + newNPSPAffiliations.size());
        npe5__Affiliation__c updatedAffl = newNPSPAffiliations[0];
        System.assertEquals(descriptionNotesUpdate, updatedAffl.npe5__Description__c);
        System.assertEquals(solicitorRole, updatedAffl.npsp__Related_Opportunity_Contact_Role__c);
        System.assertEquals(creditContact2.Id, updatedAffl.npe5__Contact__c);

        // Test that the expected OCRs were created
        List<OpportunityContactRole> retrievedOCR
            = [SELECT Id, ContactId, Role, OpportunityId
                FROM OpportunityContactRole
                WHERE ContactId = :creditContact1.Id
                AND Role = :softCreditRole
                ORDER BY CreatedDate ASC];

        // There should be 1 Soft Credit OCR per Opportunity created using the Relationship
        System.assertEquals(2, retrievedOCR.size());
        System.assertEquals(oppTestRel1.Id, retrievedOCR[0].OpportunityId);
        System.assertEquals(oppTestRel2.Id, retrievedOCR[1].OpportunityId);

        retrievedOCR = [SELECT Id, ContactId, Role, OpportunityId
                FROM OpportunityContactRole
                WHERE ContactId = :creditContact2.Id
                ORDER BY CreatedDate ASC];

        // The first Opportunity created a Soft Credit role, the second created a Solicitor role
        System.assertEquals(2, retrievedOCR.size());
        System.assertEquals(oppTestAffl1.Id, retrievedOCR[0].OpportunityId);
        System.assertEquals(softCreditRole, retrievedOCR[0].Role);
        System.assertEquals(oppTestAffl2.Id, retrievedOCR[1].OpportunityId);
        System.assertEquals(solicitorRole, retrievedOCR[1].Role);

    }

    /*******************************************************************************************************
    * @description Check that deleting HEDA Relationships and Affiliations also deletes the NPSP copies
    */ 
    @isTest
    private static void testRelatedRecordDelete() {

        User testUser = UTIL_UnitTestData_TEST.createNewUserForTests(System.now().getTime() + '@testerson.com');

        Contact donorContact1 = returnContact(donor1FirstName);
        Contact donorContact2 = returnContact(donor2FirstName);
        Contact creditContact1 = returnContact(credit1FirstName);
        Contact creditContact2 = returnContact(credit2FirstName);
        Account donorAccount = [SELECT Id, Name FROM Account WHERE Name = :donorAccountName];

        // Check that NPSP copies were actually created before we test deleting them!
        List<npe4__Relationship__c> newNPSPRelationships = getNPSPRelationships(donorContact1.Id);
        System.assertEquals(2, newNPSPRelationships.size(), 
            'There should be 2 new NPSP Relationships for this Contact, there are : ' + newNPSPRelationships.size());

        List<npe5__Affiliation__c> newNPSPAffiliations = getNPSPAffiliations(donorAccount.Id);
        System.assertEquals(2, newNPSPAffiliations.size(), 
            'There should be 2 new NPSP Affiliations, there are : ' + newNPSPAffiliations.size());


        List<hed__Relationship__c> hedaRels = getEDARElationships(donorContact1.Id);
        System.assertEquals(2, hedaRels.size(), 
            'There should still be only 2 EDA Relationships, there are : ' + hedaRels.size());

        List<hed__Affiliation__c> hedaAffls = getEDAAffiliations(donorAccount.Id);
        System.assertEquals(2, hedaAffls.size(), 
            'There should still be only 2 EDA Affiliations, there are : ' + hedaAffls.size());

        Test.startTest();
        delete hedaRels[0];
        delete hedaAffls;
        Test.stopTest();

        // Check that NPSP copies were properly deleted
        newNPSPRelationships = getNPSPRelationships(donorContact1.Id);
        System.assertEquals(1, newNPSPRelationships.size(), 
            'There should be 1 NPSP Relationship for this Contact, there are : ' + newNPSPRelationships.size());
        System.assertEquals(solicitorRole, newNPSPRelationships[0].npsp__Related_Opportunity_Contact_Role__c, 
            'The remaining NPSP Relationship should be for Solicitor, not Soft Credit');

        newNPSPAffiliations = getNPSPAffiliations(donorAccount.Id);
        System.assertEquals(0, newNPSPAffiliations.size(), 
            'There should be 0 NPSP Affiliations, there are : ' + newNPSPAffiliations.size());


        // Now test the other way, deleting NPSP records should not delete EDA ones
        delete newNPSPRelationships;

        hedaRels = getEDARElationships(donorContact1.Id);
        System.assertEquals(1, hedaRels.size(), 
            'There should still be 1 EDA Relationship, there are : ' + hedaRels.size());


        // Editing an EDA Relationship should trigger a re-sync, adding back the NPSP record
        System.runAs(testUser) {
            hedaRels[0].hed__Description__c = 'Testing Resync';
            update hedaRels;
        }

        newNPSPRelationships = getNPSPRelationships(donorContact1.Id);
        System.assertEquals(1, newNPSPRelationships.size(), 
            'There should be 1 NPSP Relationship for this Contact, there are : ' + newNPSPRelationships.size());


    }

    /*******************************************************************************************************
    * @description Check that changing the parent Contact or Account on HEDA Relationships and Affiliations 
    * correctly deletes the original NPSP copies
    * As of EDA 1.81, Relationships can no longer be reparented, so we're only testing Affiliations now.
    */ 
    @isTest
    private static void testRelatedRecordReparent() {

        User testUser = UTIL_UnitTestData_TEST.createNewUserForTests(System.now().getTime() + '@testerson.com');

        Contact donorContact1 = returnContact(donor1FirstName);
        Contact donorContact2 = returnContact(donor2FirstName);
        Account donorAccount = [SELECT Id, Name FROM Account WHERE Name = :donorAccountName];

        String newAfflAccountName = 'New Affl Account';
        List<Account> donorAccounts = 
            UTIL_UnitTestData_TEST.getMultipleTestAccounts(1,hed.UTIL_Describe_API.getBizAccRecTypeID());
        donorAccounts[0].Name = newAfflAccountName;
        insert donorAccounts;
        Account newAfflAccount = donorAccounts[0];
        Id newAfflAccountId = newAfflAccount.Id;

        List<hed__Affiliation__c> hedaAffls = getEDAAffiliations(donorAccount.Id);
        System.assertEquals(2, hedaAffls.size(), 
            'There should be 2 EDA Affiliations, there are : ' + hedaAffls.size());

        Test.startTest();
        System.runAs(testUser) {
            hedaAffls[0].hed__Account__c = newAfflAccountId;
            hedaAffls[1].hed__Account__c = newAfflAccountId;
            update hedaAffls;
        }
        Test.stopTest();

        // The existing EDA Affiliations should be updated
        hedaAffls = getEDAAffiliations(donorAccount.Id);
        System.assertEquals(0, hedaAffls.size(), 
            'There should be 0 EDA Affiliations, there are : ' + hedaAffls.size());

        hedaAffls = getEDAAffiliations(newAfflAccountId);
        System.assertEquals(2, hedaAffls.size(), 
            'There should be 2 EDA Affiliations, there are : ' + hedaAffls.size());

        // This is where the true test begins, the old copies should have been deleted 
        List<npe5__Affiliation__c> newNPSPAffiliations = getNPSPAffiliations(newAfflAccountId);
        System.assertEquals(2, newNPSPAffiliations.size(), 
            'There should be 2 NPSP Affiliations, there are : ' + newNPSPAffiliations.size());

        newNPSPAffiliations = getNPSPAffiliations(donorAccount.Id);
        System.assertEquals(0, newNPSPAffiliations.size(), 
            'There should be 0 NPSP Affiliations, there are : ' + newNPSPAffiliations.size());

    }

    private static List<hed__Relationship__c> getEDARElationships(Id donorContactId){
        return [SELECT Id, 
            hed__Description__c, 
            hed__Status__c
            FROM hed__Relationship__c
            WHERE hed__Contact__c =: donorContactId
            ORDER BY Related_Opportunity_Contact_Role__c ASC];
    }

    private static List<hed__Affiliation__c> getEDAAffiliations(Id accountId){
        return [SELECT Id, 
            Related_Opportunity_Contact_Role__c,
            hed__Description__c
            FROM hed__Affiliation__c
            WHERE hed__Account__c =: accountId
            ORDER BY Related_Opportunity_Contact_Role__c ASC];
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
            WHERE npe4__Contact__c =: primaryContactId
            ORDER BY npsp__Related_Opportunity_Contact_Role__c ASC];
    }

    private static List<npe5__Affiliation__c> getNPSPAffiliations(Id accountId){
        return [SELECT Id, 
            npsp__Related_Opportunity_Contact_Role__c, 
            npe5__Description__c,
            npe5__Contact__c,
            npe5__Role__c,
            npe5__Organization__c
            FROM npe5__Affiliation__c
            WHERE npe5__Organization__c =: accountId
            ORDER BY npsp__Related_Opportunity_Contact_Role__c ASC];
    }

    /*********************************************************************************************************
    * @description Returns a Contact based on the provided FirstName
    *
    * @return Contact
    **********************************************************************************************************/
    private static Contact returnContact(String searchValue) {
        Contact retrievedContact = new Contact();

        List<Contact> allContacts = [SELECT Id, AccountId, FirstName FROM Contact];

        for (Contact eachContact : allContacts) {
            if (searchValue.equalsIgnoreCase(eachContact.FirstName)) {
                retrievedContact = eachContact;
            }
        }

        return retrievedContact;
    }

}