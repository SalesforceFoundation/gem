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
* @date 2018
* @group Utilities
* @group-content ../../ApexDocContent/Utilities.htm
* @description Class which holds static methods for CRUD/FLS utilities,
* such as inserting and updating records with respect to CRUD and FLS.
*/
public with sharing class UTIL_CrudFLS {

    /**
     * READ - SOQL Query
     * CREATE - DML Insert
     * MODIFY - DML Update
     * MODIFY_CREATE - DML Upsert
     */
    public enum CRUD_OPERATION { READ, CREATE, MODIFY, MODIFY_CREATE }

    /**
     * @description Overload of create(List<SObject>) that takes a single SObject
     *
     * @param record                        Records to attempt to create
     *
     * @throws AccessException              When FLS/CRUD do not allow DML insert of the given record
     * @return List<Database.SaveResult>    Containing the results of the insert operation
     */
    public static List<Database.SaveResult> create(SObject record) {
        return create(new List<SObject>{record});
    }

    /**
     * @description Insert a list of SObjects, with FLS/CRUD checks.
     *
     * @param records List<SObject>         Records to attempt to create
     *
     * @throws AccessException              When FLS/CRUD do not allow DML insert of the given records
     * @return List<Database.SaveResult>    Containing the results of the insert operation
     *
     */
    public static List<Database.SaveResult> create(List<SObject> records) {
        if(records == null || records.size() == 0) {
            return null;
        }

        checkCreate(records);

        return Database.insert(records);
    }

    /**
     * @description Delete a list of SObjects, with CRUD/FLS checks. Delete is a keyword.
     *
     * @param records                       Records to attempt to delete
     *
     * @throws AccessException              When FLS/CRUD do not allow DML delete of the given records
     * @return List<Database.DeleteResult>  Containing the results of the delete operation
     */
    public static List<Database.DeleteResult> del(List<SObject> records, Boolean allOrNothing) {
        if(records == null || records.size() == 0) {
            return null;
        }

        checkDelete(records);

        return Database.delete(records, allOrNothing);
    }


    public static void checkRead(String objectName, List<String> fieldNames) {
        checkAccess(CRUD_OPERATION.READ, objectName, fieldNames);
    }

    /**
     * @description     Check if a List of SObjects is createable (DML insert)
     * @param records   Records being Created
     * @throws          AccessException when current CRUD/FLS settings prohibit DML Insert for the given records
     */
    private static void checkCreate(List<SObject> records) {
        Schema.DescribeSObjectResult objectDescribe = getDescribeFromSObjects(records);

        // check CRUD for insert
        if(!objectDescribe.isCreateable()) {
            throw new AccessException(objectDescribe, 'insert');
        }

        // check FLS for insert
        Map<String, Schema.DescribeFieldResult> fieldDescribes = getFieldDescribesFromSObjects(records);
        for(Schema.DescribeFieldResult fieldDescribe : fieldDescribes.values()) {
            if(fieldDescribe.isPermissionable()
                    && !fieldDescribe.isCalculated()
                    && (!fieldDescribe.isAccessible() || !fieldDescribe.isCreateable())) {
                throw new AccessException(objectDescribe, fieldDescribe, 'insert');
            }
        }
    }

    /**
     * @description     Overload of @see checkUpsert for a single SObject
     *
     * @param record    Record to check CRUD/FLS on
     * @throws          AccessException when CRUD and FLS do not allow for an Upsert operation
     */
    public static void checkUpsert(SObject record) {
        List<SObject> records = new List<SObject>{record};
        checkUpsert(records);
    }

    /**
     * @description Check a List of SObjects for upsert-ability.
     * Public because we are not able to provide a true "upsert" operation as a part of this Utility class.
     * Database.upsert() does not accept a generic List<SObject>
     * The caller of this function must perform the DML upsert operation on the concrete SObject
     *
     * @param record Record to check CRUD/FLS on
     * @throws AccessException when CRUD and FLS do not allow for an Upsert operation
     */
    public static void checkUpsert(List<SObject> records) {
        Schema.DescribeSObjectResult objectDescribe = getDescribeFromSObjects(records);
        Map<String, Schema.DescribeFieldResult> fieldDescribes = getFieldDescribesFromSObjects(records);
        checkAccess(CRUD_OPERATION.MODIFY_CREATE, objectDescribe, fieldDescribes.values());
    }

    /**
     * @description     Check if a List of SObjects is deletable
     * @param records   Records to check CRUD delete on
     * @throws          AccessException when CRUD does not allow delete of the given records
     */
    private static void checkDelete(List<SObject> records) {
        Schema.DescribeSObjectResult objectDescribe = getDescribeFromSObjects(records);

        // check CRUD for delete
        if(!objectDescribe.isDeletable()) {
            throw new AccessException(objectDescribe, 'delete');
        }
    }

    /**
     * Overload of @see checkAccess that accepts Strings instead of Describe Results
     *
     * @param op            CRUD operation being performed
     * @param sObjectName   Name of SObject in context
     * @param fieldNames    Name of fields in context
     */
    public static void checkAccess(CRUD_OPERATION op, String objectName, List<String> fieldNames) {
        Schema.DescribeSObjectResult objectDescribe = UTIL_Describe.getObjectDescribe(objectName);
        Map<String, Schema.DescribeFieldResult> fieldDescribeMap = UTIL_Describe.getAllFieldsDescribe(objectName);
        List<Schema.DescribeFieldResult> fieldDescribes = new List<Schema.DescribeFieldResult>();
        for(String fieldName : fieldNames) {
            // check for this field in our own namespace first
            Schema.DescribeFieldResult dfr = fieldDescribeMap.get(UTIL_Namespace.StrTokenNSPrefix(fieldName).toLowerCase());
            if(dfr == null) {
                dfr = fieldDescribeMap.get(fieldName.toLowerCase());
            }
            fieldDescribes.add(dfr);
        }
        checkAccess(op, objectDescribe, fieldDescribes);
    }

    /**
     * @description Check an object and fields for CRUD/FLS for a given operation.
     *
     * @param op                CRUD operation being performed
     * @param objectDescribe    Describe of the Object in context
     * @param fieldDescribes    Describe of the fields in context
     */
    public static void checkAccess(CRUD_OPERATION op, DescribeSObjectResult objectDescribe, List<DescribeFieldResult> fieldDescribes) {
        switch on op {
            when READ {
                if(!objectDescribe.isAccessible()) {
                    throw new AccessException(objectDescribe, 'read');
                }
                for(DescribeFieldResult fieldDescribe : fieldDescribes) {
                    if(fieldDescribe.isPermissionable() && !fieldDescribe.isAccessible()) {
                        throw new AccessException(objectDescribe, fieldDescribe, 'read');
                    }
                }
            }
            when CREATE {
                // check CRUD for insert
                if(!objectDescribe.isCreateable()) {
                    throw new AccessException(objectDescribe, 'insert');
                }
                // check FLS for insert
                for(Schema.DescribeFieldResult fieldDescribe : fieldDescribes) {
                    if(fieldDescribe.isPermissionable()
                            && !fieldDescribe.isCalculated()
                            && (!fieldDescribe.isAccessible() || !fieldDescribe.isCreateable())) {
                        throw new AccessException(objectDescribe, fieldDescribe, 'insert');
                    }
                }
            }
            when MODIFY {
                // check CRUD for update
                if(!objectDescribe.isUpdateable()) {
                    throw new AccessException(objectDescribe, 'update');
                }

                // check FLS for update
                for(Schema.DescribeFieldResult fieldDescribe : fieldDescribes) {
                    if(fieldDescribe.isPermissionable()
                            && !fieldDescribe.isCalculated()
                            && (!fieldDescribe.isAccessible() || !fieldDescribe.isCreateable())) {
                        throw new AccessException(objectDescribe, fieldDescribe, 'update');
                    }
                }
            }
            when MODIFY_CREATE {
                checkAccess(CRUD_OPERATION.CREATE, objectDescribe, fieldDescribes);
                checkAccess(CRUD_OPERATION.MODIFY, objectDescribe, fieldDescribes);
            }
        }
    }

    /**
     * @description     Utility method to get object describe information on a list of a single type of SObject. Use prior to DML.
     * @param records   List containing a single type of SObject to get describe information for
     *
     * @return          Schema.DescribeSObjectResult for the given type of SObject
     */
    private static Schema.DescribeSObjectResult getDescribeFromSObjects(List<SObject> records) {
        String objectName = records[0].getSObjectType().getDescribe().getName();
        return UTIL_Describe.getObjectDescribe(objectName);
    }

    /**
     * @description     Utility method to get field describe information on a list of a single type of SObject. Use prior to DML.
     * @param records   List containing a single type of SObject to get field describe information for
     * @return          Map containing field describe information for the given SObject
     */
    private static Map<String, Schema.DescribeFieldResult> getFieldDescribesFromSObjects(List<SObject> records) {
        String objectName = records[0].getSObjectType().getDescribe().getName();

        // collect all field names that are populated on at least one of the sobject
        Set<String> fieldNames = new Set<String>();
        for(SObject record : records) {
            fieldNames.addAll(record.getPopulatedFieldsAsMap().keySet());
        }
        Map<String, Schema.DescribeFieldResult> allFieldDescribes = UTIL_Describe.getAllFieldsDescribe(objectName);

        // collect the describe information for the populated fields, so we can check FLS
        Map<String, Schema.DescribeFieldResult> fieldDescribes = new Map<String, Schema.DescribeFieldResult>();
        for(String fieldName : fieldNames) {
            // check for this field in our own namespace first
            Schema.DescribeFieldResult dfr = allFieldDescribes.get(UTIL_Namespace.StrTokenNSPrefix(fieldName).toLowerCase());
            if(dfr == null) {
                dfr = allFieldDescribes.get(fieldName.toLowerCase());
            }
            fieldDescribes.put(fieldName, dfr);
        }

        return fieldDescribes;
    }

    /**
     * @description Exception thrown when attempting an operation prohibited by current CRUD/FLS settings
     */
    public class AccessException extends Exception {
        public AccessException(Schema.DescribeSObjectResult objectDescribe, String operation) {
            this.setMessage(operation + ' ' + Label.Error_Access_Required + '. ' 
                + Label.npsp.stgLabelObject + ': ' + objectDescribe.getName());
        }

        public AccessException(Schema.DescribeSObjectResult objectDescribe, Schema.DescribeFieldResult fieldDescribe, String operation) {
            this.setMessage(operation + ' ' + Label.Error_Access_Required + '. ' 
                + Label.npsp.stgLabelObject + ': ' + objectDescribe.getName() + ' '
                + Label.Field + ': ' + fieldDescribe.getName());
        }
    }

}