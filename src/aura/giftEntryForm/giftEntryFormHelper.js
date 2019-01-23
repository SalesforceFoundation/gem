({
    getDonationInformation: function(component, oppId){
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

                component.set('v.giftModel', giftModel);
                component.set('v.objectFieldData.objectLabels', giftModel.objNameToApiToLabel);
                component.set('v.objectFieldData.closedWonStageMap', giftModel.closedWonStageMap);

                this.handlePicklistSetup(component, giftModel.picklistValues);

                // Setup any default form values
                this.setDefaults(component, giftModel.opp);
                this.checkValidation(component);

            } else if (state === 'ERROR') {
                component.set('v.showForm', false);
                this.handleError(component, response);
            }
        });
        $A.enqueueAction(getModelAction);
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

        action.setCallback(this, function(response) {
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
    validateForm: function(component, showErrors) {
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
    createDefaultPayment: function(component){
        var amt = component.get('v.di.npsp__Donation_Amount__c');
        var date = component.get('v.di.npsp__Donation_Date__c');
        
        if(amt && date){
            var paySched = this.getChildComponents(component, 'giftPaymentScheduler');
            if(paySched){
                paySched[0].createDefaultPayment();
                // Add back if we want to show a message when the payment is updated
                // var paymentAdded = component.get('v.paymentAdded');
                // if(paymentAdded){
                //     this.showSaveToast('', 'Payment Updated');
                // } else {
                //     component.set('v.paymentAdded', true);
                // }
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
    setOppToDiMap: function(component){
        // This map is used to take field values from the Opportunity object and set them on the DataImport object
        // Note: this is only needed to avoid a bug in force:inputField that requires hard-coding the fieldname,
        // which made including an optional namespace impossible
        var nsFieldPrefix = component.get('v.namespaceFieldPrefix');
        var fieldMap = {
            'npe01__Do_Not_Automatically_Create_Payment__c': nsFieldPrefix + 'Do_Not_Automatically_Create_Payment__c',
            'npsp__Acknowledgment_Status__c': nsFieldPrefix + 'Donation_Acknowledgment_Status__c',
            'npsp__Honoree_Contact__c': nsFieldPrefix + 'Donation_Honoree_Contact__c',
            'npsp__Honoree_Name__c': nsFieldPrefix + 'Donation_Honoree_Name__c',
            'npsp__Matching_Gift__c': nsFieldPrefix + 'Donation_Matching_Gift__c',
            'npsp__Matching_Gift_Account__c': nsFieldPrefix + 'Donation_Matching_Gift_Account__c',
            'npsp__Matching_Gift_Employer__c': nsFieldPrefix + 'Donation_Matching_Gift_Employer__c',
            'npsp__Matching_Gift_Status__c': nsFieldPrefix + 'Donation_Matching_Gift_Status__c',
            'npsp__Notification_Message__c': nsFieldPrefix + 'Donation_Notification_Message__c',
            'CampaignId': nsFieldPrefix + 'Donation_Primary_Campaign__c',
            'npsp__Tribute_Type__c': nsFieldPrefix + 'Donation_Tribute_Type__c',
            'npsp__Notification_Recipient_Name__c': nsFieldPrefix + 'Notification_Recipient_Name__c'
        };

        component.set('v.oppToDiFieldMap', fieldMap);
    },
    mapOppToDi: function(component, di, opp){
        var fieldMap = component.get('v.oppToDiFieldMap');
        for(var field in fieldMap){
            var diField = fieldMap[field];
            di[diField] = opp[field];
        }
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
        // This is done to avoid referencing Adv namespace fields in markup
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
    showErrorToast: function(msgText){
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title : $A.get('$Label.c.Error'),
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