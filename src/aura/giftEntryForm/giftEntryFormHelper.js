({
    getDonationInformation: function(component, helper, oppId){
        // Make changes if a recordId was provided (Edit mode)
        if(oppId){
            this.changeSubmitText(component, $A.get('$Label.c.Gift_Update'));
            component.set('v.editMode', true);
        }

        var getModelAction = component.get('c.initClass');
        getModelAction.setParams({
            oppId: oppId
        });
        getModelAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var giftModel = response.getReturnValue();
                
                // console.log('From init'); 
                // console.log(giftModel); 

                component.set('v.giftModel', giftModel);
                component.set('v.objectFieldData.objectLabels', giftModel.objNameToApiToLabel);

                helper.handlePicklistSetup(component, giftModel.picklistValues);

                // Setup any default form values
                helper.setDefaults(component, helper, giftModel.opp);
                helper.checkValidation(component);

            } else if (state === 'ERROR') {
                helper.handleError(component, response);
            }
        });
        $A.enqueueAction(getModelAction);
    },
    setDefaults: function(component, helper, opp){
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
    handlePicklistSetup: function(component, picklistOptions, helper){
        // var picklistOptions = response.getReturnValue();
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
    handlePicklistChange: function(component, message) {
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
        // console.log('Redirect to:'); 
        // console.log(objId); 
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
    getImportedDonationId: function(component, dataImportObjId, redirectAfter){
        var action = component.get('c.getOpportunityIdFromImport');
        action.setParams({
            diObjId: dataImportObjId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var oppId = response.getReturnValue();
                component.set('v.oppId', oppId);
                //console.log('New opp ID: ' + oppId);
                if(redirectAfter){
                    this.redirectToSobject(component, oppId);
                }
            } else if (state === 'ERROR') {
                this.handleError(component, response);
            }
        });

        $A.enqueueAction(action);
    },
    handleSaveGift: function(component){
        component.set('v.showSpinner', true);
        var action = component.get('c.saveGift');
        var giftModelString = component.get('v.giftModelString');
        action.setParams({
            giftModelString: giftModelString
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var giftModel = response.getReturnValue();
                
                // console.log('Gift Model about to be overwritten by handleSaveGift'); 
                // console.log(giftModel); 

                component.set('v.giftModel', giftModel);
                var oppId = component.find('oppId').get('v.value');

                this.showSaveToast('Details Saved', 'Testing message');
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
    validateForm: function(component, showErrors) {
        component.set('v.error', null);
        // Show error messages if required fields are blank
        var validForm = this.checkFields(component, 'requiredField', true, showErrors);
        
        // Check that at least one combination of donor fields is valid, otherwise show error
        // First check if an Account field is filled in
        var donorType = component.get('v.di.npsp__Donation_Donor__c');
        var donorExists = false;

        if(donorType == 'Account1' || !donorType){
            // donorExists = donorExists || this.checkFields(component, 'requiredAccountField', false);
            donorExists = donorExists || this.checkFields(component, 'accountLookup', true);
        }
        if(donorType == 'Contact1' || !donorType) {
            // Check if Contact1 Firstname and Lastname are filled in
            // donorExists = donorExists || this.checkFields(component, 'requiredContactField', true);
            // Check any other donor fields we could use
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
            // var disabled = inputCmp.get('v.disabled');
            // if(disabled){
            //     return validSoFar;
            // }
            var fieldVal = inputCmp.get('v.value');
            // if(fieldId == 'accountLookup'){
            //     console.log(fieldVal); 
            // }
            var isValid = fieldVal || fieldVal === false;
            if(showErrors && typeof inputCmp.reportValidity === 'function'){
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
            this.setErrorMessage(component, 'Unknown error');
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

        var giftModel = component.get('v.giftModel');

        // Set the fields on the giftModal object
        var di = this.proxyToObj(component.get('v.di'));
        
        var objsToDelete = this.proxyToObj(component.get('v.objsToDelete'));
        giftModel['di'] = di;
        giftModel['objsToDelete'] = objsToDelete;

        // Clear unneeded variables
        giftModel['objNameToApiToLabel'] = {};
        giftModel['picklistValues'] = {};

        if(giftModel.payments && giftModel.payments.length > 0){
            // Payments are being scheduled, do not create one for the full donation
            giftModel['di'].Do_Not_Automatically_Create_Payment__c = true;
        }

        var giftModelString = JSON.stringify(giftModel);
        // console.log(giftModelString);

        // component.set('v.jsonObjectString', jsonObjString);
        component.set('v.giftModelString', giftModelString);
        return allRowsValid;
    },
    showSaveToast: function(titleTxt, msgText){
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title : titleTxt,
            message: msgText,
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    getRelatedComponents: function(component){
        var namespace = component.get('v.namespacePrefix');
        var rowCmpName = namespace + ':giftFormRelated';
        var formWrapper = component.find('formWrapper');
        return formWrapper.find({instancesOf:rowCmpName});
    },
    getAllForceInputs: function(component){
        var formWrapper = component.find('formWrapper');
        return formWrapper.find({instancesOf:'force:inputField'});
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
        var inputBody = field.get('v.body')[0];
        // console.log(inputBody); 
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
    setErrorMessage: function(component, errorMsg){
        component.set('v.error', errorMsg);
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