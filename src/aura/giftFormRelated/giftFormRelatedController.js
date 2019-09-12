({
    clickAddRow: function(component, event, helper) {
        helper.addSingleRow(component, helper);
        // Call addRowEvent, currently only used by the Payment Scheduler component
        var thisObj = component.get('v.objectName');
		var sendMsgEvent = $A.get('e.ltng:sendMessage');
		sendMsgEvent.setParams({
            'message': thisObj,
			'channel': 'addRowEvent'
		});
		sendMsgEvent.fire();
    },
    handleInitRows: function(component, event, helper) {
        var itemList = component.get('v.itemList');
        if(itemList && itemList.length != 0){
            // If an itemList was provided on load, add it now that picklist values are available
            helper.createRowsFromItemList(component, helper);
        }
        component.set('v.initFinished', true);
    },
    handleJsonUpdate: function(component, event, helper) {
        // Reset the duplicate checking array
        component.set('v.noDuplicateValueList', []);
        var validRows = helper.validateRows(component);
        // If there are no rows, the JSON gets overwritten
        helper.updateModelObject(component, validRows);
        return validRows;
    },
    handleItemListChange: function(component, event, helper){
        // In the payment scheduler, this event gets called twice so we prevent it one time
        var blockChange = component.get('v.blockItemChangeEvent');
        var thisObj = component.get('v.objectName');
        var rowList = component.get('v.rowList');

        // If Payments are being overwritten, call delete on each of them first
        if(thisObj === 'npe01__OppPayment__c' && rowList.length > 0){
            helper.deleteAll(component);
        }

        // We are overwriting the payment list with a matching Opportunity, force this through
		if(component.get('v.disablePaymentEvents')){
            blockChange = false;
        }

        // On load, since the itemlist comes in before the picklist values are set,
        // we need to wait for the picklists before processing the rows
        if(component.get('v.initFinished') && !blockChange){
            helper.createRowsFromItemList(component, helper);
        }
    },
    handleAmtChange: function(component, event, helper){
        if(component.get('v.disablePaymentEvents')){
            return;
        }
        var checkAmountTotals = component.get('v.checkAmountTotals');
        if(checkAmountTotals){
            helper.handleAmtChangeHelper(component);
        }
    },
    handleMessage: function(component, event, helper){
        var channel = event.getParam('channel');

        if(channel === 'deleteRowEvent'){
            helper.handleRowDelete(component, helper);
        } else if(channel === 'amtChange'){
            var thisObj = component.get('v.objectName');
            // If the amount changes, we want to force validation on the Payment scheduler
            if(thisObj === 'npe01__OppPayment__c'){
                helper.handleAmtChangeHelper(component, true);
            }
        }
    },
    toggleRelatedSection: function(component, event, helper) {
        component.set('v.expandSection', !component.get('v.expandSection'));
    },
    getRelatedObject: function(component){
        return component.get("v.objectName");
    },
    addNewRowAndFocus: function(component, event, helper){
        // component.set("v.addNewRowAfterInit", true);
        var btn = component.find('add-button');
        if(btn){
            btn.focus();
        }
    },
    disableAddButton: function(component, event, helper){
        var params = event.getParam('arguments');
		var disableBtn = false;
		if(params){
			disableBtn = params.disableBtn;
        }
        component.set("v.addButtonDisabled", disableBtn);
    }
})