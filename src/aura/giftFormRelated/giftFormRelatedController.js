({
    clickAddRow: function(component, event, helper) {
        helper.handleAddRow(component, helper);
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
        if(thisObj == 'npe01__OppPayment__c' && rowList.length > 0){
            helper.deleteAll(component);
        }

        // On load, since the itemlist comes in before the picklist values are set,
        // we need to wait for the picklists before processing the rows
        if(component.get('v.initFinished') && !blockChange){
            helper.createRowsFromItemList(component, helper);
        }
    },
    handleAmtChange: function(component, event, helper){
        var checkAmountTotals = component.get('v.checkAmountTotals');
        if(checkAmountTotals){
            helper.handleAmtChangeHelper(component);
        }
    },
    handleMessage: function(component, event, helper){
        var message = event.getParam('message');
        var channel = event.getParam('channel');

        if(channel == 'deleteRowEvent'){
            helper.handleRowDelete(component, helper);
        }
    },
    toggleRelatedSection: function(component, event, helper) {
        component.set('v.expandSection', !component.get('v.expandSection'));
    }
})