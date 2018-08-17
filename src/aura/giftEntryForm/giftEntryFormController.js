({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        // Get the data model class for the form
        // Includes picklist options, field labels, and objects if loading an existing record
        var getModelAction = component.get("c.initClass");
        getModelAction.setParams({
            oppId: recordId
        });
        getModelAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var giftModel = response.getReturnValue();
                
                console.log('From init'); 
                console.log(giftModel); 

                component.set("v.giftModel", giftModel);
                component.set("v.objectLabels", giftModel.objNameToApiToLabel);

                if(giftModel.opp){
                    component.set("v.opp", giftModel.opp);
                }
                if(giftModel.acct){
                    component.set("v.acct", giftModel.acct);
                }
                if(giftModel.contact){
                    component.set("v.contact", giftModel.contact);
                }
                if(giftModel.payments){
                    component.set("v.payments", giftModel.payments);
                }
                if(giftModel.allocs){
                    component.set("v.allocs", giftModel.allocs);
                }
                if(giftModel.partialCredits){
                    component.set("v.partialCredits", giftModel.partialCredits);
                }

            } else if (state === "ERROR") {
                helper.handleError(component, response);
            }
        });
        $A.enqueueAction(getModelAction);

        // Changes if there is already a recordId (Edit mode)
        if(recordId){
            helper.changeSubmitText(component, 'Update Gift');            
            component.set('v.editMode', true);
        }

        var namespace = component.getType().split(':')[0];
        component.set("v.namespacePrefix", namespace);
        if(namespace != "c"){
            component.set("v.namespaceFieldPrefix", namespace+'__');
        }

        // Setup Picklists and any default form values
        helper.setDefaults(component, helper);        
        helper.checkValidation(component);
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

        // TODO: Fix this in edit mode...
        var isEditMode = component.get("v.editMode");
        console.log('isEditMode: '); 
        console.log(isEditMode); 

        // console.log("Check matches"); 
        // console.log( event.getParam("oldValue") );
        // console.log( event.getParam("value") );

        var newVal = event.getParam("value");
        if(!newVal || isEditMode){
            return;
        }
        
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
    handlePicklistChange: function(component, event, helper) {
        var newVal = event.getParam("newValue");
        var fieldId = event.getParam("fieldId");
        //console.log('Picklist change: ' + newVal + " " + fieldId);
        if(fieldId){
            helper.setHiddenField(component, fieldId, newVal);
        }
    },
    handleMatchChange: function(component, event, helper) {
        var selectedObject = event.getParam("selectedObject");
        var objectType = event.getParam("objectType");
        var inputAuraId = event.getParam("inputAuraId");
        var oppLookupField = event.getParam("oppLookupField");

        helper.setLookupField(component, objectType, selectedObject, inputAuraId, oppLookupField);

        // If the donor changed, check for matches again
        if(objectType == "Contact" || objectType == "Account"){
            helper.checkMatches(component, "Opportunity");
        }
    }
})