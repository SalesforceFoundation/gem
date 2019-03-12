({
	handlePaid: function(component, event, helper) {
		var paymentDate = component.find('paymentDate');
		if(!paymentDate){
			return;
		}
		var payDate = null;
		var isPaid = component.get('v.item.npe01__Paid__c');
		if(isPaid){
			payDate = component.get('v.item.npe01__Scheduled_Date__c');
		}
		// Set the hidden Payment Date field if marked paid
		paymentDate.set('v.value', payDate);

		// Set the Payment Method field to 'required' if payment is paid
		var methodInput = component.find('methodField');
		if(methodInput){
			methodInput.set("v.required", isPaid);
		}
	},
	clearAmount: function(component, event, helper){
		component.set('v.item.npe01__Payment_Amount__c', 0);
	}
})