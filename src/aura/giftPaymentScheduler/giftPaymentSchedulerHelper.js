({
	clickCalculateHelper: function(component){
		component.set('v.calculateButtonLabel', $A.get('$Label.c.Gift_Clear_Calculate_Payments'));
		// Based on inputs, auto-generate payments for this Donation
		var amt = component.get('v.donationAmt');
		var paymentMethod = component.get('v.selectedPaymentMethod');
		var intervalFreq = component.get('v.intervalFreq');
		var intervalNum = component.get('v.intervalNum');
		var paymentNum = component.get('v.paymentNum');
		var startDate = component.get('v.startDate');
		
		var singlePaymentProxy = component.get('v.singlePayment');
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
			
			if(this.countDecimals(thisPayment) > 2 ){
				// Round down to the nearest decimal
				thisPayment = Math.floor(thisPayment * 100) / 100;
				// If there was a remainder, add it here
				if(i < remainder){
					thisPayment += 0.01;
				}
				thisPayment = Math.round(thisPayment * 100) / 100;
			}

			singlePayment = this.proxyToObj(singlePaymentProxy);
			singlePayment.npe01__Scheduled_Date__c = this.convertDateToString(dateObject);
			singlePayment.npe01__Payment_Amount__c = thisPayment;
			singlePayment.npe01__Payment_Method__c = paymentMethod;
			paymentList.push(singlePayment);
		}

		component.set('v.paymentList', paymentList);
	},
	proxyToObj: function(obj) {
		return JSON.parse(JSON.stringify(obj))
	},
	convertDateToString: function(dateObj){
		return dateObj.toISOString().split('T')[0];
	},
	countDecimals: function(value) {
		if(Math.floor(value) === value) return 0;
		return value.toString().split(".")[1].length || 0;
	}
})