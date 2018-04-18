@isTest
private class GiftEntryFormController_TEST {

    private static String cFirst = 'Testfirst';
    private static String cLast = 'Testlast';
    private static String donationName = 'Test Donation';
    private static Decimal donationAmount = 100;
    
    @testSetup static void setupGiftEntry() {
    	GiftEntryFormController.insertGiftEntrySettings();
    }
    
    @isTest
    private static void runGiftProcess() {
        // TODO: Create or use an existing helper method
        npsp__DataImport__c diObj = new npsp__DataImport__c(
            npsp__Contact1_Firstname__c = cFirst,
            npsp__Contact1_Lastname__c = cLast,
            npsp__Donation_Name__c = donationName,
            npsp__Payment_Method__c = 'Cash',
            npsp__Donation_Date__c = System.today(),
            npsp__Donation_Amount__c = donationAmount
        );
        insert diObj;

        GiftEntryFormController ge = new GiftEntryFormController();
        
        Test.startTest();
        GiftEntryFormController.runGiftProcess(diObj.Id);
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