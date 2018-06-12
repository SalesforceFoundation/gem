({
    setDefaults: function(component, helper){
        // If Updating and Stage is set to Closed, disable Donation fields
        var stageField = component.find("stageField");
        if(stageField){
            var stage = stageField.get("v.value");
            var closedStage = component.get("v.closedStage");
            var oppClosed = stage == closedStage ? true : false;
            component.set("v.oppClosed", oppClosed);
        }

        // For new forms, set Date to Today, otherwise use existing value
        var dateField = component.find("dateField");
        if(dateField){
            var closeDate = dateField.get("v.value");
            if(!closeDate){
                // Set Close Date to Today
                closeDate = new Date();
                closeDate = this.convertDateToString(closeDate);
            }
            component.set("v.paymentDate", closeDate);            
        }

        this.setPicklists(component, helper);
    },
    setPicklists: function(component, helper) {
        var action = component.get("c.getPickListValues");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Return value is a map of string arrays for our picklists
                var picklistOptions = response.getReturnValue();
                // Add "None" option to start of each picklist
                var noneOption = component.get("v.picklistNoneText");
                var noneObj = {value:'', label:noneOption};

                for(var field in picklistOptions){
                    var optionList = picklistOptions[field];
                    var convertedList = [];
                    convertedList.push(noneObj);
                    for(var i in optionList){
                        // The values come into Javascript as JSON strings, need to parse
                        var option = JSON.parse(optionList[i]);
                        convertedList.push(option);
                    }
                    picklistOptions[field] = convertedList;
                }
                // Setting this map will update all of the picklists
                component.set("v.picklistOptions", picklistOptions);

                // Check to see if values were already set for picklists
                helper.setupPicklistValues(component, helper);
            } else if (state === "ERROR") {
                this.handleError(component, response);
            }
        });

        $A.enqueueAction(action);
    },
    setupPicklistValues: function(component, helper){
        var picklistCmp = component.find("formWrapper").find({instancesOf:"c:giftPicklist"});
        // For each picklist, check for existing field values, otherwise set the first option
        for(var i=0; i < picklistCmp.length; i++){
            helper.setStartingPicklistValue(component, picklistCmp[i]);
        }
    },
    setStartingPicklistValue: function(component, picklistCmp){
        var fieldId = picklistCmp.get("v.inputFieldId");
        var field = component.find(fieldId);
        if(!field){
            var errorMsg = 'Picklist ' + fieldId + ' was not found';
            this.setErrorMessage(component, errorMsg);
            return;
        }

        var curValue = field.get("v.value");
        // If a value does not exist, set the picklist to the first option
        if(!curValue){
            var options = this.proxyToObj(picklistCmp.get("v.picklistValues"));
            curValue = options[0].value;
            this.setHiddenField(component, fieldId, curValue);
        }
        //console.log(curValue); 
        picklistCmp.set("v.selectedVal", curValue);

        // Allow the picklist change event to fire
        // Without this, the default picklist value overwrites existing object values
        picklistCmp.set("v.callEvent", true);
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
        // Show error messages if required fields are blank
        var validForm = this.checkFields(component, 'requiredField', true);
        
        // Check that at least one combination of donor fields is valid, otherwise show error
        // First check if an Account field is filled in
        var donorType = component.get("v.donorType");
        var donorExists = false;
        if(donorType == "Account1"){
            donorExists = this.checkFields(component, 'requiredAccountField', false);
        } else {
            // Check if Contact1 Firstname and Lastname are filled in
            donorExists = this.checkFields(component, 'requiredContactField', true);        
            // Check any other donor fields we could use
            donorExists = donorExists || this.checkFields(component, 'requiredDonorField', false);
        }

        if(!donorExists){
            // Show error if no Donors have been entered
            component.set("v.submitError", "Donor information is required.");
            return false;
        } else {
            component.set("v.submitError", "");
        }

        return validForm;
    },
    checkFields: function(component, fieldId, allMustBeValid){
        var findResult = component.find(fieldId); 
        if(!findResult){
            return allMustBeValid;
        }
        findResult = this.singleInputToArray(findResult);
        var validationResult = findResult.reduce(function (validSoFar, inputCmp) {
            var disabled = inputCmp.get("v.disabled");
            if(disabled){
                return validSoFar;
            }
            var fieldVal = inputCmp.get("v.value");
            var isValid = fieldVal || fieldVal === false;
            if(!allMustBeValid && (isValid || validSoFar)){
                // We only need one of these fields filled in
                return true;
            }
            return validSoFar && isValid;
        }, allMustBeValid);

        return validationResult;
    },
    singleInputToArray: function(findResult){
        if(findResult && !findResult.length){
            findResult = [findResult];
        }
        return findResult;
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
    clearInputs: function(component, fieldId){
        var findResult = component.find(fieldId);
        findResult = this.singleInputToArray(findResult);
        for(var i in findResult){
            var inputCmp = findResult[i].set("v.value", '');
        }
    },
    setErrorMessage: function(component, errorMsg){
        component.set("v.error", errorMsg);
    },
    convertDateToString: function(dateObj){
		return dateObj.toISOString().split('T')[0];
    },
    proxyToObj: function(attr){
        // Used to convert a Proxy object to an actual Javascript object
        return JSON.parse(JSON.stringify(attr));
    }
})