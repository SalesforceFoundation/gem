({
    handleAddRow: function(component, helper, item, index){
        // Now, create the component that contains the fields and pass it the list of data
        var rowList = component.getReference("v.rowList");
        var rowListArray = component.get("v.rowList");
        var newRowNum = index ? index : rowListArray.length;
        var rowCmpName = component.get("v.rowCmpName");
        var objectFieldData = component.get("v.objectFieldData");
        var amtField = component.getReference("v.amtField");
        var donationAmt = component.getReference("v.donationAmt");
        var checkAmountTotals = component.getReference("v.checkAmountTotals");
        var noDuplicateValueList = component.getReference("v.noDuplicateValueList");
    
        var showLabels = false;
        if(newRowNum == 0){
            showLabels = true;
        }

        $A.createComponent(
            rowCmpName, {
                "rowList": rowList,
                "rowComponent": rowCmpName,
                "objectFieldData": objectFieldData,
                "item": item,
                "donationAmt": donationAmt,
                "checkAmountTotals": checkAmountTotals,
                "noDuplicateValueList": noDuplicateValueList,
                "amtField": amtField,
                "showLabels": showLabels
            },
            function(relatedCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    // Add the component to the page
                    var body = component.get("v.body");
                    body.push(relatedCmp);
                    component.set("v.body", body);

                    // Could clean this up by only calling after final item is added
                    helper.getAmtTotal(component);
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
    createRowsFromItemList: function(component, helper){
        // Called when the item list is completely overwritten
        // Ex. Calculating Payment schedule, or loading existing data

        // First, clear the existing rows
        component.set("v.body", []);
        component.set("v.rowList", []);
        
        // Now add the passed in objects to the rowList
        //var itemList = event.getParam("value");
        var itemList = component.get("v.itemList");
        itemList = this.proxyToObj(itemList);

        for(var i=0; i<itemList.length; i++){
            this.handleAddRow(component, helper, itemList[i], i);
        }
        component.set("v.showAmountError", false);
        //component.set("v.blockItemChangeEvent", false);
    },
    setOppIdPlaceholder: function(component, itemObj, oppFieldName){
        // Set the opportunity field to a placeholder, which gets replaced in Apex
        var curVal = itemObj[oppFieldName];
        if(!curVal){
            var oppPlaceholder = $A.get("$Label.c.Gift_Donation_ID_Placeholder");
            itemObj[oppFieldName] = oppPlaceholder;
        }
    },
    updateModelObject: function(component, arrayList){
        var attrName = component.get("v.modelAttribute");
        arrayList = this.proxyToObj(arrayList);
        if(!arrayList){
            arrayList = null;
        }
        component.set("v.giftModel."+attrName, arrayList);
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
        var relatedRows = this.getRelatedRows(component);
        var validRows = [];
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
    deleteAll: function(component){
        var relatedRows = this.getRelatedRows(component);
        for(var i=0; i < relatedRows.length; i++){
            var thisRow = relatedRows[i];
            thisRow.clickDeleteRow();
        }
    },
    getAmtTotal: function(component){
        // Returns valid items or false if there is a validation issue
        var relatedRows = this.getRelatedRows(component);
        var totalOfAllRows = 0;
        for(var i=0; i < relatedRows.length; i++){
            var thisRow = relatedRows[i];
            // Make sure the return is a number
            var rowAmt = +thisRow.returnRowAmount();
            if(rowAmt){
                totalOfAllRows += rowAmt;
            }
        }
        totalOfAllRows = Math.round(totalOfAllRows * 100) / 100;
        component.set("v.amountTotal", totalOfAllRows);
        return totalOfAllRows;
    },
    getRelatedRows: function(component){
        var rowCmpName = component.get("v.rowCmpName");
        var relatedWrapper = component.find("relatedWrapper");
        return relatedWrapper.find({instancesOf:rowCmpName});
    },
    proxyToObj: function(attr){
        // Used to convert a Proxy object to an actual Javascript object
        return JSON.parse(JSON.stringify(attr));
    }
})