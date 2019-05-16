({
    createAllInputs : function (component, controllingField, picklistValue, fieldList, fieldNameToFieldLabel) {
        // Need to add the sobject to the map of string to sobject
        console.log('inside create all inputs');
        var componentList = [];
        var layoutItemList = [];

        for (var j = 0; j < fieldList.length; j++) {
            var sobjectRecord = component.getReference('v.sobjectRecord.' + fieldList[j]);
            var layoutItem = ["lightning:layoutItem", {
                            "padding" : "around-small",
                            "size": "6",
                            "mediumDeviceSize": "3"
            }];

            var inputField = ["lightning:inputField", {
                                "fieldName": fieldList[j],
                                "value" : sobjectRecord
            }];

            componentList.push(layoutItem);

            // Keep track of the index of layout items. 
            layoutItemList.push(componentList.length - 1);

            componentList.push(inputField);
        }


        $A.createComponents(componentList, function(createdComponentsList, status, errorMessage) {
            if (status == "SUCCESS") {
                var body = component.get("v.body");
                var layoutItem; 
                var layoutItemListToAdd = [];

                for (var i = 0; i < createdComponentsList.length; i++) {
                    if (layoutItemList.includes(i)) {
                        layoutItem = createdComponentsList[i];
                        layoutItemListToAdd.push(layoutItem);
                        body.push(layoutItem);
                    } else {
                        var inputField = createdComponentsList[i];
                        layoutItem.set("v.body", inputField);
                    }
                }

                console.log('layout item list to add: ');
                console.log(layoutItemListToAdd);

                // body.push(layoutItemListToAdd);
                // body.set("v.body", layoutItemListToAdd);
                component.set("v.body", body);
            } else if (status == "INCOMPLETE") {
                this.showErrorToast(errorMessage, 'Error')
            } else if (status == "ERROR") {
                console.log('error here');
                console.log(errorMessage);
                this.showErrorToast(errorMessage, 'Error')
            }
        });

    },
    showErrorToast: function(msgText, title){
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title : title ? title : $A.get('$Label.c.Error'),
            message: msgText,
            type: 'error',
            mode: 'sticky'
        });
        toastEvent.fire();
    },
    processSobjectRecord: function(component) {
        var sobjectRecord = component.get('v.sobjectRecord');
        var sobjectType = component.get('v.objectName');

        if ($A.util.isEmpty(sobjectRecord)) {
            component.set('v.sobjectRecord.sobjectType', sobjectType);
        }

        var objectNameToSobject = component.get('v.objectNameToSobject');

        var sobjectList = objectNameToSobject[sobjectType] || [];
        sobjectList.push(sobjectRecord);

        var controllingField = component.get('v.controllingField');
        var picklistValue = component.get('v.picklistValue');
        this.handleSobjectChange(component, sobjectRecord, controllingField, picklistValue);
    },
    handleSobjectChange: function(component, sobjectRecord, controllingField, picklistValue) {
        var sobjectRecordSelectedPicklistValue = sobjectRecord[controllingField];

        if (sobjectRecordSelectedPicklistValue != null && sobjectRecordSelectedPicklistValue != undefined) {
            if (sobjectRecordSelectedPicklistValue == picklistValue) {
                component.set('v.displaySection', true);
            } else {
                component.set('v.displaySection', false);
            }
        } else {
            component.set('v.displaySection', false);
        }
        
    }
})
