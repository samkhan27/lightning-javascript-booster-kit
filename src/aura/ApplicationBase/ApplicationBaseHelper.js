({
    //getters-setters
    getRecordId: function(cmp){ return cmp.get("v.recordId"); },
    getState: function(cmp){ return cmp.get("v.state") || {}; },
    getActions: function(cmp){ return cmp.get("v.actions"); },
    setRecordId: function(cmp, recordId){ cmp.set("v.recordId", recordId); },
    setState: function(cmp, state){ cmp.set("v.state", state || {}); },
    saveState: function(cmp, state){ this.setState(cmp, this.extend(this.getState(cmp), state)); },
    setActions: function(cmp, actions){ cmp.set("v.actions", actions || []); },

    //data and metadata services
    dataService: null, dataServiceWrapper: null, pendingDataServiceRequests: {},
    metadataService: null, metadataServiceWrapper: null, pendingMetadataServiceRequests: {},
    dataServiceMethods: [
        "executeQuery", "getRecord", "getRecords", "getFieldSetData", "createRecord", "updateRecord", "deleteRecord"
    ],
    metadataServiceMethods: [
        "getObjectName", "getRecordTypes", "getRecordTypesMap", "getPicklistValues", "executeQuery", 
        "getChildRelationships", "getQuickActions", "getLightningQuickActions"
    ],
    getDataService: function(cmp){ 
        if(this.isEmpty(this.dataServiceWrapper)) this.dataServiceWrapper = this.getServiceWrapper("data"); 
        if(this.isEmpty(this.dataService)) this.initService(cmp, "data");
        return this.dataServiceWrapper;  
    },
    getMetadataService: function(cmp){ 
        if(this.isEmpty(this.metadataServiceWrapper)) this.metadataServiceWrapper = this.getServiceWrapper("metadata"); 
        if(this.isEmpty(this.metadataService)) this.initService(cmp, "metadata");
        return this.metadataServiceWrapper;  
    },
    getService: function(type){
        return type === "data" ? this.dataService : this.metadataService;
    },
    getServiceMethods: function(type){
        return type === "data" ? this.dataServiceMethods : this.metadataServiceMethods;
    },
    getServicePendingRequests: function(type){
        return type === "data" ? this.pendingDataServiceRequests : this.pendingMetadataServiceRequests;
    },
    getServiceWrapper: function(type){
        return this.reduce(this.getServiceMethods(type), (wrapper, method) => { 
            wrapper[method] = this.partial(this.getServiceMethodWrapper, type, method); return wrapper; 
        }, {});
    },
    getServiceMethodWrapper: function(type, method, params){
        var defer = this.deferred(); params = this.isObject(params) ? params : {};
        defer.promise.then(this.callback(params.onSuccess, params.context), this.callback(params.onError, params.context));
        params.onSuccess = defer.resolve; params.onError = defer.reject;
        var pendingRequests = this.getServicePendingRequests(type);
        if(this.isEmpty(pendingRequests[method])) pendingRequests[method] = [params];
        else pendingRequests[method].push(params);
        this.initServicePendingRequests(type);
        return defer.promise;
    },
    initService: function(cmp, type){
        var params = { type: type, handler: this.compose(this.initServicePendingRequests, this.partial(this.setService, type)) };
        this.fireComponentEvent(cmp, "initServiceEvent", { params: params });
    },
    setService: function(type, service){
        if(type === "data") this.dataService = service;
        else this.metadataService = service;
        return type;
    },
    setServicePendingRequest: function(type, requests){
        if(type === "data") this.pendingDataServiceRequests = requests;
        else this.metadataDataServiceRequests = requests;
        return type;
    },
    initServicePendingRequests: function(type){
        var service = this.getService(type), pendingRequests = this.getServicePendingRequests(type);
        if(this.isEmpty(service) || this.isEmpty(pendingRequests)) return;
        this.setServicePendingRequest(type, this.map(pendingRequests, (requests, name) => {
            this.each(requests, (request) => { var method = service[name]; if(method && request) method(request); });
            return null;
        }));
    },

    //utility methods
    navigateToComponent: function(cmp, cmpName, recordId, state){
        recordId = recordId || this.getRecordId(cmp); state = state || this.getState(cmp);
        this.fireComponentEvent(cmp, "navigateToComponentEvent", { cmpName: cmpName, recordId: recordId, state: state });
    },
    navigateToPreviousComponent: function(cmp, state){
        this.fireComponentEvent(cmp, "navigateToPreviousComponentEvent", { state: this.extend(this.getState(cmp), state) });
    },
    refreshComponent: function(cmp, recordId, state){ 
        var name = cmp.getName(); if(name.startsWith("c")) name = name.replace("c", "");
        this.navigateToComponent(cmp, name, recordId, this.extend(this.getState(cmp), state));
    },
    refreshView: function(cmp){ 
        var name = cmp.getName(); if(name.startsWith("c")) name = name.replace("c", "");
        this.fireApplicationEvent("RefreshView", { cmpName: name });
        this.fireApplicationEvent("force:refreshView");
    },

    //other utility methods
    fireApplicationEvent: function(name, params){
        name = name.replace("e.", ""); name = "e." + (name.includes(":") ? name : "c:" + name); 
        var event = $A.get(name); if(event) { event.setParams(params || {}); event.fire(); return true; }
    },
    fireComponentEvent: function(cmp, name, params){
        var event = cmp.getEvent(name);
        if(event) { event.setParams(params || {}); event.fire(); return true; }
    },
    createComponent: function(cmpName, params){
        var defer = this.deferred();
        cmpName = cmpName.includes(":") ? cmpName : 'c:' + cmpName;
        $A.createComponent(cmpName, params, this.callback((newCmp, status, error) => {
            if (status === "SUCCESS") defer.resolve(newCmp);
            else { this.showErrorToast(error); defer.reject(error); }
        }));
        return defer.promise;
    },
    enqueueAction: function(enqueue, cmp, method, params, storable){
        var defer = this.deferred(), action = cmp.get(method.includes(".") ? method : 'c.' + method); 
        if(this.isUndefinedOrNull(action)) defer.reject("No action found");
        defer.promise.then(null, this.partial(this.error, cmp,  "Server Error: " + method, this, params));
        action.setCallback(this, this.partial(this.parseServerResponse, this, defer.resolve, defer.reject));
        if(storable) action.setStorable(); action.setParams(params || {}); enqueue(action); 
        return defer.promise;
    },
    parseServerResponse: function(response, resolve, reject){
        if (response.getState() === "SUCCESS") {
            resolve(response.getReturnValue());
        } else if (response.getState() === "ERROR") {
            let errors = response.getError();
            let message = 'Unknown error'; 
            if (this.isArray(errors) && this.isNotEmpty(errors)) {
                message = errors[0].message;
            }
            this.showErrorToast(message); reject(message);
        }
    },
    showHideSpinner: function(cmp, show){ 
        this.fireApplicationEvent("ShowHideSpinner", { show: show }); 
    },
    showSpinner: function(cmp){ 
        this.showHideSpinner(cmp, true); 
    },
    hideSpinner: function(cmp){ 
        this.showHideSpinner(cmp, false) 
    },
    showToast: function(mode, message, type) {
        message = this.stringifyJSON(message);
        mode = this.isNotEmpty(mode) ? mode : 'dismissible'; type = this.isNotEmpty(type) ? type : 'error';
        var params = { type: type, mode: mode, message: message, messageTemplate: "{0}", messageTemplateData: [message] };
        this.fireApplicationEvent("force:showToast", params) || alert(message);
    },
    showInfoToast: function(message) { 
        this.showToast(null, message, 'info'); 
    },
    showSuccessToast: function(message) { 
        this.showToast(null, message, 'success'); 
    },
    showErrorToast: function(message) { 
        this.showToast(null, message, 'error'); 
    }
})