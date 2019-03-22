({
    handleAddRow: function(component, helper, item, index){
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
    
        var showLabels = false;
        if(newRowNum == 0){
            showLabels = true;
        }

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
                'showLabels': showLabels
            },
            function(relatedCmp, status, errorMessage){
                if (status === 'SUCCESS') {
                    // Add the component to the page
                    var body = component.get('v.body');
                    body.push(relatedCmp);
                    component.set('v.body', body);

                    // TODO Could clean this up by only calling after final row is added
                    helper.getAmtTotal(component);
                }
                else if (status === 'INCOMPLETE') {
                    console.log($A.get('$Label.c.Error_Offline'));
                }
                else if (status === 'ERROR') {
                    console.log($A.get('$Label.c.Error') + ': ' + errorMessage);
                }
            }
        );
    },
    createRowsFromItemList: function(component, helper){
        // Called when the item list is completely overwritten
        // Ex. Calculating Payment schedule, or loading existing data

        // First, clear the existing rows
        component.set('v.body', []);
        component.set('v.rowList', []);
        
        // Now add the passed in objects to the rowList
        //var itemList = event.getParam('value');
        var itemList = component.get('v.itemList');
        itemList = this.proxyToObj(itemList);

        if(itemList instanceof Array){
            for(var i=0; i<itemList.length; i++){
                this.handleAddRow(component, helper, itemList[i], i);
            }
        }
        component.set('v.showAmountError', false);
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
    }
})