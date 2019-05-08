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
                this.createAllInputs(component, metadataRecordWrapper);

            } else if (state === "INCOMPLETE") {

            } else if (state === "ERROR") {

            }
        });

        $A.enqueueAction(action);

    },
    createAllInputs : function (component, metadataRecordWrapper) {
        console.log(metadataRecordWrapper);
        var dependentFieldList = metadataRecordWrapper.dependentFieldList;
        
        for (var pickListValue in dependentFieldList) {
            var objectToFieldList = dependentFieldList[pickListValue];
            var componentList = [];
            var layoutItemList = [];

            var ifStatement = ["aura:if", {
                                "isTrue": "true"
                            }];

            componentList.push(ifStatement);

            for (var objectName in objectToFieldList) {
                var fieldList = objectToFieldList[objectName];
                
                for (var j = 0; j < fieldList.length; j++) {

                    var value = "{!v.item." + fieldList[j] + "}";
                    var layoutItem = ["lightning:layoutItem", {
                                    "padding" : "around-small",
                                    "size": "6",
                                    "mediumDeviceSize": "1"
                    }];
                    var inputField = ["force:inputField", {
                                        "value": value
                    }];

                    componentList.push(layoutItem);

                    // Keep track of the index of layout items. 
                    layoutItemList.push(componentList.length - 1);
                    
                    componentList.push(inputField);
                }
            }

            console.log('component list is: ');
            console.log(componentList);
            $A.createComponents(componentList, function(createdComponentsList, status, errorMessage) {
                if (status == "SUCCESS") {
                    console.log('success here');
                    var body = component.get("v.body");
                    var ifStatement; 
                    var layoutItem; 
                    var layoutItemListToAdd = [];

                    for (var i = 0; i < createdComponentsList.length; i++) {
                        if (i == 0) {
                            ifStatement = createdComponentsList[i];
                        } else {
                            if (layoutItemList.includes(i)) {
                                layoutItem = createdComponentsList[i];
                                layoutItemListToAdd.push(layoutItem);
                                // ifStatement.set("v.body", layoutItem);
                            } else {
                                var inputField = createdComponentsList[i];
                                layoutItem.set("v.body", inputField);
                            }
                        }
                    }

                    ifStatement.set("v.body", layoutItemListToAdd);

                    body.push(ifStatement);
                    component.set("v.body", body);
                    console.log('pushed into body');
                } else if (status == "INCOMPLETE") {

                } else if (status == "ERROR") {
                    console.log('error here');
                }
            });
        }

    }
})
