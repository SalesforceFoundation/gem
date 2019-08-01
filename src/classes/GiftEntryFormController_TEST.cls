/*
    © 2019, Salesforce.org.
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2018
* @group Gift Entry
* @group-content ../../ApexDocContent/GiftEntry.htm
* @description Tests specific to Gift Entry. 
*/
@isTest
private class GiftEntryFormController_TEST {

    private static String acctName = 'Test Account' + Datetime.now().getTime();
    private static String cFirst = 'Testfirst';
    private static String cLast = 'Testlast';
    private static String c2First = 'Secondname';
    private static String c2Last = 'Secondlast';
    private static String oppName = 'Test Opp' + Datetime.now().getTime();
    private static String openStage = 'Prospecting';
    private static String openStage2 = 'Qualification';
    private static String tributeName = 'Tribute Name';
    private static String recipientName = 'Recipient Name';
    private static String updateStringTest = 'New Text';
    private static String donationName = 'Test Donation';
    private static Decimal donationAmount = 100;
    private static String closedWonStage = UTIL_UnitTestData_TEST.getClosedWonStage();
    
    @testSetup static void setupGiftEntry() {
        GEM_Settings__c gemSettings = UTIL_CustomSettingsFacade.getOrgGemSettings();
        gemSettings.Sync_Account_Models__c = true;
        UTIL_CustomSettingsFacade.getOrgGemSettingsForTests(gemSettings);

        UTIL_CustomSettingsFacade.setHEDASettingForTest(
            new hed__Hierarchy_Settings__c(hed__Account_Processor__c = hed.UTIL_Describe_API.getAdminAccRecTypeID()));
        GiftEntryFormController.insertGiftEntrySettings();
    }

    private static GiftEntryFormController.GiftFormModel returnGiftModel(){
        GiftEntryFormController.GiftFormModel giftModel = setModelData(acctName, 
            cFirst, cLast, oppName, closedWonStage, donationAmount);
        return giftModel;
    }

    private static GiftEntryFormController.GiftFormModel setModelData(String acctName, 
        String cFirst, String cLast, String oppName, String closedWonStage, Decimal donationAmount){
            GiftEntryFormController.GiftFormModel giftModel = new GiftEntryFormController.GiftFormModel();
            Account a = new Account(Name=acctName);
            insert a;
            Contact c = new Contact(FirstName=cFirst, LastName=cLast);
            insert c;
            giftModel.di.npsp__Account1Imported__c = a.Id;
            giftModel.di.npsp__Contact1Imported__c = c.Id;
            giftModel.di.npsp__Donation_Name__c = oppName;
            giftModel.di.npsp__Donation_Date__c = System.today(); 
            giftModel.di.npsp__Donation_Stage__c = closedWonStage;
            giftModel.di.npsp__Donation_Amount__c = donationAmount;
            return giftModel;
    }

    /*******************************************************************************************************
    * @description Test creating new Account, Contact and Opportunity via Gift Form
    */ 
    @isTest
    private static void testNewGift() {
        GEM_Settings__c gemSettings = UTIL_CustomSettingsFacade.getOrgGemSettings();
        gemSettings.Sync_Account_Models__c = true;
        UTIL_CustomSettingsFacade.getOrgGemSettingsForTests(gemSettings);

        GiftEntryFormController.GiftFormModel giftModel = returnGiftModel();
    
        Test.startTest();
        giftModel = GiftEntryFormController.saveDonationInformation(giftModel);
        Test.stopTest();

        List<Opportunity> opps = [SELECT Id FROM Opportunity 
            WHERE npsp__Primary_Contact__r.FirstName =: cFirst
            AND npsp__Primary_Contact__r.LastName =: cLast];
        System.assert(opps.size() == 1, 'Make sure Opportunity was created and Contact was assigned');
        Opportunity opp = opps[0];

        List<npe01__OppPayment__c> payments = [SELECT Id FROM npe01__OppPayment__c 
            WHERE npe01__Opportunity__c =: opp.Id];
        System.assertEquals(1, payments.size(), 'There should be a payment for the closed donation');

        // Now test loading this gift
        giftModel = GiftEntryFormController.initClass(opp.Id);
        System.assertEquals(1, giftModel.payments.size(), 'The existing payment should have been found');

    }

    @isTest
    private static void testJsonProcess() {

        String gauAmt = '123';
        String gauPerc = '12';
        String gauName = 'Test2';
        npsp__General_Accounting_Unit__c testGau = 
            new npsp__General_Accounting_Unit__c(Name=gauName, npsp__Active__c=true);

        insert testGau;
        String gauId = (String)testGau.Id;

        Contact scContact = new Contact(FirstName='Soft', LastName='Credit');
        insert scContact;
        Id scContactId = scContact.Id;

        // Test stripping Lightning attributes from JSON, then processing it into a Donation
        String testJson = '{"di":{"sobjectType":"npsp__DataImport__c","npsp__Contact1_Firstname__c":"Firstname","npsp__Contact1_Lastname__c":"Lastname","npsp__Donation_Amount__c":1000,"npsp__Donation_Name__c":"Test Opp","npsp__DonationImported__c":null'
        + ',"npsp__Account1Imported__c":"","npsp__Contact1Imported__c":"","npsp__DonationCampaignImported__c":"","Donation_Honoree_Contact__c":"","Donation_Matching_Gift_Account__c":"","Donation_Matching_Gift__c":"","npsp__Donation_Stage__c":"Closed Won","npsp__Payment_Method__c":"","Donation_Tribute_Type__c":"","Donation_Acknowledgment_Status__c":"","Donation_Matching_Gift_Status__c":"","npsp__Donation_Date__c":"2018-09-05"}'
        + ',"opp":{"sobjectType":"Opportunity","Id":"","StageName":"","ForecastCategory":""}'
        + ',"allocs":['
        + '{"npsp__Opportunity__c":"","npsp__General_Accounting_Unit__c":"'+gauId+'","npsp__Amount__c":"'+gauAmt+'","npsp__Percent__c":""}'
        + ',{"npsp__Opportunity__c":"","npsp__General_Accounting_Unit__c":"'+gauId+'","npsp__Amount__c":"","npsp__Percent__c":"'+gauPerc+'"}'
        + ']'
        + ',"payments":['
        + '{"npe01__Paid__c":false,"npe01__Payment_Amount__c":"'+gauAmt+'","npe01__Scheduled_Date__c":"2018-08-06","npe01__Payment_Method__c":"Cash","npe01__Opportunity__c":""}'
        + ']'
        + ',"partialCredits":[' 
        + '{"npsp__Amount__c":"'+gauAmt+'","npsp__Contact__c":"' + scContactId + '"}]'
        + '}';
        
        Test.startTest();
        GiftEntryFormController.GiftFormModel giftModel = new GiftEntryFormController.GiftFormModel();
        giftModel = GiftEntryFormController.saveGift(testJson);
        Test.stopTest();

        Id oppId = giftModel.oppId;
        System.assert(giftModel.oppId != null, 'The new Opportunity ID should be returned');

        List<npsp__Allocation__c> allocs = giftModel.allocs;
        List<npe01__OppPayment__c> payments = giftModel.payments;

        // Check that the allocations were created
        List<npsp__Allocation__c> alloQuery = [Select Id from npsp__Allocation__c 
            where npsp__General_Accounting_Unit__c =: gauId
            and npsp__Opportunity__c =: oppId];
        System.assertEquals(2, alloQuery.size());

        // Check that the payments were created
        Decimal payAmt = Decimal.ValueOf(gauAmt);
        List<npe01__OppPayment__c> paymentQuery = [Select Id from npe01__OppPayment__c 
            where npe01__Opportunity__c =: oppId
            and npe01__Payment_Amount__c =: payAmt
            and npe01__Paid__c = false];
        System.assertEquals(1, paymentQuery.size());
        
        // Check that partial soft credits were created
        List<npsp__Partial_Soft_Credit__c> pscQuery = [Select Id from npsp__Partial_Soft_Credit__c 
            where npsp__Contact__c =: scContactId
            and npsp__Amount__c =: payAmt];
        System.assertEquals(1, pscQuery.size());

        // Simulate donation matching, then updating a payment to be paid:
        //  Using the previously created Opportunity, run the process again with the payment marked paid,
        //  and make sure no new Data Import objects were created
        testJson = testJson.replace('"npe01__Paid__c":false', '"npe01__Paid__c":true');
        testJson = testJson.replace('"Id":"","StageName":"","ForecastCategory":""', 
            '"Id":"'+ oppId +'","StageName":"Closed Won","ForecastCategory":"Closed"');
        testJson = testJson.replace('"npsp__DonationImported__c":null', 
            '"npsp__DonationImported__c":"'+ oppId +'"');
        giftModel = GiftEntryFormController.saveGift(testJson);

        List<npsp__DataImport__c> dataImports = [SELECT Id, npsp__DonationImported__c 
                    FROM npsp__DataImport__c 
                    WHERE npsp__DonationImported__c = :oppId];
        System.assertEquals(1, dataImports.size(), 
            '1 DataImport should be returned, ' + dataImports.size() + ' were returned instead');

        paymentQuery = [Select Id from npe01__OppPayment__c 
            where npe01__Opportunity__c =: oppId
            and npe01__Payment_Amount__c =: payAmt
            and npe01__Paid__c = true];
        System.assertEquals(1, paymentQuery.size(),
            '1 Payment should be returned, ' + paymentQuery.size() + ' were returned instead');

    }

    // Testing Single Gift Entry updating an existing Opportunity
    // Make sure a second Opportunity is not created, and make sure the original Opp gets properly updated.
    @isTest
    private static void testRunGiftProcessUpdate() {
        npsp__DataImport__c diObj = getTestDI();
        diObj.Do_Not_Automatically_Create_Payment__c = true;
        diObj.npsp__Donation_Stage__c = openStage;
        insert diObj;

        GiftEntryFormController ge = new GiftEntryFormController();
        
        Test.startTest();
        GiftEntryFormController.runGiftProcess(diObj.Id, false, false);
        Test.stopTest();
        
        // Make sure the Opp is open and does not have payments, otherwise it can't be updated
        List<Opportunity> oppList = [SELECT Id, npsp__Honoree_Name__c, npsp__Notification_Recipient_Name__c
            FROM Opportunity 
            WHERE Name =: donationName
            AND npsp__Honoree_Name__c =: tributeName
            AND npsp__Notification_Recipient_Name__c =: recipientName
            AND npe01__Number_of_Payments__c = 0 
            AND IsClosed = false
        ];
        System.assertEquals(1, oppList.size());

        Decimal newAmt = 200;
        // Forcing the Opportunity match to test updating
        npsp__DataImport__c diObj2 = diObj.clone(false, false, false, false);
        diObj2.npsp__DonationImported__c = oppList[0].Id;
        diObj2.npsp__Donation_Amount__c = newAmt;
        insert diObj2;

        GiftEntryFormController.runGiftProcess(diObj2.Id, false, true);

        oppList = [SELECT Id, Amount
            FROM Opportunity 
            WHERE Name =: donationName
        ];

        System.assertEquals(1, oppList.size());
        System.assertEquals(newAmt, oppList[0].Amount);
    }
    
    @isTest
    private static void testRunGiftProcess() {
        npsp__DataImport__c diObj = getTestDI();
        insert diObj;

        // Test error handling
        Id oppId = GiftEntryFormController.getOpportunityIdFromImport(diObj.Id);
        System.assertEquals(null, oppId);

        GiftEntryFormController ge = new GiftEntryFormController();
        
        Test.startTest();
        GiftEntryFormController.runGiftProcess(diObj.Id, false, false);
        Test.stopTest();
        
        List<Opportunity> oppList = [Select Id, npsp__Honoree_Name__c, npsp__Notification_Recipient_Name__c
            from Opportunity 
            where Name =: donationName
            and npsp__Honoree_Name__c =: tributeName
            and npsp__Notification_Recipient_Name__c =: recipientName
        ];
        System.assertEquals(1, oppList.size());

        List<Contact> cList = [Select Id from Contact where FirstName =: cFirst and LastName =: cLast];
        System.assertEquals(1, cList.size());

        cList = [Select Id from Contact where FirstName =: c2First and LastName =: c2Last];
        System.assertEquals(1, cList.size());

        List<npe01__OppPayment__c> paymentList = [Select Id from npe01__OppPayment__c 
            where npe01__Payment_Amount__c =: donationAmount];
        System.assertEquals(1, paymentList.size());

        // Make sure the Opportunity ID returned is the same as the one created
        oppId = GiftEntryFormController.getOpportunityIdFromImport(diObj.Id);
        System.assertEquals(oppId, oppList[0].Id);

        Map<String,List<String>> picklistValueMap = GiftEntryFormController.getPickListValues();
        System.assert(picklistValueMap.size() > 0);

        // Now test the JSON related list object creation
        String gauAmt = '123';
        String gauPerc = '12';
        String gauName = 'Test2';
        npsp__General_Accounting_Unit__c testGau = 
            new npsp__General_Accounting_Unit__c(Name=gauName, npsp__Active__c=true);

        insert testGau;
        String gauId = (String)testGau.Id;

        String oppIdPlaceholder = Label.Gift_Donation_ID_Placeholder;
        String jsonString = '{"npsp__Allocation__c":[';
        jsonString += '{"npsp__Opportunity__c":"'+oppIdPlaceholder+'","npsp__General_Accounting_Unit__c":"'+gauId+'","npsp__Amount__c":"'+gauAmt+'","npsp__Percent__c":"","npsp__Opportunity__c":"'+oppId+'"}';
        jsonString += ',';      
        jsonString += '{"npsp__Opportunity__c":"'+oppIdPlaceholder+'","npsp__General_Accounting_Unit__c":"'+gauId+'","npsp__Amount__c":"","npsp__Percent__c":"'+gauPerc+'","npsp__Opportunity__c":"'+oppId+'"}';
        jsonString += ']}';
        diObj.Post_Process_Object_JSON__c = jsonString;
        update diObj;
        List<npsp__DataImport__c> diList = new List<npsp__DataImport__c>{diObj};
        processJSONList(diList);

        // Check that the allocations were created
        List<npsp__Allocation__c> testList = [
                Select Id
                from npsp__Allocation__c
                where npsp__General_Accounting_Unit__c = :gauId
                and npsp__Opportunity__c = :oppId
        ];
        System.assertEquals(2, testList.size());
        
    }

    /*******************************************************************************************************
    * @description For a list of DataImport objects with Post Process JSON values filled in,
    * process those lists to add related objects
    * @param listDi List of DataImport objects that will have Post_Process_Object_JSON__c processed
    * @return void
    */
    public static void processJSONList(List<npsp__DataImport__c> listDi) {
        List<SObject> objsToUpsert = new List<SObject>();

        Set<Id> diIdSet = new Set<Id>();
        // Select the fields we need
        for(npsp__DataImport__c di : listDi) {
            diIdSet.add(di.Id);
        }

        List<npsp__DataImport__c> listDiWithFields = [
                SELECT Id, Post_Process_Object_JSON__c, npsp__DonationImported__c
                FROM npsp__DataImport__c
                WHERE Id IN :diIdSet
        ];

        List<SObject> thisList;
        Map<String, Object> objNameToObjList;
        for(npsp__DataImport__c di : listDiWithFields) {
            if(di.Post_Process_Object_JSON__c == null) {
                continue;
            }
            String oppId = di.npsp__DonationImported__c;
            thisList = new List<SObject>();
            objNameToObjList = (Map<String, Object>)JSON.deserializeUntyped(di.Post_Process_Object_JSON__c);
            // For each objet type included, add the list
            for(String objName : objNameToObjList.keySet()) {
                Object objList = objNameToObjList.get(objName);
                if(objList != null) {
                    String objListString = JSON.serialize(objList);
                    // Replace opportunity Id placeholders with the actual Id
                    if(oppId != null) {
                        String oppIdPlaceholderRegex = Label.Gift_Donation_ID_Placeholder;
                        objListString = objListString.replaceAll(oppIdPlaceholderRegex, oppId);
                    }
                    Type listType = Type.forName('List<' + objName + '>');
                    thisList = (List<SObject>)JSON.deserialize(objListString, listType);
                    objsToUpsert.addAll(thisList);
                }
            }
        }

        // TODO: How to handle upsert? Need to separate into object lists?
        if(!objsToUpsert.isEmpty()) {
            UTIL_CrudFLS.create(objsToUpsert);
        }
    }

    @isTest
    private static void runGiftBatch() {
        npsp__DataImportBatch__c diBatch = new npsp__DataImportBatch__c(Name = 'Gift Entry Batch');
        insert diBatch;

        npsp__DataImport__c diObj = getTestDI();
        diObj.npsp__NPSP_Data_Import_Batch__c = diBatch.Id;
        insert diObj;
        
        // Test error handling
        GiftEntryFormController.runGiftBatch(null);

        Test.startTest();
        GiftEntryFormController.runGiftBatch(diBatch.Id);
        Test.stopTest();
        
        List<Opportunity> oppList = [Select Id from Opportunity where Name =: donationName];
        System.assertEquals(1, oppList.size());

        List<Contact> cList = [Select Id from Contact where FirstName =: cFirst and LastName =: cLast];
        System.assertEquals(1, cList.size());

        List<npe01__OppPayment__c> paymentList = [Select Id from npe01__OppPayment__c 
            where npe01__Payment_Amount__c =: donationAmount];
        System.assertEquals(1, paymentList.size());
    }

    @isTest
    private static void testGetOpenDonations() {
        Contact con1 = UTIL_UnitTestData_TEST.getContact();
        insert con1;

        Opportunity opp = UTIL_UnitTestData_TEST.getOpenOpportunity(con1, 100);
        Opportunity opp2 = UTIL_UnitTestData_TEST.getOpenOpportunity(con1, 100);
        opp2.StageName = UTIL_UnitTestData_TEST.getClosedWonStage();
        insert new List<Opportunity>{opp, opp2};

        // Add an unpaid payment to the closed Opp, which should be found by matching query
        npe01__OppPayment__c p1 = UTIL_UnitTestData_TEST.getUnpaidPayment(opp2, 100);
        insert p1;

        Test.startTest();
        String openDonations = GiftEntryFormController.getOpenDonations(con1.Id, 'Contact1');
        Test.stopTest();

        System.assert(openDonations.contains(opp.Name));
        System.assert(openDonations.contains(opp2.Name));
        System.assert(openDonations.contains(opp.Id));
        System.assert(openDonations.contains(opp2.Id));

        con1 = [SELECT Id, AccountId FROM Contact WHERE Id =:con1.Id];
        String openAccountDonations = GiftEntryFormController.getOpenDonations(con1.AccountId, 'Account1');

        System.assert(openAccountDonations.contains(opp.Name));
        System.assert(openAccountDonations.contains(opp2.Name));
        System.assert(openAccountDonations.contains(opp.Id));
        System.assert(openAccountDonations.contains(opp2.Id));
    }

    // Checking that an existing gift can be loaded and saved using our provided Permission Set
    @isTest
    private static void testGiftEntryWithPermissionSet() {

        User u = UTIL_UnitTestData_TEST.createNewUserForTests(System.now().getTime() + '@testerson.com');
        UTIL_UnitTestData_TEST.assignGiftEntryPermissionSetToUser(u.Id);

        Contact con1 = UTIL_UnitTestData_TEST.getContact();
        insert con1;

        Test.startTest();
        Opportunity opp = UTIL_UnitTestData_TEST.getOpenOpportunity(con1, 100);
        insert opp;
        Test.stopTest();

        GiftEntryFormController.GiftFormModel giftModel;
        
        System.runAs(u) {
            giftModel = GiftEntryFormController.initClass(opp.Id);
            giftModel.oppId = opp.Id;
            GiftEntryFormController.saveDonationInformation(giftModel);
        }

        System.assertNotEquals(null, giftModel);
    }
    
    // Check that field mapping validation acts like we expect
    @isTest
    private static void testValidateMappings() {

        try {
            GiftEntryFormController.validateForm();
            System.assert(true, 'No exception');
        } catch(Exception e){
            System.assert(false, 'This case should not have an exception');
        }

        List<String> fakeFields = new List<String>{'fake__c', 'fail__c'};
        
        try {
            GiftEntryFormController.validateMappings(fakeFields);
            System.assert(false, 'This case should throw an exception');
        } catch(Exception e){
            System.assert(e.getMessage().contains(Label.Error_No_Data_Import_Mapping), 
                'The exception did not match what was expected: ' + Label.Error_No_Data_Import_Mapping);
        }

    }

    private static npsp__DataImport__c getTestDI(){
        return new npsp__DataImport__c(
            npsp__Contact1_Firstname__c = cFirst,
            npsp__Contact1_Lastname__c = cLast,
            npsp__Contact2_Firstname__c = c2First,
            npsp__Contact2_Lastname__c = c2Last,
            npsp__Donation_Name__c = donationName,
            npsp__Payment_Method__c = 'Cash',
            npsp__Donation_Date__c = System.today(),
            npsp__Donation_Amount__c = donationAmount,
            Notification_Recipient_Name__c = recipientName,
            Donation_Honoree_Name__c = tributeName
        );
    }
    
}