({
	handlePicklistChange : function(component, event, helper) {
        var newVal = event.getParam("value");
        if(newVal){
			var fieldId = component.get("v.inputFieldId");
			var cmpEvent = component.getEvent("giftPicklistChangeEvent");
			cmpEvent.setParams({
				"newValue" : newVal,
				"fieldId" : fieldId
			});
			cmpEvent.fire();
        }
    }
})