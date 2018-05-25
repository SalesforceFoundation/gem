({
	doInit: function(component, event, helper) {
        // Add the initial row
        helper.handleAddRow(component);
    },
    clickAddRow: function(component, event, helper) {
        helper.handleAddRow(component);
    },
    handleJsonUpdate: function(component, event, helper) {
        helper.updateJsonObject(component);
    },
    handleRemoveRow: function(component, event, helper){
        var index = event.getParam("rowIndex");
        // Remove this component from the page
        var body = component.get("v.body");
        var rowListArray = component.get("v.rowList");
        console.log(index);
        console.log(body);
        // console.log(body.length);
        // Can't remove because index numbers after this one would be wrong
        body[index] = null;
        rowListArray[index] = null;
        //body.splice(index, 1);
        //body.push(relatedCmp);
        component.set("v.body", body);
    }
})