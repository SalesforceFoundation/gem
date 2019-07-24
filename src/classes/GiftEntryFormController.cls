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

        @AuraEnabled public Map<String, Map<String,String>> objNameToApiToLabel {get;set;}
        @AuraEnabled public Map<String, String> bdiLabels;
        @AuraEnabled Map<String, List<String>> picklistValues {get;set;}
        @AuraEnabled Map<String, Boolean> closedWonStageMap {get;set;}
        @AuraEnabled Map<String, String> diToOppFieldMap {get;set;}

        public GiftFormModel() {
            this.objNameToApiToLabel = getObjNameToApiToLabel();
            this.picklistValues = getPickListValues();
            this.closedWonStageMap = getClosedWonStageMap();
            this.di = new npsp__DataImport__c();
            this.payments = new List<npe01__OppPayment__c>();
            this.partialCredits = new List<npsp__Partial_Soft_Credit__c>();
            this.allocs = new List<npsp__Allocation__c>();
            this.bdiLabels = batchDataImportLabels;
            this.diToOppFieldMap = getDataImportToOpportunityFieldMap();
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

    /*******************************************************************************************************
     * @description Returns A map of Opp field name to corresponding Data Import field name
     * @throws UTIL_CrudFLS.AccessException when the supplied sObject is not readable by the current user
     * @return Map<String, String> A map of Opp field name to corresponding Data Import field name
     */
    public static Map<String, String> getDataImportToOpportunityFieldMap() {
        Map<String, String> diMappings = SGE_GiftEntryService.getDataImportFieldMappings();
        diMappings.put('npsp__Account1Imported__c'.toLowerCase(), 'AccountId');
        diMappings.put('npsp__Contact1Imported__c'.toLowerCase(), 'npsp__Primary_Contact__c');
        return diMappings;
  	}

    @AuraEnabled
    public static GiftFormModel initClass(Id oppId) {

        try {
            validateForm();
        } catch(UTIL_CrudFLS.AccessException ex) {
            throw returnAuraException(ex.getMessage());
        } catch(FieldNotMappedException ex) {
            throw returnAuraException(ex.getMessage());
        }
        GiftFormModel giftModel = new GiftFormModel(oppId);
        giftModel = getDonationRecords(giftModel);
        return giftModel;
    }

    public static void validateMappings(List<String> customOppFields) {
        List<String> diFields = npsp.BDI_DataImportService.listStrDataImportFields;
        // key - di field
        // valie - opp field
        Map<String, String> diToOppFieldMap = npsp.BDI_DataImportService.mapFieldsForDIObject('Opportunity', 'Opportunity', diFields);
        List<String> mappedOppFields = diToOppFieldMap.values();
        // ensure field exists inside fieldMappings
        for(String oppField : customOppFields) {
            if(!mappedOppFields.contains(oppField)) {
                throw new FieldNotMappedException(Label.Error_No_Data_Import_Mapping + ': ' + oppField);
            }
        }
    }

    public static void validateForm() {
        List<String> opportunityFields = getFieldsFromCustomizableLayout();
        validateMappings(opportunityFields);
        checkCRUDFLS(opportunityFields);
    }

    /**
     * @description This method checks CRUD/FLS on load of the gift entry form controller.
     * Not all CRUD/FLS violations may be caught by this method. Run-time CRUD/FLS checks on SOQL/DML operations
     * are used elsewhere that will prevent users from performing SOQL/DML if they do not have access.
     * For an example, @see getDonationRecords and @see saveDonationInformation
     * @param customFields Custom opportunity fields to check, passed in by validateForm
     * @throws Util_CrudFLS.AccessException if a user does not have the needed access to a field being checked
     */
    public static void checkCRUDFLS(List<String> customFields) {
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
                        'npe01__Paid__c',
                        'npe01__Payment_Date__c',
                        'npe01__Opportunity__c'
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
                        'npsp__Payment_Method__c'
                }
        );
        List<String> opportunityFields = new List<String>();
        opportunityFields.addAll(customFields);
        opportunityFields.addAll(new List<String>{
                'Amount',
                'CampaignId',
                'CloseDate',
                'Description',
                'Name',
                'StageName'
        });
        UTIL_CrudFLS.checkAccess(
                UTIL_CrudFLS.CRUD_OPERATION.MODIFY_CREATE,
                'Opportunity',
                opportunityFields
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
            // Data Import uses the Record Type name instead of ID, so we need to set that before processing
            allOppFields += ', RecordType.Name';
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
            String allPaymentFields = UTIL_Describe.getAllFieldsQueryStringFromObject('npe01__OppPayment__c');
            if(opp.npe01__Number_of_Payments__c > 0) {
                // TODO: Need to include fields that are loaded dynamically
                // Could try to leverage DynamicFieldDisplayController.getCustomMetadataRecord
                // allPaymentFields.split(',');
                List<String> paymentFields = new List<String>{
                    'Id',
                    'npe01__Payment_Amount__c',
                    'npe01__Scheduled_Date__c',
                    'npe01__Payment_Date__c',
                    'npe01__Payment_Method__c',
                    'npe01__Check_Reference_Number__c',
                    'npe01__Written_Off__c',
                    'npe01__Paid__c'
                };
                UTIL_CrudFLS.checkRead('npe01__OppPayment__c',
                        paymentFields);

                List<npe01__OppPayment__c> payments =
                    Database.query('SELECT '+ String.escapeSingleQuotes(allPaymentFields)
                        + ' FROM npe01__OppPayment__c WHERE npe01__Opportunity__c = :oppId ' 
                        + ' ORDER BY npe01__Scheduled_Date__c asc, npe01__Payment_Date__c asc');
                if(!payments.isEmpty()) {
                    giftModel.payments = payments;
                }
            }

            UTIL_CrudFLS.checkRead('npsp__Allocation__c',
                    new List<String>{
                            'npsp__Amount__c',
                            'npsp__General_Accounting_Unit__c',
                            'npsp__Percent__c',
                            'npsp__Opportunity__c'
                    });
            List<npsp__Allocation__c> allocations = [
                    SELECT Id,
                            npsp__Amount__c,
                            npsp__General_Accounting_Unit__c,
                            npsp__General_Accounting_Unit__r.Name,
                            npsp__Percent__c,
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
                            npsp__Contact__r.Name,
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
        List<Database.UpsertResult> saveResults = new List<Database.UpsertResult>();
        try {
            Boolean processDI = true;
            Boolean updateGift = false;
            // If the Opportunity is closed or has payments, the DataImport cannot be processed
            if((giftModel.opp.ForecastCategory != null && giftModel.opp.ForecastCategory == 'Closed') || 
                (giftModel.opp.npe01__Number_of_Payments__c != null && giftModel.opp.npe01__Number_of_Payments__c > 0)){
                    processDI = false;
            } else if(giftModel.oppId != null){
                // If the Opportunity can be updated, and it already exists, update via Data Import process
                updateGift = true;
            }

            if(!processDI){
                // If we can't process the DataImport, check for an existing one instead of creating a new one
                List<npsp__DataImport__c> dataImports = [SELECT Id, npsp__DonationImported__c 
                    FROM npsp__DataImport__c 
                    WHERE npsp__DonationImported__c = :giftModel.opp.Id
                    LIMIT 1];

                // TODO: Could add a comment on the DI record to show it was used to update?
                if(!dataImports.isEmpty()){
                    giftModel.di = dataImports[0];
                }
            }

            // Insert or Update the provided Donation information
            if(giftModel.di != null && giftModel.di.Id == null){
                UTIL_CrudFLS.checkUpsert(giftModel.di);
                saveResults.addAll(Database.upsert(new List<npsp__DataImport__c>{giftModel.di}));
            }

            if(processDI){
                runGiftProcess(giftModel.di.Id, false, updateGift);
            }

            Id oppId = giftModel.di.npsp__DonationImported__c != null ?
                giftModel.di.npsp__DonationImported__c : getOpportunityIdFromImport(giftModel.di.Id);
            
            if(oppId == null){
                throw returnAuraException('No Opportunity was created or matched');
            }

            if(giftModel.allocs != null && !giftModel.allocs.isEmpty()){
                for(npsp__Allocation__c a : giftModel.allocs){
                    a.npsp__Opportunity__c = oppId;
                }
                UTIL_CrudFLS.checkUpsert(giftModel.allocs);
                saveResults.addAll(Database.upsert(giftModel.allocs));
            }

            if(giftModel.payments != null && !giftModel.payments.isEmpty()) {
                for(npe01__OppPayment__c p : giftModel.payments) {
                    if(p.Id == null) {
                        p.npe01__Opportunity__c = oppId;
                    }
                }
                UTIL_CrudFLS.checkUpsert(giftModel.payments);
                saveResults.addAll(Database.upsert(giftModel.payments));
            }

            if(giftModel.partialCredits != null && !giftModel.partialCredits.isEmpty()){
                for(npsp__Partial_Soft_Credit__c c : giftModel.partialCredits){
                    if(c.Id == null){
                        c.npsp__Opportunity__c = oppId;
                    }
                }
                UTIL_CrudFLS.checkUpsert(giftModel.partialCredits);
                saveResults.addAll(Database.upsert(giftModel.partialCredits));
            }

            giftModel.oppId = oppId;

            for(Database.UpsertResult result : saveResults) {
                if(!result.isSuccess()) {
                    DmlException dmlException = new DmlException();
                    dmlException.setMessage(result.getErrors()[0].getMessage());
                    throw dmlException;
                }
            }

            return giftModel;

        } catch(Exception e) {
            Database.rollback(sp);
            throw returnAuraException(e.getMessage());
        }
    }

    /*******************************************************************************************************
    * @description Retrieves all open Opportunities, and Opportunities with unpaid Payments, for the 
    * selected Donor (Account or Contact)
    * @return JSON stringified Map<String, List<SObject>> of all openOpportunities for the given donor
    */
    @AuraEnabled
    public static String getOpenDonations(Id donorId, String donorType) {
        String relationshipField;
        if (donorType == 'Account1') {
            relationshipField = 'AccountId';
        } else if (donorType == 'Contact1') {
            relationshipField = 'npsp__Primary_Contact__c';
        }

        // Can be used to display unpaid payments on the donation matching modal
        String paymentSOQL = 'SELECT Id, ' +
                                'Name, ' +
                                'npe01__Scheduled_Date__c, ' +
                                'npe01__Opportunity__r.Name, ' +
                                'npe01__Opportunity__c, ' +
                                'npe01__Payment_Amount__c ' +
                                'FROM npe01__OppPayment__c ' +
                                'WHERE npe01__Opportunity__r.' + relationshipField + ' = :donorId ' +
                                'AND npe01__Paid__c = false ' +
                                'AND npe01__Written_Off__c = false';
        try {
            // CRUD / FLS of this operation already verified by checkCRUDFLS()
            List<npe01__OppPayment__c> unpaidPayments = Database.query(paymentSOQL);

            Set<Id> oppIdsWithUnpaidPayments = new Set<Id>();
            for (npe01__OppPayment__c payment : unpaidPayments) {
                oppIdsWithUnpaidPayments.add(payment.npe01__Opportunity__c);
            }

            // We want to include Open Opportunities, as well as Closed Opportunities with unpaid payments
            // CRUD / FLS of this operation already verified by checkCRUDFLS()
            String opportunitySOQL = 'SELECT Id, ' +
                                    'Name, ' +
                                    'StageName, ' +
                                    'CloseDate, ' +
                                    'Amount ' +
                                    'FROM Opportunity ' +
                                    'WHERE ' + relationshipField + ' = :donorId ' +
                                    'AND (IsClosed = false OR Id in :oppIdsWithUnpaidPayments) ' + 
                                    'ORDER BY CloseDate ASC ';

            List<Opportunity> openOpportunities = Database.query(opportunitySOQL);
            Map<Id, Opportunity> openOpportunitiesById = new Map<Id, Opportunity>(openOpportunities);

            Map<String, List<SObject>> response = new Map<String, List<SObject>>{
                'openOpportunities' => openOpportunitiesById.values(),
                'unpaidPayments' => null
            };
            return JSON.serialize(response);
        } catch (Exception ex){
            throw new AuraHandledException('ERROR: ' + ex.getMessage());
        }
    }

    /*******************************************************************************************************
    * @description Retrieves required schema information for the component.
    * @return Map of DataImport__c object and field name keys to their labels.
    */
    private static Map<String, String> batchDataImportLabels {
        get {
            if(batchDataImportLabels == null){
                batchDataImportLabels = new Map<String, String> {
                    'accountObject' => Schema.SObjectType.Account.getLabel(),
                    'accountLookup' => Schema.SObjectType.npsp__DataImport__c.fields.npsp__Account1Imported__c.getName(),
                    'batchIdField' => Schema.SObjectType.npsp__DataImport__c.fields.npsp__NPSP_Data_Import_Batch__c.getName(),
                    'contactLookup' => Schema.SObjectType.npsp__DataImport__c.fields.npsp__Contact1Imported__c.getName(),
                    'contactObject' => Schema.SObjectType.Contact.getLabel(),
                    'dataImportObject' => Schema.SObjectType.npsp__DataImport__c.getName(),
                    'donationDonor' => Schema.SObjectType.npsp__DataImport__c.fields.npsp__Donation_Donor__c.getName(),
                    'donationAmountField' => Schema.SObjectType.npsp__DataImport__c.fields.npsp__Donation_Amount__c.getName(),
                    'expectedCountField' => Schema.SObjectType.npsp__DataImportBatch__c.fields.npsp__Expected_Count_of_Gifts__c.getName(),
                    'expectedTotalField' => Schema.SObjectType.npsp__DataImportBatch__c.fields.npsp__Expected_Total_Batch_Amount__c.getName(),
                    'opportunityImportedLookupField' => Schema.SObjectType.npsp__DataImport__c.fields.npsp__DonationImported__c.getName(),
                    'opportunityImportedStatusField' => Schema.SObjectType.npsp__DataImport__c.fields.npsp__DonationImportStatus__c.getName(),
                    'opportunityAmount' => Schema.SObjectType.Opportunity.fields.Amount.getLabel(),
                    'opportunityObject' => Schema.SObjectType.Opportunity.getLabel(),
                    'opportunityName' => Schema.SObjectType.Opportunity.getLabel(),
                    'opportunityStage' => Schema.SObjectType.Opportunity.fields.StageName.getLabel(),
                    'paymentAmount' => Schema.SObjectType.npe01__OppPayment__c.fields.npe01__Payment_Amount__c.getLabel(),
                    'paymentObject' => Schema.SObjectType.npe01__OppPayment__c.getLabel(),
                    'paymentScheduledDate' => Schema.SObjectType.npe01__OppPayment__c.fields.npe01__Scheduled_Date__c.getLabel(),
                    'paymentImportedLookupField' => Schema.SObjectType.npsp__DataImport__c.fields.npsp__PaymentImported__c.getName(),
                    'paymentImportedStatusField' => Schema.SObjectType.npsp__DataImport__c.fields.npsp__PaymentImportStatus__c.getName(),
                    'requireTotalMatch' => Schema.SObjectType.npsp__DataImportBatch__c.fields.npsp__RequireTotalMatch__c.getName(),
                    'userSelectedNewOpp' => System.Label.npsp.bdiMatchedByUserNewOpp,
                    'userSelectedNewPayment' => System.Label.npsp.bdiMatchedApplyNewPayment,
                    'userSelectedMatch' => System.Label.npsp.bdiMatchedByUser
                };
            }
            return batchDataImportLabels;
        }
        set;
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
    private static npsp__Data_Import_Settings__c getGiftEntrySettings(Boolean updateGift) {
        npsp__Data_Import_Settings__c diSettings = npsp__Data_Import_Settings__c.getOrgDefaults();
        // If we are updating an existing gift, set the matching logic accordingly
        diSettings.npsp__Donation_Matching_Behavior__c = 
            updateGift ? npsp.BDI_DataImport_API.ExactMatchOrCreate : npsp.BDI_DataImport_API.DoNotMatch;
        return diSettings;
    }

    /*******************************************************************************************************
    * @description Run the DataImport process on a single gift
    * @param diObjId Id of DataImport object to be processed
    * @param dryRunMode Boolean to set if the process should only return import results and not process
    * @return void
    */
    @AuraEnabled
    public static void runGiftProcess(Id diObjId, Boolean dryRunMode, Boolean updateGift) {
        npsp__Data_Import_Settings__c diSettings = getGiftEntrySettings(updateGift);

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
            GiftFormModel giftModel = (GiftFormModel)JSON.deserialize(giftModelString, GiftFormModel.class);
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

    public static List<String> getFieldsFromCustomizableLayout() {
        SGE_GiftEntryService.Layout layout = SGE_GiftEntryService.readOpportunityLayout();
        return layout.getFieldNames();
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

    public class FieldNotMappedException extends Exception {}
}