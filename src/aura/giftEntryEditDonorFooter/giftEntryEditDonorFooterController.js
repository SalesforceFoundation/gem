({
    cancelClick: function(component, event, helper) {
        helper.sendMessage('save');
    },
    saveClick: function(component, event, helper) {
        helper.sendMessage('cancel');
    }
});