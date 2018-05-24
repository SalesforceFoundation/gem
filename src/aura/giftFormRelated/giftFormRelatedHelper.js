({
    updateJsonObject: function(component, arrayList){
        var jsonObj = component.get("v.jsonObj");
        var objectName = component.get("v.objectName");
        // If adding first row, set to empty object
        if(jsonObj == null){
            jsonObj = {};
        }
        jsonObj = this.proxyToObj(jsonObj);
        //jsonObj[objectName] = JSON.stringify(arrayList);
        jsonObj[objectName] = this.proxyToObj(arrayList);
        //jsonObj = JSON.stringify(jsonObj);
        component.set("v.jsonObj", jsonObj);
        // console.log(jsonObj);
        // console.log(JSON.stringify(jsonObj));
    },
    proxyToObj: function(attr){
        // Used to convert a Proxy object to an actual Javascript object
        return JSON.parse(JSON.stringify(attr));
    },
    handleAddRow: function(component){
        // Now, create the component that contains the fields and pass it the list of data
        var rowList = component.getReference("v.rowList");
        var rowCmpName = component.get("v.rowCmpName");
        $A.createComponent(
            rowCmpName, {
                "rowList": rowList
            },
            function(relatedCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    console.log(relatedCmp);
                    // var iterator = component.find('thisList');
                    // iterator.set("v.body", relatedCmp);
                    var body = component.get("v.body");
                    body.push(relatedCmp);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    }
})