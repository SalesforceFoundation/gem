/*
    Copyright (c) 2018 Salesforce.org
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
public class GiftEntryFormController {

	public Boolean hasPerm {get;set;} // Permission check
    public GiftEntryFormController(){
        hasPerm = Schema.sObjectType.npsp__DataImport__c.isCreateable();
    }

    /*******************************************************************************************************
    * @description Return a Map of string (picklist field name) to a list of strings (picklist values)
    * @return Map<String, List<String>> which maps a picklist field name to picklist values
    */
    @AuraEnabled
    public static Map<String, List<String>> getPickListValues(){
        // TODO: Pass this an array of object.picklist fields to return
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();

        Schema.DescribeFieldResult fieldResult =  
            npe01__OppPayment__c.npe01__Payment_Method__c.getDescribe();
        picklistMap.put('npe01__Payment_Method__c', returnPicklistValuesList(fieldResult));
        fieldResult = Opportunity.StageName.getDescribe();
        picklistMap.put('StageName', returnPicklistValuesList(fieldResult));
        fieldResult = Opportunity.npsp__Matching_Gift_Status__c.getDescribe();
        picklistMap.put('npsp__Matching_Gift_Status__c', returnPicklistValuesList(fieldResult));

        return picklistMap;
    }
    
    /*******************************************************************************************************
    * @description Return a list of picklist values for a given field
    * @param fieldResult DescribeFieldResult of picklist field
    * @return List<String> with all picklist values for the provided field
    */
    private static List<String> returnPicklistValuesList(Schema.DescribeFieldResult fieldResult){
        List<String> pickListValuesList = new List<String>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }

    /*******************************************************************************************************
    * @description Return the imported Opportunity (Donation) from a DataImport process
    * @param diObjId Id of DataImport object that created or matching this Opportunity
    * @return Id of the Opportunity
    */
    @AuraEnabled
    public static Id getOpportunityIdFromImport(Id diObjId){
        try {
            npsp__DataImport__c di = [SELECT npsp__DonationImported__c 
                FROM npsp__DataImport__c
                WHERE Id =: diObjId];
            return di.npsp__DonationImported__c;
        } catch(Exception e){
            System.debug(e);
            return null;
        }
    }

    /*******************************************************************************************************
    * @description Set DataImport Settings that are important to Gift Entry matching
    * @return npsp__Data_Import_Settings__c diSettings object used to process gifts
    */
    private static npsp__Data_Import_Settings__c getGiftEntrySettings(){
        npsp__Data_Import_Settings__c diSettings = npsp__Data_Import_Settings__c.getOrgDefaults();
        diSettings.npsp__Donation_Matching_Behavior__c = npsp.BDI_DataImport_API.ExactMatchOrCreate;
        diSettings.npsp__Donation_Matching_Rule__c = 'npsp__donation_date__c;npsp__donation_name__c';
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
    public static void runGiftProcess(Id diObjId, Boolean dryRunMode){
        npsp__Data_Import_Settings__c diSettings = getGiftEntrySettings();

        String allDIFields = UTIL_Describe.getAllFieldsQueryStringFromObject('npsp__DataImport__c');
        List<npsp__DataImport__c> listDI = 
            Database.query('SELECT '+ allDIFields +' FROM npsp__DataImport__c WHERE Id = :diObjId');

        // System.debug(diSettings);
        // System.debug(diObjId);
        // System.debug(listDI); 

        npsp.BDI_DataImport_API.processDataImportRecords(diSettings, listDI, dryRunMode);
    }

    // Not currently used, but useful for processing a large number of DataImport objects
    @AuraEnabled
    public static Id runGiftBatch(Id batchId){
        if(batchId != null){
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
        List<npsp__Data_Import_Settings__c> diSettings = [select ID from npsp__Data_Import_Settings__c];
        if(diSettings.size() == 0) {
            diSettings.add(
                new npsp__Data_Import_Settings__c(
                    npsp__Donation_Matching_Behavior__c = npsp.BDI_DataImport_API.ExactMatchOrCreate,
                    npsp__Donation_Matching_Rule__c = 'npsp__donation_date__c;npsp__donation_name__c'
                )
            );
            insert diSettings;
        }
    }

}