({
    setDefaults: function (component) {
        //this.setHiddenField(component, 'donationDonorField', 'Contact1');
    },
    setPicklists: function(component) {
        var action = component.get("c.getPickListValues");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var picklistOptions = response.getReturnValue();
                console.log("Picklist options:");
                console.log(picklistOptions);
                
                component.set("v.paymentMethods", picklistOptions.paymentMethods);
                this.setStartingPicklistValue(component, "paymentMethodField", "v.selectedPaymentMethod", 
                    picklistOptions.paymentMethods[0]);

                component.set("v.donationStages", picklistOptions.donationStages);
                this.setStartingPicklistValue(component, "stageField", "v.selectedStage", 
                    picklistOptions.donationStages[0]);

            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = errors[0].message;
                        component.set("v.error", errorMsg);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    setStartingPicklistValue: function(component, fieldId, selectVal, defaultVal){
        var field = component.find(fieldId);
        var curValue = field.get("v.value");
        if(!curValue){
            // This will make sure the actual field value matches the picklist, in case
            // the user never changes the picklist
            component.set(selectVal, defaultVal);
        } else {
            component.set(selectVal, curValue);
        }
    },
    setHiddenField: function(component, fieldId, newVal){
        var field = component.find(fieldId);
        if(field){
            field.set("v.value", newVal);
        }
    },
    redirectToDonation: function(component, dataImportObjId){
        var action = component.get("c.getOpportunityIdFromImport");
        action.setParams({
            diObjId: dataImportObjId
        });

        action.setCallback(this, function(response) {
            //console.log(response);
            var state = response.getState();
            if (state === "SUCCESS") {
                var oppId = response.getReturnValue();
                //console.log("New opp ID: " + oppId);

                var event = $A.get('e.force:navigateToSObject');
                event.setParams({
                    recordId: oppId
                });
                event.fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = errors[0].message;
                        console.log("Error message: " + errorMsg);
                        component.set("v.error", errorMsg);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },
    processGift: function(component, dataImportObjId) {
        //console.log(dataImportObjId);

        // Now run the batch for this single gift
        var action = component.get("c.runGiftProcess");
        action.setParams({
            diObjId: dataImportObjId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Navigate to Opportunity page
                //this.redirectToDonation(component, dataImportObjId);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = errors[0].message;
                        console.log("Error message: " + errorMsg);
                        component.set("v.error", errorMsg);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
 
        component.set("v.showForm", false);
        component.set("v.showSuccess", true);
        component.set("v.showSpinner", false);
        
    },
    validateForm: function(component) {
        component.set("v.error", null);
        var validForm = true;
        // Show error messages if required fields are blank
        validForm = component.find('requiredField').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            //inputCmp.showHelpMessageIfInvalid();

            if(!inputCmp){ 
                return false;
            }
            var fieldVal = inputCmp.get("v.value");
            var isValid = fieldVal != undefined;
            //var isValid = inputCmp.get('v.validity').valid;
            
            return validSoFar && isValid;
        }, true);

        return validForm;
    }
})