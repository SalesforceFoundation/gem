({
	handleAmountCheckHelper: function(component) {
		// Also call the event from the parent row component
		this.amountCheck(component);
		var donAmt = component.get('v.donationAmt');
		var newAmt = component.get('v.item.npsp__Amount__c');
		if(!newAmt){
			return;
		}
		if(newAmt == donAmt){
			component.set('v.creditType', $A.get('$Label.c.Full'));
		} else {
			component.set('v.creditType', $A.get('$Label.c.Partial'));
		}
	}
})