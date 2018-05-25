({
    handleAddRow: function(component){
        // Now, create the component that contains the fields and pass it the list of data
        var rowList = component.getReference("v.rowList");
        var rowCmpName = component.get("v.rowCmpName");
        var oppField = component.get("v.oppField");
        $A.createComponent(
            rowCmpName, {
                "rowList": rowList,
                "oppField": oppField
            },
            function(relatedCmp, status, errorMessage){
                if (status === "SUCCESS") {
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
    },
    setOppIdPlaceholder: function(component, itemObj, oppFieldName){
        var curVal = itemObj[oppFieldName];
        if(!curVal){
            var oppPlaceholder = $A.get("$Label.c.Gift_Donation_ID_Placeholder");
            itemObj[oppFieldName] = oppPlaceholder;
        }
    },
    updateJsonObject: function(component){
        var jsonObj = component.get("v.jsonObj");
        var objectName = component.get("v.objectName");
        var fieldList = component.get("v.fieldList");
        var oppField = component.get("v.oppField");
        var arrayList = component.get("v.rowList");

        var oppFieldName = component.get("v.oppField");

        if(jsonObj == null){
            // If adding first row, set to empty object
            jsonObj = {};
        } else {
            // If retrieved, turn the attribute into an actual Javascript object
            jsonObj = this.proxyToObj(jsonObj);
        }

        // Get the relevant fields from the list of objects    
        var newObjList = [];
        arrayList = this.proxyToObj(arrayList);
        fieldList = this.proxyToObj(fieldList);
        // Add the Opportunity field so it gets included
        fieldList.push(oppField);
        for(var i=0; i < arrayList.length; i++){
            var oldObj = arrayList[i];
            var newObj = {};
            // For each object, only save the fields we want
            for(var j=0; j < fieldList.length; j++){
                var fieldName = fieldList[j];
                newObj[fieldName] = oldObj[fieldName];
            }
            
            this.setOppIdPlaceholder(component, newObj, oppFieldName);

            newObjList.push(newObj);
        }
        jsonObj[objectName] = newObjList;
        component.set("v.jsonObj", jsonObj);
        // console.log('JSON set:');
        // console.log(JSON.stringify(jsonObj));
    },
    proxyToObj: function(attr){
        // Used to convert a Proxy object to an actual Javascript object
        return JSON.parse(JSON.stringify(attr));
    }
})