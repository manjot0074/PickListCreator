public with sharing class PickListService {

    public static Map<String,Map<String,List<String>>> getNewPickList() {
        Map<String,Map<String,List<String>>> allPicklistMap= new Map<String,Map<String,List<String>>>();
        // Contact
        Map<String,List<String>> contactPicklistMap= new Map<String, List<String>>();
        contactPicklistMap.put( 'Level__c', new List<String>{'test33', 'test43', 'test53'}) ;
        contactPicklistMap.put( 'test__c', new List<String>{'test33', 'test42', 'test53'}) ;
        allPicklistMap.put('Contact', contactPicklistMap);

        //Case
        Map<String,List<String>> casePicklistMap= new Map<String, List<String>>();
        casePicklistMap.put( 'Product__c', new List<String>{'testre' , 'testxr'});
        allPicklistMap.put('Case', casePicklistMap);

        return allPicklistMap;
    }

    public static Map<String,Map<String,List<String>>> getAbsentPickList(Map<String,Map<String,List<String>>> allPickListValues) {
        Map<String,Map<String,List<String>>> absentPickListMap = new Map<String,Map<String,List<String>>>();
        for(String objectName: allPickListValues.keySet()){
            Map<String,List<String>> fieldPickList = allPickListValues.get(objectName);
            Map<String,List<String>> absentFieldList = new Map<String, List<String>>();
            for(String fieldName : fieldPickList.keySet()){
                List<String> picklistValues = fieldPickList.get(fieldName);
                List<String> absentPicklist = getAbsentPicklist(objectName, fieldName, picklistValues);
                if(absentPicklist.size() > 0){
                    absentFieldList.put(fieldName, absentPicklist);
                }
            }
            if(absentFieldList.keySet().size() > 0 ){
                absentPickListMap.put(objectName, absentFieldList);
            }
        }
        return absentPickListMap;
    }

    public static void addPickListForField(String objectname, String fieldName, Boolean isLex){
        if(String.isBlank(objectname)) {
            throw new CustomException('ObjectName is Blank');
            // Add label
        }
        if (String.isBlank(fieldName)){
            throw new CustomException('FieldName is Blank');
        }

        Map<String,Map<String,List<String>>> allPicklistMap = getNewPickList();
        Map<String,Map<String,List<String>>> absentPickListMap = getAbsentPickList(allPicklistMap);

        Map<String,List<String>> objectPicklistMap = absentPickListMap.get(objectname);
        if(objectPicklistmap == null) {
            throw new CustomException('No Picklist values for given object are to be added');
        }
        
        List<String> fieldPicklistList = objectPicklistMap.get(fieldName);
        if(fieldPicklistList == null) {
            throw new CustomException('No Picklist values for given fields are to be added');
        }

        MetadataService.MetadataPort service = createService(isLex); 

        MetadataService.CustomField picklistField = readGivenField(service, new List<String> {objectname + '.' + fieldName})[0];
        
        picklistField.valueSet.valueSetDefinition.value.addAll(createPicklistMetadata(fieldPicklistList));

        MetadataService.SaveResult result = service.updateMetadata( new MetadataService.Metadata[] { picklistField })[0]; 
    }

    public static void addPickListForObject(String objectname, Boolean isLex){
        if(String.isBlank(objectname)) {
            throw new CustomException('ObjectName is Blank');
            // Add label
        }
        Map<String,Map<String,List<String>>> allPicklistMap = getNewPickList();
        Map<String,Map<String,List<String>>> absentPickListMap = getAbsentPickList(allPicklistMap);

        Map<String,List<String>> objectPicklistMap = absentPickListMap.get(objectname);
        if(objectPicklistmap == null) {
            throw new CustomException('No Picklist values for given object are to be added');
        }

        MetadataService.MetadataPort service = createService(isLex); 
        
        List<String>fieldNamesList = getConcatenatedFieldNames(objectname, objectPicklistMap);
        Map<String,Integer> fieldNameIndexMap = getFieldNameIndexMap(fieldNamesList);

        List<MetadataService.CustomField> picklistFields = readGivenField(service, fieldNamesList);
        
        for(String fieldName : objectPicklistMap.keySet()){
            List<String> fieldPicklistList = objectPicklistMap.get(fieldName);
            Integer index = fieldNameIndexMap.get(objectname+'.'+fieldName);
            MetadataService.CustomField picklistField = picklistFields[index];
            picklistField.valueSet.valueSetDefinition.value.addAll(createPicklistMetadata(fieldPicklistList));
        }
        List<MetadataService.Metadata> metadata = new List<MetadataService.Metadata>();
        for(MetadataService.Metadata picklistField : picklistFields){
            metadata.addAll(new MetadataService.Metadata[] {picklistField});
        }

        MetadataService.SaveResult result = service.updateMetadata(metadata)[0];   
    }

    private static List<Metadataservice.CustomValue> createPicklistMetadata(List<String> picklistNames) {
        if(picklistNames == null || picklistNames.size() < 1){
            throw new CustomException('No PicklistNames are given');
        }
        List<metadataservice.CustomValue> pickListMetadataList = new List<metadataservice.CustomValue>();
        
        for(String picklist :picklistNames){
            metadataservice.CustomValue picklistMeta = new metadataservice.CustomValue();
            picklistMeta.fullName= picklist;
            picklistMeta.default_x=false;
            pickListMetadataList.add(picklistMeta);
        }
        System.debug('###' +pickListMetadataList);
        return pickListMetadataList;
    }

    private static List<MetadataService.CustomField> readGivenField(MetadataService.MetadataPort service, List<String> fieldNames) {
        List<MetadataService.CustomField> customField = (List<MetadataService.CustomField>) service.readMetadata('CustomField', 
            fieldNames).getRecords();
        return customField;   
    }

    private static MetadataService.MetadataPort createService(Boolean isLex) {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        if(isLex){
            service.SessionHeader.sessionId = Utils.getSessionIdFromVFPage();
        } else {
            service.SessionHeader.sessionId = UserInfo.getSessionId();
        }
        
        return service;
    }

    private static List<String> getConcatenatedFieldNames(String objectname, Map<String,List<String>> fieldNamesMap) {
        List<String> contatenatedFields = new List<String>();
        for(String fieldName : fieldNamesMap.keySet()) {
            contatenatedFields.add(objectname+ '.' + fieldName);
        }
        return contatenatedFields;
    }
    
    private static Map<String,Integer> getFieldNameIndexMap(List<String> fieldNames){
        Map<String,Integer> fieldNameIndexMap = new Map<String,Integer>();
        Integer i = 0;
        for(String field: fieldNames){
            fieldNameIndexMap.put(field, i);
            i++;
        }
        return fieldNameIndexMap;
    }

    private static List<String> getAbsentPicklist(String objectName, String fieldName, List<String> pickListValues){
        SchemaSobjectService schema = SchemaSobjectService.getInstance();
        List<String> existingPicklist = schema.getExistingPicklistValues(objectName, fieldName);
        List<String> absentPicklistValues =  new List<String>();
        for(String pickList: picklistValues){
            if(!existingPicklist.contains(pickList.toLowerCase())){
                absentPicklistValues.add(pickList);
            }
        }
        return absentPicklistValues;
    }
}
