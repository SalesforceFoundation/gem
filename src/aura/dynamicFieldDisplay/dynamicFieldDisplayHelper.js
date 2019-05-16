({
    getCustomMetadata : function(component, customMetadataRecordName) {
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
        var existingItem = component.getReference('v.existingRecord');
        var objectNameToSobject = component.get("v.objectNameToSobject");

        for (var pickListValue in dependentFieldList) {
            var objectToFieldList = dependentFieldList[pickListValue];
            var componentList = [];
            var layoutItemList = [];

            for (var objectName in objectToFieldList) {
                var fieldList = objectToFieldList[objectName];
                var fieldNameToFieldLabel = objectToFieldNameToFieldLabel[objectName];

               // Build dynamic field section
               // NAMESPACE???
               var dynamicSection = ["c:DynamicFieldDisplaySection", {
                                    "objectName" : objectName,
                                    "fieldList" : fieldList,
                                    "fieldNameToFieldLabel" : fieldNameToFieldLabel,
                                    "pickListValue" : pickListValue,
                                    "objectNameToSobject" : objectNameToSobject,
                                    "controllingField" : controllingField,
                                    "controllingObject" : controllingObject,
                                    "sobjectRecord" : existingItem
                                    }];
                
                componentList.push(dynamicSection);
            }

            $A.createComponents(componentList, function(createdComponentsList, status, errorMessage) {
                if (status == "SUCCESS") {
                    // Add all the dynamic field sections into the body

                    component.set("v.body", createdComponentsList);
                } else if (status == "INCOMPLETE") {

                } else if (status == "ERROR") {
                    console.log('error here');
                    console.log(errorMessage);
                }
            });
        }
    }
})
