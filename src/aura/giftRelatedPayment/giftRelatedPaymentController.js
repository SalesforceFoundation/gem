({
	doInit: function(component, event, helper) {
		var isPaid = component.get('v.item.npe01__Paid__c');
		var isWrittenOff = component.get('v.item.npe01__Written_Off__c');
		var isEditMode = component.get('v.editMode');
		if((isPaid || isWrittenOff) && isEditMode){
			component.set("v.rowDisabled", true);
		}

		helper.getAccountingDataConsistencyEnforced(component);
	},
	handlePaidOrWriteOff: function(component, event, helper) {
		var fieldChanged = event.getParam("expression");
		helper.handlePaidOrWrittenOff(component, fieldChanged);
	},
	clearAmount: function(component, event, helper){
		component.set('v.item.npe01__Payment_Amount__c', 0);
	}
})