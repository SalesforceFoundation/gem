({
    createAllInputs : function (component, picklistValue, fieldList, fieldNameToFieldLabel) {
        // Need to add the sobject to the map of string to sobject
        console.log('inside create all inputs');
        var componentList = [];
        var layoutItemList = [];

        var ifStatement = ["aura:if", {
                            "isTrue": "true"
                        }];

        componentList.push(ifStatement);


        for (var j = 0; j < fieldList.length; j++) {

            // var value = "{!v.item." + fieldList[j] + "}";
            var label = fieldNameToFieldLabel[fieldList[j]];

            var layoutItem = ["lightning:layoutItem", {
                            "padding" : "around-small",
                            "size": "6",
                            "mediumDeviceSize": "3"
            }];

            /*
            var labelField = ["aura:html", {
                                "tag" : "label",
                                "HTMLAttributes" : {"id": "Temp","class": "slds-form-element__label"},
                                "value" : label
                                }];
            */
            var inputField = ["lightning:inputField", {
                                "fieldName": fieldList[j]
            }];

            componentList.push(layoutItem);

            // Keep track of the index of layout items. 
            layoutItemList.push(componentList.length - 1);
            // componentList.push(labelField);
            componentList.push(inputField);
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
                console.log('pushed into body for dynamic field display SECTION helper');
            } else if (status == "INCOMPLETE") {

            } else if (status == "ERROR") {
                console.log('error here');
                console.log(errorMessage);
            }
        });

    }
})
