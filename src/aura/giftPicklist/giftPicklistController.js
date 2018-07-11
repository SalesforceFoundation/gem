({
    handlePicklistChange : function(component, event, helper) {
		// We don't want the default option to overwrite the existing object value
		// Will be needed to enable editing
		var callEvent = component.get("v.callEvent");
		if(!callEvent){
			return;
		}
		var newVal = event.getParam("value");
		var fieldId = component.get("v.inputFieldId");
		var cmpEvent = component.getEvent("giftPicklistChangeEvent");
		cmpEvent.setParams({
			"newValue" : newVal,
			"fieldId" : fieldId
		});
		cmpEvent.fire();
	}
})