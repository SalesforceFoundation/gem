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

	public final String RELATED_OPPORTUNITY_CONTACT_ROLE_NONE = '--None--';

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

		// Query EDA Relationships and Affiliations to this Donor
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

		// Check for existing NPSP versions of these records
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

        Map<Id, List<SObject>> donorToHEDARelationships = convertListToMap( hedRelationships, 'hed__RelatedContact__c' );
        Map<Id, List<SObject>> donorToHEDAAffiliations = convertListToMap( hedAffiliations, 'hed__Account__c' );
        Map<Id, List<SObject>> donorToNPSPRelationships = convertListToMap( currentNpspRelationships, 'npe4__RelatedContact__c' );
        Map<Id, List<SObject>> donorToNPSPAffiliations = convertListToMap( currentNpspAffiliations, 'npe5__Organization__c' );

        List<npe4__Relationship__c> newNpspRelationships = returnSyncedRelationships(donorToHEDARelationships,
            donorToNPSPRelationships);
        List<npe5__Affiliation__c> newNpspAffiliations = returnSyncedAffiliations(donorToHEDAAffiliations,
            donorToNPSPRelationships);

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

    private List<npe4__Relationship__c> returnSyncedRelationships(Map<Id, List<SObject>> hedaRelationshipMap, 
        Map<Id, List<SObject>> npspRelationshipMap){
            List<npe4__Relationship__c> syncedNpspRelationships = new List<npe4__Relationship__c>();
            for(Id donorId : hedaRelationshipMap.keySet()){
                List<hed__Relationship__c> hedaRels = (List<hed__Relationship__c>)hedaRelationshipMap.get(donorId);
                for(hed__Relationship__c hedaRel : hedaRels){
                    Boolean foundMatch = false;
                    if(npspRelationshipMap.containsKey(donorId)){
                        List<npe4__Relationship__c> npspRels = 
                            (List<npe4__Relationship__c>)npspRelationshipMap.get(donorId);
                        for(npe4__Relationship__c npspRel : npspRels){
                            foundMatch = foundMatch || relationshipsMatch(hedaRel, npspRel);
                        }
                    }

                    if(!foundMatch){
                        syncedNpspRelationships.add(returnRelationshipCopy(hedaRel));
                    }
                }

            }
            return syncedNpspRelationships;
    }

    private List<npe5__Affiliation__c> returnSyncedAffiliations(Map<Id, List<SObject>> hedaAffiliationMap, 
        Map<Id, List<SObject>> npspAffiliationMap){
            List<npe5__Affiliation__c> syncedNpspAffiliations = new List<npe5__Affiliation__c>();
            for(Id donorId : hedaAffiliationMap.keySet()){
                List<hed__Affiliation__c> hedaAffls = (List<hed__Affiliation__c>)hedaAffiliationMap.get(donorId);
                for(hed__Affiliation__c hedaAffl : hedaAffls){
                    Boolean foundMatch = false;
                    if(npspAffiliationMap.containsKey(donorId)){
                        List<npe5__Affiliation__c> npspRels = 
                            (List<npe5__Affiliation__c>)npspAffiliationMap.get(donorId);
                        for(npe5__Affiliation__c npspRel : npspRels){
                            foundMatch = foundMatch || affiliationsMatch(hedaAffl, npspRel);
                        }
                    }

                    if(!foundMatch){
                        syncedNpspAffiliations.add(returnAffiliationCopy(hedaAffl));
                    }
                }

            }
            return syncedNpspAffiliations;
    }

    private npe4__Relationship__c returnRelationshipCopy(hed__Relationship__c hedaRel){
        npe4__Relationship__c newNpspRel = new npe4__Relationship__c();
        for(String hedaFieldName : hedaToNpspRelFieldMap.keySet()){
            String npspFieldName = hedaToNpspRelFieldMap.get(hedaFieldName);
            newNpspRel.put(npspFieldName, hedaRel.get(hedaFieldName));
        }
        return newNpspRel;
    }

    private npe5__Affiliation__c returnAffiliationCopy(hed__Affiliation__c hedaRel){
        npe5__Affiliation__c newNpspAffl = new npe5__Affiliation__c();
        for(String hedaFieldName : hedaToNpspAfflFieldMap.keySet()){
            String npspFieldName = hedaToNpspAfflFieldMap.get(hedaFieldName);
            newNpspAffl.put(npspFieldName, hedaRel.get(hedaFieldName));
        }
        return newNpspAffl;
    }

    private Boolean affiliationsMatch(hed__Affiliation__c hedaAffl, npe5__Affiliation__c npspAffl){
        if(hedaAffl.hed__Contact__c == npspAffl.npe5__Contact__c
            && hedaAffl.hed__Account__c == npspAffl.npe5__Organization__c
            && hedaAffl.Related_Opportunity_Contact_Role__c == npspAffl.npsp__Related_Opportunity_Contact_Role__c){
                return true;
        }
        return false; 
    }

    private Boolean relationshipsMatch(hed__Relationship__c hedaRel, npe4__Relationship__c npspRel){
        if(hedaRel.hed__Contact__c == npspRel.npe4__Contact__c
            && hedaRel.hed__RelatedContact__c == npspRel.npe4__RelatedContact__c
            && hedaRel.Related_Opportunity_Contact_Role__c == npspRel.npsp__Related_Opportunity_Contact_Role__c){
                return true;
        }
        return false;
    }
	
}