({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        // Get the data model class for the form
        // Includes picklist options, field labels, and objects if loading an existing record
        helper.getDonationInformation(component, helper, recordId);

        var namespace = component.getType().split(':')[0];
        component.set("v.namespacePrefix", namespace);
        if(namespace != "c"){
            component.set("v.namespaceFieldPrefix", namespace+'__');
        }
    },
    handleFieldChange: function(component, event, helper){
        helper.checkValidation(component);
    },
    handleLookupChange: function(component, event, helper){
        // This doesn't work, because the event is handled after initFinished is set to true
        // var initFinished = component.get("v.initFinished");
        // if(!initFinished){
        //     return;
        // }

        var newVal = event.getParam("value");
        var oldVal = event.getParam("oldValue");
        var donorExists = component.get("v.donorExists");
        
        // console.log('New Lookup: ');
        console.log(newVal + " was: " + oldVal);

        // If a new lookup was set and donor already exists, re-run matching
        if(!oldVal && newVal){
            console.log("Force Match Check"); 
            // component.set("v.donorExists", false);
            // component.set("v.donorExists", true);
            helper.checkMatches(component);
        }
        
        //helper.checkValidation(component);
    },
    clickCreate: function(component, event, helper) {
        component.set('v.showSpinner', true);
        var validForm = helper.validateForm(component);

        // If we pass validation, submit the form
        if(validForm){
            // Fill in the JSON data field
            var jsonIsValid = helper.fillJsonField(component);
            // console.log('jsonIsValid:'); 
            // console.log(jsonIsValid); 
            if(jsonIsValid){
                component.set("v.submitError", "");
                var checkDataMatches = component.find("doDryRun").get("v.checked");
                helper.processGiftJson(component, checkDataMatches);
            } else {
                component.set('v.showSpinner', false);
                component.set("v.submitError", "Error on form");
            }
        } else {
            component.set('v.showSpinner', false);
        }
    },
    handleCheckMatches: function(component, event, helper) {
        var isEditMode = component.get("v.editMode");

        var newVal = event.getParam("value");
        // console.log(newVal); 
        if(!newVal || isEditMode){
            return;
        }

        // console.log("Checking Matches"); 
        helper.checkMatches(component);
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
        helper.scrollToTop();
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
    handlePicklistChange: function(component, event, helper) {
        var newVal = event.getParam("newValue");
        var fieldId = event.getParam("fieldId");
        //console.log('Picklist change: ' + newVal + " " + fieldId);
        if(fieldId){
            helper.setHiddenField(component, fieldId, newVal);
        }
    },
    handleMatchChange: function(component, event, helper) {
        var isEditMode = component.get("v.editMode");
        var selectedObject = event.getParam("selectedObject");
        var objectType = event.getParam("objectType");
        var inputAuraId = event.getParam("inputAuraId");
        var oppLookupField = event.getParam("oppLookupField");

        // console.log(' ** setLookup via handleMatchChange: '); 
        // console.log(setLookup); 

        helper.setLookupField(component, objectType, selectedObject, inputAuraId, oppLookupField);

        console.log(' ** handleMatchChange for : ' + objectType); 

        if(isEditMode){
            return;
        }

        // If the donor changed, check for matches again
        if(objectType == "Contact" || objectType == "Account"){
            console.log("Search for opps!"); 
            helper.checkMatches(component, "Opportunity");
        } else if(objectType == "Opportunity"){
            console.log("Search for payments!"); 
            helper.checkMatches(component, "npe01__OppPayment__c");
        }
    }
})