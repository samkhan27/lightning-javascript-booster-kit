/*------------------------------------------------------------------------------------
Author:         Sumit Gupta
Company:        Salesforce
Description:    Metadata utility methods

History
Date            Author             Comments
--------------------------------------------------------------------------------------
01-03-2018     Sumit Gupta         Initial Release
------------------------------------------------------------------------------------*/

public class MetadataServiceUtility {

    private static Map<String, Schema.SObjectType> globalDescribe;

    static{
        globalDescribe = Schema.getGlobalDescribe();
    }

    //Method to get object name from record id
    public static String getObjectNameFromId(Id recordId){
        return recordId.getSObjectType().getDescribe().getName();
    }

    //Method to build query string based on field set, additional fields and where clause
    public static String buildQuery(String objectName, String fieldSetName, Set<String> additionalFields, String whereClause) {
        Set<String> fields = getFieldsFromFieldSet(objectName, fieldSetName);
        if(additionalFields != null) fields.addAll(additionalFields); 
        if(fields.isEmpty()) fields.add('Id'); fields = addStandardLookupNameFields(fields);
        whereClause = (!String.isBlank(whereClause) ? whereClause : '').remove('WHERE').trim();
        return 'SELECT ' + String.join(new List<String>(fields), ',') + ' FROM ' + objectName + (!String.isBlank(whereClause) ? (' WHERE ' + whereClause) : '');    
    } 

    //Method to get field set data 
    public static FieldSetDataWrapper getFieldSetData(String objectName, String fieldSetName, Set<String> additionalFields, String whereClause){
        FieldSetDataWrapper fieldSetData = new FieldSetDataWrapper(); 
        List<FieldSetColumnWrapper> columns = new List<FieldSetColumnWrapper>();
        Schema.FieldSet fieldSet = getFieldSet(objectName, fieldSetName);
        if(fieldSet != null){
            for(Schema.FieldSetMember field :fieldSet.getFields()) {
                columns.add(new FieldSetColumnWrapper(field.getFieldPath(), field.getLabel(), String.valueOf(field.getType())));
            }
        }
        if(additionalFields != null){
            Map<String, Schema.SObjectField> fieldMap = globalDescribe.get(objectName).getDescribe().fields.getMap();
            for(String fname :additionalFields){
                if(fieldMap.containsKey(fname)){
                    Schema.DescribeFieldResult field = fieldMap.get(fname).getDescribe();
                    columns.add(new FieldSetColumnWrapper(fname, field.getLabel(), String.valueOf(field.getType())));
                }
            }
        }
        fieldSetData.setColumns(columns);
        String query = buildQuery(objectName, fieldSetName, additionalFields, whereClause);
        fieldSetData.setRecords(Database.query(query));
        return fieldSetData;
    }

    //Method to get new SObject record with default field values populated 
    public static SObject getNewRecord(String objectName, Map<String, Object> defaultFieldValues){
        SObject record = globalDescribe.get(objectName).getDescribe().getSobjectType().newSObject();
        if(defaultFieldValues != null) {
            for(String key : defaultFieldValues.keySet()) {
                record.put(key, defaultFieldValues.get(key));
            }
        } 
        return record;
    }

    //Method to get all values of a picklist type field
    public static List<Schema.PicklistEntry> getPicklistValues(String objectName, String fieldName) {
        List<Schema.PicklistEntry> picklistValues = new List<Schema.PicklistEntry>();
        if(globalDescribe.containsKey(objectName)){
            Map<String, Schema.SObjectField> fieldMap = globalDescribe.get(objectName).getDescribe().fields.getMap();
            if(fieldMap.containsKey(fieldName)) {
                Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
                if(fieldResult.getType() ==  DisplayType.Picklist) {
                    picklistValues = fieldResult.getPicklistValues();
                }
            }
        }
        return picklistValues;
    } 

    public static List<SObject> getRecordTypes(String objectName){
        return DataServiceUtility.getRecords('RecordType', new Set<String>{'Name', 'DeveloperName'}, 'SobjectType = \'' + objectName + '\'');
    }

    //Method to get child relationships from a record id  
    public static Map<String, Object> getChildRelationships(String objectName){
        List<Schema.ChildRelationship> relationships = globalDescribe.get(objectName).getDescribe().getChildRelationships();
        Map<String, String> objectLabels = new Map<String, String>();
        for(Schema.ChildRelationship relationship : relationships){
            Schema.DescribeSObjectResult result = relationship.getChildSObject().getDescribe();
            objectLabels.put(result.getName(), result.labelPlural);
        }
        return new Map<String, Object>{ 'relationships' => relationships, 'objectLabels' => objectLabels };
    }

    //Method to get quick actions
    public static List<QuickAction.DescribeAvailableQuickActionResult> getQuickActions(String objectName){
        return QuickAction.DescribeAvailableQuickActions(objectName);
    }

    //Method to get lightning quick actions
    public static List<QuickAction.DescribeQuickActionResult> getLightningQuickActions(String objectName){
        List<String> quickActionNames = new List<String>();
        for(QuickAction.DescribeAvailableQuickActionResult result :getQuickActions(objectName)){
            if(result.getType() == 'LightningComponent') quickActionNames.add(result.getName());
        }
        return QuickAction.DescribeQuickActions(quickActionNames);
    }

    //Method to get object name from record id
    public static Map<String,Schema.SObjectType> getGlobalDescribe(){
        return globalDescribe;
    }

    //Method to get object name from record id
    public static Schema.DescribeSObjectResult getObjectDescribe(String objectName){
        return globalDescribe.get(objectName).getDescribe();
    }

    //Method to get fields from a field set
    private static Set<String> getFieldsFromFieldSet(String objectName, String fieldSetName) {
        Set<String> fields = new Set<String>();
        Schema.FieldSet fieldSet = getFieldSet(objectName, fieldSetName);
        if(fieldSet == null) return fields;
        for(Schema.FieldSetMember fieldSetMember :fieldSet.getFields()) {
            String fieldName = fieldSetMember.getFieldPath();
            if(fieldSetMember.getType() == Schema.DisplayType.Reference && !fieldName.endsWith('Id')){
                fields.add(fieldName.substring(0, fieldName.length()-1) + 'r.Name');
            } else {
                fields.add(fieldName);
            }
        }
        return fields;
    }

    //Method to read and create schema based on field set structure and object name  
    private static Schema.FieldSet getFieldSet(String objectName, String fieldSetName){ 
        Schema.FieldSet fieldSet;
        if(objectName != null && fieldSetName != null){
            if(globalDescribe.containsKey(objectName)){
                fieldSet = globalDescribe.get(objectName).getDescribe().FieldSets.getMap().get(fieldSetName);
            }
        }
        return fieldSet;
    }

    //Method to add name field from all lookup objects
    private static Set<String> addStandardLookupNameFields(Set<String> fields){
        Set<String> results = new Set<String>();
        for(String field :fields) {
            if(field.length() > 2 && field.endsWith('Id')) {
                results.add(field.substring(0,field.length()-2) +'.Name');
            }
            results.add(field);
        }
        return results;
    }

    //Method to get all updatable fields for an object
    public static Set<String> getUpdatableFields(String objectName){
        Set<String> fields = new Set<String>();
        if(globalDescribe.containsKey(objectName)){
            Map<String, Schema.SObjectField> fieldMap = globalDescribe.get(objectName).getDescribe().fields.getMap();
            for(String fname :fieldMap.keySet()){
                Schema.DescribeFieldResult field = fieldMap.get(fname).getDescribe();
                if(field.isUpdateable() || field.getType() == Schema.DisplayType.Reference) fields.add(fname); 
            }
        }
        return fields;
    }

    public class FieldSetDataWrapper{
        public List<FieldSetColumnWrapper> columns{get;set;}
        public List<SObject> records {get;set;}

        public FieldSetDataWrapper(){
            columns = new List<FieldSetColumnWrapper>();
            records = new List<SObject>();
        }
       
        public void setColumns(List<fieldSetColumnWrapper> columns){
            this.columns = columns;
        }

        public void setRecords(List<SObject> records){
            this.records = records;
        }
    }

    public class FieldSetColumnWrapper{
        public String fieldName;
        public String label;
        public String type;

        public FieldSetColumnWrapper(String name, String label, String type){
            this.fieldName = name; this.label = label; this.type = type.toLowerCase();
        }
    }
}