public with sharing class dynamicFieldDisplayController {
    public dynamicFieldDisplayController() {

    }

    @AuraEnabled
    public static GiftEntryFieldMappingWrapper getCustomMetadataRecord(String recordName) {
        List<Gift_Entry_Field_Mapping__mdt> fieldMappingRecordList = [Select Id, Controlling_Field__r.QualifiedAPIName, Controlling_Object__r.QualifiedAPIName, Dependent_Field_List__c From Gift_Entry_Field_Mapping__mdt where QualifiedApiName =: recordName];
        GiftEntryFieldMappingWrapper mappingRecordWrapper; 
        System.debug(loggingLevel.ERROR, 'inside of get custom metadata record');
        if (!fieldMappingRecordList.isEmpty()) {
            mappingRecordWrapper = new GiftEntryFieldMappingWrapper(fieldMappingRecordList.get(0));
        }
        System.debug(loggingLevel.ERROR, 'mapping record: ' + mappingRecordWrapper);
        return mappingRecordWrapper;
    }

    public class GiftEntryFieldMappingWrapper {
        
        @AuraEnabled public Gift_Entry_Field_Mapping__mdt originalMetadataRecord;
        @AuraEnabled public  String controllingObject;
        @AuraEnabled public String controllingField;

        // Picklist value -> object -> field on object
        @AuraEnabled public Map<String, Map<String, List<String>>> dependentFieldList;
        @AuraEnabled public Map<String, Map<String, String>> objectToFieldNameToLabel;

        public GiftEntryFieldMappingWrapper(Gift_Entry_Field_Mapping__mdt originalMetadataRecord) {
            this.originalMetadataRecord = originalMetadataRecord;
            controllingObject = originalMetadataRecord.Controlling_Object__r.QualifiedAPIName;
            controllingField = originalMetadataRecord.Controlling_Field__r.QualifiedAPIName;
            dependentFieldList = (Map<String, Map<String, List<String>>>)JSON.deserialize(originalMetadataRecord.Dependent_Field_List__c, Map<String, Map<String, List<String>>>.class);

            objectToFieldNameToLabel = buildObjectToFieldNameToLabelMap(dependentFieldList);
            
        }

        public Map<String, Map<String, String>> buildObjectToFieldNameToLabelMap(Map<String, Map<String, List<String>>> dependentFieldList) {
            Map<String, Map<String, String>> objectToFieldNameToLabel = new Map<String, Map<String, String>>();
            List<Map<String, List<String>>> allObjectToFieldList = dependentFieldList.values();
            Map<String, Schema.SobjectType> globalDescribe = Schema.getGlobalDescribe();

            // Build the mapping of object name to field name to field label
            // This is to display the field label on the front end. 
            for (Map<String, List<String>> objectToFieldList : allObjectToFieldList) {
                for (String objectName : objectToFieldList.keySet()) {

                    // If the object name is not a real object/doesn't exist, we just skip it for now. 
                    if (globalDescribe.containsKey(objectName)) {
                        Schema.DescribeSObjectResult objectDescribeResult = globalDescribe.get(objectName).getDescribe();
                        Map<String, Schema.SObjectField> fieldMap = objectDescribeResult.fields.getMap();
                        Map<String, String> fieldNameToLabel = new Map<String, String>();

                        if (objectToFieldNameToLabel.containsKey(objectName)) {
                            fieldNameToLabel = objectToFieldNameToLabel.get(objectName);
                        }

                        List<String> fieldList = objectToFieldList.get(objectName);

                        for (String fieldName : fieldList) {
                            if (fieldMap.containsKey(fieldName)) {
                                Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();

                                String fieldLabel = fieldResult.getLabel();
                                fieldNameToLabel.put(fieldName, fieldLabel);

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
