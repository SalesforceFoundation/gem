({
	doInit : function(component, event, helper) {
		// Add the new item to the related array
		helper.addRowHelper(component);
	},
	clickDeleteRow : function(component, event, helper) {
		// Call delete row event 
		var rowIndex = component.get("v.rowNum");
		var deleteEvent = component.getEvent("giftFormDeleteRowEvent");
		deleteEvent.setParams({"rowIndex" : rowIndex});
		deleteEvent.fire();
	}
})