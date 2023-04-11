public class LookupSearchComponentController {
    @AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String searchString) {
        List<SObJectResult> listOfWrapper = new List<SObJectResult>();
        for(sObject obj : Database.Query('Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + searchString + '%\'')) {
            String fieldvalue = (String)obj.get(fieldName);
            listOfWrapper.add(new SObjectResult(fieldvalue, obj.Id));
        }        
        return listOfWrapper;
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
}