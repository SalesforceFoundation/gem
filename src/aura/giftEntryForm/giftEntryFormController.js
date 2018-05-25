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
            // Fill in the JSON data field        
            helper.fillJsonField(component);
            component.find('giftEditForm').submit();
        } else {
            component.set('v.showSpinner', false);
        }
    },
    clickGoToDonation: function(component, event, helper){
        helper.redirectToDonation(component);
    },
    clickRunProcess: function(component, event, helper){
        var diId = component.get('v.returnedRecordId');
        helper.processGift(component, diId, false);
    },
    clickBackToForm: function(component, event, helper){
        component.set("v.showForm", true);
        component.set("v.showSuccess", false);
        helper.checkValidation(component);
    },
    handleLoad: function(component, event, helper) {
        //console.log("Handle Load");
        // In the case of a new gift, the recordId changes, which would trigger a second load event
        if(component.get("v.dataLoaded")){
            return;
        }
        component.set("v.dataLoaded", true);
        helper.setPicklists(component);
        helper.setDefaults(component);

        var stageField = component.find("stageField");
        if(stageField){
            var stage = stageField.get("v.value");
            var closedStage = component.get("v.closedStage");
            var oppClosed = stage == closedStage ? true : false;
            component.set("v.oppClosed", oppClosed);
        }
        helper.checkValidation(component);
    },
    handleSubmit: function(component, event, helper) {
        //console.log("Handle Submit");
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
        if(newVal && fieldId){
            var noneOption = component.get("v.picklistNoneText");
            if(newVal == noneOption){
                newVal = '';
            }
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
    },
    doJsonUpdate: function(component, event, helper) {
        helper.fillJsonField(component);
    }
})