({
    handlePercentChange: function(component, event, helper){
        // Set the amount based on this percent so we can check totals
        var percentInput = component.get('v.item.npsp__Percent__c');
        if(!percentInput){
            component.set('v.item.npsp__Percent__c', null);
            return;
        }
        
        var percent = Math.round((+percentInput + 0.00001) * 100) / 100;
        component.set('v.item.npsp__Percent__c', percent);

        var donationAmt = component.get('v.donationAmt');
        var amt = Math.floor(percent * donationAmt) / 100;

        component.set('v.item.npsp__Amount__c', amt);

        // Also trigger a change event to check totals
        helper.amountCheck(component, event, helper);
    }
})