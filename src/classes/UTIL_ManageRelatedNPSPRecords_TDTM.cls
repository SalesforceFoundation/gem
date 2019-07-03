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
* @date 2019
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description This class is used to sync donor Relationship and Affiliations records from EDA to NPSP.
**/
public class UTIL_ManageRelatedNPSPRecords_TDTM {

    private final static String gemRelatedOCRField = UTIL_Namespace.StrTokenNSPrefix('Related_Opportunity_Contact_Role__c');

    public static Map<String, String> EDAToNPSPRelFieldMap = new Map<String, String>{
        'hed__Contact__c' => 'npe4__Contact__c',
        'hed__Description__c' => 'npe4__Description__c',
        'hed__RelatedContact__c' => 'npe4__RelatedContact__c',
        gemRelatedOCRField => 'npsp__Related_Opportunity_Contact_Role__c',
        'hed__Status__c' => 'npe4__Status__c',
        'hed__Type__c' => 'npe4__Type__c'
    };

    public static Map<String, String> EDAToNPSPRelMatchMap = new Map<String, String>{
        'hed__Contact__c' => 'npe4__Contact__c',
        'hed__RelatedContact__c' => 'npe4__RelatedContact__c',
        gemRelatedOCRField => 'npsp__Related_Opportunity_Contact_Role__c'
    };

    public static Map<String, String> EDAToNPSPAfflFieldMap = new Map<String, String>{
        'hed__Contact__c' => 'npe5__Contact__c',
        'hed__Description__c' => 'npe5__Description__c',
        'hed__EndDate__c' => 'npe5__EndDate__c',
        'hed__Account__c' => 'npe5__Organization__c',
        'hed__Primary__c' => 'npe5__Primary__c',
        gemRelatedOCRField => 'npsp__Related_Opportunity_Contact_Role__c',
        'hed__Role__c' => 'npe5__Role__c',
        'hed__StartDate__c' => 'npe5__StartDate__c',
        'hed__Status__c' => 'npe5__Status__c'
    };

    public static Map<String, String> EDAToNPSPAfflMatchMap = new Map<String, String>{
        'hed__Contact__c' => 'npe5__Contact__c',
        'hed__Account__c' => 'npe5__Organization__c',
        gemRelatedOCRField => 'npsp__Related_Opportunity_Contact_Role__c'
    };

    public static final String RELATED_OPPORTUNITY_CONTACT_ROLE_NONE = '--None--';
    public static final String NPSP_RELATIONSHIP_API_NAME = 'npe4__Relationship__c';
    public static final String NPSP_AFFILIATION_API_NAME = 'npe5__Affiliation__c';

    /*******************************************************************************************************
    * @description Take a list of EDA Affiliations and sync them their NPSP versions
    * @param EDAffiliations a list of EDA Affiliations being inserted, updated, or deleted
    * @return void
    ********************************************************************************************************/
    public static void synchronizeAffiliationRecords(List<hed__Affiliation__c> EDAffiliations){

        Set<Id> donorAccountIds = new Set<Id>();
		for(hed__Affiliation__c affl : EDAffiliations){
		    donorAccountIds.add(affl.hed__Account__c);
		}

        // Query all EDA Affiliations to these Donors
        String allEDAAfflFields = UTIL_Describe.getAllFieldsQueryStringFromObject('hed__Affiliation__c');
        EDAffiliations = 
            Database.query('SELECT '
				+ String.escapeSingleQuotes(allEDAAfflFields) 
				+' FROM hed__Affiliation__c '
				+ 'WHERE Related_Opportunity_Contact_Role__c != null '
                + 'AND Related_Opportunity_Contact_Role__c != :RELATED_OPPORTUNITY_CONTACT_ROLE_NONE '
				+ 'AND hed__Account__c in :donorAccountIds ');

        // Query existing NPSP Affiliations to these Donors
    	String allNPSPAfflFields = UTIL_Describe.getAllFieldsQueryStringFromObject('npe5__Affiliation__c');
        List<npe5__Affiliation__c> currentNPSPAffiliations = 
            Database.query('SELECT '
				+ String.escapeSingleQuotes(allNPSPAfflFields) 
				+' FROM npe5__Affiliation__c '
				+ 'WHERE npsp__Related_Opportunity_Contact_Role__c != null '
                + 'AND npsp__Related_Opportunity_Contact_Role__c != :RELATED_OPPORTUNITY_CONTACT_ROLE_NONE '
				+ 'AND npe5__Organization__c in :donorAccountIds ');

        //Organize records by Donor ID, which for Relationships is a Contact, for Affiliations an Account
        Map<Id, List<SObject>> donorToEDAAffiliations = convertListToMap( EDAffiliations, 'hed__Account__c' );
        Map<Id, List<SObject>> donorToNPSPAffiliations = convertListToMap( currentNPSPAffiliations, 'npe5__Organization__c' );

        // Compare the maps and make sure the NPSP copies match the EDA versions
        syncLists(donorToEDAAffiliations, donorToNPSPAffiliations, NPSP_AFFILIATION_API_NAME);
 
    }

	/*******************************************************************************************************
    * @description Take a list of EDA Relationships and sync them their NPSP versions
    * @param EDARelationships a list of EDA Relationships being inserted, updated, or deleted
    * @return void
    ********************************************************************************************************/
    public static void synchronizeRelationshipRecords(List<hed__Relationship__c> EDARelationships){
		
        Set<Id> donorContactIds = new Set<Id>();
		for(hed__Relationship__c rel : EDARelationships){
		    donorContactIds.add(rel.hed__Contact__c);
		}

        // Query all EDA Relationships to these Donors
        String allEDARelFields = UTIL_Describe.getAllFieldsQueryStringFromObject('hed__Relationship__c');
        EDARelationships = 
            Database.query('SELECT '
				+ String.escapeSingleQuotes(allEDARelFields) 
				+' FROM hed__Relationship__c '
				+ 'WHERE Related_Opportunity_Contact_Role__c != null '
				+ 'AND Related_Opportunity_Contact_Role__c != :RELATED_OPPORTUNITY_CONTACT_ROLE_NONE '
				+ 'AND hed__Contact__c in :donorContactIds ');

		// Query existing NPSP Relationships to these Donors
		String allNPSPRelFields = UTIL_Describe.getAllFieldsQueryStringFromObject('npe4__Relationship__c');
        List<npe4__Relationship__c> currentNPSPRelationships = 
            Database.query('SELECT '
				+ String.escapeSingleQuotes(allNPSPRelFields) 
				+' FROM npe4__Relationship__c '
				+ 'WHERE npsp__Related_Opportunity_Contact_Role__c != null '
                + 'AND npsp__Related_Opportunity_Contact_Role__c != :RELATED_OPPORTUNITY_CONTACT_ROLE_NONE '
				+ 'AND npe4__Contact__c in :donorContactIds ');

        //Organize records by Donor ID, which for Relationships is a Contact, for Affiliations an Account
        Map<Id, List<SObject>> donorToEDARelationships = convertListToMap( EDARelationships, 'hed__RelatedContact__c' );
        Map<Id, List<SObject>> donorToNPSPRelationships = convertListToMap( currentNPSPRelationships, 'npe4__RelatedContact__c' );


        // Compare the maps and make sure the NPSP copies match the EDA versions
        syncLists(donorToEDARelationships, donorToNPSPRelationships, NPSP_RELATIONSHIP_API_NAME);

	}

    /*******************************************************************************************************
    * @description Take a list of records and create a map using the provided Id field as the key values
    * @param objectList a list of records
    * @param donorIdField the field name that should become the map key
    * @return Map<Id, List<SObject>> a map of Donor Id to a list of its related records
    ********************************************************************************************************/
    private static Map<Id, List<SObject>> convertListToMap(List<SObject> objectList, String donorIdField){
        Map<Id, List<SObject>> donorMap = new Map<Id, List<SObject>>();
        for(SObject rel : objectList){
            Id donorId = (Id)rel.get(donorIdField);
            if(!donorMap.containsKey(donorId)){
                donorMap.put(donorId, new List<SObject>());
            }
            donorMap.get(donorId).add(rel);
        }
        return donorMap;
    }

    /*******************************************************************************************************
    * @description Take a map of Donor Id to EDA Relationship or Affiliation records and make sure the 
    * NPSP copies match the EDA versions
    * @param sourceMap map of Donor Id to the EDA versions of the records
    * @param copyMap map of Donor Id to existing NPSP versions of the records
    * @param destObjectName the API name of the NPSP version of the copies
    * @return void
    ********************************************************************************************************/
    private static void syncLists(Map<Id, List<SObject>> sourceMap, 
        Map<Id, List<SObject>> copyMap, String destObjectName){

            List<SObject> toDelete = new List<SObject>();

            Map<String, String> fullFieldMap;
            Map<String, String> matchFieldMap;

            if(destObjectName == NPSP_RELATIONSHIP_API_NAME){
                fullFieldMap = EDAToNPSPRelFieldMap;
                matchFieldMap = EDAToNPSPRelMatchMap;
            } else {
                fullFieldMap = EDAToNPSPAfflFieldMap;
                matchFieldMap = EDAToNPSPAfflMatchMap;
            }
            
            SObject[] toUpsert = (SObject[])Type.forName('List<'+destObjectName+'>').newInstance();
            SObject destRecordTemplate = Schema.getGlobalDescribe().get(destObjectName).newSObject();

            Set<Id> donorIdsFromSourceAndCopies = new Set<Id>();
            donorIdsFromSourceAndCopies.addAll(sourceMap.keySet());
            donorIdsFromSourceAndCopies.addAll(copyMap.keySet());

            for(Id donorId : donorIdsFromSourceAndCopies){
                List<SObject> sourceList = new List<SObject>();
                if(sourceMap.containsKey(donorId)){
                    sourceList = sourceMap.get(donorId);
                }

                List<SObject> copyList = new List<SObject>();
                if(copyMap.containsKey(donorId)){
                    copyList = copyMap.get(donorId);
                }
                
                // Each source record needs to find an existing match, or create a copy of itself
                for(SObject sourceRecord : sourceList){

                    SObject destRecord = destRecordTemplate.clone(false, true, false, false);
                    Boolean foundMatch = false;

                    // This list only exists if a sync has already occurred on these records
                    for(Integer i = 0; i < copyList.size(); i++){
                        SObject copyRecord = copyList[i];

                        if(returnFieldsMatch(sourceRecord, copyRecord, matchFieldMap)){
                            foundMatch = true;
                            // The records match, but does the copy need an update?
                            if(!returnFieldsMatch(sourceRecord, copyRecord, fullFieldMap)){
                                toUpsert.add(returnCopy(sourceRecord, copyRecord));
                            }
                            // Remove this copy as a candidate for matching
                            copyList.remove(i);
                            break;
                        }
                    }

                    if(!foundMatch){
                        // No match was found, the NPSP record needs to be created as a copy
                        toUpsert.add(returnCopy(sourceRecord, destRecord));
                    }
                }

                // If there are items in the copyMap that haven't been matched, delete them
                if(!copyList.isEmpty()){
                    toDelete.addAll(copyList);
                }
            }

            // Need to handle the case where the sourceMap is empty, meaning copyMap should be deleted
            if(sourceMap.isEmpty() && !copyMap.isEmpty()){
                for(Id donorId : copyMap.keySet()){
                    List<SObject> copyList = copyMap.get(donorId);
                    toDelete.addAll(copyList);
                }
            }

            if(!toUpsert.isEmpty()){
                upsert toUpsert;
            }

            if(!toDelete.isEmpty()){
                delete toDelete;
            }

    }

    /*******************************************************************************************************
    * @description Take an EDA version of Relationship or Affiliation and check if it matches with a NPSP version
    * @param srcRecord the EDA version of the record
    * @param copyRecord the potential NPSP version of the record
    * @param fieldMap A map of String to String of fields to compare between objects
    * @return Boolean true if all field values match, false otherwise
    ********************************************************************************************************/
    private static Boolean returnFieldsMatch(SObject srcRecord, SObject copyRecord, Map<String, String> fieldMap){
        Boolean recordsMatch = true;
        for(String srcFieldName : fieldMap.keySet()){
            String destFieldName = fieldMap.get(srcFieldName);
            if(srcRecord.get(srcFieldName) != copyRecord.get(destFieldName)){
                recordsMatch = false;
                break;
            }
        }
        return recordsMatch;
    }

    /*******************************************************************************************************
    * @description Take an EDA version of Relationship or Affiliation and copy its values into the provided 
    * NPSP version
    * @param srcRecord the EDA version of the record to copy from
    * @param destRecord the NPSP version of the record to copy to
    * @return SObject the NPSP version of the record with all fields copied over
    ********************************************************************************************************/
    private static SObject returnCopy(SObject srcRecord, SObject destRecord){
        String destObjName = destRecord.getSObjectType().getDescribe().getLocalName();

        Map<String, String> fieldMap = (destObjName == NPSP_RELATIONSHIP_API_NAME) 
            ? EDAToNPSPRelFieldMap : EDAToNPSPAfflFieldMap;

        for(String srcFieldName : fieldMap.keySet()){
            String destFieldName = fieldMap.get(srcFieldName);

            // Avoids trying to edit Master-Detail fields
            if(srcRecord.get(srcFieldName) != destRecord.get(destFieldName)){
                destRecord.put(destFieldName, srcRecord.get(srcFieldName));
            }

        }

        return destRecord;
    }

    /*******************************************************************************************************
    * @description Take a List of List<SObject> and combine them into one List
    * @param triggerLists a List of List<SObject> from a trigger handler to combine
    * @return List<SObject> the combined trigger list
    ********************************************************************************************************/
    public static List<SObject> combineLists(List<List<SObject>> triggerLists){
        List<SObject> combinedList = new List<SObject>();

        for(List<SObject> triggerList : triggerLists){
            if(triggerList != null && !triggerList.isEmpty()){
                combinedList.addAll(triggerList);
            }
        }

        return combinedList;
    }

}