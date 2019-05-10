({
    doInit : function(component, event, helper) {
        console.log('dynamic field display section controller');
        var picklistValue = component.get('v.pickListValue');
        var fieldList = component.get('v.fieldList');
        var fieldNameToFieldLabel = component.get('v.fieldNameToFieldLabel')

        var customMetadataJSON = helper.createAllInputs(component, picklistValue, fieldList, fieldNameToFieldLabel );
    }
})
