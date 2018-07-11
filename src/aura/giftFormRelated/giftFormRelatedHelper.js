({
    handleAddRow: function(component, item, index){
        // Now, create the component that contains the fields and pass it the list of data
        var rowList = component.getReference("v.rowList");
        var rowListArray = component.get("v.rowList");
        var newRowNum = rowListArray.length;
        var rowCmpName = component.get("v.rowCmpName");
        var picklistOptions = component.get("v.picklistOptions");
        var amountTotal = component.getReference("v.amountTotal");
        var donationAmt = component.getReference("v.donationAmt");
        var checkAmountTotals = component.getReference("v.checkAmountTotals");
        var noDuplicateValueList = component.getReference("v.noDuplicateValueList");
        //var oppField = component.get("v.oppField");
        var showLabels = true;
        if(newRowNum > 0 || index && index > 0){
            showLabels = false;
        }

        $A.createComponent(
            rowCmpName, {
                "rowList": rowList,
                "rowComponent": rowCmpName,
                "picklistOptions": picklistOptions,
                "rowNum": newRowNum,
                "item": item,
                "amountTotal": amountTotal,
                "donationAmt": donationAmt,
                "checkAmountTotals": checkAmountTotals,
                "noDuplicateValueList": noDuplicateValueList,
                "showLabels": showLabels
            },
            function(relatedCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    // Add the component to the page
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
        // Set the opportunity field to a placeholder, which gets replaced in Apex
        var curVal = itemObj[oppFieldName];
        if(!curVal){
            var oppPlaceholder = $A.get("$Label.c.Gift_Donation_ID_Placeholder");
            itemObj[oppFieldName] = oppPlaceholder;
        }
    },
    updateJsonObject: function(component, arrayList){
        var jsonObj = component.get("v.jsonObj");
        var objectName = component.get("v.objectName");
        var fieldList = component.get("v.fieldList");
        var oppField = component.get("v.oppField");
        var oppFieldName = component.get("v.oppField");

        if(jsonObj == null){
            // If adding first row, set to empty object
            jsonObj = {};
            component.set("v.jsonObj", jsonObj);
        } else {
            // If retrieved, turn the attribute into an actual Javascript object
            jsonObj = this.proxyToObj(jsonObj);
        }

        // Get the relevant fields from the list of objects    
        var newObjList = [];
        arrayList = this.proxyToObj(arrayList);
        //console.log(arrayList);
        fieldList = this.proxyToObj(fieldList);
        // Add the Opportunity field so it gets included
        fieldList.push(oppField);
        for(var i=0; i < arrayList.length; i++){
            var oldObj = arrayList[i];
            // If this row was deleted, skip it
            if(!oldObj){
                continue;
            }
            var newObj = {};
            // For each object, only save the fields we want
            for(var j=0; j < fieldList.length; j++){
                var fieldName = fieldList[j];
                var fieldVal = oldObj[fieldName];
                newObj[fieldName] = fieldVal;
            }
            this.setOppIdPlaceholder(component, newObj, oppFieldName);
            newObjList.push(newObj);
        }
        // console.log(objectName);
        // console.log(arrayList);
        //jsonObj[objectName] = newObjList;

        // Can't set entire object, async calls overwrite each other
        // Should overwrite with blank array if no list is passed!
        component.set("v.jsonObj."+objectName, newObjList);
        
        // console.log('JSON set:');
        // jsonObj = component.get("v.jsonObj");
        // console.log(JSON.stringify(jsonObj));
    },
    validateRows: function(component){
        var preventSubmit = component.get("v.preventSubmit");
        if(preventSubmit){
            return false;
        }
        // Returns valid items or false if there is a validation issue
        var rowCmpName = component.get("v.rowCmpName");
        var relatedWrapper = component.find("relatedWrapper");
        var relatedRows = relatedWrapper.find({instancesOf:rowCmpName});
        var validRows = [];
        var rowsAreValid = true;
        var invalidRow = false;
        for(var i=0; i < relatedRows.length; i++){
            var thisRow = relatedRows[i];
            var rowValid = thisRow.checkValidation();
            if(rowValid === undefined){
                // Skip this row, it's either deleted or blank
            } else if(rowValid){
                // Add this row to the array to pass along
                var item = thisRow.get("v.item");
                validRows.push(item);
            } else {
                // There is a row that's invalid, show an error message
                invalidRow = true;
            }
        }

        if(invalidRow){
            return false;
        } else {
            return validRows;
        }
    },
    getAmountTotal: function(component){
        // Returns valid items or false if there is a validation issue
        var relatedWrapper = component.find("relatedWrapper");
        var relatedRows = relatedWrapper.find("v.amountNumber");
        //console.log(relatedRows); 
    },
    proxyToObj: function(attr){
        // Used to convert a Proxy object to an actual Javascript object
        return JSON.parse(JSON.stringify(attr));
    }
})