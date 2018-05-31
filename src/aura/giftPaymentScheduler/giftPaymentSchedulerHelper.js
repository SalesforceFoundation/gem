({
	proxyToObj: function(obj) {
		return JSON.parse(JSON.stringify(obj))
	},
	convertDateToString: function(dateObj){
		return dateObj.toISOString().split('T')[0];
	}
})