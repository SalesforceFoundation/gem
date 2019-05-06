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

    public Map<String, String> hedaToNpspRelMatchMap = new Map<String, String>{
        'hed__Contact__c' => 'npe4__Contact__c',
        'hed__RelatedContact__c' => 'npe4__RelatedContact__c',
        'Related_Opportunity_Contact_Role__c' => 'npsp__Related_Opportunity_Contact_Role__c',
        'hed__Status__c' => 'npe4__Status__c'
    };

	public final String RELATED_OPPORTUNITY_CONTACT_ROLE_NONE = '--None--';
	public final String NPSP_RELATIONSHIP_API_NAME = 'npe4__Relationship__c';
	public final String NPSP_AFFILIATION_API_NAME = 'npe5__Affiliation__c';

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

	private void synchronizeRelatedDonorRecords(List<Opportunity> oppList){
		
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

        List<npe5__Affiliation__c> newNpspAffiliations = returnSyncedList(donorToHEDAAffiliations,
            donorToNpspAffiliations, NPSP_AFFILIATION_API_NAME);

        // System.debug(newNpspRelationships); 
        // System.debug(hedAffiliations); 
        // System.debug(newNpspAffiliations); 

        if(!newNpspRelationships.isEmpty()){
            upsert newNpspRelationships;
        }

        if(!newNpspAffiliations.isEmpty()){
            upsert newNpspAffiliations;
        }
	}

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

    private List<SObject> returnSyncedList(Map<Id, List<SObject>> sourceMap, 
        Map<Id, List<SObject>> copyMap, String destObjectName){

            SObject[] toUpsert = (SObject[])Type.forName('List<'+destObjectName+'>').newInstance();

            for(Id donorId : sourceMap.keySet()){
                List<SObject> sourceList = sourceMap.get(donorId);
                for(SObject sourceRecord : sourceList){
                    Boolean foundMatch = false;
                    if(copyMap.containsKey(donorId)){
                        List<SObject> copyList = copyMap.get(donorId);
                        for(SObject copyRecord : copyList){
                            foundMatch = foundMatch || 
                                checkRecordMatch(sourceRecord, copyRecord, destObjectName);
                        }
                    }
                    if(!foundMatch){
                        toUpsert.add(returnCopy(sourceRecord, destObjectName));
                    }
                }
            }
            return toUpsert;
    }

    private SObject returnCopy(SObject srcRecord, String destObjectName){
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(destObjectName);
        SObject destRecord = targetType.newSObject();

        Map<String, String> fieldMap = (destObjectName == NPSP_RELATIONSHIP_API_NAME) 
            ? hedaToNpspRelFieldMap : hedaToNpspAfflFieldMap;

        for(String srcFieldName : fieldMap.keySet()){
            String destFieldName = fieldMap.get(srcFieldName);
            destRecord.put(destFieldName, srcRecord.get(srcFieldName));
        }
        return destRecord;
    }

    private Boolean checkRecordMatch(SObject srcRecord, SObject copyRecord, String destObjectName){
        Map<String, String> fieldMatchMap = (destObjectName == NPSP_RELATIONSHIP_API_NAME) 
            ? hedaToNpspRelMatchMap : hedaToNpspAfflMatchMap;

        // TODO: Also check if other fields are out of sync and update them instead of creating
        // a new record
        
        // Map<String, String> fieldMap = (destObjectName == NPSP_RELATIONSHIP_API_NAME) 
        //     ? hedaToNpspRelFieldMap : hedaToNpspAfflFieldMap;

        Boolean recordsMatch = true;
        for(String srcFieldName : fieldMatchMap.keySet()){
            String destFieldName = fieldMatchMap.get(srcFieldName);
            if(srcRecord.get(srcFieldName) != copyRecord.get(destFieldName)){
                recordsMatch = false;
                break;
            }
        }
        return recordsMatch;
    }
	
}