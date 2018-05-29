({
	doInit: function(component, event, helper) {
        // Add the initial row
        helper.handleAddRow(component);
    },
    clickAddRow: function(component, event, helper) {
        helper.handleAddRow(component);
    },
    handleJsonUpdate: function(component, event, helper) {
        var isValid = helper.validateRows(component);
        if(isValid){
            helper.updateJsonObject(component);
        }
        return isValid;
    }
})