/*------------------------------------------------------------------------------------
Author:        Sumit Gupta
Company:       Salesforce
Description:   Aura Service Response Wrapper class

History
Date            Author             Comments
--------------------------------------------------------------------------------------
21-05-2018     Sumit Gupta          Initial Release
------------------------------------------------------------------------------------*/
public with sharing class ServiceResponseWrapper {

    private static String DEFAULT_ERROR_MESSAGE = 'There was an Error';

    public class ServiceResponse {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String data;
        @AuraEnabled public Object error;

        public ServiceResponse(String data){
            isSuccess = true; this.data = data; 
        }

        public ServiceResponse(Exception ex, String errorMessage){
            isSuccess = false; error = (Object)ex; 
            this.errorMessage = (ex != null ? ex.getMessage() : errorMessage);
        }
    }

    public static ServiceResponse getResponse(){
        return new ServiceResponse(null);
    }

    public static ServiceResponse getResponse(Object data){
        return new ServiceResponse(JSON.serialize(data));
    }

    public static ServiceResponse getResponse(String data){
        return new ServiceResponse(data);
    }

    public static ServiceResponse getError(Exception ex){
        return new ServiceResponse(ex, DEFAULT_ERROR_MESSAGE);
    }

    public static ServiceResponse getError(String errorMessage){
        return new ServiceResponse(null, errorMessage);
    }

    public static String getResponseString(Object data){
        return JSON.serialize(new ServiceResponse(JSON.serialize(data)));
    }

    public static String getResponseString(String data){
        return JSON.serialize(new ServiceResponse(data));
    }

    public static String getErrorString(Exception ex){
        return JSON.serialize(new ServiceResponse(ex, DEFAULT_ERROR_MESSAGE));
    }

    public static String getErrorString(String errorMessage){
        return JSON.serialize(new ServiceResponse(null, errorMessage));
    }
}