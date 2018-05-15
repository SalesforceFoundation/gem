({
    doInit: function(component, event, helper) {
        var hasRecordId = component.get('v.recordId') != '';
        component.set('v.editMode', hasRecordId);

        // Make changes based on mode
        if(hasRecordId){
            component.find('createButton').set('v.label', 'Update Gift');
        }
        
        /*
        component.find("giftData").getNewRecord(
            "npsp__DataImport__c", // objectApiName
            null, // recordTypeId
            false, // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.giftObject");
                var error = component.get("v.error");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    console.log("Record template initialized: " + rec.sobjectType);
                    // Set defaults in the form
                    helper.setDefaults(component);
                }
            })
        );
        */
    },
    handleFieldChange: function(component, event, helper){
        var formValid = helper.validateForm(component);
        var btn = component.find('createButton');
        btn.set('v.disabled',!formValid);
    },
    clickCreate: function(component, event, helper) {
        component.set('v.showSpinner', true);
        var validForm = helper.validateForm(component);

        // If we pass error checking, submit the form
        if(validForm){
            //helper.submitForm(component, helper);
            component.find('giftEditForm').submit();
        } else {
            component.set('v.showSpinner', false);
        }
    },
    clickGoToDonation: function(component, event, helper){
        var recordId = component.get('v.recordId');
        helper.redirectToDonation(component, recordId);
    },
    handleLoad: function(component, event, helper) {
        helper.setPicklists(component);
        helper.setDefaults(component);
    },
    handleSubmit: function(component, event, helper) {
    
    },
    handleSuccess: function(component, event, helper) {
        var response = event.getParam('response');
        component.set('v.recordId', response.id);
        helper.processGift(component, response.id);
    },
    handlePaymentMethodChange: function(component, event, helper) {
        var newVal = event.getParam("value");
        if(newVal){
            helper.setHiddenField(component, 'paymentMethodField', newVal);
            //component.set('v.selectedPaymentMethod', newVal);
        }
    },
    handleStageChange: function(component, event, helper) {
        var newVal = event.getParam("value");
        if(newVal){
            helper.setHiddenField(component, 'stageField', newVal);
            //component.set('v.selectedStage', newVal);
        }
    }
})