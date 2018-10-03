({
	handlePaid : function(component, event, helper) {
		var isPaid = component.get("v.item.npe01__Paid__c");
		var paymentDate = component.find('paymentDate');
		if(!paymentDate){
			return;
		}
		var payDate = null;
		if(isPaid){
			payDate = component.get("v.item.npe01__Scheduled_Date__c");
		}
		paymentDate.set("v.value", payDate);
	}
})