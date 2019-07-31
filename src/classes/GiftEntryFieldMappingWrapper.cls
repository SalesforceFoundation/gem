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
* @description This class is used to represent Gift Entry Field Mappings in code
**/
public class GiftEntryFieldMappingWrapper {

    @AuraEnabled public Gift_Entry_Field_Mapping__mdt originalMetadataRecord;
    @AuraEnabled public String controllingObject;
    @AuraEnabled public String controllingField;
    
    // Picklist value -> object -> field on object
    @AuraEnabled public Map<String, Map<String, List<String>>> dependentFieldList;
    @AuraEnabled public Map<String, Map<String, Map<String, String>>> objectToFieldNameToLabel;
    @AuraEnabled public Map<String, Map<String, String>> objectToFieldNameToType;
    
    public GiftEntryFieldMappingWrapper(Gift_Entry_Field_Mapping__mdt originalMetadataRecord) {
        this.originalMetadataRecord = originalMetadataRecord;

        controllingObject = originalMetadataRecord.Controlling_Object__r.QualifiedAPIName;
        controllingField = originalMetadataRecord.Controlling_Field__r.QualifiedAPIName;

        // This isn't ideal, but it allows us to setup Test mappings much easier
        if(controllingObject == null){controllingObject = originalMetadataRecord.Controlling_Object__c;}
        if(controllingField == null){controllingField = originalMetadataRecord.Controlling_Field__c;}

        try {
            dependentFieldList = (Map<String, Map<String, List<String>>>)JSON.deserialize(
                originalMetadataRecord.Dependent_Field_List__c, 
                Map<String, Map<String, List<String>>>.class);
        } catch(Exception e){
            throw new GiftEntryFieldMappingException(Label.Error_Gift_Field_Mapping + ' ' 
                + originalMetadataRecord.DeveloperName);
        }

        objectToFieldNameToLabel = buildObjectToFieldNameToDescribeMap(dependentFieldList);

    }
    
    // This builds a mapping of 
    // Object API Name -> Field API Name -> Field Label
    // and
    // Object API Name -> Field API Name -> Field Type
    public Map<String, Map<String, Map<String, String>>> buildObjectToFieldNameToDescribeMap(Map<String, Map<String, List<String>>> dependentFieldList) {
        
        Map<String, Map<String, Map<String, String>>> objectToFieldNameToLabel = new Map<String, Map<String, Map<String, String>>>();
        
        for (String controllingFieldValue : dependentFieldList.keySet()) {
        
            // Build the mapping of object name to field name to field label
            // This is to display the field label on the front end. 
            Map<String, List<String>> objectToFieldList = dependentFieldList.get(controllingFieldValue);

            for (String objectName : objectToFieldList.keySet()) {
                
                Schema.DescribeSObjectResult objectDescribeResult = 
                    UTIL_Describe.getObjectDescribe(objectName);
                // If the object name is not a real object/doesn't exist, we just skip it for now. 
                if (objectDescribeResult != null) {
                    
                    Map<String, Schema.SObjectField> fieldMap = objectDescribeResult.fields.getMap();
                    Map<String, Map<String, String>> fieldNameToLabel = new Map<String, Map<String, String>>();
                    
                    if (objectToFieldNameToLabel.containsKey(objectName)) {
                        fieldNameToLabel = objectToFieldNameToLabel.get(objectName);
                    }
                    
                    List<String> fieldList = objectToFieldList.get(objectName);

                    List<String> toRemove = new List<String>();
                    Set<String> fieldAdded = new Set<String>();
                    
                    for (String fieldName : fieldList) {
                        if (!fieldAdded.contains(fieldName) && fieldMap.containsKey(fieldName)) {
                            Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
                            
                            String fieldLabel = fieldResult.getLabel();
                            String fieldType = fieldResult.getType().name();
                            Map<String, String> fieldInfoMap = new Map<String, String>();
                            fieldInfoMap.put('Label', fieldLabel);
                            fieldInfoMap.put('Type', fieldType);
                            fieldNameToLabel.put(fieldName, fieldInfoMap);
                            // Make sure we don't add the same field twice
                            fieldAdded.add(fieldName);
                        } else {
                            // This field was not found on the object, or is a duplicate, remove it from the list
                            toRemove.add(fieldName);
                        }
                    }

                    for(String fieldToRemove : toRemove){
                        Integer indexToRemove = this.dependentFieldList.get(controllingFieldValue).get(objectName).indexOf(fieldToRemove);
                        String removed = this.dependentFieldList.get(controllingFieldValue).get(objectName).remove(indexToRemove);
                    }
                    
                    objectToFieldNameToLabel.put(objectName, fieldNameToLabel);
                }
            }
        }
        
        return objectToFieldNameToLabel;
    }

    /*******************************************************************************************************
    * @description This is the expection class for GiftEntryFieldMappingWrapper class
    ********************************************************************************************************/
    private class GiftEntryFieldMappingException extends Exception{}

}