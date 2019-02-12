({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        // Get the data model class for the form
        // Includes picklist options, field labels, and objects if loading an existing record
        helper.getDonationInformation(component, recordId);

        // Set the namespace var so components load in managed package
        var namespace = component.getType().split(':')[0];
        component.set('v.namespacePrefix', namespace);
        if(namespace != 'c'){
            component.set('v.namespaceFieldPrefix', namespace+'__');
        }
        helper.setOppToDiMap(component);
    },
    handlePaymentChange: function(component, event, helper){
        helper.checkForPaymentChange(component, helper);
        helper.checkValidation(component);
    },
    handleFieldChange: function(component, event, helper){
        // Each time a required input changes, check validation
        helper.checkValidation(component);
    },
    onDonorChange: function(component, event, helper){
        helper.clearDonationSelectionOptions(component);
        const lookupField = component.get('v.di.npsp__Donation_Donor__c') === 'Contact1' ? 'contactLookup' : 'accountLookup';
        const lookupValue = component.find(lookupField).get('v.value');
        const lookupValueIsValidId = lookupValue.length === 18;

        if (lookupValueIsValidId) {
            // TODO: Add loading spinner during query
            // helper.sendMessage('showFormSpinner', '');
            helper.queryOpenDonations(component, lookupValue);
        }

        helper.checkValidation(component);
    },
    clickEditDonor: function(component, event, helper) {
        var donorType = component.get('v.di.npsp__Donation_Donor__c');
        var donorId;
        if(donorType == 'Account1'){
            donorId = component.get('v.di.npsp__Account1Imported__c');
        } else {
            donorId = component.get('v.di.npsp__Contact1Imported__c');
        }
        helper.showEditRecordModal(component, donorId);
    },
    clickCreate: function(component, event, helper) {
        component.set('v.showSpinner', true);
        component.set('v.disabled', true);
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
        var donorType = event.getParam('value');
        // Need to clear the other donor fields
        if(donorType == 'Account1'){
            helper.clearInputs(component, 'contactLookup');
        } else if(donorType == 'Contact1'){
            helper.clearInputs(component, 'accountLookup');
        }
    },
    handleMessage: function(component, event, helper){
        var message = event.getParam('message');
        var channel = event.getParam('channel');

        if(channel == 'picklistChangeEvent'){
            helper.handlePicklistChange(component, message);
        } else if(channel == 'matchChangeEvent'){
            helper.handleMatchChange(component, message, helper);
        } else if(channel == 'validateEvent'){
            helper.validateForm(component, true);
        }
    },
    expandTributeSection: function(component, event, helper) {
        helper.doToggleSection(component, 'expandTribute');
    },
    expandMatchingSection: function(component, event, helper) {
        helper.doToggleSection(component, 'expandMatching');
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
                        title: $A.get('$Label.c.PageMessagesError'),
                        errorMessage: $A.get('$Label.c.stgUnknownError')
                    };
                    helper.sendMessage('onError', message);

                } else if (status === 'ERROR') {
                    const message = {title: $A.get('$Label.c.PageMessagesError'), errorMessage: errorMessage};
                    helper.sendMessage('onError', message);
                }
            });
    }
})