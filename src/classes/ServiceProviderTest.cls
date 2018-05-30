/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Company:       Salesforce
Description:   test class for service utilities 

History
Date            Author             Comments
--------------------------------------------------------------------------------------
04-03-2018     Sumit Gupta       	Initial Release
------------------------------------------------------------------------------------*/
@isTest
private class ServiceProviderTest {
	
	@isTest static void test_ServiceUtility() {

		ServiceResponseWrapper.ServiceResponse success = DataServiceProvider.createRecord('Account', new Map<String, Object> { 'Name' => 'Test Account' });
		System.assertEquals(success.isSuccess, true);

		Id accountId = success.data;

		ServiceResponseWrapper.ServiceResponse success1 = DataServiceProvider.getRecords('Account', new List<String>{ 'Name' }, 'Name = \'Test Account\'');
		System.assertEquals(success1.isSuccess, true);

		ServiceResponseWrapper.ServiceResponse success2 = DataServiceProvider.getRecord(accountId, new List<String>{ 'Name' }, 'Name = \'Test Account\'');
		System.assertEquals(success2.isSuccess, true);

		ServiceResponseWrapper.ServiceResponse success3 = DataServiceProvider.updateRecord(accountId, new Map<String, Object>());
		System.assertEquals(success3.isSuccess, true);

		ServiceResponseWrapper.ServiceResponse success4 = DataServiceProvider.executeQuery('SELECT Id FROM Account');
		System.assertEquals(success4.isSuccess, true);

		ServiceResponseWrapper.ServiceResponse success5 = MetadataServiceProvider.getRecordTypes('Account');
		System.assertEquals(success5.isSuccess, true);

		ServiceResponseWrapper.ServiceResponse success6 = MetadataServiceProvider.getPicklistValues('Account', 'Type');
		System.assertEquals(success6.isSuccess, true);

		ServiceResponseWrapper.ServiceResponse success7 = MetadataServiceProvider.getChildRelationships('Account');
		System.assertEquals(success7.isSuccess, true);

		ServiceResponseWrapper.ServiceResponse success8 = MetadataServiceProvider.getQuickActions('Account');
		System.assertEquals(success8.isSuccess, true);

		ServiceResponseWrapper.ServiceResponse success9 = MetadataServiceProvider.getLightningQuickActions('Account');
		System.assertEquals(success9.isSuccess, true);

		DataServiceProvider.getFieldSetData('Account', 'Compact_Layout', new List<String>(),  null);
		DataServiceProvider.deleteRecord(accountId);

		MetadataServiceUtility.getUpdatableFields('Account');

		ServiceResponseWrapper.ServiceResponse failure1 = DataServiceProvider.createRecord(null, null);
		System.assertEquals(failure1.isSuccess, false);

		ServiceResponseWrapper.ServiceResponse failure2 = DataServiceProvider.getRecords(null, null, null);
		System.assertEquals(failure2.isSuccess, false);

		ServiceResponseWrapper.ServiceResponse failure3 = DataServiceProvider.getRecord(null, null, null);
		System.assertEquals(failure3.isSuccess, false);

		ServiceResponseWrapper.ServiceResponse failure4 = DataServiceProvider.updateRecord(null, null);
		System.assertEquals(failure4.isSuccess, false);

		ServiceResponseWrapper.ServiceResponse failure5 = DataServiceProvider.executeQuery(null);
		System.assertEquals(failure5.isSuccess, false);

		ServiceResponseWrapper.ServiceResponse failure6 = MetadataServiceProvider.getRecordTypes(null);
		System.assertEquals(failure6.isSuccess, false);

		ServiceResponseWrapper.ServiceResponse failure7 = MetadataServiceProvider.getPicklistValues(null, null);
		System.assertEquals(failure7.isSuccess, false);

		ServiceResponseWrapper.ServiceResponse failure8 = MetadataServiceProvider.getChildRelationships(null);
		System.assertEquals(failure8.isSuccess, false);

		ServiceResponseWrapper.ServiceResponse failure9 = MetadataServiceProvider.getQuickActions(null);
		System.assertEquals(failure9.isSuccess, false);

		ServiceResponseWrapper.ServiceResponse failure10 = MetadataServiceProvider.getLightningQuickActions(null);
		System.assertEquals(failure10.isSuccess, false);

		DataServiceProvider.deleteRecord(null);
	}
}