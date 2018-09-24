({
	doInit: function(component, event, helper) {
        var today = new Date();
        component.set('v.startDate', helper.convertDateToString(today));
	},
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
		helper.clickCalculateHelper(component);
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
    }
})