({
	handleListChange : function(component, event, helper) {
		// var enableChangeEvent = component.get("v.enableChangeEvent");
		// // console.log("handleSelectionChange: " + enableChangeEvent);
		// if(!enableChangeEvent){
		// 	return;
		// }

		var createNewVal = '';
		var objectType = component.get("v.objectType");
		var curVal = component.get("v.selectedValue");
		// console.log("curval for " + objectType + ": " + curVal);
		component.set("v.enableChangeEvent", false);
		if(curVal === undefined){
			component.set("v.selectedValue", createNewVal);
		}
		
		var objList = component.get("v.objectList");
		console.log(objectType); 
		console.log(objList); 
		if(!objList || objList.length == 0){ // || curVal !== createNewVal
			component.set("v.optionList", []);
			return;
		}
		
		var selectedObject = component.get("v.selectedObject");
		var currentLookupValue = component.get("v.currentLookupValue");
		var fieldsToShow = component.get("v.fieldsToShow");

		objList = helper.proxyToObj(objList);
		var newList = [{'label':'Create New','value':createNewVal}];
		// Parse the object list into the label/value list that we need
		for(var i=0; i < objList.length; i++){
			var optionLabel = '';
			var thisItem = objList[i];
			// If the returned item matches the lookup selection, update field values
			if(currentLookupValue == thisItem.Id){
				component.set("v.selectedValue", i);
				if(!selectedObject || selectedObject.Id != thisItem.Id){
					helper.selectionChange(component, i);
					component.set("v.optionList", []);
					return;
				}
			}
			for(var j=0; j<fieldsToShow.length; j++){
				var thisField = fieldsToShow[j];
				optionLabel += thisItem[thisField] + " ";
			}
			newList[i+1] = {'label': optionLabel, 'value': i};
		}

		// console.log(' ** newList'); 
		// console.log(newList); 

		// component.set("v.selectedValue", curVal);
		console.log("SHOW MATCHES for " + objectType); 
		component.set("v.optionList", newList);
		component.set("v.enableChangeEvent", true);

	},
	handleSelectionChange : function(component, event, helper) {
		var newIndex = event.getParam("value");
		helper.selectionChange(component, newIndex);
	}
})