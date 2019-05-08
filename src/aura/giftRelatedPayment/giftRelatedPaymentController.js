({
	handlePaid: function(component, event, helper) {
		var payDate = null;		
		var isPaid = component.get('v.item.npe01__Paid__c');
		if(isPaid){
			payDate = component.get('v.item.npe01__Scheduled_Date__c');
			// A Payment cannot be paid and written off
			component.set('v.item.npe01__Written_Off__c', false);
		}

		var paymentDateField = component.find('paymentDate');
        if(paymentDateField){
            // Set the hidden Payment Date field if marked paid
            paymentDateField.set('v.value', payDate);
        }

		// Set the Payment Method field to 'required' if payment is paid
		var methodInput = component.find('methodField');
		if(methodInput){
			methodInput.set("v.required", isPaid);
		}
	},
	preventPaidAndWrittenOff: function(component, event, helper){
		var isWrittenOff = event.getParam('value');
		if(isWrittenOff){
			// A Payment cannot be paid and written off
			component.set('v.item.npe01__Paid__c', false);
		}
	},
	clearAmount: function(component, event, helper){
		component.set('v.item.npe01__Payment_Amount__c', 0);
	}
})