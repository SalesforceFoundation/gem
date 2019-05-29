({
    doInit : function(component, event, helper) {
        helper.processSobjectRecord(component);
    },
    handleSobjectChange : function(component, event, helper) {
        var sobjectRecord = component.get('v.sobjectRecord');
        var controllingField = component.get('v.controllingField');
        var picklistValue = component.get('v.pickListValue');

        helper.handleSobjectChange(component, sobjectRecord, controllingField, picklistValue);
    }
})
