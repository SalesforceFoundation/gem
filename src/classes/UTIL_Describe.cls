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
* @author Salesforce Foundation
* @date 2018
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description This class allows easy access to object and field description information from within other classes.
*
* It is called statically, and therefore will supply the same information to all calls made from
* within one transaction, or set of trigger calls. This is beneficial because this info should
* be the same for all calls in a transaction, and by calling it statically we reduce the calls
* that are made, making the total transaction more efficient.
*/

public with sharing class UTIL_Describe {

    public static Boolean checkCRUD = true;

    // throw custom exceptions when a bogus object or field is provided.
    public class SchemaDescribeException extends Exception {}

    //maps to hold the describe info
    private static Map<String, Schema.SObjectType> gd;
    private static Map<String, Schema.DescribeSObjectResult> objectDescribes = new Map<String, Schema.DescribeSObjectResult>();
    private static Map<String, Map<String, Schema.SObjectField>> fieldTokens = new Map<String,Map<String, Schema.SObjectField>>();
    private static Map<String, Map<String, Schema.DescribeFieldResult>> fieldDescribes = new Map<String,Map<String, Schema.DescribeFieldResult>>();

    /*******************************************
    * Gets describe maps for a new object
    ********************************************/
    static void fillMapsForObject(String objectName) {
        // get the object map the first time
        if (gd == null) {
            gd = Schema.getGlobalDescribe();
        }

        // get the object description
        if (gd.containsKey(objectName)) {

            if (!objectDescribes.containsKey(objectName)) {
                objectDescribes.put(objectName, gd.get(objectName).getDescribe());
            }
        } else {
            throw new SchemaDescribeException(System.Label.Error_Object_Not_Found + ' \'' + objectName + '\'');
        }
    }

    /*******************************************
    * Gets a field map for a new object/field pair
    ********************************************/
    private static void fillFieldMapsForObject(String objectName, String fieldName) {
        // get the object map the first time
        fillMapsForObject(objectName);

        // get the field description
        if (!fieldTokens.containsKey(objectName)) {
            fieldTokens.put(objectName, objectDescribes.get(objectName).fields.getMap());
            fieldDescribes.put(objectName, new Map<String, Schema.DescribeFieldResult>());
        }
        if (!fieldDescribes.get(objectName).containsKey(fieldName)) {
            if (fieldTokens.get(objectName).containsKey(fieldName)) {
                Schema.DescribeFieldResult dfr = fieldTokens.get(objectName).get(fieldName).getDescribe();
                fieldDescribes.get(objectName).put(fieldName, dfr);
            } else {
                throw new SchemaDescribeException(System.Label.Error_Field_Not_Found + ' \'' + fieldName + '\'');
            }
        }
    }

    /*******************************************
    * Gets all field maps for a new object
    ********************************************/
    static void fillFieldMapsForObject(String objectName) {
        // get the object map the first time
        fillMapsForObject(objectName);

        // get the field description
        if (!fieldTokens.containsKey(objectName)) {
            fieldTokens.put(objectName, objectDescribes.get(objectName).fields.getMap());
            fieldDescribes.put(objectName, new Map<String, Schema.DescribeFieldResult>());
        }

        //Map<String, Schema.SObjectField> fieldsMap = objectDescribes.get(objectName).fields.getMap();
        if (fieldTokens.get(objectName).size() != fieldDescribes.get(objectName).size()) {
            for ( String fieldName : fieldTokens.get(objectName).keySet()) {
                if (!fieldDescribes.get(objectName).containsKey(fieldName)) {
                    Schema.DescribeFieldResult dfr = fieldTokens.get(objectName).get(fieldName).getDescribe();
                    fieldDescribes.get(objectName).put(fieldName, dfr);
                }
            }
        }
    }

    /*******************************************************************************************************
    * @description Returns new object of given type.
    * @param objectName the name of the object to create
    * @return the new SObject
    */
    public static SObject getPrototypeObject(String objectName) {
        // make sure we have this object's schema mapped
        if (!objectDescribes.containsKey(objectName)) {
            fillMapsForObject(objectName);
        }
        return gd.get(objectName).newSObject();
    }

    /*******************************************************************************************************
    * @description Returns object friendly name.
    * @param objectName the name of the object to lookup
    * @return the Label of the object
    */
    public static String getObjectLabel(String objectName) {
        // make sure we have this object's schema mapped
        if (!objectDescribes.containsKey(objectName)) {
            fillMapsForObject(objectName);
        }
        return objectDescribes.get(objectName).getLabel();
    }

    /*******************************************************************************************************
    * @description Returns object describe data.
    * @param objectName the name of the object to lookup
    * @return Schema.DescribeSObjectResult of the object
    */
    public static Schema.DescribeSObjectResult getObjectDescribe(String objectName) {
        // make sure we have this object's schema mapped
        if (!objectDescribes.containsKey(objectName)) {
            fillMapsForObject(objectName);
        }
        return objectDescribes.get(objectName);
    }

    /*******************************************************************************************************
    * @description Compares Id to verify object type
    * @param salesforceId of the object
    * @param objectName
    * @return true if the Id is for the given object type, false otherwise.
    */
    public static Boolean isObjectIdThisType(Id salesforceId, String objectName) {
        // make sure we have this object's schema mapped
        if (!objectDescribes.containsKey(objectName)) {
            fillMapsForObject(objectName);
        }

        // now grab the requested id prefix
        Boolean ret = false;
        if (salesforceId != null) {
            String prefix = objectDescribes.get(objectName).getKeyPrefix();
            if (prefix != null) {
                ret = ((String) (salesforceId)).startsWith(prefix);
            }
        }
        return ret;
    }

    /*******************************************************************************************************
    * @description Returns all field describe data
    * @param objectName the name of the object to look up
    * @return Map<String, Schema.DescribeFieldResult> a map of field names names to describe field results.
    */
    public static Map<String, Schema.DescribeFieldResult> getAllFieldsDescribe(String objectName) {
        // make sure we have this field's schema mapped
        fillFieldMapsForObject(objectName);

        Map<String, Schema.DescribeFieldResult> fieldMap = fieldDescribes.get(objectName);
        return fieldMap;
    }

    /*******************************************************************************************************
    * @description Gives field type name - ID, STRING, TEXTAREA, DATE, DATETIME, BOOLEAN, REFERENCE,
    * PICKLIST, MULTIPICKLIST, CURRENCY, DOUBLE, INTEGER, PERCENT, PHONE, EMAIL
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return string the name of the of the field's type
    */
    public static String getFieldType(String objectName, String fieldName) {
        // make sure we have this field's schema mapped
        if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName)) {
            fillFieldMapsForObject(objectName, fieldName);
        }

        Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
        return dfr.getType().name();
    }

    /*******************************************************************************************************
    * @description Returns field describe data
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return Schema.DescribeFieldResult the describe field result for the given field
    */
    public static Schema.DescribeFieldResult getFieldDescribe(String objectName, String fieldName) {
        // make sure we have this field's schema mapped
        if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName)) {
            fillFieldMapsForObject(objectName, fieldName);
        }

        Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
        return dfr;
    }

    /*******************************************************************************************************
    * @description Gives field friendly name
    * @param objectName the name of the object to look up
    * @param fieldName the name of the field to look up
    * @return string the label of the field
    */
    public static String getFieldLabel(String objectName, String fieldName) {
        // make sure we have this field's schema mapped
        if (!fieldDescribes.containsKey(objectName) || !fieldDescribes.get(objectName).containsKey(fieldName)) {
            fillFieldMapsForObject(objectName, fieldName);
        }

        Schema.DescribeFieldResult dfr = fieldDescribes.get(objectName).get(fieldName);
        return dfr.getLabel();
    }

    /*******************************************************************************************************
    * @description Cache for the record type Object Name to DeveloperName-to-ID map. It is a Map with
    * Object name as the key and Map as the value. The value Map is the RecordType Developer Name to
    * RecordType Id
    */
    private static Map<String, Map<String, Id>> mapRecordTypes = new Map<String, Map<String, Id>>();

    /*******************************************************************************************************
     * @description Returns a map of active, user-available RecordType IDs for a given SObjectType,
     * keyed by each RecordType's unique, unchanging DeveloperName.
     * @param objectName Name of the object to retrieve record types for.
     * @return Map<String, Id> Map of DeveloperName-to-ID of available record types for object specified.
     */
    public static Map<String, Id> getRecTypesMapByDevName(String objectName) {
        return getRecTypesMap(objectName, true);
    }

    /*******************************************************************************************************
     * @description Returns a map of active, user-available RecordType IDs for a given SObjectType, keyed
     * by either the RecordType's Name or the Developer Name, depending on the value of the second param.
     * @param objectName Name of the object to retrieve record types for.
     * @param devName True if we want the key of the returned map to be the record type's developer name.
     * False if we want it to be the friendly name.
     * @return Map<String, Id> Map of Name-to-ID or DeveloperName-to-ID (depending on the second paramater),
     * of available record types for object specified.
     */
    private static Map<String, Id> getRecTypesMap(String objectName, Boolean devName) {
        if(mapRecordTypes.get(objectName) == null) {
            Map<String, Id> recTypes = new Map<String, Id>();

            // Get the Describe Result
            fillMapsForObject(objectName);
            Schema.DescribeSObjectResult obj = objectDescribes.get(objectName);

            // Obtain ALL Active Record Types for the given SObjectType objectType
            String soql = 'SELECT Id, Name, DeveloperName FROM RecordType ' + 'WHERE SObjectType = \''
                    + String.escapeSingleQuotes(obj.getName()) + '\' ' + 'AND IsActive = TRUE';
            List<SObject> results;
            try {
                results = Database.query(soql);
            } catch (Exception ex) {
                results = new List<SObject>();
            }

            // Obtain the RecordTypeInfos for this SObjectType objectType
            Map<Id,Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosById();

            for (SObject rt : results) {
                // Check RecordType IS available for the running user
                if (!Test.isRunningTest()) {
                    if (recordTypeInfos.get(rt.Id).isAvailable()) {
                        if(devName) {
                            recTypes.put(String.valueOf(rt.get('DeveloperName')), rt.Id);
                        } else {
                            recTypes.put(String.valueOf(rt.get('Name')), rt.Id);
                        }
                    }
                    // We don't want our tests to depend on the profile configuration in the org. Otherwise tests
                    // might fail just because the user running them does not have certain record types assigned.
                } else {
                    if(devName) {
                        recTypes.put(String.valueOf(rt.get('DeveloperName')), rt.Id);
                    } else {
                        recTypes.put(String.valueOf(rt.get('Name')), rt.Id);
                    }
                }
            }
            mapRecordTypes.put(objectName, recTypes);
        }
        return mapRecordTypes.get(objectName);
    }

    /*******************************************************************************************************
     * @description Returns a comma delimited string with all accessible fields of an object, used for queries.
     * @param sobjectname Name of the object to retrieve field list for.
     * @throws UTIL_CrudFLS.AccessException when the supplied sObject is not readable by the current user
     * @return String A comma delimited String with all fields of an object.
     */
    public static String getAllFieldsQueryStringFromObject(String sObjectName) {
        DescribeSObjectResult objectDescribe = getObjectDescribe(sObjectName);
        if(checkCRUD && !objectDescribe.isAccessible()) {
            throw new UTIL_CrudFLS.AccessException(objectDescribe, 'read');
        }

    	Map<String, Schema.DescribeFieldResult> fields = getAllFieldsDescribe(sObjectName);
  
    	Set<String> accessibleFields = new Set<String>();
  
    	for(Schema.DescribeFieldResult field : fields.values()){
      		if(!checkCRUD || field.isAccessible()) {
                if(field.getType() == Schema.DisplayType.Location){
                    // Since Geolocation fields return an object, including them was causing an internal server error
                    // The Latitude and Longitude fields are still included in the list and can be referenced
                    continue;
                } else {
        	        accessibleFields.add(field.getName());
                }
            }
    	}
  
    	String allFields = '';
    	for(String fieldName : accessibleFields){
      		allFields += fieldName+',';
        }
    	allFields = allFields.substring(0, allFields.length()-1);
    	return allFields;
  	}

}