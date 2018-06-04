({
	doInit: function(component, event, helper) {
        var today = new Date();
        component.set('v.startDate', helper.convertDateToString(today));
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

		// Calcualte data for payments
		for(var i=0; i<paymentNum; i++){
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

			var paymentAmt = amt / paymentNum;
			if(helper.countDecimals(paymentAmt) > 2 ){
				// The amount is a repeating decimal, round down
				paymentAmt = Math.round(paymentAmt * 100) / 100;
				// To add up to the total, a single payment rounds up
				if(i==0){
					paymentAmt += 0.01;
				}
			}

			singlePayment = helper.proxyToObj(singlePaymentProxy);
			singlePayment.npe01__Payment_Date__c = helper.convertDateToString(dateObject);
			singlePayment.npe01__Payment_Amount__c = paymentAmt;
			singlePayment.npe01__Payment_Method__c = paymentMethod;
			paymentList.push(singlePayment);
		}
		component.set("v.payments", paymentList);
		component.set("v.showPayments", true);
	}
})