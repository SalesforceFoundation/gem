({
	doInit: function(component, event, helper) {
		// Add the new item to the related array
		helper.addRowHelper(component);

		var inputs = helper.getInputs(component);
		if(inputs.length > 0){
			var firstInput = inputs[0];
			if(typeof firstInput.focus === 'function'){
				// TODO: Trying to focus on first input, only works on lookup fields?
				// firstInput.focus();
			}
		}
	},
	clickDeleteRow: function(component, event, helper) {
		component.set('v.markedForDelete', true);

		// Call delete event, handled by the parent
		var sendMsgEvent = $A.get('e.ltng:sendMessage');
		sendMsgEvent.setParams({
			'channel': 'deleteRowEvent'
		});
		sendMsgEvent.fire();
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