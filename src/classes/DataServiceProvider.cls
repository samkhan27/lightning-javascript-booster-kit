/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Company:       Salesforce
Description:   controller class for data service lightning component 

History
Date            Author             Comments
--------------------------------------------------------------------------------------
01-03-2018     Sumit Gupta       	Initial Release
------------------------------------------------------------------------------------*/

public without sharing class DataServiceProvider {

	@AuraEnabled
    public static ServiceResponseWrapper.ServiceResponse executeQuery(String query){
        try{
            if(String.isBlank(query)) {
                return ServiceResponseWrapper.getError('query string is required to execute query');
            }
            return ServiceResponseWrapper.getResponse(Database.query(query));
        } catch(Exception ex){
            return ServiceResponseWrapper.getError(ex);
        }
    }

    @AuraEnabled
    public static ServiceResponseWrapper.ServiceResponse getRecord(String recordId, List<String> fields, String whereClause){
    	try{
    		if(String.isBlank(recordId)) {
                return ServiceResponseWrapper.getError('recordId is required to fetch record');
            }
    		return ServiceResponseWrapper.getResponse(DataServiceUtility.getRecord(recordId, new Set<String>(fields), whereClause));
    	} catch(Exception ex){
            return ServiceResponseWrapper.getError(ex);
        }
    }

    @AuraEnabled
    public static ServiceResponseWrapper.ServiceResponse getRecords(String objectName, List<String> fields, String whereClause){
        try{
            if(String.isBlank(objectName)) {
                return ServiceResponseWrapper.getError('objectName is required to fetch records');
            }
            return ServiceResponseWrapper.getResponse(DataServiceUtility.getRecords(objectName, new Set<String>(fields), whereClause));
        } catch(Exception ex){
            return ServiceResponseWrapper.getError(ex);
        }
    }

	@AuraEnabled
    public static ServiceResponseWrapper.ServiceResponse getFieldSetData(String objectName, String fieldSetName, List<String> additionalFields, String whereClause){
        try{
            if(String.isBlank(objectName)) {
                return ServiceResponseWrapper.getError('objectName is required to fetch field set data');
            }
            return ServiceResponseWrapper.getResponse(DataServiceUtility.getFieldSetData(objectName, fieldSetName, new Set<String>(additionalFields), whereClause));
        } catch(Exception ex){
            return ServiceResponseWrapper.getError(ex);
        }
    }

    @AuraEnabled
    public static ServiceResponseWrapper.ServiceResponse createRecord(String objectName, Map<String, Object> defaultFieldValues) {
        try{
            if(String.isBlank(objectName)) {
                return ServiceResponseWrapper.getError('objectName is required to create new record');
            }
            return ServiceResponseWrapper.getResponse(DataServiceUtility.createRecord(objectName, defaultFieldValues));
        } catch(Exception ex){
            return ServiceResponseWrapper.getError(ex);
        }
    }

    @AuraEnabled
    public static ServiceResponseWrapper.ServiceResponse updateRecord(String recordId, Map<String, Object> fieldValues) {
        try{
            if(String.isBlank(recordId)){
                return ServiceResponseWrapper.getError('recordId is required to update record');
            }
            return ServiceResponseWrapper.getResponse(DataServiceUtility.updateRecord(recordId, fieldValues));
        } catch(Exception ex){
            return ServiceResponseWrapper.getError(ex);
        }
    }

    @AuraEnabled
    public static ServiceResponseWrapper.ServiceResponse deleteRecord(String recordId) {
        try{
            if(String.isBlank(recordId)) {
                return ServiceResponseWrapper.getError('recordId is required to delete record');
            }
            return ServiceResponseWrapper.getResponse(DataServiceUtility.deleteRecord(recordId));
        } catch(Exception ex){
            return ServiceResponseWrapper.getError(ex);
        }
    }
}