({
    handlePercentChange: function(component, event, helper){
        // Set the amount based on this percent so we can check totals
        var donationAmt = component.get("v.donationAmt");
        var percent = component.get("v.item.npsp__Percent__c");
        if(!percent){
            return;
        }
        var amt = percent * donationAmt / 100;
        component.set("v.item.npsp__Amount__c", amt);
        // Also trigger a change event to check totals
        helper.amountCheck(component, event, helper);
    }
})