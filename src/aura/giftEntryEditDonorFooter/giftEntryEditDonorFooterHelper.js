({
    sendMessage: function(message) {
        const msg = $A.get('e.ltng:sendMessage');
        msg.setParams({
            channel: 'editDonorModal',
            message: message
        });
        msg.fire();
            }
});