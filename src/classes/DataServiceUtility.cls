/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Company:       Salesforce
Description:   data service utility class for data service lighning component 

History
Date            Author             Comments
--------------------------------------------------------------------------------------
01-03-2018     Sumit Gupta       	Initial Release
------------------------------------------------------------------------------------*/

public without sharing class DataServiceUtility {

	public static SObject getRecord(Id recordId, Set<String> fields, String whereClause) {
		whereClause = (!String.isBlank(whereClause) ? whereClause : '').remove('WHERE').trim();
		whereClause = 'Id = \'' + recordId + '\'' + (!String.isBlank(whereClause) ? ' AND ' + whereClause : '');
		String query = MetadataServiceUtility.buildQuery(MetadataServiceUtility.getObjectNameFromId(recordId), null, fields, whereClause);
		return Database.query(query).get(0);
	}

	public static List<SObject> getRecords(String objectName, Set<String> fields, String whereClause) {
		String query = MetadataServiceUtility.buildQuery(objectName, null, fields, whereClause);
		query += ' ORDER BY Name'; return Database.query(query);
	}

	public static MetadataServiceUtility.FieldSetDataWrapper getFieldSetData(String objectName, String fieldSetName, 
			Set<String> additionalFields, String whereClause) {
		return MetadataServiceUtility.getFieldSetData(objectName, fieldSetName, additionalFields, whereClause);
	}

	public static String createRecord(String objectName, Map<String, Object> defaultFieldValues) {
		Sobject record = MetadataServiceUtility.getNewRecord(objectName, defaultFieldValues);
		insert record; return record.Id;
	}

	public static String updateRecord(Id recordId, Map<String, Object> fieldValues) {
		String objectName = MetadataServiceUtility.getObjectNameFromId(recordId);
		SObject record = MetadataServiceUtility.getNewRecord(objectName, fieldValues);
		record.Id = recordId; update record; return record.Id;
	}

	public static String deleteRecord(Id recordId) {
		delete recordId.getSObjectType().newSObject(recordId); return recordId;
	}
}