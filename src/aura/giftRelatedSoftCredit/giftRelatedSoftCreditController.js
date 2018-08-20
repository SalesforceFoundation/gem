({
	handleTypeChange: function(component, event, helper) {
		var newType = event.getParam("value");
		var donAmt = component.get("v.donationAmt");
		if(newType == 'Full' && donAmt){
			component.set("v.item.npsp__Amount__c", donAmt);
		}
	}, 
	handleAmountCheck: function(component, event, helper) {
		var donAmt = component.get("v.donationAmt");
		var newAmt = component.get("v.item.npsp__Amount__c");
		if(newAmt == donAmt){
			component.set("v.creditType", "Full");
		} else {
			component.set("v.creditType", "Partial");
		}
	},
	handleDonationChange: function(component, event, helper) {
		var newAmt = event.getParam("value");
		var creditType = component.get("v.creditType");
		if(creditType == 'Full' && newAmt){
			component.set("v.item.npsp__Amount__c", newAmt);
		}
	},
})