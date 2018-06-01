({
	doInit: function(component, event, helper) {
        // Add the initial row
        helper.handleAddRow(component);
    },
    clickAddRow: function(component, event, helper) {
        helper.handleAddRow(component);
    },
    handleJsonUpdate: function(component, event, helper) {
        var validRows = helper.validateRows(component);
        var isValid = validRows;
        // If there are no rows, the JSON gets overwritten
        helper.updateJsonObject(component, validRows);
        return isValid;
    },
    handleItemListChange: function(component, event, helper){
        // First, clear the existing rows
        component.set("v.body", []);
        component.set("v.rowList", []);
        
        // Now add the calculated payments
        var itemList = event.getParam("value");
        itemList = helper.proxyToObj(itemList);
        //console.log(itemList);
        for(var i=0; i<itemList.length; i++){
            helper.handleAddRow(component, itemList[i], i);
        }
    }
})