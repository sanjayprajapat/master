public class CustomKanbanViewController {
    
    @AuraEnabled
    public static wrapperResponse getInitialData(String sObjectName , List<String> listOfField ,String kanbanField ,Integer limitOfRecord){
        
        List<picklistWrapper> listofPickList = new List<picklistWrapper>();
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe();   
        // Get the field dynamically
        DescribeFieldResult fieldResult = objResult.fields.getMap().get(kanbanField).getDescribe();
        
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues()) { 
            picklistWrapper wrap = new picklistWrapper(f.getLabel(),f.getValue(),f.getLabel().replaceAll(' ',''),0);
            listofPickList.add(wrap);            
        }
        
        List<sObject> resultList = new List<sObject>();
        String query = 'SELECT ';
        if(listOfField != null && listOfField.size() > 0){
            query = query + string.join(listOfField, ',');
        }
        if(!String.isBlank(sObjectName)){
            query = query + ' FROM '+sObjectName +' LIMIT '+limitOfRecord;
        }
        system.debug('query === '+query);
        resultList = Database.query(query);
        
        for(sObject obj : resultList){
            for(picklistWrapper wrapObj : listofPickList){
                if(obj.get(kanbanField) == wrapObj.label){                    
                    if(wrapObj.label == obj.get(kanbanField)){
                        wrapObj.totalCount  =  wrapObj.totalCount+1;
                    }
                }                
            }
        }
        
        /*List<picklistWrapper> listofPickList = new List<picklistWrapper>();
        //listofPickList.add(new picklistWrapper('Backlog','Backlog','Backlog'));
        listofPickList.add(new picklistWrapper('Draft','Draft','Draft'));
        listofPickList.add(new picklistWrapper('In progress','In progress','Inprogress'));
        listofPickList.add(new picklistWrapper('Ready for development','Ready for development','Readyfordevelopment'));
        listofPickList.add(new picklistWrapper('Completed','Completed','Completed'));*/
        return new wrapperResponse(resultList , listofPickList);
    }
    
    public class wrapperResponse{
        @AuraEnabled public List<Sobject> listOfsObject{get;set;}
        @AuraEnabled public List<picklistWrapper> listOfPicklistWrapper{get;set;}      
        public wrapperResponse(List<sObject> listOfsObject , List<picklistWrapper> listOfPicklistWrapper){
            this.listOfsObject = listOfsObject;
            this.listOfPicklistWrapper = listOfPicklistWrapper;
        }
    }
    
    public class picklistWrapper{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String valueWithoutSpace {get;set;}
        @AuraEnabled public Integer totalCount {get;set;}
        public picklistWrapper(String label , String value , String valueWithoutSpace,Integer totalCount){
            this.label = label;
            this.value = value;
            this.valueWithoutSpace = valueWithoutSpace;
            this.totalCount = totalCount;
        }
    }
    
    public class cObject{
        sObject obj {get; set;}
        
        public cObject(sObject obj){
            this.obj = obj;
        }
    }
    
}