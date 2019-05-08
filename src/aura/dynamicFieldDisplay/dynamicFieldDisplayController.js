({
    doInit : function(component, event, helper) {
        var customMetadataRecordName = component.get('v.metadataRecordName');

        var customMetadataJSON = helper.getCustomMetadata(component, customMetadataRecordName);
        console.log('custom metadata json');
        console.log(customMetadataJSON);
    }
})
