({
	doInit: function(component, event, helper) {
        var today = new Date();
        component.set('v.startDate', helper.convertDateToString(today));
	},
	handlePaymentsChange: function(component, event, helper){
		// Gets called twice, we only want to event to fire once
		var blockChange = component.get("v.blockItemChangeEvent");
		component.set("v.blockItemChangeEvent", !blockChange);
		component.set("v.showPayments", true);
    },
	clickCalculate: function(component, event, helper) {
		component.set("v.calculateButtonLabel", "Clear and Calculate New Payments");
		// Based on inputs, auto-generate payments for this Donation
		var amt = component.get("v.donationAmt");
		var paymentMethod = component.get("v.selectedPaymentMethod");
		var intervalFreq = component.get("v.intervalFreq");
		var intervalNum = component.get("v.intervalNum");
		var paymentNum = component.get("v.paymentNum");
		var startDate = component.get("v.startDate");
		
		var singlePaymentProxy = component.get("v.singlePayment");
		var paymentList = [];
		var singlePayment;
		var dateObject;

		var paymentAmt = amt / paymentNum;
        var remainder = (amt * 100) % paymentNum;

		// Calcualte data for payments
		for(var i=0; i<paymentNum; i++){
			var thisPayment = paymentAmt;
			dateObject = new Date(startDate);
			if(i > 0){
				var interval = i*intervalNum;
				// Figure out what the date should be
				if(intervalFreq == 'Week'){
					dateObject.setDate(dateObject.getDate() + interval * 7);
				} else if(intervalFreq == 'Month'){
					dateObject.setMonth(dateObject.getMonth() + interval);
				} else if(intervalFreq == 'Year'){
					dateObject.setFullYear(dateObject.getFullYear() + interval);
				}
			}
			
			if(helper.countDecimals(thisPayment) > 2 ){
				// Round down to the nearest decimal
				thisPayment = Math.floor(thisPayment * 100) / 100;
				// If there was a remainder, add it here
				if(i < remainder){
					thisPayment += 0.01;
				}
				thisPayment = Math.round(thisPayment * 100) / 100;
			}

			singlePayment = helper.proxyToObj(singlePaymentProxy);
			singlePayment.npe01__Scheduled_Date__c = helper.convertDateToString(dateObject);
			singlePayment.npe01__Payment_Amount__c = thisPayment;
			singlePayment.npe01__Payment_Method__c = paymentMethod;
			paymentList.push(singlePayment);
		}
		
		// console.log('paymentList:'); 
		// console.log(paymentList); 

		component.set("v.paymentList", paymentList);
	},
	handleAmtChange: function(component, event, helper) {
		var donationAmt = component.get("v.donationAmt");
		var btn = component.find('calcButton');
		// Enable the calculate button if valid amount is entered
		if(btn){
			var validAmount = (donationAmt > 0);
			btn.set('v.disabled',!validAmount);
		}
	},
	handleMethodChange: function(component, event, helper) {
		var paymentMethod = component.get("v.paymentMethod");
		component.set("v.selectedPaymentMethod", paymentMethod);
	}
})