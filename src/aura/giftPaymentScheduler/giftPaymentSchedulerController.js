({
	handlePaymentsChange: function(component, event, helper){
		// Gets called twice (once while bubbling up, once from the parent change)
		// We only want to event to fire once, boolean is toggled to handle this
		var blockChange = component.get('v.blockItemChangeEvent');
		component.set('v.blockItemChangeEvent', !blockChange);
		if(blockChange){
			return;
		}
	},
	clickCalculate: function(component, event, helper) {
		component.set('v.userInteracted', true);
		helper.clickCalculateHelper(component, false);
	},
	handleAmtChange: function(component, event, helper) {
		if(component.get('v.disablePaymentEvents')){
            return;
        }
		var donationAmt = component.get('v.donationAmt');
		var btn = component.find('calcButton');
		var calcDisabled = component.get('v.calcButtonDisabled');
		// Enable the calculate button if a valid amount is entered
		if(btn && !calcDisabled){
			var validAmount = (donationAmt > 0);
			btn.set('v.disabled', !validAmount);
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
		var params = event.getParam('arguments');
		var amtWasChanged = false;
		if(params){
			amtWasChanged = params.amtWasChanged;
		}

		// Only overwrite the payment if the user has not used the scheduler yet
		if(!component.get('v.userInteracted')){
			helper.clickCalculateHelper(component, true);
		} else if(amtWasChanged) {
			helper.clearPaymentAmts(component, helper);
		}
	},
	disableCalcButton: function(component, event, helper){
		var btn = component.find('calcButton');
		btn.set('v.disabled', true);
		component.set('v.calcButtonDisabled', true);
	},
	handleMessage: function(component, event, helper){
		var channel = event.getParam('channel');
		
		if(channel == 'addRowEvent'){
			var objectAdded = event.getParam('message');
			if(objectAdded == 'npe01__OppPayment__c'){
				component.set('v.userInteracted', true);
			}
		}
	}
})