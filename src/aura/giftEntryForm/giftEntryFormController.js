({
    doInit: function(component, event, helper) {
        component.set('v.showSpinner', true);
        var recordId = component.get('v.recordId');
        // Get the data model class for the form
        // Includes picklist options, field labels, and objects if loading an existing record
        helper.getDonationInformation(component, recordId);

        // Set the namespace var so components load in managed package
        var namespace = component.getType().split(':')[0];
        component.set('v.namespacePrefix', namespace);
        if(namespace !== 'c'){
            component.set('v.namespaceFieldPrefix', namespace+'__');
        }
    },
    handlePaymentChange: function(component, event, helper){
        if(component.get('v.disableBlurEvents')){
            return;
        }
        // This is run "on change" so we know that a value changed when the blur event occurs
        component.set('v.paymentValChanged', true);
    },
    checkPaymentChange: function(component, event, helper){
        // This is run "on blur" to prevent mutiple calls as the donation amount changes
        var fieldVal = event.getSource().get('v.value');
        var paymentValChanged = component.get('v.paymentValChanged');
        // We only want to run this blur event if a payment related value actually changed
        if(paymentValChanged){
            helper.updateRelatedPaymentAmounts(component, fieldVal);
        }
        component.set('v.paymentValChanged', false);
        helper.checkValidation(component);
    },
    handleFieldChange: function(component, event, helper){
        if(component.get('v.disableBlurEvents')){
            return;
        }
        // Each time a required input changes, check validation
        helper.checkValidation(component);
    },
    onDonorChange: function(component, event, helper){
        if(component.get('v.disableBlurEvents')){
            return;
        }
        helper.clearDonationSelectionOptions(component);
        const lookupField = component.get('v.di.npsp__Donation_Donor__c') === 'Contact1' ? 'contactLookup' : 'accountLookup';
        const lookupValue = component.find(lookupField).get('v.value');
        const lookupId = helper.getIdFromLookupValue(lookupValue);
        if(!lookupId){
            return;
        }
        const lookupValueIsValidId = lookupId.length === 18;

        if (lookupValueIsValidId) {
            helper.queryOpenDonations(component, lookupId);
        }

        helper.checkValidation(component);
    },
    clickEditDonor: function(component, event, helper) {
        var donorType = component.get('v.di.npsp__Donation_Donor__c');
        var lookupValue;
        if(donorType === 'Account1'){
            lookupValue = component.get('v.opp.AccountId');
        } else {
            lookupValue = component.get('v.opp.npsp__Primary_Contact__c');
        }
        var donorId = helper.getIdFromLookupValue(lookupValue);
        helper.showEditRecordModal(component, donorId);
    },
    clickCreate: function(component, event, helper) {
        component.set('v.showSpinner', true);
        component.set('v.disableCreate', true);
        var validForm = helper.validateForm(component, true);

        // If we pass validation, submit the form
        if(validForm){
            // Fill in the JSON data field
            var jsonIsValid = helper.fillJsonField(component);
            if(jsonIsValid){
                component.set('v.submitError', '');
                helper.handleSaveGift(component);
            } else {
                helper.showErrorMessage(component, $A.get('$Label.c.Gift_Form_Error'), true);
            }
        } else {
            // Did not pass validation, show generic error if no other one has been set
            if(!component.get('v.submitError')){
                helper.showErrorMessage(component, $A.get('$Label.c.Gift_Form_Error'), true);
            }
        }
    },
    clickCancel: function(component, event, helper) {
        // Refresh the view to clear the form
        $A.get('e.force:refreshView').fire();
    },
    handleDonorTypeChange: function(component, event, helper){
        // Ignore this if currently loading a Donation, or if a Donation it being edited
        if(component.get('v.disableBlurEvents') || component.get('v.editMode')){
            return;
        }
        var donorType = event.getParam('value');
        // Need to clear the other donor fields
        if(donorType === 'Account1'){
            helper.clearInputs(component, 'contactLookup');
        } else if(donorType === 'Contact1'){
            helper.clearInputs(component, 'accountLookup');
        }
    },
    handleMessage: function(component, event, helper){
        var message = event.getParam('message');
        var channel = event.getParam('channel');

        if(channel === 'picklistChangeEvent'){
            helper.handlePicklistChange(component, message);
        } else if(channel === 'validateEvent'){
            helper.validateForm(component, true);
        } else if(channel == 'selectedDonation'){
            helper.setDonation(component, message);
        } else if (channel === 'onError') {
            helper.showErrorToast(message.errorMessage, message.title);
        }
    },
    handleCustomFieldsLoaded: function(component, event, helper) {
        const hasFields = event.getParam('hasFields');
        if(hasFields) {
            const header = component.find('dynamicFormHeader');
            const container = component.find('dynamicFormContainer');
            $A.util.removeClass(header, 'slds-hidden');
            $A.util.removeClass(container, 'slds-hidden');
        }
    },
    toggleSection: function(component, event, helper) {
        const section = event.currentTarget.dataset.section;
        helper.doToggleSection(component, section);
    },
    openMatchModal: function(component, event, helper) {
        $A.createComponent('npsp:BGE_DonationSelector', {
                'aura:id': 'donationSelector',
                'name': 'donationSelector',
                'unpaidPayments': component.get('v.unpaidPayments'),
                'openOpportunities': component.get('v.openOpportunities'),
                'selectedDonation': component.get('v.selectedDonation'),
                'labels': component.get('v.bdiLabels')
            },
            function (newcomponent, status, errorMessage) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: component.get('v.donationModalHeader'),
                        body: newcomponent,
                        showCloseButton: true,
                        cssClass: 'slds-modal_large'
                    });
                } else if (status === 'INCOMPLETE') {
                    const message = {
                        title: $A.get('$Label.npsp.PageMessagesError'),
                        errorMessage: $A.get('$Label.npsp.stgUnknownError')
                    };
                    helper.sendMessage('onError', message);

                } else if (status === 'ERROR') {
                    const message = {title: $A.get('$Label.npsp.PageMessagesError'), errorMessage: errorMessage};
                    helper.sendMessage('onError', message);
                }
            });
    },
    handleToast: function(component, event, helper) {
        var isRecordEdit = helper.parseToast(event.getParams().message);

        if (isRecordEdit == true) {
            helper.rerenderInputs(component, 'renderDonorInputs');
        }
    }
})