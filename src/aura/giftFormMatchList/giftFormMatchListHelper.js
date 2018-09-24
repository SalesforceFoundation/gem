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

		var objList = component.get("v.objectList");

		// If undefined, pass an empty object instead? Just grab type?
		var selectedObject = objList[newIndex];
		component.set("v.selectedObject", selectedObject);

		var objectType = component.get("v.objectType");
		var idField = component.get("v.idField");
		var inputAuraId = component.get("v.inputAuraId");

		var message = {
			selectedObject: selectedObject, 
			objectType: objectType,
			inputAuraId: inputAuraId, 
			oppLookupField: idField
		};

		console.log(message); 

		var sendMsgEvent = $A.get("e.ltng:sendMessage");
		sendMsgEvent.setParams({
			"message": message,
			"channel": "matchChangeEvent"
		});
		sendMsgEvent.fire();
	},
	proxyToObj: function(attr){
		// Used to convert a Proxy object to an actual Javascript object
		return JSON.parse(JSON.stringify(attr));
	}
})