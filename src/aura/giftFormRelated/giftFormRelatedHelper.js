({
    addRows: function(component, helper, newRowList){
        // Collect all new rows in an array, and add them to the page after they're all created
        Promise.all(newRowList).then($A.getCallback(function(values) {
            helper.setBody(component, helper, values);
        })).catch(function(e) {
            console.log(e);
        });
    },
    distributeRemainder: function(component) {
        const allocationComponents = component.find({instancesOf: 'c:giftRelatedAllocation'});
        const _self = this;
        if(Array.isArray(allocationComponents) && allocationComponents.length > 1) {
            const donationAmount = component.get('v.donationAmt');
            const allocationData = allocationComponents.reduce((acc, val) => {
                const record = val.get('v.item');
                return {
                    percent: acc.percent + _self.isNumber(record.npsp__Percent__c) ? record.npsp__Percent__c : 0,
                    amount: acc.amount + _self.isNumber(record.npsp__Amount__c) ? record.npsp__Amount__c : 0
                };
            }, {percent: 0, amount: 0});

            if(allocationData.percent === 100 && allocationData.amount < donationAmount) {
                const remainderInCents = Math.round((donationAmount * 100) - (allocationData.amount * 100));
                for(let i = 0; i <= remainderInCents; i++) {
                    const allocationComponent = allocationComponents[i];
                    const originalAmount = allocationComponent.get('v.item.npsp__Amount__c');
                    const newAmount = Math.round(((originalAmount * 100) + 1)/100);
                    allocationComponent.set('v.item.npsp__Amount__c', newAmount);
                }
                for(let allocationComponent in allocationComponents) {
                    const amount = allocationComponent.get('v.item.npsp__Amount__c');
                    allocationComponent.set('v.item.npsp__Amount__c')
                }
            }
        }
    },
    handleAddRow: function(component, helper, item, index, canEditRow){

        return new Promise(function(resolve, reject){
            // Now, create the component that contains the fields and pass it the list of data
            var rowList = component.getReference('v.rowList');
            var rowListArray = component.get('v.rowList');
            var newRowNum = index ? index : rowListArray.length;
            var rowCmpName = component.get('v.rowCmpName');
            var objectFieldData = component.get('v.objectFieldData');
            var amtField = component.getReference('v.amtField');
            var donationAmt = component.getReference('v.donationAmt');
            var checkAmountTotals = component.getReference('v.checkAmountTotals');
            var noDuplicateValueList = component.getReference('v.noDuplicateValueList');
            // Passing canEditRow as true forces the row to be editable
            var editMode = (canEditRow === true) ? false : component.get('v.editModeOverride');
            var editModePaidPayments = component.get('v.editModePaidPayments');
            var showLabels = (index === 0 || newRowNum === 0);

            $A.createComponent(
                rowCmpName, {
                    'rowList': rowList,
                    'rowComponent': rowCmpName,
                    'objectFieldData': objectFieldData,
                    'item': item,
                    'donationAmt': donationAmt,
                    'checkAmountTotals': checkAmountTotals,
                    'noDuplicateValueList': noDuplicateValueList,
                    'amtField': amtField,
                    'showLabels': showLabels,
                    'editMode': editMode,
                    'editModePaidPayments': editModePaidPayments
                },
                function(relatedCmp, status, errorMessage){
                    if (status === 'SUCCESS') {
                        resolve(relatedCmp);
                    }
                    else if (status === 'INCOMPLETE') {
                        errorMessage = $A.get('$Label.c.Error_Offline');
                        reject(errorMessage);
                    }
                    else if (status === 'ERROR') {
                        reject(errorMessage);
                    }
                }
            );
        });
    },
    addSingleRow: function(component, helper){
        var cmp = this.handleAddRow(component, helper);
        this.addRows(component, helper, [cmp]);
    },
    setBody: function(component, helper, cmpList){
        var body = component.get('v.body');
        for(var i=0; i<cmpList.length; i++){
            body.push(cmpList[i]);
        }

        // Add the new rows to the page
        component.set('v.body', body);

        helper.getAmtTotal(component);

        // Check amount validation on this section
        this.handleAmtChangeHelper(component);

        // This way, new rows will not be locked
        component.set('v.editModeOverride', false);
    },
    createRowsFromItemList: function(component, helper){
        // Called when the item list is completely overwritten
        // Ex. Calculating Payment schedule, or loading existing data

        // We want a separate editMode variable for this component to override the "lock"
        // on new rows
        var formEditMode = component.get('v.editMode');
        component.set('v.editModeOverride', formEditMode);

        // First, clear the existing rows
        component.set('v.body', []);
        component.set('v.rowList', []);
        
        // Now add the passed in objects to the rowList
        var itemList = component.get('v.itemList');
        itemList = this.proxyToObj(itemList);

        var cmpList = [];
        var i = 0;
        if(itemList instanceof Array){
            for(i=0; i<itemList.length; i++){
                var newCmp = this.handleAddRow(component, helper, itemList[i], i);
                cmpList.push(newCmp);
            }
        }

        // TODO: WIP for adding a new row after init
        if(component.get("v.addNewRowAfterInit")){
            var canEditRow = true;
            var newCmp = this.handleAddRow(component, helper, null, i+1, canEditRow);
            cmpList.push(newCmp);
            component.set("v.addNewRowAfterInit", false);
        }

        this.addRows(component, helper, cmpList);
    },
    handleAmtChangeHelper: function(component, checkForZero){
        var amountTotal = this.getAmtTotal(component);
        var preventAmountSurplus = component.get('v.preventAmountSurplus');
        var preventAmountDeficit = component.get('v.preventAmountDeficit');
        var displayErrorOnAmountSurplus = component.get('v.displayErrorOnAmountSurplus');
        var donationAmt = component.get('v.donationAmt');
        // If there is a donation amount and a total, and they do not match, show message
        var amtError = '';
        component.set('v.messageIsError', false);

        var amtIsNumber = amountTotal;
        if(checkForZero){
            amtIsNumber = amtIsNumber || amountTotal === 0;
        }
        var amountsDoNotMatch = donationAmt && amtIsNumber && (donationAmt != amountTotal);
        var preventSubmit = false;
        if (amountTotal > donationAmt) {
            if (displayErrorOnAmountSurplus) {
                if (preventAmountSurplus) {
                    component.set('v.messageIsError', true);
                    preventSubmit = true;
                }
                amtError += $A.get('$Label.c.Gift_Amounts_Greater_than_Donation');
            }
        } else if(amountsDoNotMatch){
            if(preventAmountDeficit){
                component.set('v.messageIsError', true);
                preventSubmit = true;
            }
            amtError += $A.get('$Label.c.Gift_Amounts_Do_Not_Match');
        } else {
            amtError = '';
        }
        var prevSubmitStatus = component.get('v.preventSubmit');
        component.set('v.preventSubmit', preventSubmit);
        component.set('v.amountError', amtError);

        // If amounts are now valid, check validation of the form
        if(!preventSubmit && prevSubmitStatus){
            // Potential issue when re-calculating payment list, runs unneeded validation
            this.sendValidateMessage();
        }

        // Setting to false will ensure totals get checked again if a change occurs
        component.set('v.checkAmountTotals', false);
    },
    sendValidateMessage: function() {
		// Call validate event, handled by the parent
		var sendMsgEvent = $A.get('e.ltng:sendMessage');
		sendMsgEvent.setParams({
			'channel': 'validateEvent'
		});
		sendMsgEvent.fire();
	},
    handleRowDelete: function(component, helper){
        var relatedRows = helper.getRelatedRows(component);

        var rowList = component.get('v.rowList');
        var body = component.get('v.body');
        var nextRowShowLabels = false;
        rowList = helper.proxyToObj(rowList);

        for(var i=0; i < relatedRows.length; i++){
            // For each remaining row, reset its index and set the first to show labels
            var thisRow = relatedRows[i];
            if(nextRowShowLabels){
                thisRow.set('v.showLabels', true);
                nextRowShowLabels = false;
            }

            if(thisRow.get('v.markedForDelete')){
                var thisItem = thisRow.get('v.item');
                thisItem = helper.proxyToObj(thisItem);
                if(thisRow.get('v.showLabels')){
                    nextRowShowLabels = true;
                }
                body.splice(i,1);
                rowList.splice(i,1);
                thisRow.destroy();
            }
        }
        component.set('v.rowList', rowList);
        component.set('v.body', body);

        // Update error message
        component.set('v.checkAmountTotals', true);
    },
    updateModelObject: function(component, arrayList){
        var attrName = component.get('v.modelAttribute');
        arrayList = this.proxyToObj(arrayList);
        if(!arrayList){
            arrayList = null;
        }
        // Remove any related object info, it causes errors during JSON parsing in Apex
        for(var i in arrayList){
            var relatedObj = arrayList[i];
            for(var j in relatedObj){
                var fieldVal = relatedObj[j];
                if(fieldVal instanceof Object){
                    delete arrayList[i][j];
                }
            }
        }
        component.set('v.giftModel.'+attrName, arrayList);
    },
    validateRows: function(component){
        var preventSubmit = component.get('v.preventSubmit');
        if(preventSubmit){
            return false;
        }
        // Returns valid items or false if there is a validation issue
        var relatedRows = this.getRelatedRows(component);
        var validRows = [];
        var invalidRow = false;
        for(var i=0; i < relatedRows.length; i++){
            var thisRow = relatedRows[i];
            var rowValid = thisRow.checkValidation();
            if(rowValid === undefined){
                // Skip this row, it's either deleted or blank
            } else if(rowValid){
                // Add this row to the array to pass along
                var item = thisRow.get('v.item');
                validRows.push(item);
            } else {
                // There is a row that's invalid, show an error message
                invalidRow = true;
            }
        }

        if(invalidRow){
            return false;
        } else {
            return validRows;
        }
    },
    deleteAll: function(component){
        var relatedRows = this.getRelatedRows(component);
        for(var i=0; i < relatedRows.length; i++){
            var thisRow = relatedRows[i];
            thisRow.clickDeleteRow();
        }
    },
    getAmtTotal: function(component){
        // Returns valid items or false if there is a validation issue
        var relatedRows = this.getRelatedRows(component);
        var totalOfAllRows = 0;
        for(var i=0; i < relatedRows.length; i++){
            var thisRow = relatedRows[i];
            // Make sure the return is a number
            var rowAmt = +thisRow.returnRowAmount();
            if(rowAmt){
                totalOfAllRows += rowAmt;
            }
        }
        totalOfAllRows = Math.round(totalOfAllRows * 100) / 100;
        component.set('v.amountTotal', totalOfAllRows);
        return totalOfAllRows;
    },
    getRelatedRows: function(component){
        var rowCmpName = component.get('v.rowCmpName');
        return component.find({instancesOf:rowCmpName});
    },
    proxyToObj: function(attr){
        // Used to convert a Proxy object to an actual Javascript object
        return JSON.parse(JSON.stringify(attr));
    },
    isNumber: function(val) {
        return !(Array.isArray(val) && (val - parseFloat(val)) + 1 >= 0);
    }
})