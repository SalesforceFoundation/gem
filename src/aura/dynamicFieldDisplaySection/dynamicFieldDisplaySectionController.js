({
    doInit : function(component, event, helper) {
        helper.processSobjectRecord(component);
        var picklistValue = component.get('v.pickListValue');
        var fieldList = component.get('v.fieldList');
        var fieldNameToFieldLabel = component.get('v.fieldNameToFieldLabel')
        var controllingField = component.get('v.controllingField');

        var customMetadataJSON = helper.createAllInputs(component, controllingField, picklistValue, fieldList, fieldNameToFieldLabel );
    },
    handleSobjectChange : function(component, event, helper) {
        var sobjectRecord = component.get('v.sobjectRecord');
        var controllingField = component.get('v.controllingField');
        var picklistValue = component.get('v.pickListValue');

        helper.handleSobjectChange(component, sobjectRecord, controllingField, picklistValue);
    }

    
})
