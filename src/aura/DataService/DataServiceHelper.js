({
	execute: function(cmp, event, method) {
 		var params = event.getParam("arguments").params || {};
 		params.onSuccess = this.callback(params.onSuccess, params.context);
 		params.onError = this.callback(params.onError, params.context);
 		this.promise(method.bind(this, cmp, params)).then(params.onSuccess, params.onError);
	},
	executeServerAction: function(cmp, method, params, storable){
    	return this.enqueueAction($A.enqueueAction, cmp, method, params, storable).then(this.parseResponse);
    },
    parseResponse: function(response){
    	var defer = this.deferred();
    	if(response && response.isSuccess) defer.resolve(this.parseJSON(response.data));
    	else defer.reject(response.errorMessage);
    	return defer.promise;
    },
    executeQuery: function(cmp, params, resolve, reject){
		var params = { query: params.query };
		this.executeServerAction(cmp, 'executeQuery', params).then(resolve, reject);
	},
	getRecord: function(cmp, params, resolve, reject) {
		var params = { recordId: params.recordId, fields: params.fields || [] };
		this.executeServerAction(cmp, 'getRecord', params).then(resolve, reject);
	},
	getRecords: function(cmp, params, resolve, reject) {
		var params = { objectName: params.objectName, fields: params.fields || [], whereClause: params.whereClause };
		this.executeServerAction(cmp, 'getRecords', params).then(resolve, reject);
	},
	getFieldSetData: function(cmp, params, resolve, reject) {
		var params = { 
			objectName: params.objectName, fieldSetName: params.fieldSetName, 
			additionalFields: params.additionalFields, whereClause: params.whereClause 
		};
		this.executeServerAction(cmp, 'getFieldSetData', params).then(resolve, reject);
	},
	createRecord: function(cmp, params, resolve, reject){
		var params = { objectName: params.objectName, defaultFieldValues: params.defaultFieldValues };
		this.executeServerAction(cmp, 'createRecord', params).then(resolve, reject);
	},
	updateRecord: function(cmp, params, resolve, reject){
		var params = { recordId: params.recordId, fieldValues: params.fieldValues };
		this.executeServerAction(cmp, 'updateRecord', params).then(resolve, reject);
	},
	deleteRecord: function(cmp, params, resolve, reject) {
		var params = { recordId: params.recordId };
		this.executeServerAction(cmp, 'deleteRecord', params).then(resolve, reject);
	}
})