({
    handlePercentChange: function(component, event, helper){
        // Set the amount based on this percent so we can check totals
        var percentInput = component.get('v.item.npsp__Percent__c');
        if(!percentInput){
            component.set('v.item.npsp__Percent__c', null);
            return;
        }

        var donationAmt = component.get('v.donationAmt');

        // Get the percentage as a decimal.
        var percent = +percentInput / 100;

        // Figure out what the percentage of the donation amount is.
        var percentageOfAmount = donationAmt * percent;

        // Round the amount to the nearest penny, following the same rounding that NPSP uses
        var actualAmount = Math.round(percentageOfAmount * 100) / 100;

        component.set('v.item.npsp__Amount__c', actualAmount);

        // Also trigger a change event to check totals
        helper.amountCheck(component, event, helper);
    }
})