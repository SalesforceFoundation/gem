({
	handlePaidOrWrittenOff: function(component, fieldChanged) {
		var payDate = null;

		var newValue = component.get(fieldChanged) === true;
		
		var paidChange = fieldChanged.indexOf('npe01__Paid__c') > 0;
		var writeOffChange = fieldChanged.indexOf('npe01__Written_Off__c') > 0;

		var isPaid = component.get('v.item.npe01__Paid__c');
		var isWrittenOff = component.get('v.item.npe01__Written_Off__c');

		// Either Paid, or written off, we need to set the Payment Date
		if(isPaid || isWrittenOff){
			var dateObj = new Date();
			payDate = dateObj.toISOString().split('T')[0];
		}

		if(paidChange && newValue){
			// A Payment cannot be paid and written off
			component.set('v.item.npe01__Written_Off__c', false);
		} else if(writeOffChange && newValue){
			// A Payment cannot be paid and written off
			component.set('v.item.npe01__Paid__c', false);
		}
		
		var paymentDateField = component.find('paymentDate');
        if(paymentDateField){
			// Set the Payment Date field if marked paid or written off, and the field is blank
			// Clear the Payment Date if paid and written off become unchecked
			if(paymentDateField.get('v.value') == null || payDate == null){
				paymentDateField.set('v.value', payDate);
			}
        }

		// Set the Payment Method field to 'required' if payment is paid or written off
		var methodInput = component.find('methodField');
		if(methodInput){
			methodInput.set("v.required", newValue);
		}

		// Hide and show lookup fields to update them
		this.rerenderInputs(component, 'renderRequiredInputs');

	},
	getAccountingDataConsistencyEnforced: function(component) {
		var getAccountingDataConsistencyEnforced = component.get('c.getIsEnforceAccountingDataConsistencyEnabled');

		getAccountingDataConsistencyEnforced.setCallback(this, function(response) {
			var state = response.getState();
			if (state === 'SUCCESS') {
				var queriedDataConsistencyEnabled = response.getReturnValue();
				component.set('v.accountingDataConsistencyEnabled', queriedDataConsistencyEnabled);
			} else if (state === 'ERROR') {
				// When there is an error, don't do anything. The Boolean already has a default value.
			}
		});
		$A.enqueueAction(getAccountingDataConsistencyEnforced);
	}, rerenderInputs: function(component, booleanAttr) {
		console.log('calling rerender input');
		var boolString = 'v.'+booleanAttr;
		component.set(boolString, false);
		setTimeout($A.getCallback(() => component.set(boolString, true)));
	}
})