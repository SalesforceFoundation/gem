({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        // Get the data model class for the form
        // Includes picklist options, field labels, and objects if loading an existing record
        helper.getDonationInformation(component, helper, recordId);

        // Set the namespace var so components load in managed package
        var namespace = component.getType().split(':')[0];
        component.set("v.namespacePrefix", namespace);
        if(namespace != "c"){
            component.set("v.namespaceFieldPrefix", namespace+'__');
        }
    },
    handleFieldChange: function(component, event, helper){
        // Each time a required input changes, check validation
        helper.checkValidation(component);
    },
    handleLookupChange: function(component, event, helper){
        // When a lookup field change, we may need to check for data matches using that value
        var newVal = event.getParam("value");
        var oldVal = event.getParam("oldValue");
        var donorExists = component.get("v.donorExists");
        
        // console.log('New Lookup: ');
        console.log(newVal + " was: " + oldVal);

        // If a new lookup was set and donor already exists, re-run matching
        // if(!oldVal && newVal){
        console.log("Run Match Check"); 
        // component.set("v.donorExists", false);
        // component.set("v.donorExists", true);
        helper.checkMatches(component);
        // }
        
        helper.checkValidation(component);
    },
    clickEditDonor: function(component, event, helper) {
        var donorType = component.get("v.di.npsp__Donation_Donor__c");
        var donorId;
        if(donorType == 'Account1'){
            donorId = component.get("v.di.npsp__Account1Imported__c");
        } else {
            donorId = component.get("v.di.npsp__Contact1Imported__c");
        }
        helper.showEditRecordModal(component, donorId);
    },
    clickCreate: function(component, event, helper) {
        component.set('v.showSpinner', true);
        var validForm = helper.validateForm(component, true);

        // If we pass validation, submit the form
        if(validForm){
            // Fill in the JSON data field
            var jsonIsValid = helper.fillJsonField(component);
            if(jsonIsValid){
                component.set("v.submitError", "");
                var checkDataMatches = component.find("doDryRun").get("v.checked");
                helper.processGiftJson(component, checkDataMatches);
            } else {
                helper.showErrorMessage(component, $A.get("$Label.c.Gift_Form_Error"), true);
            }
        } else {
            if(!component.get("v.submitError")){
                helper.showErrorMessage(component, $A.get("$Label.c.Gift_Form_Error"), true);
            }
        }
    },
    clickCancel: function(component, event, helper) {
        // TODO: Clear the form? Close a modal?
        console.log("Do Cancel");
    },
    handleCheckMatches: function(component, event, helper) {
        // The form should send its current information and check for data matches
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
        var diId = component.get('v.di.Id');
        // helper.processGift(component, diId, false);
        helper.processGiftJson(component, true);
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
            // helper.setLookupValue(component, 'contactLookup', '');
            helper.clearInputs(component, 'contactLookup');
            // helper.clearInputs(component, 'requiredDonorField');
        } else if(donorType == 'Contact1'){
            // helper.setLookupValue(component, 'accountLookup', '');
            helper.clearInputs(component, 'accountLookup');
        }
        
        // console.log("Donor type change!"); 
        //helper.checkValidation(component);
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
        // A new selection was made on a data match list
        var isEditMode = component.get("v.editMode");
        var selectedObject = event.getParam("selectedObject");
        var objectType = event.getParam("objectType");
        var inputAuraId = event.getParam("inputAuraId");
        var oppLookupField = event.getParam("oppLookupField");

        // console.log(' ** setLookup via handleMatchChange: '); 
        // console.log(setLookup); 
        console.log(' ** handleMatchChange for : ' + objectType); 

        // Could be an option on the component instead, lookup vs. normal input?
        if(objectType == "npe01__OppPayment__c"){
            // Since this isn't a lookup field, just set the value
            var field = component.find(inputAuraId);
            if(field){
                var newVal = (selectedObject && selectedObject.Id) ? selectedObject.Id : null;
                field.set("v.value", newVal);
            }
        } else {
            // Lookup fields take extra steps to show correctly in the UI
            helper.setLookupField(component, objectType, selectedObject, inputAuraId, oppLookupField);
        }

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
    },
    clickMarkPaymentPaid: function(component, event, helper) {
        var paymentId = component.get("v.payment.Id");
        helper.setPaymentPaid(component, paymentId);
    },
    expandTributeSection: function(component, event, helper) {
        helper.doToggleSection(component, 'expandTribute');
    },
    expandMatchingSection: function(component, event, helper) {
        helper.doToggleSection(component, 'expandMatching');
    }
})