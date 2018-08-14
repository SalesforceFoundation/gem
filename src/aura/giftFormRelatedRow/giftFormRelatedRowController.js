({
	doInit: function(component, event, helper) {
		// Add the new item to the related array
		helper.addRowHelper(component);
	},
	clickDeleteRow: function(component, event, helper) {
        // Can't fully remove because array index numbers after this one would be wrong
		var rowIdentifier = component.get("v.rowNum");
		var rowList = component.get("v.rowList");
		rowList[rowIdentifier] = null;
		helper.setRowAmt(component, 0);
		component.destroy();
	},
	checkValidation: function(component, event, helper) {
		var isValid = helper.validateRow(component, helper);
		return isValid;
	},
	returnRowAmount: function(component, event, helper){
		return helper.getRowAmt(component);
	},
	handleAmountCheck: function(component, event, helper) {
		helper.amountCheck(component, event, helper);
	}
})