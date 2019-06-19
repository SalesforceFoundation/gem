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
* @group GiftEntry
* @group-content ../../ApexDocContent/GiftEntry.htm
* @description This class is used to access Gift Entry Field Mappings
**/
public with sharing class DynamicFieldDisplayController {

    @AuraEnabled
    public static GiftEntryFieldMappingWrapper getCustomMetadataRecord(String recordName) {

        GiftEntryFieldMappingWrapper mappingRecordWrapper; 

        // Query for the custom metadata type record via the record's API Name. 
        List<Gift_Entry_Field_Mapping__mdt> fieldMappingRecordList = [SELECT Id, DeveloperName, 
                Controlling_Field__r.QualifiedAPIName, Controlling_Object__r.QualifiedAPIName, 
                Dependent_Field_List__c 
            FROM Gift_Entry_Field_Mapping__mdt 
            WHERE Label =: recordName];
        
        if (!fieldMappingRecordList.isEmpty()) {
            // Build the wrapper, which puts the fields/values into easy to access fields from Javascript
            mappingRecordWrapper = new GiftEntryFieldMappingWrapper(fieldMappingRecordList.get(0));
        }

        return mappingRecordWrapper;
    }

}
