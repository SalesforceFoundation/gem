public with sharing class DynamicFieldDisplayController {

    @AuraEnabled
    public static GiftEntryFieldMappingWrapper getCustomMetadataRecord(String recordName) {

        GiftEntryFieldMappingWrapper mappingRecordWrapper; 

        // Query for the custom metadata type record via the record's API Name. 
        List<Gift_Entry_Field_Mapping__mdt> fieldMappingRecordList = [SELECT Id, 
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

    public class GiftEntryFieldMappingWrapper {
        
        @AuraEnabled public Gift_Entry_Field_Mapping__mdt originalMetadataRecord;
        @AuraEnabled public  String controllingObject;
        @AuraEnabled public String controllingField;

        // Picklist value -> object -> field on object
        @AuraEnabled public Map<String, Map<String, List<String>>> dependentFieldList;
        @AuraEnabled public Map<String, Map<String, Map<String, String>>> objectToFieldNameToLabel;
        @AuraEnabled public Map<String, Map<String, String>> objectToFieldNameToType;

        public GiftEntryFieldMappingWrapper(Gift_Entry_Field_Mapping__mdt originalMetadataRecord) {
            this.originalMetadataRecord = originalMetadataRecord;
            controllingObject = originalMetadataRecord.Controlling_Object__r.QualifiedAPIName;
            controllingField = originalMetadataRecord.Controlling_Field__r.QualifiedAPIName;
            dependentFieldList = (Map<String, Map<String, List<String>>>)JSON.deserialize(
                originalMetadataRecord.Dependent_Field_List__c, 
                Map<String, Map<String, List<String>>>.class);

            objectToFieldNameToLabel = buildObjectToFieldNameToDescribeMap(dependentFieldList);
            
        }

        // This builds a mapping of 
        // Object API Name -> Field API Name -> Field Label
        // and
        // Object API Name -> Field API Name -> Field Type
        public Map<String, Map<String, Map<String, String>>> buildObjectToFieldNameToDescribeMap(Map<String, Map<String, List<String>>> dependentFieldList) {
            Map<String, Map<String, Map<String, String>>> objectToFieldNameToLabel = new Map<String, Map<String, Map<String, String>>>();
            List<Map<String, List<String>>> allObjectToFieldList = dependentFieldList.values();

            // Build the mapping of object name to field name to field label
            // This is to display the field label on the front end. 
            for (Map<String, List<String>> objectToFieldList : allObjectToFieldList) {
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

                        for (String fieldName : fieldList) {
                            if (fieldMap.containsKey(fieldName)) {
                                Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();

                                String fieldLabel = fieldResult.getLabel();
                                String fieldType = fieldResult.getType().name();
                                Map<String, String> fieldInfoMap = new Map<String, String>();
                                fieldInfoMap.put('Label', fieldLabel);
                                fieldInfoMap.put('Type', fieldType);
                                fieldNameToLabel.put(fieldName, fieldInfoMap);

                            }
                        }

                        objectToFieldNameToLabel.put(objectName, fieldNameToLabel);
                    }
                }
            }
            
            return objectToFieldNameToLabel;
        }
    }
}
