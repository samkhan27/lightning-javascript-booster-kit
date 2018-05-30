/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Company:       Salesforce
Description:   controller class for metadata service lightning component 

History
Date            Author             Comments
--------------------------------------------------------------------------------------
01-03-2018     Sumit Gupta       	Initial Release
------------------------------------------------------------------------------------*/
public without sharing class MetadataServiceProvider {

	@AuraEnabled
    public static ServiceResponseWrapper.ServiceResponse getObjectName(String recordId){
        try{
            if(String.isBlank(recordId)) {
                return ServiceResponseWrapper.getError('recordId is required to get object name');
            }
            return ServiceResponseWrapper.getResponse(MetadataServiceUtility.getObjectNameFromId(recordId));
        } catch(Exception ex){
            return ServiceResponseWrapper.getError(ex);
        }
    }

    @AuraEnabled
    public static ServiceResponseWrapper.ServiceResponse getRecordTypes(String objectName) {
        try{
            if(String.isBlank(objectName)) {
                return ServiceResponseWrapper.getError('objectName is required to get record types');
            }
            return ServiceResponseWrapper.getResponse(MetadataServiceUtility.getRecordTypes(objectName));
        } catch(Exception ex){
            return ServiceResponseWrapper.getError(ex);
        }
    }

    @AuraEnabled
    public static ServiceResponseWrapper.ServiceResponse getPicklistValues(String objectName, String fieldName) {
        try{
            if(String.isBlank(objectName) || String.isBlank(fieldName)) {
                return ServiceResponseWrapper.getError('fieldName is required to get picklist values');
            }
            return ServiceResponseWrapper.getResponse(MetadataServiceUtility.getPicklistValues(objectName, fieldName));
        } catch(Exception ex){
            return ServiceResponseWrapper.getError(ex);
        }
    }

    @AuraEnabled
    public static ServiceResponseWrapper.ServiceResponse getChildRelationships(String objectName){
        try{
            if(String.isBlank(objectName)) {
                return ServiceResponseWrapper.getError('objectName is required to get child relationships');
            }
            return ServiceResponseWrapper.getResponse(MetadataServiceUtility.getChildRelationships(objectName));
        } catch(Exception ex){
            return ServiceResponseWrapper.getError(ex);
        }
    }

    @AuraEnabled
    public static ServiceResponseWrapper.ServiceResponse getQuickActions(String objectName){
        try{
            if(String.isBlank(objectName)) {
                return ServiceResponseWrapper.getError('objectName is required to get quick actions');
            }
            return ServiceResponseWrapper.getResponse(MetadataServiceUtility.getQuickActions(objectName));
        } catch(Exception ex){
            return ServiceResponseWrapper.getError(ex);
        }
    }

    @AuraEnabled
    public static ServiceResponseWrapper.ServiceResponse getLightningQuickActions(String objectName){
        try{
            if(String.isBlank(objectName)) {
                return ServiceResponseWrapper.getError('objectName is required to get lightning quick actions');
            }
            return ServiceResponseWrapper.getResponse(MetadataServiceUtility.getLightningQuickActions(objectName));
        } catch(Exception ex){
            return ServiceResponseWrapper.getError(ex);
        }
    }
}