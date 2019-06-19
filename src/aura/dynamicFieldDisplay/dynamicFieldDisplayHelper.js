({
    getCustomMetadata : function(component, customMetadataRecordName) {

        // Query for custom metadata type record and get a wrapper with the 
        // values ready to go. 
        var action = component.get('c.getCustomMetadataRecord');
        var recordName = component.get('v.metadataRecordName');

        action.setParams({
            recordName : recordName
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var metadataRecordWrapper = response.getReturnValue();

                component.set('v.retrievedMetadataRecordWrapper', metadataRecordWrapper);
                this.createDynamicDisplaySections(component, metadataRecordWrapper);

            } else if (state === "INCOMPLETE") {
                this.handleError(component, response);
            } else if (state === "ERROR") {
                this.handleError(component, response);
            }
        });

        $A.enqueueAction(action);

    },
    createDynamicDisplaySections: function (component, metadataRecordWrapper) {
        var dependentFieldList = metadataRecordWrapper.dependentFieldList;
        var objectToFieldNameToFieldDescribe = metadataRecordWrapper.objectToFieldNameToLabel;
        var controllingObject = metadataRecordWrapper.controllingObject;
        var controllingField = metadataRecordWrapper.controllingField;
        var existingItem = component.getReference("v.existingRecord");
        var objectNameToSobject = component.get("v.objectNameToSobject");
        var rowDisabled = component.get("v.rowDisabled");

        // For each picklist value and for each object, create a new dynamic section
        // It has to be for each object because the dynamic section has the 
        // RecordEditForm, which can only be one object name at a time. 
        var componentList = [];
        var permanentFieldList = component.get("v.permanentFieldList");
        for (var pickListValue in dependentFieldList) {
            var objectToFieldList = dependentFieldList[pickListValue];

            for (var objectName in objectToFieldList) {
                var fieldList = objectToFieldList[objectName];
                var fieldListNoDefaults = [];
                var fieldNameToDescribe = objectToFieldNameToFieldDescribe[objectName];

                // Remove fields that are part of the default, non-dynamic list
                // Also remove fields that have no describe mapping, they were not found
                for(var i in fieldList){
                    var field = fieldList[i];
                    var fieldNotFound = typeof(fieldNameToDescribe[field]) === "undefined";
                    if(permanentFieldList.indexOf(field) < 0 && !fieldNotFound){
                        fieldListNoDefaults.push(field);
                    }
                }

               // Build dynamic field section
               var dynamicSection = ["c:dynamicFieldDisplaySection", {
                                    "objectName" : objectName,
                                    "fieldList" : fieldListNoDefaults,
                                    "fieldNameToFieldLabel" : fieldNameToDescribe,
                                    "pickListValue" : pickListValue,
                                    "objectNameToSobject" : objectNameToSobject,
                                    "controllingField" : controllingField,
                                    "controllingObject" : controllingObject,
                                    "sobjectRecord" : existingItem,
                                    "rowDisabled" : rowDisabled
                                    }];
                
                componentList.push(dynamicSection);
            }
        }

        $A.createComponents(componentList, function(createdComponentsList, status, errorMessage) {
            if (status == "SUCCESS") {
                // Just add the created components into the body and set it. 
                component.set("v.body", createdComponentsList);
            } else if (status == "INCOMPLETE") {
                console.log(errorMessage); 
            } else if (status == "ERROR") {
                console.log(errorMessage); 
            }
        });

    },
    handleError: function(component, response) {
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log(errorMsg); 
            }
        } else {
            console.log($A.get('$Label.c.Error_Unknown'));
        }
    }
})
