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

    private static String cFirst = 'Testfirst';
    private static String cLast = 'Testlast';
    private static String c2First = 'Secondname';
    private static String c2Last = 'Secondlast';
    private static String openStage = 'Prospecting';
    private static String openStage2 = 'Qualification';
    private static String tributeName = 'Tribute Name';
    private static String recipientName = 'Recipient Name';
    private static String updateStringTest = 'New Text';
    private static String donationName = 'Test Donation';
    private static Decimal donationAmount = 100;
    
    @testSetup static void setupGiftEntry() {
    	GiftEntryFormController.insertGiftEntrySettings();
    }

    @isTest
    private static void testDataImportUpdate() {

        List<npsp__Data_Import_Settings__c> diSettingsList = 
            [Select npsp__Donation_Matching_Behavior__c from npsp__Data_Import_Settings__c];

        // TODO: Create or use an existing helper method
        npsp__DataImport__c diObj = new npsp__DataImport__c(
            npsp__Contact1_Firstname__c = cFirst,
            npsp__Contact1_Lastname__c = cLast,
            npsp__Contact2_Firstname__c = c2First,
            npsp__Contact2_Lastname__c = c2Last,
            npsp__Donation_Name__c = donationName,
            npsp__Payment_Method__c = 'Cash',
            npsp__Donation_Date__c = System.today(),
            npsp__Donation_Amount__c = donationAmount,
            npsp__Donation_Stage__c = openStage,
            Notification_Recipient_Name__c = recipientName,
            Donation_Honoree_Name__c = tributeName
        );
        insert diObj;
        
        GiftEntryFormController.runGiftProcess(diObj.Id);
        
        List<Opportunity> oppList = [Select Id, npsp__Honoree_Name__c, npsp__Notification_Recipient_Name__c
            from Opportunity 
            where Name =: donationName
            and npsp__Honoree_Name__c =: tributeName
            and npsp__Notification_Recipient_Name__c =: recipientName
            and StageName =: openStage
        ];
    
        System.assertEquals(1, oppList.size());

        //Make the payment unpaid so we can update it
        List<npe01__OppPayment__c> paymentList = [Select Id from npe01__OppPayment__c 
            where npe01__Payment_Amount__c =: donationAmount];
        System.assertEquals(1, paymentList.size());
        // paymentList[0].npe01__Paid__c = false;
        // update paymentList;

        // Now make a change to the DataImport object, and check that the Donation and Payment were updated

        diObj.npsp__Payment_Method__c = 'Check';
        diObj.Notification_Recipient_Name__c = updateStringTest;
        diObj.npsp__Donation_Stage__c = openStage2;
        Decimal newAmt = 500;
        diObj.npsp__Donation_Amount__c = newAmt;

        update diObj;

        Test.startTest();
        GiftEntryFormController.runGiftProcess(diObj.Id);
        Test.stopTest();

        // Check the errors on diObj
        diObj = [Select npsp__Status__c,
            npsp__Contact1ImportStatus__c,
            npsp__FailureInformation__c,
            npsp__DonationImportStatus__c,
            npsp__PaymentImportStatus__c
            from npsp__DataImport__c 
            where Id =: diObj.Id];

        System.debug(diObj);

        //and npe01__Paid__c = true
        // The payment should be udpated
        paymentList = [Select Id from npe01__OppPayment__c 
            where npe01__Payment_Amount__c =: newAmt
            and npe01__Payment_Method__c =: 'Check'];
        System.assertEquals(1, paymentList.size());

        // Make sure this is still only 1 opportunity
        oppList = [Select Id from Opportunity];
        System.assertEquals(1, oppList.size());

        oppList = [Select Id, npsp__Honoree_Name__c, npsp__Notification_Recipient_Name__c,
            Amount, StageName
            from Opportunity 
            where Name =: donationName
            and npsp__Honoree_Name__c =: tributeName
            and npsp__Notification_Recipient_Name__c =: updateStringTest
        ];

        // TODO: Figure out why Amount and Stage aren't updating
        // and StageName =: openStage2
        // and npsp__Notification_Recipient_Name__c =: updateStringTest

        System.debug(oppList);

        System.assertEquals(1, oppList.size());

    }
    
    @isTest
    private static void runGiftProcess() {
        // TODO: Create or use an existing helper method
        npsp__DataImport__c diObj = new npsp__DataImport__c(
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
        insert diObj;

        // Test error handling
        Id oppId = GiftEntryFormController.getOpportunityIdFromImport(diObj.Id);
        System.assertEquals(null, oppId);

        GiftEntryFormController ge = new GiftEntryFormController();
        
        Test.startTest();
        GiftEntryFormController.runGiftProcess(diObj.Id);
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
    }

    @isTest
    private static void runGiftBatch() {
        // TODO: Create or use an existing helper method
        npsp__DataImportBatch__c diBatch = new npsp__DataImportBatch__c(Name = 'Gift Entry Batch');
        insert diBatch;

        insert new npsp__DataImport__c(npsp__NPSP_Data_Import_Batch__c = diBatch.Id,
            npsp__Contact1_Firstname__c = cFirst,
            npsp__Contact1_Lastname__c = cLast,
            npsp__Donation_Name__c = donationName,
            npsp__Payment_Method__c = 'Cash',
            npsp__Donation_Date__c = System.today(),
            npsp__Donation_Amount__c = donationAmount);
        
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
    
}