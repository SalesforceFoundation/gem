({
	doInit: function(component, event, helper) {
		// Add the new item to the related array
		helper.addRowHelper(component);
	},
	clickDeleteRow: function(component, event, helper) {
		component.set("v.markedForDelete", true);
		// Call delete event, handled by the parent
		var cmpEvent = component.getEvent("giftDeleteRowEvent");
		cmpEvent.fire();
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