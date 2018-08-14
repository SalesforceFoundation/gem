({
    doInit: function(component, event, helper) {
        // Get Object field labels for use in the form
        var getClassAction = component.get("c.initClass");
        getClassAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var giftCtrl = response.getReturnValue();
                component.set("v.giftClassController", giftCtrl);
                component.set("v.objectLabels", giftCtrl.objNameToApiToLabel);
                
                // TODO: More init functions here? Check for existing record Id?

            } else if (state === "ERROR") {
                helper.handleError(component, response);
            }
        });
        $A.enqueueAction(getClassAction);


        var recordId = component.get('v.recordId');
        // Make changes based on mode
        if(recordId){
            // Get data from Apex
            var action = component.get("c.getDonationRecords");
            action.setParams({
                oppId: recordId
            });

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var objMap = response.getReturnValue();
                    console.log(objMap); 
                    if(objMap){
                        if(objMap.Opportunity){
                            component.set("v.opp", objMap.Opportunity[0]);
                        }
                        if(objMap.Account){
                            component.set("v.acct", objMap.Account[0]);
                        }
                        if(objMap.Contact){
                            component.set("v.contact", objMap.Contact[0]);
                        }
                        if(objMap.Payments){
                            component.set("v.payments", objMap.Payments);
                        }
                        if(objMap.Allocations){
                            component.set("v.allocs", objMap.Allocations);
                        }
                        if(objMap.PartialCredits){
                            component.set("v.partialCredits", objMap.PartialCredits);
                        }
                    }
                }
            });

            $A.enqueueAction(action); 

            component.set('v.editMode', true);
            helper.changeSubmitText(component, 'Update Gift');
        }


        var namespace = component.getType().split(':')[0];
        component.set("v.namespacePrefix", namespace);
        if(namespace != "c"){
            component.set("v.namespaceFieldPrefix", namespace+'__');
        }

        //console.log("Handle Load");
        // In the case of a new gift, the recordId changes, which would trigger a second load event
        // if(component.get("v.dataLoaded")){
        //     helper.checkValidation(component);
        //     return;
        // }
        // component.set("v.dataLoaded", true);

        // Setup Picklists and any default form values
        helper.setDefaults(component, helper);
        
        // Also set the amount in the payment scheduler
        // var amtField = component.find("amtField");
        // if(amtField){
        //     var amt = amtField.get("v.value");
        //     helper.updateAmountField(component, amt);
        // }

        //helper.setGiftObjMap(component);
        
        helper.checkValidation(component);
    },
    handleFieldChange: function(component, event, helper){
        helper.checkValidation(component);
    },
    // handleAmountChange: function(component, event, helper){
    //     var newAmt = event.getParam("value");
    //     helper.updateAmountField(component, newAmt);
    //     helper.checkValidation(component);
    // },
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
    checkMatches: function(component, event, helper) {

        // TODO: Fix this in edit mode...
        var isEditMode = component.get("v.editMode");

        // console.log("Check matches"); 
        // console.log( event.getParam("oldValue") );
        // console.log( event.getParam("value") );

        var newVal = event.getParam("value");
        if(!newVal || isEditMode){
            return;
        }
        
        helper.fillJsonField(component);
        helper.processGiftJson(component, true);
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
    }
})