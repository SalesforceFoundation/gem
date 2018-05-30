({
	doInit: function(component, event, helper) {
        // Add the initial row
        helper.handleAddRow(component);
    },
    clickAddRow: function(component, event, helper) {
        helper.handleAddRow(component);
    },
    handleJsonUpdate: function(component, event, helper) {
        var validRows = helper.validateRows(component);
        var isValid = validRows && validRows.length > 0;
        if(isValid){
            helper.updateJsonObject(component, validRows);
        }
        return isValid;
    }
})