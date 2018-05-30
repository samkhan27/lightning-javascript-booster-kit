({
	getObjectNameJS: function(cmp, event, helper) {
		helper.execute(cmp, event, helper.getObjectName);
	},
	getRecordTypesJS: function(cmp, event, helper) {
		helper.execute(cmp, event, helper.getRecordTypes);
	},
	getRecordTypesMapJS: function(cmp, event, helper) {
		helper.execute(cmp, event, helper.getRecordTypesMap);
	},
	getPicklistValuesJS: function(cmp, event, helper) {
		helper.execute(cmp, event, helper.getPicklistValues);
	},
	getChildRelationshipsJS: function(cmp, event, helper) {
		helper.execute(cmp, event, helper.getChildRelationships);
	},
	getQuickActionsJS: function(cmp, event, helper) {
		helper.execute(cmp, event, helper.getQuickActions);
	},
	getLightningQuickActionsJS: function(cmp, event, helper) {
		helper.execute(cmp, event, helper.getLightningQuickActions);
	}
})