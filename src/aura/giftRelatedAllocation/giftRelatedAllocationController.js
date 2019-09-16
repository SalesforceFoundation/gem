({
    handlePercentChange: function(component, event, helper){
        // Set the amount based on this percent so we can check totals
        var percentInput = component.get('v.item.npsp__Percent__c');
        if(!percentInput){
            component.set('v.item.npsp__Percent__c', null);
            return;
        }

        // NOTE: This calculation will NOT work with negative numbers.
        var donationAmt = component.get('v.donationAmt');

        // Get the percentage as a decimal.
        var percent = (Math.round((+percentInput + 0.00001) * 100) / 100)/100;

        // Figure out what the percentage of the donation amount is.
        // We multiply by 100 so we can use the floor function as a replacement
        // for the truncate function. 
        var percentageOfAmount = donationAmt * percent * 100;

        // Get the floor so that in cases where the amount is an odd number, we can divide evenly
        // and give the left over penny to the default.
        var flooredPercentageAmount = Math.floor(percentageOfAmount);
        var actualAmount = flooredPercentageAmount / 100;

        component.set('v.item.npsp__Amount__c', actualAmount);

        // Also trigger a change event to check totals
        helper.amountCheck(component, event, helper);
    }
})