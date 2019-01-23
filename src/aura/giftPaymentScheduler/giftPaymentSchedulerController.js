({
	handlePaymentsChange: function(component, event, helper){
		// Gets called twice (once while bubbling up, once from the parent change)
		// We only want to event to fire once, boolean is toggled to handle this
		var blockChange = component.get('v.blockItemChangeEvent');
		component.set('v.blockItemChangeEvent', !blockChange);
		var paymentList = component.get('v.paymentList');
		if(paymentList.length > 0){
			component.set('v.showPayments', true);
		}
    },
	clickCalculate: function(component, event, helper) {
		component.set('v.userInteracted', true);
		helper.clickCalculateHelper(component, false);
	},
	handleAmtChange: function(component, event, helper) {
		var donationAmt = component.get('v.donationAmt');
		var btn = component.find('calcButton');
		// Enable the calculate button if a valid amount is entered
		if(btn){
			var validAmount = (donationAmt > 0);
			btn.set('v.disabled',!validAmount);
		}
	},
	handleMethodChange: function(component, event, helper) {
		var paymentMethod = component.get('v.paymentMethod');
		component.set('v.selectedPaymentMethod', paymentMethod);
	},
	toggleRelatedSection: function(component, event, helper) {
        component.set('v.expandSection', !component.get('v.expandSection'));
	},
	createDefaultPayment: function(component, event, helper){
		// Only overwrite the payment if the user has not used the scheduler
		if(!component.get('v.userInteracted')){
			helper.clickCalculateHelper(component, true);
		}
	},
	handleMessage: function(component, event, helper){
		var channel = event.getParam('channel');
		
        if(channel == 'addRowEvent'){
            component.set('v.userInteracted', true);
        }
    }
})