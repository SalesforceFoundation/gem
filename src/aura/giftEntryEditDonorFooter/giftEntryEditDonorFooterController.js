({
    cancelClick: function(component, event, helper) {
        helper.sendMessage('cancel');
    },
    saveClick: function(component, event, helper) {
        helper.sendMessage('save');
    }
});