({
	selectionChange : function(component, newIndex) {
		var enableChangeEvent = component.get("v.enableChangeEvent");
		console.log("handleSelectionChange: " + enableChangeEvent);
		if(!enableChangeEvent){
			return;
		}

		var objectType = component.get("v.objectType");
		console.log(' ** SELECTION CHANGE for: '); 
		console.log(objectType); 

		// var newIndex = event.getParam("value");
		var objList = component.get("v.objectList");

		// If undefined, pass an empty object instead? Just grab type?
		var selectedObject = objList[newIndex];
		component.set("v.selectedObject", selectedObject);
		// console.log(selectedObject);

		var objectType = component.get("v.objectType");
		var idField = component.get("v.idField");
		var inputAuraId = component.get("v.inputAuraId");

		var cmpEvent = component.getEvent("giftMatchChangeEvent");
		cmpEvent.setParams({
			"selectedObject" : selectedObject,
			"objectType" : objectType,
			"inputAuraId" : inputAuraId,
			"oppLookupField" : idField
		});
		cmpEvent.fire();

	},
	proxyToObj: function(attr){
		// Used to convert a Proxy object to an actual Javascript object
		return JSON.parse(JSON.stringify(attr));
	}
})