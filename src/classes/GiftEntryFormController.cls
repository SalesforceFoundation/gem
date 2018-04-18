/**
* @author Salesforce.org
* @date 2018
* @group Settings
* @group-content ../../ApexDocContent/Settings.htm
* @description Base Class for Gift Entry Components with Aura Enabled Methods
*/
public class GiftEntryFormController {
	public Boolean hasPerm {get;set;} // Permission check

    public GiftEntryFormController(){
        hasPerm = Schema.sObjectType.npsp__DataImport__c.isCreateable();
    }

    @AuraEnabled
    public static void runGiftProcess(Id diObjId){
        npsp__Data_Import_Settings__c diSettings = npsp__Data_Import_Settings__c.getInstance();

        // TODO: Query all fields from this object instead of a subset
        List<npsp__DataImport__c> listDI = [SELECT Id,
                npsp__Contact1_Firstname__c,
                npsp__Contact1_Lastname__c,
                npsp__Donation_Name__c,
                npsp__Payment_Method__c,
                npsp__Donation_Date__c,
                npsp__Donation_Amount__c,
                npsp__NPSP_Data_Import_Batch__c
            FROM npsp__DataImport__c 
            WHERE Id =: diObjId];

        System.debug(diSettings);
        System.debug(diObjId);
        System.debug(listDI);

        npsp.BDI_DataImport_API.processDataImportRecords(diSettings, listDI, false);
    }

    // Useful for processing a large number of DataImport objects
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
    * @description Inserts the default Data Import Settings Object.
    * @return void
    */
    public static void insertGiftEntrySettings() {
        List<npsp__Data_Import_Settings__c> diSettings = [select ID from npsp__Data_Import_Settings__c];
        if(diSettings.size() == 0) {
            diSettings.add(
                new npsp__Data_Import_Settings__c()
            );
            insert diSettings;
        }
    }

}