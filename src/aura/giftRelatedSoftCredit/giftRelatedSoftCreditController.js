({
	doInit: function(component, event, helper) {
		// Set the credit options
		var fullOption = $A.get('$Label.c.Full');
		var partialOption = $A.get('$Label.c.Partial');
		var typeOptions = 
			[{'label': fullOption, 'value': fullOption},{'label': partialOption, 'value': partialOption}];
		component.set('v.typeOptions', typeOptions);

		// If loading data, checks the amounts
		helper.handleAmountCheckHelper(component);

		// TODO: Add ability to delete existing rows when editing a Donation
		// This is partially figured out by using the 'markedForDelete' attribute
		// Partial Soft Credits can always been removed, even in edit mode
		// component.set('v.removeButtonDisabled', false);
	},
	handleTypeChange: function(component, event, helper) {
		var newType = event.getParam('value');
		var donAmt = component.get('v.donationAmt');
		if(newType == 'Full' && donAmt){
			component.set('v.item.npsp__Amount__c', donAmt);
			// Also call the event from the extended giftFormRelatedRow component
			helper.amountCheck(component, event, helper);
		}
	},
	handleAmountCheck: function(component, event, helper) {
		helper.handleAmountCheckHelper(component);
	},
	handleDonationChange: function(component, event, helper) {
		var newAmt = event.getParam('value');
		var creditType = component.get('v.creditType');
		if(creditType == 'Full' && newAmt){
			component.set('v.item.npsp__Amount__c', newAmt);
		}
	}
})