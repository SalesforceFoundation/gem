({
    getDonationInformation: function(component, oppId){
        component.set('v.oppClosed', false);
        // Make changes if a recordId was provided (Edit mode)
        if(oppId){
            this.changeSubmitText(component, $A.get('$Label.c.Gift_Update'));
            component.set('v.editMode', true);
        } else {
            this.changeSubmitText(component, $A.get('$Label.c.Gift_Create'));
            component.set('v.editMode', false);
            this.resetForm(component);
            var bdiLabels = component.get('v.bdiLabels');
            if(bdiLabels){
                // The form has already been loaded, just return
                return;
            }
        }

        var getModelAction = component.get('c.initClass');
        getModelAction.setParams({
            oppId: oppId
        });
        getModelAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var giftModel = response.getReturnValue();
                // console.log(giftModel); 
                component.set('v.giftModel', giftModel);

                var bdiLabels = component.get('v.bdiLabels');

                // This is the initial call, set helper variables
                // If using this page to load edits directly, we may need a separate variable
                if(!bdiLabels){
                    component.set('v.bdiLabels', giftModel.bdiLabels);
                    component.set('v.objectFieldData.objectLabels', giftModel.objNameToApiToLabel);
                    component.set('v.objectFieldData.closedWonStageMap', giftModel.closedWonStageMap);
                    component.set('v.objectFieldData.diToOppFieldMap', giftModel.diToOppFieldMap);

                    this.handlePicklistSetup(component, giftModel.picklistValues);
                    // Setup any default form values
                    this.setDefaults(component, giftModel.opp);
                }

                // An Opportunity was matched, update the form to reflect that
                if(giftModel.oppId){
                    component.set('v.disableBlurEvents', true);
                    if(giftModel.opp.ForecastCategory == 'Closed' || giftModel.opp.npe01__Number_of_Payments__c){
                        component.set('v.oppClosed', true);
                    }
                    this.disablePaymentCalculateButton(component);
                    // var opp = this.proxyToObj(giftModel.opp);
                    var di = this.proxyToObj(component.get('v.di'));

                    // Update the Data Import status to user-matched
                    di[bdiLabels.opportunityImportedStatusField] = bdiLabels.userSelectedMatch;

                    // Map fields from Opportunity to DataImport
                    this.mapOppToDi(component, di, giftModel.opp);
                    component.set('v.opp', giftModel.opp);
                    this.setDiFields(component, di);

                    component.set('v.campaignId', giftModel.opp.CampaignId);
                    component.set('v.opp.npsp__Matching_Gift__c', giftModel.opp.npsp__Matching_Gift__c);

                    console.log(di);

                    // console.log(giftModel.payments); 
                    component.set('v.allocs', giftModel.allocs);
                    component.set('v.partialCredits', giftModel.partialCredits);
                    component.set('v.payments', giftModel.payments);
                    component.set('v.disableBlurEvents', false);
                }

                this.checkValidation(component);
                component.set('v.showSpinner', false);
            } else if (state === 'ERROR') {
                component.set('v.showForm', false);
                this.handleError(component, response);
                component.set('v.showSpinner', false);
            }
        });
        $A.enqueueAction(getModelAction);
    },
    resetForm: function(component){
        component.set('v.allocs', []);
        component.set('v.partialCredits', []);
        component.set('v.payments', []);
    },
    setDiFields: function(component, di){
        var val;
        var vField;
        for(var field in di){
            vField = 'v.di.' + field;
            val = di[field];
            component.set(vField, val);
        }
    },
    setDefaults: function(component, opp){
        // For new forms, set Date to Today, otherwise use existing value
        var curDate = component.get('v.di.npsp__Donation_Date__c');
        if(!curDate){
            // Set Close Date to Today
            var closeDate = new Date();
            closeDate = this.convertDateToString(closeDate);
            component.set('v.di.npsp__Donation_Date__c', closeDate);
        }

        // Also check whether the Contact or Account information should be shown
        if(opp && opp.AccountId && !opp.npsp__Primary_Contact__c){
            component.set('v.di.npsp__Donation_Donor__c', 'Account1');
        } else {
            component.set('v.di.npsp__Donation_Donor__c', 'Contact1');
        }
    },
    handlePicklistSetup: function(component, picklistOptions){
        // Add 'None' option to start of each picklist
        var noneOption = component.get('v.picklistNoneText');
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
        component.set('v.objectFieldData.picklistOptions', picklistOptions);
    },
    handlePicklistChange: function(component, message){
        var newVal = message['newVal'];
        var fieldId = message['fieldId'];
        if(fieldId){
            this.setHiddenField(component, fieldId, newVal);
        }
    },
    setHiddenField: function(component, fieldId, newVal){
        var field = component.find(fieldId);
        if(field){
            field.set('v.value', newVal);
        }
    },
    redirectToSobject: function(component, objId){
        var event = $A.get('e.force:navigateToSObject');
        event.setParams({
            recordId: objId
        });
        event.fire();
    },
    showEditRecordModal: function(component, objId){
        var event = $A.get('e.force:editRecord');
        event.setParams({
            recordId: objId
        });
        event.fire();
    },
    handleSaveGift: function(component){
        component.set('v.showSpinner', true);
        var action = component.get('c.saveGift');
        var giftModelString = component.get('v.giftModelString');
        action.setParams({
            giftModelString: giftModelString
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                var giftModel = response.getReturnValue();
                component.set('v.giftModel', giftModel);
                var oppId = component.find('oppId').get('v.value');

                this.showSaveToast($A.get('$Label.c.Gift_Save_Message_Title'), 
                    $A.get('$Label.c.Gift_Save_Message_Detail'));
                this.redirectToSobject(component, oppId);
            } else if (state === 'ERROR') {
                this.handleError(component, response);
            }
        });

        $A.enqueueAction(action);

    },
    checkValidation: function(component){
        this.validateForm(component);
    },
    validateForm: function(component, showErrors){
        component.set('v.error', null);
        // Show error messages if required fields are blank
        var validForm = this.checkFields(component, 'requiredField', true, showErrors);
        
        // Check that at least one combination of donor fields is valid, otherwise show error
        // First check if an Account field is filled in
        var donorType = component.get('v.di.npsp__Donation_Donor__c');
        var donorExists = false;

        // Make sure a donor has been provided
        if(donorType == 'Account1' || !donorType){ 
            donorExists = donorExists || this.checkFields(component, 'accountLookup', true);
        }
        if(donorType == 'Contact1' || !donorType) {
            donorExists = donorExists || this.checkFields(component, 'contactLookup', true);
        }

        component.set('v.donorExists', donorExists);
        
        if(!donorExists){
            // Show error if no Donor has been entered
            if(showErrors){
                this.showErrorMessage(component, $A.get('$Label.c.Gift_Donor_Required'), true);
            }
            return false;
        } else {
            // Clear the error
            this.showErrorMessage(component, '', false);            
        }

        return validForm;
    },
    showErrorMessage: function(component, errorMsg, msgIsError){
        component.set('v.messageIsError', msgIsError);
        component.set('v.showSpinner', false);
        component.set('v.submitError', errorMsg);
        if(errorMsg){
            // If an error was reported, re-enable the Create button
            component.set('v.disableCreate', false);
        }
    },
    checkForPaymentChange: function(component, helper){
        // Delay payment creation to avoid duplicate events
        var timer = component.get('v.paymentTimer');
        clearTimeout(timer);

        var timer = window.setTimeout(
            $A.getCallback(function(){
                helper.createDefaultPayment(component);
                clearTimeout(timer);
                component.set('v.paymentTimer', null);
            }), 200
        );

        component.set('v.paymentTimer', timer);
    },
    disablePaymentCalculateButton: function(component){
        var paySched = this.getChildComponents(component, 'giftPaymentScheduler');
        if(paySched){
            paySched[0].disableCalcButton();
        }
    },
    focusOnAddPayment: function(component){
        var relatedCmp = this.getChildComponents(component, 'giftFormRelated');
        if(relatedCmp){
            for(var i=0; i < relatedCmp.length; i++){
                var objectName = relatedCmp[i].getRelatedObject();
                if(objectName == 'npe01__OppPayment__c'){
                    relatedCmp[i].focusOnAddButton();
                }
            }
        }
    },
    updateRelatedPaymentAmounts: function(component, fieldVal){
        var amt = component.get('v.di.npsp__Donation_Amount__c');
        var date = component.get('v.di.npsp__Donation_Date__c');

        if(!amt){
            return;
        }

        var amtWasChanged = false;
		if(fieldVal){
			// Check if the change was made to the amount field and not the date field
			amtWasChanged = fieldVal.indexOf('-') < 0;
		}
        
        // If the amount and date are set, check if the Payment Schedule should be updated
        if(date){
            var paySched = this.getChildComponents(component, 'giftPaymentScheduler');
            if(paySched){  
                paySched[0].createDefaultPayment(amtWasChanged);
                // Add back if we want to show a message when the payment is updated
                // var paymentAdded = component.get('v.paymentAdded');
                // if(paymentAdded){
                //     this.showSaveToast('', 'Payment Updated');
                // } else {
                //     component.set('v.paymentAdded', true);
                // }
            }
        }
        
        // If the amount was changed, check if Allocation percentages need to be updated
        if(amtWasChanged){
            var allocations = this.getChildComponents(component, 'giftRelatedAllocation');
            if(allocations){
                for(var i=0; i<allocations.length; i++){
                    allocations[i].handlePercentChange();
                }
            }
            var softcredits = this.getChildComponents(component, 'giftRelatedSoftCredit');
            if(softcredits){
                for(var i=0; i<softcredits.length; i++){
                    softcredits[i].handleDonationChange();
                }
            }
        }
    },
    checkFields: function(component, fieldId, allMustBeValid, showErrors){
        var findResult = component.find(fieldId); 
        if(!findResult){
            return allMustBeValid;
        }
        findResult = this.singleInputToArray(findResult);
        var validationResult = findResult.reduce(function (validSoFar, inputCmp) {
            var fieldVal = inputCmp.get('v.value');
            var isValid = fieldVal || fieldVal === false;
            if(showErrors && typeof inputCmp.reportValidity === 'function'){
                var validMsg = inputCmp.reportValidity();
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
        component.set('v.showSpinner', false);
        component.set('v.disableCreate', false);
        var errors = response.getError();
        if (errors) {
            if (errors[0] && errors[0].message) {
                var errorMsg = errors[0].message;
                this.showErrorToast(errorMsg);
            }
        } else {
            this.showErrorToast($A.get('$Label.c.Error_Unknown'));
        }
    },
    setDonation: function(component, selectedDonation) {
        component.set('v.showSpinner', true);
        component.set('v.selectedDonation', selectedDonation);
        var selection = this.proxyToObj(selectedDonation);

        // "create a new Opportunity" was selected
        if(!selection){
            this.getDonationInformation(component, null);
            return;
        }

        // Focus on Add New Payment button after loading this Donation
        if (selection.applyPayment) {
            this.focusOnAddPayment(component);
        }

        // Check if a Payment was selected, and get the Opportunity Id
        var oppId = selection["npe01__Opportunity__c"];
        if(!oppId){
            // An Opportunity was selected, set the Id
            oppId = selection["Id"];
        }
        // Update the form to edit the selected Opportunity
        this.getDonationInformation(component, oppId);

        // TODO: Add, and lock, this payment in the scheduler
        // component.set('v.payments', [selection]);
    },
    mapOppToDi: function(component, di, opp){
        console.log(opp); 
        var fieldMap = component.get('v.objectFieldData.diToOppFieldMap');
        fieldMap = this.proxyToObj(fieldMap);
        for(var field in fieldMap){
            var oppField = fieldMap[field];
            var oppValue = opp[oppField];
            // Small exception for record type, Data Import wants the name, not the ID
            if(oppField == 'RecordTypeId' && opp['RecordType']){
                oppValue = opp['RecordType'].Name;
            }
            if(oppValue){
                di[field] = oppValue;
            }
        }
        if(opp.Id){
            di['npsp__DonationImported__c'] = opp.Id;
        }
    },
    clearDonationSelectionOptions: function(component) {
        component.set('v.selectedDonation', null);
        component.set('v.openOpportunities', null);
        component.set('v.unpaidPayments', null);
    },
    queryOpenDonations: function(component, donorId) {
        const donorType = component.get('v.di.npsp__Donation_Donor__c');

        let action = component.get('c.getOpenDonations');
        action.setParams({donorId: donorId, donorType: donorType});
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                const openDonations = JSON.parse(response.getReturnValue());
                console.log(openDonations); 
                component.set('v.openOpportunities', openDonations.openOpportunities);
                component.set('v.unpaidPayments', openDonations.unpaidPayments);
            } else {
                this.handleError(component, response);
            }
        });
        $A.enqueueAction(action);
    },
    fillJsonField: function(component) {
        var relatedCmp = this.getChildComponents(component, 'giftFormRelated');
        var allRowsValid = true;

        // First process the related objects
        for(var i=0; i < relatedCmp.length; i++){
            // Need to get variable name for each of these to know where to map the return
            var jsonResp = relatedCmp[i].handleJsonUpdate();
            allRowsValid = allRowsValid && jsonResp;
        }

        var giftModel = component.get('v.giftModel');
        var opp = this.proxyToObj(component.get('v.opp'));
        var di = this.proxyToObj(component.get('v.di'));

        // Map fields from Opportunity to DataImport
        // This is done to avoid referencing GEM namespace fields in markup
        this.mapOppToDi(component, di, opp);
        
        giftModel['di'] = di;

        // Clear unneeded variables
        giftModel['objNameToApiToLabel'] = {};
        giftModel['picklistValues'] = {};

        var giftModelString = JSON.stringify(giftModel);
        component.set('v.giftModelString', giftModelString);
        return allRowsValid;
    },
    showSaveToast: function(titleTxt, msgText){
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title : titleTxt,
            message: msgText,
            duration:' 5000',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
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
    getChildComponents: function(component, cmpName){
        var namespace = component.get('v.namespacePrefix');
        var rowCmpName = namespace + ':' + cmpName;
        var formWrapper = component.find('formWrapper');
        return formWrapper.find({instancesOf:rowCmpName});
    },
    scrollToTop: function(){
        window.scrollTo(0, 0);
    },
    updateFieldUI: function(field){
        var inputBody = field.get('v.body')[0];
        if(inputBody.updateValues){
            inputBody.updateValues();
        }
    },
    clearInputs: function(component, fieldId){
        var findResult = component.find(fieldId);
        findResult = this.singleInputToArray(findResult);
        for(var i in findResult){
            findResult[i].set('v.value', '');
            this.updateFieldUI(findResult[i]);
        }
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