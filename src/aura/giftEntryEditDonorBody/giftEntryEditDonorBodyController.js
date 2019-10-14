({
    handleMessage: function(component, event, helper) {
        var channel = event.getParam('channel');
        var message = event.getParam('message');
        if(channel === 'editDonorModal' && message === 'save') {
            helper.showSpinner(component);
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
        helper.showSpinner(component);
    },
    handleError: function(component, event, helper) {
        helper.hideSpinner(component);
    }
});