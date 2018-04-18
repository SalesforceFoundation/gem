({
    setDefaults: function (component) {
        component.find("donationDonorField").set("v.value", "Contact1");
    },
    setPicklists: function(component) {
        // TODO: Get these from object describes
        var paymentOptions = ['--None--','Credit','Cash','Check','Credit Card'];
        component.set("v.paymentMethods", paymentOptions);
    },
    submitForm: function(component, helper) {
        component.find("giftData").saveRecord(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                component.set("v.error", "Success, now redirecting to new Gift");
                console.log("Record Saved:");
                console.log(saveResult.recordId);
                // Now, run the gift creation process
                helper.processGift(component, saveResult.recordId);
            }
            else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            }
            else if (saveResult.state === "ERROR") {
                console.log('Problem saving gift, error: ' +
                                JSON.stringify(saveResult.error));
            }
            else {
                console.log('Unknown problem, state: ' + saveResult.state +
                            ', error: ' + JSON.stringify(saveResult.error));
            }
        });
    },
    processGift: function(component, dataImportObjId) {
        console.log(dataImportObjId);

        // Now run the batch for this single gift
        var action = component.get("c.runGiftProcess");
        action.setParams({
            diObjId: dataImportObjId
        });

        action.setCallback(this, function(response) {
            console.log(response);
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showForm", false);
                component.set("v.showSpinner", false);
                component.set("v.showSuccess", true);
                console.log("return value: " + response.getReturnValue());

                // Navigate to Opportunity page
                // TODO: Query the Opportunity ID from the Data Import object?
                var event = $A.get('e.force:navigateToObjectHome');
                event.setParams({
                    scope: 'Opportunity',
                    resetHistory: true
                });
                event.fire();
            }
            else if (state === "INCOMPLETE") {

            }
            else if (state === "ERROR") {
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
    validateForm: function(component) {
        component.set("v.error", null);
        var validForm = true;
        // Show error messages if required fields are blank
        validForm = component.find('giftField').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();

            var fieldVal = inputCmp.get("v.value");
            var isValid = inputCmp.get('v.validity').valid;
            
            return validSoFar && fieldVal;
        }, true);
        
        // Other steps to validation? Check objects?
        return validForm;
    }

})