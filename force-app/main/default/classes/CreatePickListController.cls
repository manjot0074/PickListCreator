public with sharing class CreatePickListController {
    
    @AuraEnabled
    public static List<PicklistWrapper> getPickListValues(){
        List<PicklistWrapper> pickListValues = new List<PicklistWrapper>();
        try{
            Map<String,Map<String,List<String>>> allPicklistMap = PickListService.getNewPickList();
            for(String objectName : allPicklistMap.keySet()){
                Map<String,List<String>> objectPicklistMap = allPicklistMap.get(objectname);
                List<fieldPickListWrapper> fieldPickList = new List<fieldPickListWrapper>();
                for(String fieldName : objectPicklistMap.keySet()){
                    fieldPickList.add(new fieldPickListWrapper(fieldName, objectPicklistMap.get(fieldName)));
                }
                pickListValues.add(new PicklistWrapper(objectName, fieldPickList));
            }
        } catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValues;
    }

    @AuraEnabled
    public static void createPickListForObject(String objectName){ 
        try{
            PickListService.addPickListForObject(objectName, true);
        } catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void addPickListForField(String objectName, String fieldName){ 
        try{
            PickListService.addPickListForField(objectName,fieldName, true);
        } catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class PicklistWrapper {
        @AuraEnabled public String objectname {get;set;}
        @AuraEnabled List<fieldPickListWrapper> fieldPickLists {get;set;}
        public PicklistWrapper(String objectname, List<fieldPickListWrapper> fieldPickLists) {
            this.objectname = objectname;
            this.fieldPickLists = fieldPickLists;
        }
    }

    public class fieldPickListWrapper {
        @AuraEnabled public String fieldName {get;set;}
        @AuraEnabled public List<String> pickListValues {get;set;}
        public fieldPickListWrapper(String fieldName, List<String> pickListValues) {
            this.fieldName = fieldName;
            this.pickListValues = pickListValues;
        }
    }
}
