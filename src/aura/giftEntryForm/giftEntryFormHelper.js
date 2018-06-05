({
    setPicklists: function(component) {
        var action = component.get("c.getPickListValues");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var picklistOptions = response.getReturnValue();
                // console.log("Picklist options:");
                // console.log(picklistOptions);

                this.setupPicklist(component, "paymentMethodField", "v.selectedPaymentMethod", 
                    "v.paymentMethods", picklistOptions.npe01__Payment_Method__c);
                this.setupPicklist(component, "stageField", "v.selectedStage", "v.donationStages",
                    picklistOptions.StageName);
                this.setupPicklist(component, "matchingGiftStatusField", "v.matchingGiftStatus", 
                    "v.matchingGiftStatuses", picklistOptions.npsp__Matching_Gift_Status__c);
                this.setupPicklist(component, "ackPrefStatusField", "v.ackPrefStatus", 
                    "v.ackPrefStatuses", picklistOptions.npsp__Acknowledgment_Status__c);

            } else if (state === "ERROR") {
                this.handleError(component, response);
            }
        });

        $A.enqueueAction(action);
    },
    setupPicklist: function(component, fieldId, selectedVal, optionListVal, optionListReturned){
        // Add a "none" option to the start of every picklist
        var noneOption = component.get("v.picklistNoneText");
        optionListReturned.unshift(noneOption);
        component.set(optionListVal, optionListReturned);
        this.setStartingPicklistValue(component, fieldId, selectedVal, optionListReturned[0]);
    },
    setStartingPicklistValue: function(component, fieldId, selectVal, defaultVal){
        var field = component.find(fieldId);
        if(!field){
            var errorMsg = 'Picklist ' + fieldId + ' was not found';
            this.setErrorMessage(component, errorMsg);
            return;
        }
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
    updateAmountField: function(component, amt){
        component.set("v.donationAmount", amt);
    },
    redirectToDonation: function(component){
        var oppId = component.get("v.oppId");

        if(!oppId){
            var recordId = component.get('v.returnedRecordId');
            var redirectAfter = true;
            this.getImportedDonationId(component, recordId, redirectAfter);
        } else {
            var event = $A.get("e.force:navigateToSObject");
            event.setParams({
                recordId: oppId
            });
            event.fire();
        }
    },
    getImportedDonationId: function(component, dataImportObjId, redirectAfter){
        var action = component.get("c.getOpportunityIdFromImport");
        action.setParams({
            diObjId: dataImportObjId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var oppId = response.getReturnValue();
                component.set("v.oppId", oppId);
                //console.log("New opp ID: " + oppId);
                if(redirectAfter){
                    this.redirectToDonation(component);
                }
            } else if (state === "ERROR") {
                this.handleError(component, response);
            }
        });

        $A.enqueueAction(action);
    },
    processGift: function(component, dataImportObjId, dryRun) {
        component.set("v.showSpinner", true);

        // Now run the batch for this single gift
        var action = component.get("c.runGiftProcess");
        action.setParams({
            diObjId: dataImportObjId,
            dryRunMode: dryRun
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.scrollToTop();
                // Navigate to Opportunity page
                if(!dryRun){
                    this.redirectToDonation(component, dataImportObjId);
                } else {
                    // If dry run, show the results of data matching
                    component.set("v.showForm", false);
                    component.set("v.showSuccess", true);
                    component.set("v.showSpinner", false);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                this.handleError(component, response);
            }
        });

        $A.enqueueAction(action);        
    },
    checkValidation: function(component){
        var formValid = this.validateForm(component);
        var btn = component.find('createButton');
        btn.set('v.disabled',!formValid);
    },
    validateForm: function(component) {
        component.set("v.error", null);
        var validForm = true;
        // Show error messages if required fields are blank
        validForm = component.find('requiredField').reduce(function (validSoFar, inputCmp) {
            var disabled = inputCmp.get("v.disabled");
            if(disabled){
                return validSoFar;
            }
            // Displays error messages for invalid fields
            //inputCmp.showHelpMessageIfInvalid();
            var fieldVal = inputCmp.get("v.value");
            var isValid = fieldVal || fieldVal === false;
            return validSoFar && isValid;
        }, true);

        return validForm;
    },
    handleError: function(component, response) {
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                var errorMsg = errors[0].message;
                this.setErrorMessage(component, errorMsg);
            }
        } else {
            this.setErrorMessage(component, "Unknown error");
        }
    },
    fillJsonField: function(component) {
        var relatedCmp = component.find("formWrapper").find({instancesOf:"c:giftFormRelated"});
        var allRowsValid = true;

        for(var i=0; i < relatedCmp.length; i++){
            var jsonResp = relatedCmp[i].handleJsonUpdate();
            allRowsValid = allRowsValid && jsonResp;
        }

        // Need to prevent overwrite by undefined related objects!
        var jsonField = component.find("postProcessJsonField");
        var jsonObj = component.get("v.jsonObject");
        //console.log("All rows valid: " + allRowsValid); 
        if(jsonObj.npe01__OppPayment__c && jsonObj.npe01__OppPayment__c.length > 0){
            // Payments are being scheduled, do not create one for the full donation
            var autoPaymentField = component.find('doNotAutoCreatePayment');
            if(autoPaymentField){
                autoPaymentField.set("v.value", true);
            }
        }
        jsonObj = JSON.stringify(jsonObj);
        console.log(jsonObj);
        jsonField.set("v.value", jsonObj);
        return allRowsValid;
    },
    scrollToTop: function(){
        window.scrollTo(0, 0);
    },
    setErrorMessage: function(component, errorMsg){
        component.set("v.error", errorMsg);
    }
})