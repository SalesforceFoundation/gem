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
			payDate = component.get('v.item.npe01__Scheduled_Date__c');
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
            // Set the hidden Payment Date field if marked paid or written off
            paymentDateField.set('v.value', payDate);
        }

		// Set the Payment Method field to 'required' if payment is paid or written off
		var methodInput = component.find('methodField');
		if(methodInput){
			methodInput.set("v.required", newValue);
		}
	}
})