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
* @description Base Class for Gift Entry Components with Aura Enabled Methods
*/
public with sharing class GiftEntryFormController {

    public class GiftFormModel {
        @AuraEnabled public Id oppId {get;set;}
        @AuraEnabled public npsp__DataImport__c di {get;set;}
        @AuraEnabled public Opportunity opp {get;set;}
        @AuraEnabled public Account acct {get;set;}
        @AuraEnabled public Contact contact {get;set;}
        @AuraEnabled public List<npe01__OppPayment__c> payments {get;set;}
        @AuraEnabled public List<npsp__Allocation__c> allocs {get;set;}
        @AuraEnabled public List<npsp__Partial_Soft_Credit__c> partialCredits {get;set;}

        @AuraEnabled public List<Opportunity> matchedOpps {get;set;}
        @AuraEnabled public List<Account> matchedAccts {get;set;}
        @AuraEnabled public List<Contact> matchedContacts {get;set;}
        @AuraEnabled public List<npe01__OppPayment__c> matchedPayments {get;set;}

        @AuraEnabled public Map<String, Map<String,String>> objNameToApiToLabel {get;set;}

        @AuraEnabled Map<String, List<String>> picklistValues {get;set;}

        @AuraEnabled Map<String, Boolean> closedWonStageMap {get;set;}

        public GiftFormModel() {
            this.objNameToApiToLabel = getObjNameToApiToLabel();
            this.picklistValues = getPickListValues();
            this.closedWonStageMap = getClosedWonStageMap();
            this.di = new npsp__DataImport__c();
            this.matchedOpps = new List<Opportunity>();
            this.matchedContacts = new List<Contact>();
            this.matchedAccts = new List<Account>();
            this.matchedPayments = new List<npe01__OppPayment__c>();
            this.payments = new List<npe01__OppPayment__c>();
            this.partialCredits = new List<npsp__Partial_Soft_Credit__c>();
            this.allocs = new List<npsp__Allocation__c>();
        }

        public GiftFormModel(Id oppId) {
            this();
            this.oppId = oppId;
        }
    }

    /******************************************************************************************************
    * @description String helper property for getClosedWonStageMap() method.
    *******************************************************************************************************/
    private static Map<String, Boolean> closedWonStageMap = null;

    /******************************************************************************************************
    * @description Build a the Map that includes all closed/won Opportunity Stage
    * @return Map<String, Boolean> the Map that includes all closed/won Opportunity Stage
    *******************************************************************************************************/
    public static Map<String, Boolean> getClosedWonStageMap() {
        if(closedWonStageMap == null) {
            closedWonStageMap = new Map<String, Boolean>();
            List<OpportunityStage> closedWonStages = [SELECT Id, MasterLabel FROM OpportunityStage WHERE IsWon = true AND IsClosed = true AND isActive = true];
            if (closedWonStages != null && closedWonStages.size() > 0) {
                for (OpportunityStage stage : closedWonStages) {
                    closedWonStageMap.put(stage.MasterLabel, true);
                }
            }
        }

        return closedWonStageMap;
    }

    @AuraEnabled
    public static GiftFormModel initClass(Id oppId) {
        try {
            checkCRUDFLS();
        } catch(UTIL_CrudFLS.AccessException ex) {
            throw returnAuraException(ex.getMessage());
        }
        GiftFormModel giftModel = new GiftFormModel(oppId);
        giftModel = getDonationRecords(giftModel);
        return giftModel;
    }

    /**
     * @description This method checks CRUD/FLS on load of the gift entry form controller.
     * Not all CRUD/FLS violations may be caught by this method. Run-time CRUD/FLS checks on SOQL/DML operations
     * are used elsewhere that will prevent users from performing SOQL/DML if they do not have access.
     * For an example, @see getDonationRecords and @see saveDonationInformation
     * @throws Util_CrudFLS.AccessException if a user does not have the needed access to a field being checked
     */
    public static void checkCRUDFLS() {
        UTIL_CrudFLS.checkAccess(
                UTIL_CrudFLS.CRUD_OPERATION.MODIFY_CREATE,
                'npsp__Allocation__c',
                new List<String>{
                        'npsp__General_Accounting_Unit__c',
                        'npsp__Percent__c',
                        'npsp__Amount__c',
                        'npsp__Opportunity__c'
                }
        );

        UTIL_CrudFLS.checkAccess(
                UTIL_CrudFLS.CRUD_OPERATION.MODIFY_CREATE,
                'npe01__OppPayment__c',
                new List<String>{
                        'npe01__Payment_Amount__c',
                        'npe01__Scheduled_Date__c',
                        'npe01__Payment_Method__c',
                        'npe01__Check_Reference_Number__c',
                        'npe01__Paid__c',
                        'npe01__Payment_Date__c'
                }
        );

        UTIL_CrudFLS.checkAccess(
                UTIL_CrudFLS.CRUD_OPERATION.MODIFY_CREATE,
                'npsp__Partial_Soft_Credit__c',
                new List<String>{
                        'npsp__Contact__c',
                        'npsp__Amount__c',
                        'npsp__Role_Name__c',
                        'npsp__Opportunity__c'
                }
        );
        UTIL_CrudFLS.checkAccess(
                UTIL_CrudFLS.CRUD_OPERATION.MODIFY_CREATE,
                'npsp__DataImport__c',
                new List<String>{
                        'npsp__Account1Imported__c',
                        'npsp__Contact1Imported__c',
                        'npsp__Donation_Donor__c',
                        'npsp__Donation_Name__c',
                        'npsp__Donation_Amount__c',
                        'npsp__Donation_Stage__c',
                        'npsp__Payment_Method__c',
                        'npsp__Payment_Check_Reference_Number__c',
                        'npsp__Donation_Description__c'
                }
        );
        UTIL_CrudFLS.checkAccess(
                UTIL_CrudFLS.CRUD_OPERATION.MODIFY_CREATE,
                'Opportunity',
                new List<String>{
                        'CampaignId',
                        'npsp__Tribute_Type__c',
                        'npsp__Acknowledgment_Status__c',
                        'npsp__Honoree_Name__c',
                        'npsp__Honoree_Contact__c',
                        'npsp__Notification_Recipient_Name__c',
                        'npsp__Notification_Message__c',
                        'npsp__Matching_Gift_Employer__c',
                        'npsp__Matching_Gift_Account__c',
                        'npsp__Matching_Gift__c',
                        'npsp__Matching_Gift_Status__c'
                }
        );
    }

    /*******************************************************************************************************
    * @description Return a Map of Object Name to Map<String,String> of field names to labels
    * @return Map<String, Map<String,String>> which maps an object name to a map of fields
    */
    @AuraEnabled
    public static Map<String, Map<String,String>> getObjNameToApiToLabel() {
        Map<String, Map<String,String>> objLabelMap = new Map<String, Map<String,String>>();
        objLabelMap = new Map<String, Map<String,String>>();
        objLabelMap.put('Account', getFieldNameToLabelForObject('Account'));
        objLabelMap.put('Contact', getFieldNameToLabelForObject('Contact'));
        objLabelMap.put('Opportunity', getFieldNameToLabelForObject('Opportunity'));
        objLabelMap.put('Payment', getFieldNameToLabelForObject('npe01__OppPayment__c'));
        objLabelMap.put('PSC', getFieldNameToLabelForObject('npsp__Partial_Soft_Credit__c'));
        objLabelMap.put('Allocation', getFieldNameToLabelForObject('npsp__Allocation__c'));
        return objLabelMap;
    }

    /*******************************************************************************************************
    * @description Return a Map<String,String> of field names to labels for a given object
    * @param objName Name of object to return field map for
    * @return Map<String,String> of field names to labels for a given object
    */
    private static Map<String,String> getFieldNameToLabelForObject(String objName) {
        Map<String,String> fieldNameToLabel = new Map<String,String>();
        for(Schema.DescribeFieldResult df : hed.UTIL_Describe_API.getAllFieldsDescribe(objName).values()) {
            String fieldLabel = df.getLabel();
            fieldLabel = fieldLabel.replace(' ID', '');
            fieldNameToLabel.put(df.getLocalName(), fieldLabel);
        }
        return fieldNameToLabel;
    }

    /*******************************************************************************************************
    * @description Return the Opportunity (Donation) and associated objects for editing 
    * @param diObjId Id of DataImport object that created or matching this Opportunity
    * @return Id of the Opportunity
    */
    private static GiftFormModel getDonationRecords(GiftFormModel giftModel) {
        try {
            Id oppId = giftModel.oppId;
            if(oppId == null) {
                return giftModel;
            }

            String allOppFields = UTIL_Describe.getAllFieldsQueryStringFromObject('Opportunity');
            String allAccountFields = UTIL_Describe.getAllFieldsQueryStringFromObject('Account');
            String allContactFields = UTIL_Describe.getAllFieldsQueryStringFromObject('Contact');
            List<Opportunity> opps = 
                Database.query('SELECT '+ String.escapeSingleQuotes(allOppFields) +' FROM Opportunity WHERE Id = :oppId');

            if(!opps.isEmpty()) {
                giftModel.opp = opps[0];
            } else {
                return giftModel;
            }

            Opportunity opp = giftModel.opp;

            if(opp.AccountId != null) {
                Id aId = opp.AccountId;
                List<Account> accounts = 
                    Database.query('SELECT '+ String.escapeSingleQuotes(allAccountFields) +' FROM Account WHERE Id = :aId');
                if(!accounts.isEmpty()) {
                    giftModel.acct = accounts[0];
                }
            }

            if(opp.npsp__Primary_Contact__c != null) {
                Id cId = opp.npsp__Primary_Contact__c;
                List<Contact> contacts = 
                    Database.query('SELECT '+ String.escapeSingleQuotes(allContactFields) +' FROM Contact WHERE Id = :cId');
                if(!contacts.isEmpty()) {
                    giftModel.contact = contacts[0];
                }
            }

            // Now check for related objects
            if(opp.npe01__Number_of_Payments__c > 0) {
                UTIL_CrudFLS.checkRead('npe01__OppPayment__c',
                        new List<String>{
                                'Id',
                                'npe01__Payment_Amount__c',
                                'npe01__Scheduled_Date__c',
                                'npe01__Payment_Date__c',
                                'npe01__Payment_Method__c',
                                'npe01__Check_Reference_Number__c',
                                'npe01__Paid__c'
                        });
                List<npe01__OppPayment__c> payments = [
                        SELECT Id,
                                npe01__Payment_Amount__c,
                                npe01__Scheduled_Date__c,
                                npe01__Payment_Date__c,
                                npe01__Payment_Method__c,
                                npe01__Check_Reference_Number__c,
                                npe01__Paid__c
                        FROM npe01__OppPayment__c
                        WHERE npe01__Opportunity__c = :oppId
                ];
                if(!payments.isEmpty()) {
                    giftModel.payments = payments;
                }
            }

            UTIL_CrudFLS.checkRead('npsp__Allocation__c',
                    new List<String>{
                            'npsp__Amount__c',
                            'npsp__General_Accounting_Unit__c',
                            'npsp__Percent__c',
                            'npsp__Recurring_Donation__c',
                            'npsp__Opportunity__c'
                    });
            List<npsp__Allocation__c> allocations = [
                    SELECT Id,
                            npsp__Amount__c,
                            npsp__General_Accounting_Unit__c,
                            npsp__Percent__c,
                            npsp__Recurring_Donation__c,
                            npsp__Opportunity__c
                    FROM npsp__Allocation__c
                    WHERE npsp__Opportunity__c = :oppId
            ];
            if(!allocations.isEmpty()) {
                giftModel.allocs = allocations;
            }

            UTIL_CrudFLS.checkRead('npsp__Partial_Soft_Credit__c',
                    new List<String>{
                            'npsp__Amount__c',
                            'npsp__Contact__c',
                            'npsp__Contact_Name__c',
                            'npsp__Role_Name__c',
                            'npsp__Opportunity__c'
                    });
            List<npsp__Partial_Soft_Credit__c> partialCredits = [
                    SELECT Id,
                            npsp__Amount__c,
                            npsp__Contact__c,
                            npsp__Contact_Name__c,
                            npsp__Role_Name__c,
                            npsp__Opportunity__c
                    FROM npsp__Partial_Soft_Credit__c
                    WHERE npsp__Opportunity__c = :oppId
            ];
            if(!partialCredits.isEmpty()) {
                giftModel.partialCredits = partialCredits;
            }

            return giftModel;

        } catch(Exception e) {
            System.debug(e);
            return null;
        }
    }

    /*******************************************************************************************************
    * @description Add the objects in a giftModel to the database, passing back the new Ids
    * @param giftModel GiftFormModel which holds the information to be committed to the database
    * @return GiftFormModel with new Ids included
    */
    @TestVisible
    private static GiftFormModel saveDonationInformation(GiftFormModel giftModel) {
        Savepoint sp = Database.setSavepoint();
        // Upsert or Delete the provided Donor and Donation information
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
        try {
            // Insert or Update the provided Donation information
            if(giftModel.di != null) {
                saveResults.addAll(UTIL_CrudFLS.create(giftModel.di));
            } else {
                System.debug('No DataImport object was provided'); 
                return null;
            }

            // After saving, need to process
            runGiftProcess(giftModel.di.Id, false);

            Id oppId = getOpportunityIdFromImport(giftModel.di.Id);

            if(giftModel.allocs != null && !giftModel.allocs.isEmpty()){
                for(npsp__Allocation__c a : giftModel.allocs){
                    a.npsp__Opportunity__c = oppId;
                }
                saveResults.addAll(UTIL_CrudFLS.create(giftModel.allocs));
            }

            if(giftModel.payments != null && !giftModel.payments.isEmpty()) {
                for(npe01__OppPayment__c p : giftModel.payments) {
                    if(p.Id == null) {
                        p.npe01__Opportunity__c = oppId;
                    }
                }
                saveResults.addAll(UTIL_CrudFLS.create(giftModel.payments));
            }

            if(giftModel.partialCredits != null && !giftModel.partialCredits.isEmpty()){
                for(npsp__Partial_Soft_Credit__c c : giftModel.partialCredits){
                    if(c.Id == null){
                        c.npsp__Opportunity__c = oppId;
                    }
                }
                saveResults.addAll(UTIL_CrudFLS.create(giftModel.partialCredits));
            }

            giftModel.oppId = oppId;

            for(Database.SaveResult result : saveResults) {
                if(!result.isSuccess()) {
                    DmlException dmlException = new DmlException();
                    dmlException.setMessage(result.getErrors()[0].getMessage());
                    throw dmlException;
                }
            }

            return giftModel;

        } catch(Exception e) {
            Database.rollback(sp);
            throw e;
        }
    }

    /*******************************************************************************************************
    * @description Return a Map of string (picklist field name) to a list of strings (picklist values)
    * @return Map<String, List<String>> which maps a picklist field name to picklist values
    */
    @AuraEnabled
    public static Map<String, List<String>> getPickListValues() {
        Map<String, List<String>> picklistMap = 
            new Map<String, List<String>>();

        List<Schema.PicklistEntry> picklistValues = 
            npe01__OppPayment__c.npe01__Payment_Method__c.getDescribe().getPicklistValues();
        picklistMap.put('npsp__Payment_Method__c', returnPicklistValuesList(picklistValues));

        picklistValues = Opportunity.StageName.getDescribe().getPicklistValues();
        picklistMap.put('npsp__Donation_Stage__c', returnPicklistValuesList(picklistValues));
        
        picklistValues = Opportunity.npsp__Matching_Gift_Status__c.getDescribe().getPicklistValues();
        picklistMap.put('Donation_Matching_Gift_Status__c', returnPicklistValuesList(picklistValues));
        
        picklistValues = Opportunity.npsp__Acknowledgment_Status__c.getDescribe().getPicklistValues();
        picklistMap.put('Donation_Acknowledgment_Status__c', returnPicklistValuesList(picklistValues));
        
        picklistValues = Opportunity.npsp__Tribute_Type__c.getDescribe().getPicklistValues();
        picklistMap.put('Donation_Tribute_Type__c', returnPicklistValuesList(picklistValues));

        picklistValues = OpportunityContactRole.Role.getDescribe().getPicklistValues();
        picklistMap.put('npsp__Role_Name__c', returnSoftCreditRoleList(picklistValues));
        
        return picklistMap;
    }

    /*******************************************************************************************************
    * @description Return a list of picklist values for the soft credit role field
    * Uses NPSP custom settings to determine which opportunity contact roles should be included
    * @param ple List<Schema.PicklistEntry> of picklist entries for the field
    * @return List<String> with picklist values filtered for soft credit roles
    */
    private static List<String> returnSoftCreditRoleList(List<Schema.PicklistEntry> ple) {
        Set<String> softCreditRoles = new Set<String>();
        String softCreditRoleString = 
            npsp.UTIL_CustomSettings_API.getHouseholdsSettings().npo02__Soft_Credit_Roles__c;
        if (softCreditRoleString != null) {
            softCreditRoles = new set<String>(softCreditRoleString.split(';'));
        }

        List<Schema.PicklistEntry> pleRoles = new List<Schema.PicklistEntry>();
        for (Schema.PicklistEntry pe : ple) {
            if (pe.getValue() != npsp.UTIL_CustomSettings_API.getContactsSettings().npe01__Opportunity_Contact_Role_Default_role__c &&
                (softCreditRoles.contains(pe.getValue()) || softCreditRoles.contains(pe.getLabel()))) {
                pleRoles.add(pe);
            }
        }
        return returnPicklistValuesList(pleRoles);
    }
    
    /*******************************************************************************************************
    * @description Return a list of picklist values for a given field
    * @param ple List<Schema.PicklistEntry> of picklist entries for the field
    * @return List<String> with all picklist values for the provided field
    */
    private static List<String> returnPicklistValuesList(List<Schema.PicklistEntry> ple) {
        List<String> pickListValuesList = new List<String>();
        PicklistOptionWrapper plWrapper;
        String plLabel;
        String plValue;
        String optionJson;
        for(Schema.PicklistEntry pickListVal : ple) {
            plLabel = pickListVal.getLabel();
            plValue = pickListVal.getValue();
            plWrapper = new PicklistOptionWrapper(plLabel, plValue);
            // Convert to JSON for easier parsing in Javascript
            optionJson = JSON.serialize(plWrapper);
            pickListValuesList.add(optionJson);
        }
        return pickListValuesList;
    }

    /*******************************************************************************************************
    * @description Return the imported Opportunity (Donation) from a DataImport process
    * @param diObjId Id of DataImport object that created or matching this Opportunity
    * @return Id of the Opportunity
    */
    @AuraEnabled
    public static String getOpportunityIdFromImport(Id diObjId) {
        try {
            UTIL_CrudFLS.checkRead(
                    'npsp__DataImport__c',
                    new List<String>{
                            'npsp__DonationImported__c',
                            'npsp__FailureInformation__c'
                    }
            );
            npsp__DataImport__c di = [
                    SELECT npsp__DonationImported__c,
                            npsp__FailureInformation__c
                    FROM npsp__DataImport__c
                    WHERE Id = :diObjId
            ];
            if(di.npsp__FailureInformation__c != null) {
                throw returnAuraException(di.npsp__FailureInformation__c);
            }
            return di.npsp__DonationImported__c;
        } catch(Exception e) {
            throw returnAuraException(e.getMessage());
        }
    }

    private static AuraHandledException returnAuraException(String errorMsg) {
        AuraHandledException ex = new AuraHandledException(errorMsg);
        ex.setMessage(errorMsg);
        return ex;
    }

    /*******************************************************************************************************
    * @description Set DataImport Settings that are important to Gift Entry matching
    * @return npsp__Data_Import_Settings__c diSettings object used to process gifts
    */
    private static npsp__Data_Import_Settings__c getGiftEntrySettings() {
        npsp__Data_Import_Settings__c diSettings = npsp__Data_Import_Settings__c.getOrgDefaults();
        diSettings.npsp__Donation_Matching_Behavior__c = npsp.BDI_DataImport_API.BestMatchOrCreate;
        diSettings.npsp__Donation_Matching_Rule__c = 'npsp__donation_amount__c;npsp__donation_date__c';
        diSettings.npsp__Donation_Date_Range__c = 5;
        diSettings.npsp__Contact_Matching_Rule__c = 'Firstname,Lastname';
        return diSettings;
    }

    /*******************************************************************************************************
    * @description Run the DataImport process on a single gift
    * @param diObjId Id of DataImport object to be processed
    * @param dryRunMode Boolean to set if the process should only return import results and not process
    * @return void
    */
    @AuraEnabled
    public static void runGiftProcess(Id diObjId, Boolean dryRunMode) {
        npsp__Data_Import_Settings__c diSettings = getGiftEntrySettings();

        String allDIFields = UTIL_Describe.getAllFieldsQueryStringFromObject('npsp__DataImport__c');
        List<npsp__DataImport__c> listDI = 
            Database.query('SELECT '+ String.escapeSingleQuotes(allDIFields) +' FROM npsp__DataImport__c WHERE Id = :diObjId');

        npsp.BDI_DataImport_API.processDataImportRecords(diSettings, listDI, dryRunMode);
    }

    // Not currently used, but useful for processing a large number of DataImport objects
    @AuraEnabled
    public static Id runGiftBatch(Id batchId) {
        if(batchId != null) {
            List<npsp.BDI_DataImport_API.ProcessDataImportBatchesResult> batchesResults =
                new List<npsp.BDI_DataImport_API.ProcessDataImportBatchesResult>();
            List<Id> listBatchId = new List<Id>{batchId};
            batchesResults = npsp.BDI_DataImport_API.processDataImportBatches(listBatchId);
            return batchesResults[0].apexJobId;
        } else {
            System.debug('No Data Import Settings were found');
            return null;
        }
    }

    /*******************************************************************************************************
    * @description Inserts the default Data Import Settings Object, if none exists
    * @return void
    */
    public static void insertGiftEntrySettings() {
        npsp__Data_Import_Settings__c diSettings = npsp__Data_Import_Settings__c.getOrgDefaults();
        if(diSettings.Id == null) {
            diSettings.npsp__Donation_Matching_Behavior__c = npsp.BDI_DataImport_API.ExactMatchOrCreate;
            diSettings.npsp__Donation_Matching_Rule__c = 'npsp__donation_date__c;npsp__donation_name__c';
            UTIL_CrudFLS.create(diSettings);
        }
    }


    /*******************************************************************************************************
    * @description Given a list of objects in JSON, process them in the right order
    * @param jsonObj A JSON object containing all objects related to a gift
    * @return Id of the Opportunity created
    */
    @AuraEnabled
    public static GiftFormModel processGiftModelString(String giftModelString) {
        try {
            if(giftModelString == null) {
                return new GiftFormModel(null);
            }

            // First, remove attributes passed from Lightning that can't be deserialized
            String sObjectTypeRegex = '"sobjectType":.+?(?=,),';
            // Now remove related lookup object attributes, we can't upsert with the Id AND the object
            // NOTE: If this stops working, it may be best to loop through the object and remove
            // any objects at a certain "depth"
            String relatedObjectRegex = ',"((?!",")(?!\\[)(?!attributes)(?!\\}).)+\\{((?!",")(?!\\}).)+\\}';

            giftModelString = giftModelString.replaceAll(sObjectTypeRegex, '');
            giftModelString = giftModelString.replaceAll(relatedObjectRegex, '');

            GiftFormModel giftModel = (GiftFormModel)JSON.deserialize(giftModelString, GiftFormModel.class);
            // TODO: Loop through and remove objects of a certain depth

            return giftModel;

        } catch(Exception e) {
            throw returnAuraException(e.getMessage());
        }
    }

    @AuraEnabled
    public static GiftFormModel saveGift(String giftModelString) {
        GiftFormModel giftModel = processGiftModelString(giftModelString);
        giftModel = saveDonationInformation(giftModel);
        return giftModel;
    }
    
    /*******************************************************************************************************
    * @description Holds the label and value for a picklist option in the Gift Entry Form
    * @attribute label String for the visible label
    * @attribute value String for the actual input
    */
    class PicklistOptionWrapper {
        String label {get; set;}
        String value {get; set;}

        PicklistOptionWrapper(String optionLabel, String optionValue) {
            this.label = optionLabel;
            this.value = optionValue;
        }
    }
}