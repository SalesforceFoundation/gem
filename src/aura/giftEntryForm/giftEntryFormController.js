({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        // Make changes based on mode
        if(recordId){
            component.set('v.editMode', true);
            component.find('createButton').set('v.label', 'Update Gift');
        }
    },
    handleFieldChange: function(component, event, helper){
        helper.checkValidation(component);
    },
    clickCreate: function(component, event, helper) {
        component.set('v.showSpinner', true);
        var validForm = helper.validateForm(component);

        // If we pass validation, submit the form
        if(validForm){
            component.find('giftEditForm').submit();
        } else {
            component.set('v.showSpinner', false);
        }
    },
    clickGoToDonation: function(component, event, helper){
        var recordId = component.get('v.returnedRecordId');
        helper.redirectToDonation(component, recordId);
    },
    clickRunProcess: function(component, event, helper){
        //helper.prepareRelatedObjects(component);
        var diId = component.get('v.returnedRecordId');
        helper.processGift(component, diId, false);
    },
    clickBackToForm: function(component, event, helper){
        component.set("v.showForm", true);
        component.set("v.showSuccess", false);
    },
    handleLoad: function(component, event, helper){
        //console.log("Handle Load");
        // In the case of a new gift, the recordId changes, which would trigger a second load event
        if(component.get("v.dataLoaded")){
            helper.checkValidation(component);
            return;
        }
        component.set("v.dataLoaded", true);

        // Setup Picklists and any default form values
        helper.setDefaults(component, helper);
    },
    handleDateChange: function(component, event, helper){
        var newDate = event.getParam("value");
        helper.setHiddenField(component, "dateField", newDate);
        helper.checkValidation(component);
    },
    handleDonorTypeChange: function(component, event, helper){
        var donorType = event.getParam("value");
        // Need to clear the other donor fields
        if(donorType == 'Account1'){
            helper.clearInputs(component, 'requiredContactField');
            helper.clearInputs(component, 'requiredDonorField');
        } else if(donorType == 'Contact1'){
            helper.clearInputs(component, 'requiredAccountField');
        }
        helper.checkValidation(component);
    },
    handleSuccess: function(component, event, helper) {
        //console.log("Handle Success");
        var response = event.getParam('response');
        
        var returnedId = response.id;
        component.set('v.returnedRecordId', returnedId);
        var curId = component.get('v.recordId');
        if(!curId){
            component.set('v.recordId', returnedId);
        }
        // Process the gift as a dry run, see how object matching would turn out
        var doDryRun = component.find("doDryRun").get("v.checked");
        helper.processGift(component, returnedId, doDryRun);
    },
    handlePicklistChange: function(component, event, helper) {
        var newVal = event.getParam("newValue");
        var fieldId = event.getParam("fieldId");
        //console.log('Picklist change: ' + newVal + " " + fieldId);
        if(fieldId){
            helper.setHiddenField(component, fieldId, newVal);
        }
    },
    handleDryRunLoad: function(component, event, helper) {
        //console.log("Handle dry run load");
        // Hide and show messages based on results of the dry run import
        var donationImportStatusField = component.find("donationImportStatus");
        if(donationImportStatusField){
            var donationImportStatus = donationImportStatusField.get("v.value");
            var importFailureString = $A.get("$Label.npsp.bdiErrorDonationLookupMatch");
            if(donationImportStatus == importFailureString){
                component.set("v.showDonationImportError", true);
            }
        }
    }
})