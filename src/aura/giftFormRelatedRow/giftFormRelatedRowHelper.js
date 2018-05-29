({
	addRowHelper: function(component){
        this.addToObjectArray(component, "v.rowList", "v.item");
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

        var validForm = true;
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
            // console.log(fieldVal);
            var isValid = fieldVal || fieldVal === false;
            // Show error for invalid fields
            if(!isValid){
                helper.addError(inputCmp);
            } else {
                helper.removeError(inputCmp);
            }
            return isValid && validSoFar;
        }, true);

        return validForm;
    },
    addError: function(inputCmp){
        $A.util.addClass(inputCmp, 'slds-has-error');
    },
    removeError: function(inputCmp){
        $A.util.removeClass(inputCmp, 'slds-has-error');
    }
})