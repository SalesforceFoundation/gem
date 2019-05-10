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
                                    "objectNameToSobject" : objectNameToSobject
                                    }];
                
                componentList.push(dynamicSection);
            }

            console.log('component list is: ');
            console.log(componentList);
            $A.createComponents(componentList, function(createdComponentsList, status, errorMessage) {
                if (status == "SUCCESS") {
                    // Add all the dynamic field sections into the body
                    console.log('success here creating the sections');
                    var body = component.get("v.body");
                    var dynamicSection = [];

                    for (var i = 0; i < createdComponentsList.length; i++) {
                        dynamicSection.push(createdComponentsList[i]);
                    }


                    body.push(dynamicSection);
                    component.set("v.body", body);
                    console.log('pushed into body for dynamic field display helper');
                } else if (status == "INCOMPLETE") {

                } else if (status == "ERROR") {
                    console.log('error here');
                    console.log(errorMessage);
                }
            });
        }
    }
})
