({
    setDefaults: function (component) {
        component.find("donationDonorField").set("v.value", "Contact1");
    },
    setPicklists: function(component) {
        var action = component.get("c.getPickListValues");

        action.setCallback(this, function(response) {
            //console.log(response);
            var state = response.getState();
            if (state === "SUCCESS") {
                var picklistOptions = response.getReturnValue();
                // console.log("Picklist options:");
                // console.log(picklistOptions);
                component.set("v.paymentMethods", picklistOptions.paymentMethods);
            } else if (state === "ERROR") {
                var errors = response.getError();
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
    submitForm: function(component, helper) {
        component.find("giftData").saveRecord(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // console.log("Record Saved:");
                // console.log(saveResult.recordId);
                // Now, run the gift creation process
                helper.processGift(component, saveResult.recordId);
            } else if (saveResult.state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = errors[0].message;
                        component.set("v.error", errorMsg);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log('Unknown problem, state: ' + saveResult.state +
                            ', error: ' + JSON.stringify(saveResult.error));
            }
        });
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
            //console.log(response);
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log("return value: " + response.getReturnValue());
                // Navigate to Opportunity page
                this.redirectToDonation(component, dataImportObjId);
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
        validForm = component.find('giftField').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            //inputCmp.showHelpMessageIfInvalid();

            var fieldVal = inputCmp.get("v.value");
            var isValid = inputCmp.get('v.validity').valid;
            
            return validSoFar && isValid;
        }, true);

        return validForm;
    }
})