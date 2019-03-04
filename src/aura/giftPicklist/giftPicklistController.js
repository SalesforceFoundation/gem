({
    handlePicklistChange : function(component, event, helper) {
		// We don't want the default option to overwrite the existing object value		
		// Will be needed to enable editing
		var callEvent = component.get("v.callEvent");
		var fieldId = component.get("v.inputFieldId");
		if(!callEvent || !fieldId){
			// We either shouldn't make the update, or there is no field provided
			return;
		}
		var newVal = event.getParam("value");
		var message = {newVal: newVal, fieldId: fieldId};
		var sendMsgEvent = $A.get("e.ltng:sendMessage");
		sendMsgEvent.setParams({
			"message": message,
			"channel": "picklistChangeEvent"
		});
		sendMsgEvent.fire();
	}
})