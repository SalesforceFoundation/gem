({
    clickAddRow: function(component, event, helper) {
        var wasLoadEvent = event.getParam("value");
        var itemList = component.get("v.itemList");
        // Only add a row on init if we aren't loading existing data
        if(!wasLoadEvent || wasLoadEvent && itemList && itemList.length == 0){
            helper.handleAddRow(component, helper);
        }
    },
    handleJsonUpdate: function(component, event, helper) {
        // Reset the duplicate checking array
        component.set("v.noDuplicateValueList", []);
        var validRows = helper.validateRows(component);
        var isValid = validRows;
        // If there are no rows, the JSON gets overwritten
        helper.updateJsonObject(component, validRows);
        return isValid;
    },
    handleItemListChange: function(component, event, helper){
        // Called when the item list is completely overwritten
        // Ex. Calculating Payment schedule, or loading existing data

        // First, clear the existing rows
        component.set("v.body", []);
        component.set("v.rowList", []);
        
        // Now add the passed in objects to the rowList
        var itemList = event.getParam("value");
        itemList = helper.proxyToObj(itemList);
        console.log('itemList'); 
        console.log(itemList); 
        if(!itemList){
            return;
        }

        for(var i=0; i<itemList.length; i++){
            helper.handleAddRow(component, helper, itemList[i], i);
        }
        component.set("v.showAmountError", false);
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