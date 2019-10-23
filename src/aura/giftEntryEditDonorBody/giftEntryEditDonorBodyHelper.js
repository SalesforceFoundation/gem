({
    sendMessage: function(message) {
        const msg = $A.get('e.ltng:sendMessage');
        msg.setParams({
            channel: 'editDonorModal',
            message: message
        });
        msg.fire();
    },
    showSpinner: function(component) {
        component.set('v.showSpinner', true);
    },
    hideSpinner: function(component) {
        component.set('v.showSpinner', false);
    }
});