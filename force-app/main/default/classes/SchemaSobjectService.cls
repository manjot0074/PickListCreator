public with sharing class SchemaSobjectService {
    
    private static SchemaSobjectService SchemaSobjectInstance = null; 
    public Map<String,Schema.SObjectType> globalDescribe; 

    private SchemaSobjectService() { 
        globalDescribe = Schema.getGlobalDescribe(); 
    } 

    public static SchemaSobjectService getInstance() { 
        if (SchemaSobjectInstance == null) {
            SchemaSobjectInstance = new SchemaSobjectService();
        }
        return SchemaSobjectInstance; 
    }

    public List<String> getExistingPicklistValues(String objectName, String fieldName) {
        List<String> picklists = new List<String>();

        //Assuming ObjectName and FieldName is correct 
        List<Schema.PicklistEntry> picklistvalues = globalDescribe.get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues();
        for(Schema.PicklistEntry picklist : picklistvalues) {
            picklists.add(picklist.getValue().toLowercase());
        }
        return picklists;
    }

}
