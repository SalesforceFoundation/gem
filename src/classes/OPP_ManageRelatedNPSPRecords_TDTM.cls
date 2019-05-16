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
* @group TDTM
* @group-content ../../ApexDocContent/TDTM.htm
* @description This class is used to sync donor Relationship and Affiliations records from EDA to NPSP.
**/
global class OPP_ManageRelatedNPSPRecords_TDTM extends hed.TDTM_Runnable {

    public Map<String, String> hedaToNpspRelFieldMap = new Map<String, String>{
        'hed__Contact__c' => 'npe4__Contact__c',
        'hed__Description__c' => 'npe4__Description__c',
        'hed__RelatedContact__c' => 'npe4__RelatedContact__c',
        'Related_Opportunity_Contact_Role__c' => 'npsp__Related_Opportunity_Contact_Role__c',
        'hed__Status__c' => 'npe4__Status__c',
        'hed__Type__c' => 'npe4__Type__c'
    };

    public Map<String, String> hedaToNpspRelMatchMap = new Map<String, String>{
        'hed__Contact__c' => 'npe4__Contact__c',
        'hed__RelatedContact__c' => 'npe4__RelatedContact__c',
        'Related_Opportunity_Contact_Role__c' => 'npsp__Related_Opportunity_Contact_Role__c',
        'hed__Status__c' => 'npe4__Status__c'
    };

    public Map<String, String> hedaToNpspAfflFieldMap = new Map<String, String>{
        'hed__Contact__c' => 'npe5__Contact__c',
        'hed__Description__c' => 'npe5__Description__c',
        'hed__EndDate__c' => 'npe5__EndDate__c',
        'hed__Account__c' => 'npe5__Organization__c',
        'hed__Primary__c' => 'npe5__Primary__c',
        'Related_Opportunity_Contact_Role__c' => 'npsp__Related_Opportunity_Contact_Role__c',
        'hed__Role__c' => 'npe5__Role__c',
        'hed__StartDate__c' => 'npe5__StartDate__c',
        'hed__Status__c' => 'npe5__Status__c'
    };

    public Map<String, String> hedaToNpspAfflMatchMap = new Map<String, String>{
        'hed__Contact__c' => 'npe5__Contact__c',
        'hed__Account__c' => 'npe5__Organization__c',
        'Related_Opportunity_Contact_Role__c' => 'npsp__Related_Opportunity_Contact_Role__c',
        'hed__Status__c' => 'npe5__Status__c'
    };

	public final String RELATED_OPPORTUNITY_CONTACT_ROLE_NONE = '--None--';
	public final String NPSP_RELATIONSHIP_API_NAME = 'npe4__Relationship__c';
	public final String NPSP_AFFILIATION_API_NAME = 'npe5__Affiliation__c';
    private static List<SObject> toDelete = new List<SObject>();

	/*******************************************************************************************************
    * @description Trigger Handler on Opportunities that syncs donor Relationship and Affiliations records 
    * from EDA to NPSP 
    * @param listNew the list of Opportunities from trigger new
    * @param listOld the list of Opportunities from trigger old
    * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.)
    * @param objResult the describe for Opportunities
    * @return dmlWrapper always null
    ********************************************************************************************************/
    public override hed.TDTM_Runnable.DmlWrapper run(List<SObject> newlist, List<SObject> oldlist,
    		hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {

		// BEFORE INSERT
        if (triggerAction == hed.TDTM_Runnable.Action.BeforeInsert) {
            synchronizeRelatedDonorRecords(newlist);
        }

    	return null;

    }

	/*******************************************************************************************************
    * @description Take a list of Opportunities and sync Donor HEDA Relationships and Affiliations to their 
    * NPSP versions
    * @param objectList a list of opportunities being inserted
    * @return void
    ********************************************************************************************************/
    private void synchronizeRelatedDonorRecords(List<Opportunity> oppList){
		
        // Make sure this static list is cleared
        toDelete.clear();
        Set<Id> donorContactIds = new Set<Id>();
		Set<Id> donorAccountIds = new Set<Id>();
		for(Opportunity opp : oppList){
			if(opp.npsp__Primary_Contact__c != null){
				donorContactIds.add(opp.npsp__Primary_Contact__c);
			}
			if(opp.AccountId != null){
				donorAccountIds.add(opp.AccountId);
			}
		}

		// Query HEDA Relationships and Affiliations to this Donor
		String allHedaRelFields = UTIL_Describe.getAllFieldsQueryStringFromObject('hed__Relationship__c');
        List<hed__Relationship__c> hedRelationships = 
            Database.query('SELECT '
				+ String.escapeSingleQuotes(allHedaRelFields) 
				+' FROM hed__Relationship__c '
				+ 'WHERE Related_Opportunity_Contact_Role__c != null '
				+ 'AND Related_Opportunity_Contact_Role__c != :RELATED_OPPORTUNITY_CONTACT_ROLE_NONE '
				+ 'AND hed__Contact__c in :donorContactIds ');

		String allHedaAfflFields = UTIL_Describe.getAllFieldsQueryStringFromObject('hed__Affiliation__c');
        List<hed__Affiliation__c> hedAffiliations = 
            Database.query('SELECT '
				+ String.escapeSingleQuotes(allHedaAfflFields) 
				+' FROM hed__Affiliation__c '
				+ 'WHERE Related_Opportunity_Contact_Role__c != null '
                + 'AND Related_Opportunity_Contact_Role__c != :RELATED_OPPORTUNITY_CONTACT_ROLE_NONE '
				+ 'AND hed__Account__c in :donorAccountIds ');

		// Query existing NPSP versions of these records
		String allNpspRelFields = UTIL_Describe.getAllFieldsQueryStringFromObject('npe4__Relationship__c');
        List<npe4__Relationship__c> currentNpspRelationships = 
            Database.query('SELECT '
				+ String.escapeSingleQuotes(allNpspRelFields) 
				+' FROM npe4__Relationship__c '
				+ 'WHERE npsp__Related_Opportunity_Contact_Role__c != null '
                + 'AND npsp__Related_Opportunity_Contact_Role__c != :RELATED_OPPORTUNITY_CONTACT_ROLE_NONE '
				+ 'AND npe4__Contact__c in :donorContactIds ');

		String allNpspAfflFields = UTIL_Describe.getAllFieldsQueryStringFromObject('npe5__Affiliation__c');
        List<npe5__Affiliation__c> currentNpspAffiliations = 
            Database.query('SELECT '
				+ String.escapeSingleQuotes(allNpspAfflFields) 
				+' FROM npe5__Affiliation__c '
				+ 'WHERE npsp__Related_Opportunity_Contact_Role__c != null '
                + 'AND npsp__Related_Opportunity_Contact_Role__c != :RELATED_OPPORTUNITY_CONTACT_ROLE_NONE '
				+ 'AND npe5__Organization__c in :donorAccountIds ');

        Map<Id, List<SObject>> donorToHedaRelationships = convertListToMap( hedRelationships, 'hed__RelatedContact__c' );
        Map<Id, List<SObject>> donorToHedaAffiliations = convertListToMap( hedAffiliations, 'hed__Account__c' );
        Map<Id, List<SObject>> donorToNpspRelationships = convertListToMap( currentNpspRelationships, 'npe4__RelatedContact__c' );
        Map<Id, List<SObject>> donorToNpspAffiliations = convertListToMap( currentNpspAffiliations, 'npe5__Organization__c' );

        // Compare the lists and return any new, or updated, NPSP Relationships
        List<npe4__Relationship__c> newNpspRelationships = returnSyncedList(donorToHEDARelationships,
            donorToNPSPRelationships, NPSP_RELATIONSHIP_API_NAME);
        
        // Compare the lists and return any new, or updated, NPSP Affiliations
        List<npe5__Affiliation__c> newNpspAffiliations = returnSyncedList(donorToHEDAAffiliations,
            donorToNpspAffiliations, NPSP_AFFILIATION_API_NAME);

        if(!newNpspRelationships.isEmpty()){
            upsert newNpspRelationships;
        }

        if(!newNpspAffiliations.isEmpty()){
            upsert newNpspAffiliations;
        }

        if(!toDelete.isEmpty()){
            delete toDelete;
        }

	}

    /*******************************************************************************************************
    * @description Take a list of records and create a map using the provided Id field as the key values
    * @param objectList a list of records
    * @param donorIdField the field name that should become the map key
    * @return Map<Id, List<SObject>> a map of Donor Id to a list of its related records
    ********************************************************************************************************/
    private Map<Id, List<SObject>> convertListToMap(List<SObject> objectList, String donorIdField){
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
    * @description Take a map of Donor Id to HEDA Relationship or Affiliations records and return a list of 
    * synced Relationship or Affiliations NPSP records
    * @param sourceMap map of Donor Id to the HEDA versions of the records
    * @param copyMap map of Donor Id to existing NPSP versions of the records
    * @param destObjectName the API name of the NPSP version of the copies
    * @return List<SObject> synced NPSP versions of the records
    ********************************************************************************************************/
    private List<SObject> returnSyncedList(Map<Id, List<SObject>> sourceMap, 
        Map<Id, List<SObject>> copyMap, String destObjectName){

            Map<String, String> fullFieldMap;
            Map<String, String> matchFieldMap;

            if(destObjectName == NPSP_RELATIONSHIP_API_NAME){
                fullFieldMap = hedaToNpspRelFieldMap;
                matchFieldMap = hedaToNpspRelMatchMap;
            } else {
                fullFieldMap = hedaToNpspAfflFieldMap;
                matchFieldMap = hedaToNpspAfflMatchMap;
            }
            
            SObject[] toUpsert = (SObject[])Type.forName('List<'+destObjectName+'>').newInstance();
            SObject destRecordTemplate = Schema.getGlobalDescribe().get(destObjectName).newSObject();

            for(Id donorId : sourceMap.keySet()){
                List<SObject> sourceList = sourceMap.get(donorId);
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

            return toUpsert;
    }

    /*******************************************************************************************************
    * @description Take a HEDA version of Relationship or Affiliation and check if it matches with a NPSP version
    * @param srcRecord the HEDA version of the record
    * @param copyRecord the potential NPSP version of the record
    * @param fieldMap A map of String to String of fields to compare between objects
    * @return Boolean true if all field values match, false otherwise
    ********************************************************************************************************/
    private Boolean returnFieldsMatch(SObject srcRecord, SObject copyRecord, Map<String, String> fieldMap){
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
    * @description Take a HEDA version of Relationship or Affiliation and copy its values into the provided 
    * NPSP version
    * @param srcRecord the HEDA version of the record to copy from
    * @param destRecord the NPSP version of the record to copy to
    * @return SObject the NPSP version of the record with all fields copied over
    ********************************************************************************************************/
    private SObject returnCopy(SObject srcRecord, SObject destRecord){
        String destObjName = destRecord.getSObjectType().getDescribe().getLocalName();

        Map<String, String> fieldMap = (destObjName == NPSP_RELATIONSHIP_API_NAME) 
            ? hedaToNpspRelFieldMap : hedaToNpspAfflFieldMap;

        for(String srcFieldName : fieldMap.keySet()){
            String destFieldName = fieldMap.get(srcFieldName);

            // Avoids trying to edit Master-Detail fields
            if(srcRecord.get(srcFieldName) != destRecord.get(destFieldName)){
                destRecord.put(destFieldName, srcRecord.get(srcFieldName));
            }

        }

        return destRecord;
    }

}