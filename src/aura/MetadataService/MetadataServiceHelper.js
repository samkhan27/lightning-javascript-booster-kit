({
	execute: function(cmp, event, method) {
 		var params = event.getParam("arguments").params || {};
 		params.onSuccess = this.callback(params.onSuccess, params.context);
 		params.onError = this.callback(params.onError, params.context);
 		this.promise(method.bind(this, cmp, params)).then(params.onSuccess, params.onError);
	},
	executeServerAction: function(cmp, method, params){
    	return this.enqueueAction($A.enqueueAction, cmp, method, params, true).then(this.parseResponse);
    },
    parseResponse: function(response){
    	var defer = this.deferred();
    	if(response && response.isSuccess) defer.resolve(this.parseJSON(response.data));
    	else defer.reject(response.errorMessage);
    	return defer.promise;
    },
    getRecordTypes: function(cmp, params, resolve, reject) {
		var params = { objectName: params.objectName };
		this.executeServerAction(cmp, 'getRecordTypes', params)
		.then(this.partial(this.map, this, (item) => { return { id: item.Id, name: item.DeveloperName, label: item.Name }; }))
		.then(resolve, reject);
	},
	getRecordTypesMap: function(cmp, params, resolve, reject) {
		var params = { objectName: params.objectName };
		this.executeServerAction(cmp, 'getRecordTypes', params)
		.then(this.partial(this.reduce, this, (map, item) => { map[item.DeveloperName] = item.Id; return map; }, {}))
		.then(resolve, reject);
	},
	getPicklistValues: function(cmp, params, resolve, reject){
		var params = { objectName: params.objectName, fieldName: params.fieldName };
		this.executeServerAction(cmp, 'getPicklistValues', params).then(resolve, reject);
	},
	getChildRelationships: function(cmp, params, resolve, reject){
		var params = { objectName: params.objectName };
		this.executeServerAction(cmp, 'getChildRelationships', params).then(resolve, reject);
	},
	getQuickActions: function(cmp, params, resolve, reject){
		var params = { objectName: params.objectName };
		this.executeServerAction(cmp, 'getQuickActions', params).then(resolve, reject);
	},
	getLightningQuickActions: function(cmp, params, resolve, reject){
		var params = { objectName: params.objectName };
		this.executeServerAction(cmp, 'getLightningQuickActions', params).then(resolve, reject);
	},
	getObjectName: function(cmp, params, resolve, reject){
		var params = { recordId: params.recordId };
		this.executeServerAction(cmp, 'getObjectName', params).then(resolve, reject);
	}
})