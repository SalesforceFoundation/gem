({
	addRowHelper: function(component){
        this.addToObjectArray(component, "v.rowList", "v.item");
    },
    amountChanged: function(component, event, helper){
		var newAmt = this.checkUndefined(event.getParam("value"));
        var oldAmt = this.checkUndefined(event.getParam("oldValue"));
        //var total = this.checkUndefined(component.get("v.amountTotal"));
        var total = component.get("v.amountTotal");
        if(total === undefined){
            // If the total was undefined, set it to the old amount
            total = oldAmt;
        }
        console.log(newAmt + ", " + oldAmt + ", " + total);
        total += (newAmt - oldAmt);
        component.set("v.amountTotal", total);
        // console.log('new total: ');
        console.log(total);
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
        // Check if this row has all required inputs filled in
        // If none are filled in, assume this row should not be processed
        var needsError = [];
        var validForm = false;
        var allBlank = true;
        // Show error messages if required fields are blank
        var reqFields = component.find('requiredField');
        // console.log('reqFields:');
        // console.log(reqFields);
        if(!reqFields || reqFields.size < 1){
            return true;
        }
        
        validForm = reqFields.reduce(function (validSoFar, inputCmp) {
            var disabled = inputCmp.get("v.disabled");
            if(disabled){
                helper.removeError(inputCmp);
                return validSoFar;
            }
            var fieldVal = inputCmp.get("v.value");
            //console.log(fieldVal);
            var isValid = fieldVal || fieldVal === false;
            // Show error for invalid fields
            if(!isValid){
                helper.addError(inputCmp);
                needsError.push(inputCmp);
            } else {
                // There is at least one valid field
                allBlank = false;
                helper.removeError(inputCmp);
            }
            return isValid && validSoFar;
        }, true);

        // If ALL fields are blank, skip this row and consider it valid
        if(allBlank){
            for(var i=0; i<needsError.length; i++){
                helper.removeError( needsError[i] );
            }
            return undefined; // This is interpreted as a blank row
        }

        return validForm;
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
            return num;
        }
    }
})