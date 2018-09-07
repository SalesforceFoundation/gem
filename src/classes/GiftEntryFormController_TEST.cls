/*
    Copyright (c) 2018, Salesforce.org
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

    private static String acctName = 'Test Account';
    private static String cFirst = 'Testfirst';
    private static String cLast = 'Testlast';
    private static String c2First = 'Secondname';
    private static String c2Last = 'Secondlast';
    private static String oppName = 'Test Opp';
    private static String openStage = 'Prospecting';
    private static String openStage2 = 'Qualification';
    private static String tributeName = 'Tribute Name';
    private static String recipientName = 'Recipient Name';
    private static String updateStringTest = 'New Text';
    private static String donationName = 'Test Donation';
    private static Decimal donationAmount = 100;
    private static String closedWonStage = UTIL_UnitTestData_TEST.getClosedWonStage();
    
    @testSetup static void setupGiftEntry() {
    	GiftEntryFormController.insertGiftEntrySettings();
    }

    private static GiftEntryFormController.GiftFormModel setupModelData(){
        GiftEntryFormController.GiftFormModel giftModel = new GiftEntryFormController.GiftFormModel();
        giftModel.acct = new Account(Name=acctName);
        giftModel.contact = new Contact(FirstName=cFirst, LastName=cLast);
        giftModel.opp = new Opportunity(Name=oppName, 
            CloseDate=System.today(), 
            StageName=closedWonStage, 
            Amount=donationAmount);
        return giftModel;
    }

    /*******************************************************************************************************
    * @description Test creating new Account, Contact and Opportunity via Gift Form
    */ 
    @isTest
    private static void testNewGift() {

        GiftEntryFormController.GiftFormModel giftModel = setupModelData();
    
        Test.startTest();
        giftModel = GiftEntryFormController.GiftFormModel.saveDonationInformation(giftModel);
        Test.stopTest();

        List<Opportunity> opps = [SELECT Id FROM Opportunity 
            WHERE Account.Name =: acctName
            AND npsp__Primary_Contact__r.FirstName =: cFirst
            AND npsp__Primary_Contact__r.LastName =: cLast];
        System.assert(opps.size() == 1, 'Make sure Opportunity was created and Account and Contact were assigned');
        Opportunity opp = opps[0];

        Contact c = [SELECT Id, Account.Name FROM Contact WHERE Id =: giftModel.contact.Id];
        // Contact is being set to 'TestLast Administrative Account', is that right?
        //System.assertEquals(acctName, c.Account.Name, 'The Contact should be under the new Account ');

        List<npe01__OppPayment__c> payments = [SELECT Id FROM npe01__OppPayment__c 
            WHERE npe01__Opportunity__c =: opp.Id];
        System.assertEquals(1, payments.size(), 'There should be a payment for the closed donation');

    }

    @isTest
    private static void setDataMatches() {

        Account a = new Account(Name=acctName + ' 2');
        insert a;
        insert new Contact(Firstname='NewFirst',Lastname=cLast);
        insert new Opportunity(Name=oppName + ' 2', 
            CloseDate=System.today().addDays(-10),
            AccountId=a.Id, 
            StageName=closedWonStage,
            Amount=50);

        GiftEntryFormController.GiftFormModel giftModel = setupModelData();
        giftModel.opp.AccountId = a.Id;

        giftModel = GiftEntryFormController.GiftFormModel.setDataMatches(giftModel);

        System.assertNotEquals(null, giftModel.matchedAccts);
        System.assertEquals(1, giftModel.matchedAccts.size(), 
            'One Account match should be found');

        System.assertNotEquals(null, giftModel.matchedContacts);
        System.assertEquals(1, giftModel.matchedContacts.size(), 
            'One Contact match should be found');

        System.assertNotEquals(null, giftModel.matchedOpps);
        System.assertEquals(1, giftModel.matchedContacts.size(), 
            'One Opportunity match should be found');

    }

    /*******************************************************************************************************
    * @description Test updating existing Account and Contact via Gift Form
    */ 
    @isTest
    private static void testUpdateGiftDonor() {

        String acctName = 'Test Account';
        String acctName2 = 'Test Account Update';
        String cFirst = 'TestFirst';
        String cLast = 'TestLast';
        String cLast2 = 'TestLastUpdate';
        String closedWonStage = UTIL_UnitTestData_TEST.getClosedWonStage();

        Account a = new Account(Name=acctName);
        Contact c = new Contact(FirstName=cFirst, LastName=cLast);

        insert a;
        insert c;

        GiftEntryFormController.GiftFormModel giftModel = new GiftEntryFormController.GiftFormModel();
        giftModel.acct = new Account(Name=acctName2);
        giftModel.contact = new Contact(FirstName=cFirst, LastName=cLast2);
        giftModel.opp = new Opportunity(Name='Test Opp', 
            CloseDate=System.today(), 
            StageName=closedWonStage, 
            Amount=100,
            npsp__Primary_Contact__c=c.Id,
            AccountId = a.Id);
    
        Test.startTest();
        giftModel = GiftEntryFormController.GiftFormModel.saveDonationInformation(giftModel);
        Test.stopTest();

        List<Opportunity> opps = [SELECT Id FROM Opportunity 
            WHERE Account.Name =: acctName2
            AND npsp__Primary_Contact__r.FirstName =: cFirst
            AND npsp__Primary_Contact__r.LastName =: cLast2];
        System.assert(opps.size() == 1, 'Make sure Opportunity was created and Account and Contact were assigned and updated');

        List<Contact> cList = [SELECT Id, Account.Name FROM Contact];
        System.assert(cList.size() == 1, 'Contact should have been updated, not added');

        List<Account> aList = [SELECT Id, Name FROM Account WHERE Name =: acctName];
        System.assert(aList.size() == 0, 'Account should have been updated, not added');
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
        String testJson = '{"di":{"sobjectType":"npsp__DataImport__c","npsp__Contact1_Firstname__c":"Firstname","npsp__Contact1_Lastname__c":"Lastname","npsp__Donation_Amount__c":1000,"npsp__Donation_Name__c":"Test Opp"'
        + ',"npsp__Account1Imported__c":"","npsp__Account1Imported__r":{"sobjectType":"Account","Name":""},"npsp__Contact1Imported__c":"","npsp__Contact1Imported__r":{"sobjectType":"Contact","Name":""},"Donation_Primary_Campaign__c":"","Donation_Primary_Campaign__r":{"sobjectType":"Campaign","Name":""},"Donation_Honoree_Contact__c":"","Donation_Honoree_Contact__r":{"sobjectType":"Contact","Name":""},"Donation_Matching_Gift_Account__c":"","Donation_Matching_Gift_Account__r":{"sobjectType":"Account","Name":""},"Donation_Matching_Gift__c":"","Donation_Matching_Gift__r":{"sobjectType":"Opportunity","Name":""},"npsp__Donation_Stage__c":"Closed Won","npsp__Payment_Method__c":"","Donation_Tribute_Type__c":"","Donation_Acknowledgment_Status__c":"","Donation_Matching_Gift_Status__c":"","npsp__Donation_Date__c":"2018-09-05"}'
        // + ',"contact":{"FirstName":"Firstname","LastName":"Lastname"}'
        // + ',"opp":{"sobjectType":"Opportunity","AccountId":"","Account":{"sobjectType":"Account","Name":""},"npsp__Primary_Contact__c":"","npsp__Primary_Contact__r":{"sobjectType":"Contact","Name":""},"StageName":"Closed Won","Campaign":{"sobjectType":"Campaign","Name":""},"npsp__Tribute_Type__c":"","npsp__Acknowledgment_Status__c":"","npsp__Honoree_Contact__c":"","npsp__Honoree_Contact__r":{"sobjectType":"Contact","Name":""},"npsp__Matching_Gift_Account__c":"","npsp__Matching_Gift_Account__r":{"sobjectType":"Account","Name":""},"npsp__Matching_Gift__c":"","npsp__Matching_Gift__r":{"sobjectType":"Opportunity","Name":""},"npsp__Matching_Gift_Status__c":"","Name":"Test Opp","Amount":1000,"CloseDate":"2018-08-03"}'
        + ',"allocs":['
        + '{"npsp__Opportunity__c":"","npsp__General_Accounting_Unit__c":"'+gauId+'","npsp__Amount__c":"'+gauAmt+'","npsp__Percent__c":""}'
        + ',{"npsp__Opportunity__c":"","npsp__General_Accounting_Unit__c":"'+gauId+'","npsp__Amount__c":"","npsp__Percent__c":"'+gauPerc+'"}'
        + ']'
        + ',"payments":['
        + '{"npe01__Payment_Amount__c":"'+gauAmt+'","npe01__Scheduled_Date__c":"2018-08-06","npe01__Payment_Method__c":"Cash","npe01__Opportunity__c":""}'
        + ']'
        + ',"partialCredits":[' 
        + '{"npsp__Amount__c":"'+gauAmt+'","npsp__Contact__c":"' + scContactId + '"}]'
        + '}';
        
        GiftEntryFormController.GiftFormModel giftModel = new GiftEntryFormController.GiftFormModel();
        giftModel = GiftEntryFormController.processGiftModelString(testJson);
        giftModel = GiftEntryFormController.saveDonationInformation(giftModel);

        Id oppId = giftModel.oppId;
        System.assert(giftModel.oppId != null, 'The new Opportunity ID should be returned');

        // Contact c = giftModel.contact;
        // Account a = giftModel.acct;
        // Opportunity o = giftModel.opp;
        List<npsp__Allocation__c> allocs = giftModel.allocs;
        List<npe01__OppPayment__c> payments = giftModel.payments;

        // System.assertEquals('Firstname', c.FirstName, 'The Contact should be set on the controller');
        // System.assertEquals('New Account', a.Name, 'The Account should be set on the controller');
        // System.assertEquals('Test Opp', o.Name, 'The Opportunity should be set on the controller');

        // Check that the allocations were created
        List<npsp__Allocation__c> alloQuery = [Select Id from npsp__Allocation__c 
            where npsp__General_Accounting_Unit__c =: gauId
            and npsp__Opportunity__c =: oppId];
        System.assertEquals(2, alloQuery.size());

        // Check that the payments were created
        Decimal payAmt = Decimal.ValueOf(gauAmt);
        List<npe01__OppPayment__c> paymentQuery = [Select Id from npe01__OppPayment__c 
            where npe01__Opportunity__c =: oppId
            and npe01__Payment_Amount__c =: payAmt];
        System.assertEquals(1, paymentQuery.size());
        
        // Check that partial soft credits were created
        List<npsp__Partial_Soft_Credit__c> pscQuery = [Select Id from npsp__Partial_Soft_Credit__c 
            where npsp__Contact__c =: scContactId
            and npsp__Amount__c =: payAmt];
        System.assertEquals(1, pscQuery.size());

        // Now test deletion of related objects
        List<SObject> objToDelete = new List<SObject>();

        objToDelete.addAll((List<SObject>)alloQuery);
        objToDelete.addAll((List<SObject>)paymentQuery);
        objToDelete.addAll((List<SObject>)pscQuery);

        giftModel.objsToDelete = objToDelete;

        GiftEntryFormController.deleteObjList(giftModel.objsToDelete);

        alloQuery = [Select Id from npsp__Allocation__c 
            where npsp__General_Accounting_Unit__c =: gauId
            and npsp__Opportunity__c =: oppId];
        System.assertEquals(0, alloQuery.size());

        paymentQuery = [Select Id from npe01__OppPayment__c 
            where npe01__Opportunity__c =: oppId
            and npe01__Payment_Amount__c =: payAmt];
        System.assertEquals(0, paymentQuery.size());

        pscQuery = [Select Id from npsp__Partial_Soft_Credit__c 
            where npsp__Contact__c =: scContactId
            and npsp__Amount__c =: payAmt];
        System.assertEquals(0, pscQuery.size());
        
    }

    @isTest
    private static void testDataImportUpdate() {

        List<npsp__Data_Import_Settings__c> diSettingsList = 
            [Select npsp__Donation_Matching_Behavior__c from npsp__Data_Import_Settings__c];

        npsp__DataImport__c diObj = getTestDI();
        diObj.npsp__Donation_Stage__c = openStage;
        diObj.Do_Not_Automatically_Create_Payment__c = true;
        insert diObj;
        
        GiftEntryFormController.runGiftProcess(diObj.Id, false);
        
        List<Opportunity> oppList = [Select Id, npsp__Honoree_Name__c, npsp__Notification_Recipient_Name__c
            from Opportunity 
            where Name =: donationName
            and npsp__Honoree_Name__c =: tributeName
            and npsp__Notification_Recipient_Name__c =: recipientName
            and StageName =: openStage
        ];
    
        System.assertEquals(1, oppList.size());

        // Now make a change to the DataImport object, 
        // and check that the Donation and Payment were updated
        diObj.npsp__Payment_Method__c = 'Check';
        diObj.Notification_Recipient_Name__c = updateStringTest;
        diObj.npsp__Donation_Stage__c = openStage2;
        Decimal newAmt = 500;
        diObj.npsp__Donation_Amount__c = newAmt;

        update diObj;

        Test.startTest();
        GiftEntryFormController.runGiftProcess(diObj.Id, false);
        Test.stopTest();

        // Check the errors on diObj
        diObj = [Select npsp__Status__c,
            npsp__Contact1ImportStatus__c,
            npsp__FailureInformation__c,
            npsp__DonationImportStatus__c,
            npsp__PaymentImportStatus__c
            from npsp__DataImport__c 
            where Id =: diObj.Id];
        //System.debug(diObj);

        // There should not be a payment, it will need to be added later
        List<npe01__OppPayment__c> paymentList = [Select Id from npe01__OppPayment__c];
        System.assertEquals(0, paymentList.size());

        // Make sure there is still only 1 opportunity
        oppList = [Select Id from Opportunity];
        System.assertEquals(1, oppList.size());

        // Now check that the Opportunity was correctly updated
        oppList = [Select Id, npsp__Honoree_Name__c, npsp__Notification_Recipient_Name__c,
            Amount, StageName
            from Opportunity 
            where Name =: donationName
            and npsp__Honoree_Name__c =: tributeName
            and npsp__Notification_Recipient_Name__c =: updateStringTest
            and StageName =: openStage2
            and npsp__Notification_Recipient_Name__c =: updateStringTest
        ];

        //System.debug(oppList);
        System.assertEquals(1, oppList.size());
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
        GiftEntryFormController.runGiftProcess(diObj.Id, false);
        Test.stopTest();
        
        List<Opportunity> oppList = [Select Id, npsp__Honoree_Name__c, npsp__Notification_Recipient_Name__c
            from Opportunity 
            where Name =: donationName
            and npsp__Honoree_Name__c =: tributeName
            and npsp__Notification_Recipient_Name__c =: recipientName
        ];
        //System.debug(oppList);
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
        GiftEntryFormController.processJSONList(diList);

        // Check that the allocations were created
        List<npsp__Allocation__c> testList = [Select Id from npsp__Allocation__c 
            where npsp__General_Accounting_Unit__c =: gauId
            and npsp__Opportunity__c =: oppId];
        System.assertEquals(2, testList.size());
        
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