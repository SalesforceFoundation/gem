({
    createAllInputs : function (component, controllingField, picklistValue, fieldList, fieldNameToFieldLabel) {
        // Need to add the sobject to the map of string to sobject
        var componentList = [];
        var layoutItemIndexList = [];
        var rowDisabled = component.get("v.rowDisabled");

        // Given the list of fields that should be shown for this particular picklist value,
        // Create a lightning layout item and also a lighting input field. 
        for (var j = 0; j < fieldList.length; j++) {
            var fieldName = fieldList[j];
            var fieldNameToDescribe = this.proxyToObj(fieldNameToFieldLabel);
            var fieldRecordValueRef = component.getReference('v.sobjectRecord.' + fieldName);
            var fieldType = this.getFieldType(fieldNameToDescribe, fieldName);
            var fieldLabel = fieldNameToDescribe[fieldName]['Label'];

            var inputJSON = {
                "disabled" : rowDisabled
            };

            var componentType = "lightning:inputField";
            if(fieldType == 'BOOLEAN') {
                // For some reason, Checkbox inputFields don't get their values set correctly
                componentType = "lightning:input";
                inputJSON["checked"] = fieldRecordValueRef;
                inputJSON["label"] = fieldLabel;
                inputJSON["type"] = "checkbox";
            } else if(fieldType == 'TIME') {
                // Time fields are not supported by lightning:inputField as of Summer '19
                componentType = "lightning:input";
                inputJSON["label"] = fieldLabel;
                inputJSON["type"] = "time";
                inputJSON["value"] = fieldRecordValueRef;
            } else {
                inputJSON["fieldName"] = fieldName;
                inputJSON["value"] = fieldRecordValueRef;
            }

            var medDeviceSize = "3";
            var wideFields = ['TEXTAREA', 'MULTIPICKLIST', 'DATETIME'];
            if(wideFields.indexOf(fieldType) > -1) {
                // Some field types look better with some more space
                medDeviceSize = "6";
            }

            var layoutItem = ["lightning:layoutItem", {
                "padding" : "horizontal-small",
                "class": "slds-p-bottom_small",
                "size": "6",
                "mediumDeviceSize": medDeviceSize
            }];

            var inputField = [componentType, inputJSON];

            componentList.push(layoutItem);

            // Keep track of the index of layout items. 
            // So we know which items are layout items instead of inputfields. 
            layoutItemIndexList.push(componentList.length - 1);

            componentList.push(inputField);
        }

        $A.createComponents(componentList, function(createdComponentsList, status, errorMessage) {
            if (status == "SUCCESS") {
                var body = component.get("v.body");
                var layoutItem; 

                // Go through the created component list and process them
                // Set the input fields into the body of the layout items
                for (var i = 0; i < createdComponentsList.length; i++) {
                    var thisCmp = createdComponentsList[i];
                    if (layoutItemIndexList.includes(i)) {
                        layoutItem = thisCmp;
                    } else {
                        var inputField = thisCmp;
                        layoutItem.set("v.body", inputField);
                        // The new layoutItem now has its input, push it to the component body
                        body.push(layoutItem);
                    }
                }

                // Put everything into the body.
                component.set("v.body", body);
            } else if (status == "INCOMPLETE") {
                this.showErrorToast(errorMessage, 'Error')
            } else if (status == "ERROR") {
                // console.log('error here');
                // console.log(errorMessage);
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
        // Check to see if the sobject Record is empty or not. 
        // If it is empty, that means that an existing record was not passed in
        // If that is the case, give it an sobject type
        // Afterwards, update the display Section boolean 
        var sobjectRecord = component.get('v.sobjectRecord');
        var sobjectType = component.get('v.objectName');

        if ($A.util.isEmpty(sobjectRecord)) {
            component.set('v.sobjectRecord.sobjectType', sobjectType);
        }

        var objectNameToSobject = component.get('v.objectNameToSobject');

        var sobjectList = objectNameToSobject[sobjectType] || [];
        sobjectList.push(sobjectRecord);
        component.set('v.objectNameToSobject', sobjectList);

        var controllingField = component.get('v.controllingField');
        var picklistValue = component.get('v.pickListValue');

        var fieldList = component.get('v.fieldList');
        var fieldNameToFieldLabel = component.get('v.fieldNameToFieldLabel')

        var customMetadataJSON = this.createAllInputs(component, controllingField, 
            picklistValue, fieldList, fieldNameToFieldLabel );

        this.handleSobjectChange(component, sobjectRecord, controllingField, picklistValue, fieldNameToFieldLabel);
    },
    handleSobjectChange: function(component, sobjectRecord, controllingField, picklistValue, fieldNameToFieldLabel) {
        // We set the display section to true if the sobject record's selected picklist value
        // is the same as the picklist value this section is for.
        // If it is not the same picklist value, we hide the section because these fields should not be shown
        // for the selected picklist value
        var sobjectRecordSelectedPicklistValue = sobjectRecord[controllingField];

        var currentChoice = component.get("v.currentChoice");
        // Only run this when the controlling picklist field changes
        if(sobjectRecordSelectedPicklistValue == currentChoice){
            return;
        } else {
            component.set("v.currentChoice", sobjectRecordSelectedPicklistValue);
        }

        var fieldNameToDescribe = this.proxyToObj(fieldNameToFieldLabel);

        if (sobjectRecordSelectedPicklistValue != null && sobjectRecordSelectedPicklistValue != undefined) {
            if (sobjectRecordSelectedPicklistValue == picklistValue) {
                component.set('v.displaySection', true);
            } else {
                this.clearFieldsAndHideSection(component, sobjectRecord, fieldNameToDescribe);
            }
        } else {
            this.clearFieldsAndHideSection(component, sobjectRecord, fieldNameToDescribe);
        }
        
    },
    clearFieldsAndHideSection: function(component, sobjectRecord, fieldNameToDescribe){
        component.set('v.displaySection', false);
        
        // If loading sections for the first time, don't clear fields, since there could be existing data
        if(component.get('v.loadingData')){
            return;
        }

        var fieldList = component.get('v.fieldList');        
        for(var i in fieldList){
            var fieldName = fieldList[i];
            var fieldType = this.getFieldType(fieldNameToDescribe, fieldName);
            // To handle checkbox fields, which have to be true or false
            if(fieldType === 'BOOLEAN'){
                sobjectRecord[fieldName] = false;
            } else {
                sobjectRecord[fieldName] = null;
            }
        }
    },
    getFieldType: function(fieldNameToDescribe, fieldName){
        return fieldNameToDescribe[fieldName]['Type'];
    },
    proxyToObj: function(attr){
        // Used to convert a Proxy object to an actual Javascript object
        return JSON.parse(JSON.stringify(attr));
    }
})
