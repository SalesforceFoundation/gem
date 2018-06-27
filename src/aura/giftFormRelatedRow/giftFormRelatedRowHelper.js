({
	addRowHelper: function(component){
        this.addToObjectArray(component, "v.rowList", "v.item");
    },
    amountCheck: function(component, event, helper){
        component.set("v.checkAmountTotals", true);
    },
    amountChanged: function(component, event, helper){
        component.set("v.checkAmountTotals", false);
		var newAmt = this.checkUndefined(event.getParam("value"));
        var oldAmt = this.checkUndefined(event.getParam("oldValue"));
        //var total = this.checkUndefined(component.get("v.amountTotal"));
        var total = component.get("v.amountTotal");
        if(total === undefined){
            // If the total was undefined, set it to the old amount
            total = oldAmt;
        }
        //console.log(newAmt + ", " + oldAmt + ", " + total);
        total += (newAmt - oldAmt);
        total = Math.round(total * 100) / 100;
        component.set("v.amountTotal", total);
        //console.log(total);
    },
    addToObjectArray: function(component, vArray, vObj){
        // Now, create the component that contains the fields and pass it the list of data
        // The parent list needs an actual reference to the item, 
		// so that it gets updated as fields are filled in
        var objList = component.get(vArray);
		var obj = component.get(vObj);
        objList.push(obj);
        component.set(vArray, objList);
        //console.log(objList);
    },
    validateRow: function(component, helper) {
        component.set("v.showError", false);
        // Check if this row has all required inputs filled in
        // If none are filled in, assume this row should not be processed
        // var needsError = [];
        var validationInfo = {needsError: [], allBlank: true, validSoFar: true, 
            noDuplicateValueList: []};
        validationInfo.noDuplicateValueList = 
            helper.proxyToObj(component.get('v.noDuplicateValueList'));
        var validSoFar = true;
        var validForm = true;
        var duplicateCheck = true;
        
        // Show error messages if required fields are blank
        var reqFields = component.find('requiredField');
        //console.log(reqFields); 

        var noDuplicatesList = component.find('noDuplicates');
        //console.log(noDuplicates); 
        
        if(!reqFields && !noDuplicatesList){
            return true;
        }
     
        reqFields = this.singleInputToArray(reqFields);
        noDuplicatesList = this.singleInputToArray(noDuplicatesList);
        
        // Check required fields
        if(reqFields){
            validForm = reqFields.reduce(function (validSoFar, inputCmp) {
                validationInfo.validSoFar = validSoFar;
                return helper.validateField(component, inputCmp, validationInfo, false, helper);
            }, true);
        }

        if(noDuplicatesList){
            duplicateCheck = noDuplicatesList.reduce(function (validSoFar, inputCmp) {
                validationInfo.validSoFar = validSoFar;
                return helper.validateField(component, inputCmp, validationInfo, true, helper);
            }, true);
        }

        component.set('v.noDuplicateValueList', validationInfo.noDuplicateValueList);

        // If ALL fields are blank, skip this row and consider it valid
        if(validationInfo.allBlank){
            for(var i=0; i<validationInfo.needsError.length; i++){
                helper.removeError(validationInfo.needsError[i]);
            }
            return undefined; // This is interpreted as a blank row
        }

        return validForm && duplicateCheck;
    },
    singleInputToArray: function(findResult){
        if(findResult && !findResult.length){
            findResult = [findResult];
        }
        return findResult;
    },
    validateField: function(component, inputCmp, validationInfo, checkDupes, helper){
        var disabled = inputCmp.get("v.disabled");
        if(disabled){
            helper.removeError(inputCmp);
            return validationInfo.validSoFar;
        }
        var fieldVal = inputCmp.get("v.value");
        //console.log(fieldVal);
        var isValid = fieldVal || fieldVal === false;

        if(checkDupes){
            // Check for duplicate values
            if(validationInfo.noDuplicateValueList.indexOf(fieldVal) > -1){
                //inputCmp.set("v.value", "Duplicate");
                component.set("v.showError", true);
                component.set("v.errorMessage", "Duplicate values are not allowed:");
                isValid = false;
                // This value duplicates another field, prevent it
            } else {
                // No duplicate found, add this value to the array to track
                validationInfo.noDuplicateValueList.push(fieldVal);
            }
        }

        // Show error for invalid fields
        if(!isValid){
            helper.addError(inputCmp);
            validationInfo.needsError.push(inputCmp);
        } else {
            // There is at least one valid field
            validationInfo.allBlank = false;
            helper.removeError(inputCmp);
        }

        return isValid && validationInfo.validSoFar;
    },
    addError: function(inputCmp){
        $A.util.addClass(inputCmp, 'slds-has-error');
    },
    removeError: function(inputCmp){
        $A.util.removeClass(inputCmp, 'slds-has-error');
    },
    checkUndefined: function(num){
        if(num === undefined){
            return 0;
        } else {
            return +num; // Convert string to number, just in case
        }
    },
    proxyToObj: function(attr){
        // Used to convert a Proxy object to an actual Javascript object
        return JSON.parse(JSON.stringify(attr));
    }
})