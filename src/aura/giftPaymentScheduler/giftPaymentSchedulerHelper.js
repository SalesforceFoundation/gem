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
					dateObject.setUTCMonth(dateObject.getUTCMonth() + interval);
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

			var firstPaymentClosed = false;
			if(i == 0 && isClosedWon){
				firstPaymentClosed = true;
			}

			singlePayment = this.setPaymentFields(singlePaymentProxy, firstPaymentClosed, dateObject, thisPayment, paymentMethod);
			paymentList.push(singlePayment);
		}

		component.set('v.paymentList', paymentList);
	},
	setDefaults: function(component) {
		// For new forms, set Date to Today, otherwise use existing value
        var curDate = component.get('v.startDate');
        if(!curDate) {
            // Set Close Date to Today
            var closeDate = new Date();
            closeDate = this.convertDateToString(closeDate);
            component.set('v.startDate', closeDate);
        }
	},
	setPaymentFields: function(paymentProxy, paymentPaid, date, amt, method){
		var singlePayment = this.proxyToObj(paymentProxy);
		var strDate = this.convertDateToString(date);
		singlePayment.npe01__Scheduled_Date__c = strDate;
		if(paymentPaid){
			// singlePayment.npe01__Payment_Date__c = strDate;
			// singlePayment.npe01__Paid__c = true;
		}
		singlePayment.npe01__Payment_Amount__c = amt;
		singlePayment.npe01__Payment_Method__c = method;
		return singlePayment;
	},
	clearPaymentAmts: function(component){
		var paymentList = this.getChildRows(component);
		if(paymentList.length < 1){
			return;
		}
		for(var i = 0; i < paymentList.length; i++){
			paymentList[i].clearAmount();
		}
		// Call validate event, handled by the parent
		var sendMsgEvent = $A.get('e.ltng:sendMessage');
		sendMsgEvent.setParams({
			'channel': 'amtChange'
		});
		sendMsgEvent.fire();
	},
	getChildRows: function(component){
		var rowCmpName = component.get('v.rowCmpName');
        var formWrapper = component.find('paymentWrap');
        return formWrapper.find({instancesOf:rowCmpName});
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