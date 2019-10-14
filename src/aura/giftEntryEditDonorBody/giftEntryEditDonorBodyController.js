({
    handleMessage: function(component, event) {
        var channel = event.getParam('channel');
        var message = event.getParam('message');
        if(channel === 'editDonorModal' && message === 'save') {
            component.find('donorEditForm').submit();
        }
    },
    handleSuccess: function(component, event, helper) {
        helper.sendMessage('success');
    },
    handleCancel: function(component, event, helper) {
        helper.sendMessage('cancel');
    },
    handleSubmit: function(component, event, helper) {
        component.set('v.showSpinner', true);
    },
    handleError: function(component, event, helper) {
        component.set('v.showSpinner', false);
    }
});