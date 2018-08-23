({
    clickAddRow: function(component, event, helper) {
        helper.handleAddRow(component, helper);
    },
    handleInitRows: function(component, event, helper) {
        var thisObj = component.get("v.objectName");
        var itemList = component.get("v.itemList");
        var rowList = component.get("v.rowList");

        // Only add a row on init if we aren't loading existing data
        if(itemList && itemList.length == 0){
            // If a row has already been added, don't add a new one
            if(rowList.length == 0){
                helper.handleAddRow(component, helper);
            }
        } else {
            // If an itemList was provided on load, add it now that picklist values are available
            helper.createRowsFromItemList(component, helper);
        }
        component.set("v.initFinished", true);
    },
    handleJsonUpdate: function(component, event, helper) {
        // Reset the duplicate checking array
        component.set("v.noDuplicateValueList", []);
        var validRows = helper.validateRows(component);
        var isValid = validRows;
        // If there are no rows, the JSON gets overwritten
        helper.updateModelObject(component, validRows);
        return isValid;
    },
    handleItemListChange: function(component, event, helper){
        // In the payment scheduler, this event gets called twice so we prevent it one time
        var blockChange = component.get("v.blockItemChangeEvent");
        var thisObj = component.get("v.objectName");
        var rowList = component.get("v.rowList");

        // If Payments are being overwritten, call delete on each of them first
        if(thisObj == 'npe01__OppPayment__c' && rowList.length > 0){
            helper.deleteAll(component);
        }

        // On load, since the itemlist comes in before the picklist values are set,
        // we need to wait for the picklists before processing the rows
        if(component.get("v.initFinished") && !blockChange){
            helper.createRowsFromItemList(component, helper);
        }
    },
    handleRowDelete: function(component, event, helper){
        // var rowIdentifier = event.getParam("deletedIndex");
        var relatedRows = helper.getRelatedRows(component);

        //console.log(rowIdentifier); 
        var rowList = component.get("v.rowList");
        var objsToDelete = component.get("v.objsToDelete");
        var body = component.get("v.body");
        var nextRowShowLabels = false;
        rowList = helper.proxyToObj(rowList);

        // console.log(rowList); 

        for(var i=0; i < relatedRows.length; i++){
            // For each remaining row, reset its index and set the first to show labels
            var thisRow = relatedRows[i];
            // console.log('thisRow'); 
            // console.log(thisRow); 

            if(nextRowShowLabels){
                thisRow.set("v.showLabels", true);
                nextRowShowLabels = false;
            }

            if(thisRow.get("v.markedForDelete")){
                var objName = component.get("v.objectName");
                var thisItem = thisRow.get("v.item");
                thisItem = helper.proxyToObj(thisItem);
                // console.log(thisItem); 
                if(thisItem.Id != null){
                    // Required attribute to delete a list of generic sobjects
                    thisItem["attributes"] = {"type":objName};
                    objsToDelete.push(thisItem);
                }
                if(thisRow.get("v.showLabels")){
                    nextRowShowLabels = true;
                }
                body.splice(i,1);
                rowList.splice(i,1);
                thisRow.destroy();
            }
        }

        // console.log(objsToDelete); 

        component.set("v.objsToDelete", objsToDelete);
        component.set("v.rowList", rowList);
        component.set("v.body", body);

        helper.getAmtTotal(component);
    },
    handleAmtChange: function(component, event, helper){
        var checkAmountTotals = component.get("v.checkAmountTotals");
        if(!checkAmountTotals){
            return;
        }

        var amountTotal = helper.getAmtTotal(component);

        var preventAmountSurplus = component.get("v.preventAmountSurplus");
        var preventAmountDeficit = component.get("v.preventAmountDeficit");
        var donationAmt = component.get("v.donationAmt");
        //var amountTotal = component.get("v.amountTotal");
        // console.log(donationAmt);
        // console.log(amountTotal);
        // If there is a donation amount and a total, and they do not match, show message
        var amtError = $A.get("$Label.c.Warning");
        var amountsDoNotMatch = donationAmt && amountTotal && (donationAmt != amountTotal);
        var preventSubmit = false;
        if(amountTotal > donationAmt){
            if(preventAmountSurplus){
                amtError = $A.get("$Label.c.Error");
                preventSubmit = true;
            }
            amtError += ' : ' + $A.get("$Label.c.Gift_Amounts_Greater_than_Donation");
        } else if(amountsDoNotMatch){
            if(preventAmountDeficit){
                amtError = $A.get("$Label.c.Error");
                preventSubmit = true;
            }
            amtError += ' : ' + $A.get("$Label.c.Gift_Amounts_Do_Not_Match");
        } else {
            amtError = '';
        }
        component.set("v.preventSubmit", preventSubmit);
        component.set("v.amountError", amtError);

        component.set("v.checkAmountTotals", false);
    }
})