({
    getCustomMetadata : function(component, customMetadataRecordName) {

        // Query for custom metadata type record and get a wrapper with the 
        // values ready to go. 
        var action = component.get('c.getCustomMetadataRecord');
        var recordName = component.get('v.metadataRecordName');

        action.setParams({
            recordName : component.get('v.metadataRecordName')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var metadataRecordWrapper = response.getReturnValue();

                component.set('v.retrievedMetadataRecordWrapper', metadataRecordWrapper);
                this.createDynamicDisplaySections(component, metadataRecordWrapper);

            } else if (state === "INCOMPLETE") {

            } else if (state === "ERROR") {

            }
        });

        $A.enqueueAction(action);

    },
    createDynamicDisplaySections: function (component, metadataRecordWrapper) {
        var dependentFieldList = metadataRecordWrapper.dependentFieldList;
        var objectToFieldNameToFieldLabel = metadataRecordWrapper.objectToFieldNameToLabel;
        var controllingObject = metadataRecordWrapper.controllingObject;
        var controllingField = metadataRecordWrapper.controllingField;
        var existingItem = component.getReference("v.existingRecord");
        var objectNameToSobject = component.get("v.objectNameToSobject");

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

                // Remove fields that are part of the default, non-dynamic list
                for(var i in fieldList){
                    var field = fieldList[i];
                    if(permanentFieldList.indexOf(field) < 0){
                        fieldListNoDefaults.push(field);
                    }
                }
                var fieldNameToFieldLabel = objectToFieldNameToFieldLabel[objectName];

               // Build dynamic field section
               var dynamicSection = ["c:dynamicFieldDisplaySection", {
                                    "objectName" : objectName,
                                    "fieldList" : fieldListNoDefaults,
                                    "fieldNameToFieldLabel" : fieldNameToFieldLabel,
                                    "pickListValue" : pickListValue,
                                    "objectNameToSobject" : objectNameToSobject,
                                    "controllingField" : controllingField,
                                    "controllingObject" : controllingObject,
                                    "sobjectRecord" : existingItem
                                    }];
                
                componentList.push(dynamicSection);
            }
        }

        $A.createComponents(componentList, function(createdComponentsList, status, errorMessage) {
            if (status == "SUCCESS") {
                // Just add the created components into the body and set it. 
                component.set("v.body", createdComponentsList);
            } else if (status == "INCOMPLETE") {

            } else if (status == "ERROR") {
                console.log('error here');
                console.log(errorMessage);
            }
        });

    }
})
