({
	proxyToObj: function(attr){
        // Used to convert a Proxy object to an actual Javascript object
        return JSON.parse(JSON.stringify(attr));
	}
})