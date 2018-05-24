({
	addRowHelper: function(component){
        this.addToObjectArray(component, "v.rowList", "v.item");
    },
    addToObjectArray: function(component, vArray, vObj){
        var objList = component.get(vArray);
		// The parent list needs an actual reference to the item, 
		// so that it gets updated as fields are filled in
		var obj = component.get(vObj);
        objList.push(obj);
		component.set(vArray, objList);
		console.log(objList);
	}
})