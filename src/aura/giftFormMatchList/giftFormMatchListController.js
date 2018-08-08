({
	handleListChange : function(component, event, helper) {
		var objList = component.get("v.objectList");
		if(!objList){
			return;
		}
		objList = helper.proxyToObj(objList);
		var newList = [{'label':'Create New','vallue':''}];
		// Parse the object list into the label/value list that we need
		for(var i=0; i < objList.length; i++){
			var thisItem = objList[i];
			//console.log(thisItem);
			newList[i+1] = {'label': thisItem.Name, 'value': thisItem.Id};
		}
		component.set("v.optionList", newList);
	},
	handleSelectionChange : function(component, event, helper) {
		var newId = event.getParam("value");
		if(newId == 'on'){
			newId = null;
		}
		//console.log(newId);
		// After selecting a match, set the appropriate Id field on the opportunity
		var opp = helper.proxyToObj(component.get("v.oppObj"));
		var idField = component.get("v.idField");
		if(idField){
			opp[idField] = newId;
		}
		component.set("v.oppObj", opp);
	}
})