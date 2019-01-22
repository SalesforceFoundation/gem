({
	clickCalculateHelper: function(component, createDefault){
		component.set('v.calculateButtonLabel', $A.get('$Label.c.Gift_Clear_Calculate_Payments'));
		// Based on inputs, auto-generate payments for this Donation
		var amt = component.get('v.donationAmt');
		var paymentMethod = component.get('v.selectedPaymentMethod');
		var intervalFreq = component.get('v.intervalFreq');
		var intervalNum = component.get('v.intervalNum');
		var paymentNum = component.get('v.paymentNum');
		var startDate = component.get('v.startDate');
		var stageName = component.get('v.donationStage');
		var stageMap = this.proxyToObj(component.get('v.objectFieldData.closedWonStageMap'));
		var isClosedWon = stageMap[stageName];
		
		var singlePaymentProxy = component.get('v.singlePayment');
		var paymentList = [];
		var singlePayment;
		var dateObject = new Date(startDate);

		var paymentAmt = amt / paymentNum;
		var remainder = (amt * 100) % paymentNum;
		
		if(createDefault){
			singlePayment = this.setPaymentFields(singlePaymentProxy, isClosedWon, dateObject, amt, paymentMethod);
			paymentList.push(singlePayment);
		}

		// Calcualte data for payments
		for(var i=0; i<paymentNum; i++){
			if(createDefault)
				break;

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

			singlePayment = this.setPaymentFields(singlePaymentProxy, isClosedWon, dateObject, thisPayment, paymentMethod);
			paymentList.push(singlePayment);
		}

		component.set('v.paymentList', paymentList);
	},
	setPaymentFields: function(paymentProxy, isClosedWon, date, amt, method){
		var singlePayment = this.proxyToObj(paymentProxy);
		var strDate = this.convertDateToString(date);
		singlePayment.npe01__Scheduled_Date__c = strDate;
		if(isClosedWon){
			singlePayment.npe01__Payment_Date__c = strDate;
			singlePayment.npe01__Paid__c = true;
		}
		singlePayment.npe01__Payment_Amount__c = amt;
		singlePayment.npe01__Payment_Method__c = method;
		return singlePayment;
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