({
	handleListChange : function(component, event, helper) {
		var createNewVal = '';
		component.set("v.enableChangeEvent", false);
		component.set("v.selectedValue", createNewVal);
		var objectType = component.get("v.objectType");
		var curVal = component.get("v.selectedValue");
		var selectedObject = component.get("v.selectedObject");
		var currentLookupValue = component.get("v.currentLookupValue");

		var objList = component.get("v.objectList");
		if(!objList || objList.length == 0){
			component.set("v.optionList", []);
			return;
		}
		objList = helper.proxyToObj(objList);
		var newList = [{'label':'Create New','value':createNewVal}];
		// Parse the object list into the label/value list that we need
		for(var i=0; i < objList.length; i++){
			var thisItem = objList[i];
			// If the returned item matches the lookup selection, update field values
			if(currentLookupValue == thisItem.Id){
				component.set("v.selectedValue", i);
				if(!selectedObject || selectedObject.Id != thisItem.Id){
					// component.set("v.searchForOpps", true);
					helper.selectionChange(component, i);
				}
			}
			newList[i+1] = {'label': thisItem.Name, 'value': i};
		}

		// console.log(' ** newList'); 
		// console.log(newList); 

		// component.set("v.selectedValue", curVal);
		component.set("v.optionList", newList);
		component.set("v.enableChangeEvent", true);
	},
	handleSelectionChange : function(component, event, helper) {
		var enableChangeEvent = component.get("v.enableChangeEvent");
		// console.log("handleSelectionChange: " + enableChangeEvent); 		

		if(!enableChangeEvent){
			return;
		}

		var objectType = component.get("v.objectType");
		// console.log(" ** Select changed via input "); 

		var newIndex = event.getParam("value");
		helper.selectionChange(component, newIndex);
	}
})