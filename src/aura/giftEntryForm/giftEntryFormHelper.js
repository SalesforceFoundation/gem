({
    getDonationInformation: function(component, helper, oppId){
        // Make changes if a recordId was provided (Edit mode)
        if(oppId){
            this.changeSubmitText(component, $A.get("$Label.c.Gift_Update"));
            component.set('v.editMode', true);
        }

        var getModelAction = component.get("c.initClass");
        getModelAction.setParams({
            oppId: oppId
        });
        getModelAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var giftModel = response.getReturnValue();
                
                console.log('From init'); 
                console.log(giftModel); 

                component.set("v.giftModel", giftModel);

                if(giftModel.opp){
                    component.set("v.opp", giftModel.opp);
                }
                if(giftModel.acct){
                    component.set("v.acct", giftModel.acct);
                    // Make sure the lookup field UI gets updated
                    var selectedObject = this.proxyToObj(giftModel.acct);
                    helper.updateLookupUI(component, 'accountLookup', 'Account', selectedObject);
                }
                if(giftModel.contact){
                    component.set("v.contact", giftModel.contact);
                    // Make sure the lookup field UI gets updated
                    var selectedObject = this.proxyToObj(giftModel.contact);
                    helper.updateLookupUI(component, 'contactLookup', 'Contact', selectedObject);
                }
                if(giftModel.payments){
                    component.set("v.payments", giftModel.payments);
                }
                if(giftModel.allocs){
                    component.set("v.allocs", giftModel.allocs);
                }
                if(giftModel.partialCredits){
                    component.set("v.partialCredits", giftModel.partialCredits);
                }

                component.set("v.objectFieldData.objectLabels", giftModel.objNameToApiToLabel);
                helper.handlePicklistSetup(component, giftModel.picklistValues);

                // Setup any default form values
                helper.setDefaults(component, helper, giftModel.opp);
                helper.checkValidation(component);

            } else if (state === "ERROR") {
                helper.handleError(component, response);
            }
        });
        $A.enqueueAction(getModelAction);
    },
    setDefaults: function(component, helper, opp){
        // If Updating and Stage is set to Closed, disable Donation fields
        // var stageField = component.find("stageField");
        // if(stageField){
        //     var stage = stageField.get("v.value");
        //     // TODO: Query this instead
        //     var closedStage = component.get("v.closedStage");
        //     var oppClosed = stage == closedStage ? true : false;
        //     component.set("v.oppClosed", oppClosed);
        // }

        // For new forms, set Date to Today, otherwise use existing value
        var curDate = component.get("v.di.npsp__Donation_Date__c");
        if(!curDate){
            // Set Close Date to Today
            var closeDate = new Date();
            closeDate = this.convertDateToString(closeDate);
            component.set("v.di.npsp__Donation_Date__c", closeDate);
        }

        // Also check whether the Contact or Account information should be shown
        if(opp && opp.AccountId && !opp.npsp__Primary_Contact__c){
            component.set("v.di.npsp__Donation_Donor__c", 'Account1');
        } else {
            component.set("v.di.npsp__Donation_Donor__c", 'Contact1');
        }

        //this.setPicklists(component, helper);
    },
    handlePicklistSetup: function(component, picklistOptions, helper){
        // var picklistOptions = response.getReturnValue();
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
        //component.set("v.picklistOptions", picklistOptions);
        component.set("v.objectFieldData.picklistOptions", picklistOptions);

        // Check to see if values were already set for picklists
        //helper.setupPicklistValues(component, helper);
    },
    // setupPicklistValues: function(component, helper){
    //     var namespacePrefix = component.get("v.namespacePrefix");
    //     var picklistCmp = component.find("formWrapper").find({instancesOf:namespacePrefix+":giftPicklist"});
    //     // For each picklist, check for existing field values, otherwise set the first option
    //     for(var i=0; i < picklistCmp.length; i++){
    //         helper.setStartingPicklistValue(component, picklistCmp[i]);
    //     }
    // },
    // setStartingPicklistValue: function(component, picklistCmp){
    //     var fieldId = picklistCmp.get("v.inputFieldId");
    //     // For nested picklist components (e.g. Payment Method in the Scheduler),
    //     // we will not find it in the current component, so just return
    //     var field = component.find(fieldId);
    //     if(!field){
    //         //var errorMsg = 'Picklist ' + fieldId + ' was not found';
    //         //this.setErrorMessage(component, errorMsg);
    //         //console.log(errorMsg); 
    //         return;
    //     }

    //     var curValue = field.get("v.value");
    //     // If a value does not exist, set the picklist to the first option
    //     if(!curValue){
    //         var options = this.proxyToObj(picklistCmp.get("v.picklistValues"));
    //         curValue = options[0].value;
    //         this.setHiddenField(component, fieldId, curValue);
    //     }
    //     //console.log(curValue); 
    //     picklistCmp.set("v.selectedVal", curValue);

    //     // Allow the picklist change event to fire
    //     // Without this, the default picklist value overwrites existing object values
    //     picklistCmp.set("v.callEvent", true);
    // },
    setHiddenField: function(component, fieldId, newVal){
        var field = component.find(fieldId);
        if(field){
            field.set("v.value", newVal);
        }
    },
    redirectToDonation: function(component, objId){
        console.log('Redirect to:'); 
        console.log(objId); 
        var event = $A.get("e.force:navigateToSObject");
        event.setParams({
            recordId: objId
        });
        event.fire();
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
                    this.redirectToDonation(component, oppId);
                }
            } else if (state === "ERROR") {
                this.handleError(component, response);
            }
        });

        $A.enqueueAction(action);
    },
    processGiftJson: function(component, checkDataMatches) {
        
        var action;
        if(checkDataMatches){
            component.set("v.showMatchSpinner", true);
            action = component.get("c.returnDataMatches");
        } else {
            component.set("v.showSpinner", true);
            action = component.get("c.saveGift");
        }
        
        // var jsonString = component.get("v.jsonObjectString");
        var giftModelString = component.get("v.giftModelString");
        // console.log(giftModelString); 

        action.setParams({
            giftModelString: giftModelString
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var giftModel = response.getReturnValue();
                
                console.log("Gift Model about to be overwritten by processGiftJSON"); 
                console.log(giftModel); 

                component.set("v.giftModel", giftModel);
                var oppId = component.find("oppId").get("v.value");

                if(checkDataMatches){
                    // After a lookup change, we have to query the fields and update
                    // the UI to reflect that change
                    // if(giftModel.contact){
                    //     console.log(" *** Overwrite contact fields"); 
                    //     component.set("v.contact", giftModel.contact);
                    // }
                    // if(giftModel.acct){
                    //     console.log(" *** Overwrite account fields");
                    //     component.set("v.acct", giftModel.acct);
                    // }

                    component.set('v.showSpinner', false);
                    component.set("v.showMatchSpinner", false);
                } else {
                    this.redirectToDonation(component, oppId);
                }
            } else if (state === "ERROR") {
                this.handleError(component, response);
            }
        });

        $A.enqueueAction(action);
    },
    // processGift: function(component, dataImportObjId, dryRun) {
    //     // No longer used in Single Gift Entry, could be useful for Batch Gift Entry
    //     component.set("v.showSpinner", true);

    //     // Now run the batch for this single gift
    //     var action = component.get("c.runGiftProcess");
    //     action.setParams({
    //         diObjId: dataImportObjId,
    //         dryRunMode: dryRun
    //     });

    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             this.scrollToTop();
    //             // Navigate to Opportunity page
    //             if(!dryRun){
    //                 this.redirectToDonation(component, dataImportObjId);
    //             } else {
    //                 // If dry run, show the results of data matching
    //                 component.set("v.showForm", false);
    //                 component.set("v.showSuccess", true);
    //                 component.set("v.showSpinner", false);
    //             }
    //         } else if (state === "ERROR") {
    //             this.handleError(component, response);
    //         }
    //     });

    //     $A.enqueueAction(action);        
    // },
    checkValidation: function(component){
        var formValid = this.validateForm(component);
        // var btn = component.find('createButton');
        // btn.set('v.disabled',!formValid);
    },
    validateForm: function(component, showErrors) {
        component.set("v.error", null);
        // Show error messages if required fields are blank
        var validForm = this.checkFields(component, 'requiredField', true, showErrors);
        
        // Check that at least one combination of donor fields is valid, otherwise show error
        // First check if an Account field is filled in
        var donorType = component.get("v.di.npsp__Donation_Donor__c");
        var donorExists = false;

        if(donorType == "Account1" || !donorType){
            // donorExists = donorExists || this.checkFields(component, 'requiredAccountField', false);
            donorExists = donorExists || this.checkFields(component, 'accountLookup', true);
        }
        if(donorType == "Contact1" || !donorType) {
            // Check if Contact1 Firstname and Lastname are filled in
            // donorExists = donorExists || this.checkFields(component, 'requiredContactField', true);
            // Check any other donor fields we could use
            donorExists = donorExists || this.checkFields(component, 'contactLookup', true);
        }

        component.set("v.donorExists", donorExists);

        if(!donorExists){
            // Show error if no Donor has been entered
            if(showErrors){
                this.showErrorMessage(component, $A.get("$Label.c.Gift_Donor_Required"), true);
            }
            return false;
        } else {
            // Clear the error
            this.showErrorMessage(component, "", false);            
        }

        return validForm;
    },
    showErrorMessage: function(component, errorMsg, msgIsError){
        component.set("v.messageIsError", msgIsError);
        component.set("v.showSpinner", false);
        component.set("v.submitError", errorMsg);
    },
    checkFields: function(component, fieldId, allMustBeValid, showErrors){
        var findResult = component.find(fieldId); 
        if(!findResult){
            return allMustBeValid;
        }
        findResult = this.singleInputToArray(findResult);
        var validationResult = findResult.reduce(function (validSoFar, inputCmp) {
            // lightning:inputField can use reportValidity
            //TODO: How to check force:inputField for disabled?
            // var disabled = inputCmp.get("v.disabled");
            // if(disabled){
            //     return validSoFar;
            // }
            var fieldVal = inputCmp.get("v.value");
            // if(fieldId == 'accountLookup'){
            //     console.log(fieldVal); 
            // }
            var isValid = fieldVal || fieldVal === false;
            if(showErrors && typeof inputCmp.reportValidity === "function"){
                var validMsg = inputCmp.reportValidity();
                // console.log(validMsg); 
            }
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
        var relatedCmp = this.getRelatedComponents(component);
        var allRowsValid = true;

        // First process the related objects
        for(var i=0; i < relatedCmp.length; i++){
            // Need to get variable name for each of these to know where to map the return
            var jsonResp = relatedCmp[i].handleJsonUpdate();
            allRowsValid = allRowsValid && jsonResp;
        }

        var giftModel = component.get("v.giftModel");

        // Now set the "primary" gift field
        var di = this.proxyToObj(component.get("v.di"));
        // var acct = this.proxyToObj(component.get("v.acct"));
        // var contact = this.proxyToObj(component.get("v.contact"));
        // var opp = this.proxyToObj(component.get("v.opp"));
        
        // console.log(' *** opp'); 
        // console.log(opp); 
        
        var objsToDelete = this.proxyToObj(component.get("v.objsToDelete"));
        giftModel['di'] = di;
        // giftModel['acct'] = acct;
        // giftModel['contact'] = contact;
        // giftModel['opp'] = opp;
        giftModel['objsToDelete'] = objsToDelete;

        // Clear unneeded variables
        giftModel['objNameToApiToLabel'] = {};
        giftModel['picklistValues'] = {};

        // console.log("Gift Model about to be overwritten by fillJsonField"); 
        // component.set("v.jsonObj", jsonObj);
        // component.set("v.giftModel", giftModel);

        if(giftModel.payments && giftModel.payments.length > 0){
            // Payments are being scheduled, do not create one for the full donation
            giftModel['di'].Do_Not_Automatically_Create_Payment__c = true;
        }

        var giftModelString = JSON.stringify(giftModel);
        console.log(giftModelString);

        // component.set("v.jsonObjectString", jsonObjString);
        component.set("v.giftModelString", giftModelString);
        return allRowsValid;
    },
    setLookupField: function(component, objectType, selectedObject, inputAuraId, oppLookupField){
        var newId = null;
        //console.log(selectedObject);
        if(selectedObject){
            selectedObject = this.proxyToObj(selectedObject);
            newId = selectedObject.Id;
        }

        console.log("setLookupField for: " + objectType); 

        if(objectType == 'Opportunity'){
            // component.set("v.opp", null);
            // component.set("v.opp", selectedObject);
            // Instead of filling every field, just redirect to that Opportunity?
            // this.redirectToDonation(component, newId);
            var relatedCmp = this.getRelatedComponents(component);
            for(var i=0; i < relatedCmp.length; i++){
                relatedCmp[i].set("v.initFinished", false);
            }
            this.getDonationInformation(component, this, newId);
            return;

        } else if(objectType == 'Account'){
            component.set("v.acct", null);
            component.set("v.acct", selectedObject);
        } else if(objectType == 'Contact'){
            // component.set("v.contact", null);
            component.set("v.contact.Email", null);
            component.set("v.contact.Phone", null);
            component.set("v.contact", selectedObject);
            // Value updates, but UI does not
            // var contact = this.proxyToObj(component.get("v.contact"));
            // console.log(contact); 
            this.updateInputUI(component);
        }

        var oppObj = component.get("v.opp");
        oppObj = this.proxyToObj(oppObj);
        if(oppLookupField){
            oppObj[oppLookupField] = newId;
            component.set("v.opp", oppObj);
        }
		
		if(inputAuraId){
            this.updateLookupUI(component, inputAuraId, objectType, selectedObject);
        }
    },
    updateLookupUI: function(component, inputAuraId, objectType, selectedObject){
        var newValue = [{}];
        // If updating a lookup field, make sure the UI reflects the change
        newValue[0] = {
            id: selectedObject.Id,
            type: objectType,
            label: selectedObject.Name
        };
        // console.log(newValue); 
        this.setLookupValue(component, inputAuraId, newValue);
    },
    setLookupValue: function(component, inputAuraId, newValue){
        var field = component.find(inputAuraId);
        if(field){
            // this.updateFieldUI(field);
            var lookupInput = field.get("v.body")[0];
            if(lookupInput){
                lookupInput.updateValues();
                lookupInput.set("v.values", this.proxyToObj(newValue));
            }
        }
    },
    setPaymentPaid: function(component, paymentId){
        component.set("v.showSpinner", true);
        var action = component.get("c.markPaymentPaid");
        action.setParams({
            paymentId: paymentId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var wasPaymentUpdated = response.getReturnValue();
                if(wasPaymentUpdated){
                    component.set("v.payment.Id", null);
                    this.checkMatches(component);
                }
                component.set("v.showSpinner", false);
            } else if (state === "ERROR") {
                helper.handleError(component, response);
            }
        });
        $A.enqueueAction(action);
    },
    checkMatches: function(component, objToMatch){
        var isEditMode = component.get("v.editMode");
        var matchListCmps = this.getMatchListComponents(component);
        console.log("Check matches for: " + objToMatch); 

        for(var i=0; i<matchListCmps.length; i++){
            var thisCmp = matchListCmps[i];
            var objType = thisCmp.get("v.objectType");
            // console.log('isEditMode: ' + isEditMode); 

            // Don't fire the change event if we aren't checking matches for this object
            if( (objToMatch && objType != objToMatch) || isEditMode){
                thisCmp.set("v.enableChangeEvent", false);
            }
        }

        this.fillJsonField(component);
        this.processGiftJson(component, true);
    },
    getRelatedComponents: function(component){
        var namespace = component.get("v.namespacePrefix");
        var rowCmpName = namespace + ":giftFormRelated";
        var formWrapper = component.find("formWrapper");
        return formWrapper.find({instancesOf:rowCmpName});
    },
    getMatchListComponents: function(component){
        var namespace = component.get("v.namespacePrefix");
        var rowCmpName = namespace + ":giftFormMatchList";
        var formWrapper = component.find("formWrapper");
        return formWrapper.find({instancesOf:rowCmpName});
    },
    getAllForceInputs: function(component){
        var formWrapper = component.find("formWrapper");
        return formWrapper.find({instancesOf:"force:inputField"});
    },
    updateInputUI: function(component){
        var inputArray = this.getAllForceInputs(component);
        for(var i=0; i<inputArray.length; i++){
            var field = inputArray[i];
            this.updateFieldUI(field);
        }
        // Refreshes the whole page
        //$A.get('e.force:refreshView').fire();
    },
    scrollToTop: function(){
        window.scrollTo(0, 0);
    },
    updateFieldUI: function(field){
        var inputBody = field.get("v.body")[0];
        // console.log(inputBody); 
        if(inputBody.updateValues){
            inputBody.updateValues();
        }
    },
    clearInputs: function(component, fieldId){
        var findResult = component.find(fieldId);
        findResult = this.singleInputToArray(findResult);
        for(var i in findResult){
            findResult[i].set("v.value", '');
            this.updateFieldUI(findResult[i]);
        }
    },
    setErrorMessage: function(component, errorMsg){
        component.set("v.error", errorMsg);
    },
    convertDateToString: function(dateObj){
		return dateObj.toISOString().split('T')[0];
    },
    proxyToObj: function(attr){
        if(!attr){
            return null;
        }
        // Used to convert a Proxy object to an actual Javascript object
        return JSON.parse(JSON.stringify(attr));
    },
    changeSubmitText: function(component, newText){
        component.find('createButton').set('v.label', newText);
    },
    doToggleSection: function changeState (component, sectionBool){
        component.set('v.' + sectionBool, !component.get('v.' + sectionBool));
    }
})