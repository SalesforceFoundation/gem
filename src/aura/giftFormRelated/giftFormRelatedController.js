({
	doInit: function(component, event, helper) {
        // Add the initial row
        helper.handleAddRow(component);
    },
    clickAddRow: function(component, event, helper) {
        helper.handleAddRow(component);
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
        // Called when the item list is overwritten
        // Ex. Calculating multiple Payments

        // First, clear the existing rows
        component.set("v.body", []);
        component.set("v.rowList", []);

        // Set the starting total to the donation amount
        var donationAmt = component.get("v.donationAmt");
        component.set("v.amountTotal", +donationAmt);
        
        // Now add the calculated payments
        var itemList = event.getParam("value");
        itemList = helper.proxyToObj(itemList);
        //console.log(itemList);
        for(var i=0; i<itemList.length; i++){
            helper.handleAddRow(component, itemList[i], i);
        }
        component.set("v.showAmountError", false);
    },
    handleAmtChange: function(component, event, helper){
        var checkAmountTotals = component.get("v.checkAmountTotals");
        if(!checkAmountTotals){
            return;
        }
        var preventAmountSurplus = component.get("v.preventAmountSurplus");
        var donationAmt = component.get("v.donationAmt");
        var amountTotal = component.get("v.amountTotal");
        // console.log(donationAmt);
        // console.log(amountTotal);
        // If there is a donation amount and a total and they do not match, show message
        var amtError = '';
        var showError = donationAmt && amountTotal && (donationAmt != amountTotal);
        if(amountTotal > donationAmt && preventAmountSurplus){
            // Prevent submission of form
            component.set("v.preventSubmit", true);
            amtError = $A.get("$Label.c.Gift_Amounts_Greater_than_Donation");
        } else if(showError){
            amtError = $A.get("$Label.c.Gift_Amounts_Do_Not_Match");
        } else {
            component.set("v.preventSubmit", false);
        }
        component.set("v.amountError", amtError);
    }
})