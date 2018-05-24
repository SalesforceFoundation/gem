({
	doInit: function(component, event, helper) {
        // Add the initial row
        helper.handleAddRow(component);
    },
    clickAddRow: function(component, event, helper) {
        //helper.addRowHelper(component);
        helper.handleAddRow(component);
    },
    handleSetJSON: function(component, event, helper) {
        //Testing: Update the value of jsonObj and check if it changes in parent cmp
        var theList = component.get("v.rowList");

        // Loop over list and parse objects?
        console.log(JSON.stringify(theList));

        var obj = JSON.parse(JSON.stringify(theList));
        var strobj = JSON.stringify(theList);
        component.set("v.jsonObj", obj);
        console.log('handle set json');
        console.log(obj);
        console.log(strobj);
    }
})