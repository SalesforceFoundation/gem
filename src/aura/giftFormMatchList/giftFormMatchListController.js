({
	handleListChange : function(component, event, helper) {
		var objectType = component.get("v.objectType");
		var curVal = component.get("v.selectedValue");
		// console.log('curVal for ' + objectType); 
		// console.log(curVal); 
		var objList = component.get("v.objectList");
		if(!objList){
			component.set("v.optionList", []);
			return;
		}
		var createNewVal = '';
		objList = helper.proxyToObj(objList);
		var newList = [{'label':'Create New','value':createNewVal}];
		// Parse the object list into the label/value list that we need
		for(var i=0; i < objList.length; i++){
			var thisItem = objList[i];
			newList[i+1] = {'label': thisItem.Name, 'value': i};
		}

		// console.log(' ** newList'); 
		// console.log(newList); 

		if(!curVal){
			curVal = createNewVal;
		}
		component.set("v.selectedValue", curVal);
		component.set("v.optionList", newList);
		component.set("v.enableChangeEvent", true);
	},
	handleSelectionChange : function(component, event, helper) {
		if(!component.get("v.enableChangeEvent")){
			return;
		}

		var objectType = component.get("v.objectType");
		console.log(' ** SELECTION CHANGE for: '); 
		console.log(objectType); 

		var newIndex = event.getParam("value");
		var objList = component.get("v.objectList");

		// If undefined, pass an empty object instead? Just grab type?
		var selectedObject = objList[newIndex];
		console.log(selectedObject);

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

	}
})