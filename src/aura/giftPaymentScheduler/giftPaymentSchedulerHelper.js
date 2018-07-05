({
	proxyToObj: function(obj) {
		return JSON.parse(JSON.stringify(obj))
	},
	convertDateToString: function(dateObj){
		return dateObj.toISOString().split('T')[0];
	},
	countDecimals: function(value) {
		if(Math.floor(value) === value) return 0;
		return value.toString().split(".")[1].length || 0;
	}
})