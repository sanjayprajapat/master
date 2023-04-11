public class AutoCompleteComController {
    public String selectedObjName {set;get;}
    public string searchTerm 	  {set;get;}   
    public String listOfFields    {set;get;}
    Public boolean accountDetailVisible {set;get;}
    public sobject selectedAccount {set;get;}
    public Id selectedAccountId {set;get;}
    public static Map<String,Schema.SObjectField> mapOfFields=new Map<String,Schema.SObjectField>();
    public list<string> listOfFieldsName {set;get;}
    
    public void showAccountDetail(){
        String query='';
        query='select ';
        listOfFieldsName=new List<String>();
        mapOfFields=Schema.getGlobalDescribe().get(selectedObjName).getDescribe().fields.getMap();        
        Set<String> setOfkeys=mapOfFields.keySet();
        for(String keys:setOfkeys){
            Schema.DescribeFieldResult fldResult = mapOfFields.get(keys).getDescribe();                  
            if(fldResult.isAccessible()  && fldResult.isUpdateable()  && fldResult.isSortable() && fldResult.isCreateable() && fldResult.isGroupable()
                && fldResult.getType() != Schema.DisplayType.ADDRESS  && fldResult.getType() != Schema.DisplayType.LOCATION ){
                query=query+fldResult.getname()+',';               
                listOfFieldsName.add(fldResult.getName());
            }            
        }
        query=query.removeEnd(',');
        query=query+' From '+selectedObjName+' Where Id =\''+selectedAccountId+'\' LIMIT 1';        
        system.debug('query 1 '+query);
        system.debug('query 2 '+ ' From '+selectedObjName+' Where Id =\''+selectedAccountId+'\' LIMIT 1');
        selectedAccount=database.query(query);
        //selectedAccount = [Select Id,Name,Website,AccountNumber,Phone ,Fax FROM Account WHERE Id =:selectedAccountId Limit 1];
        accountDetailVisible= true;
    }
    public PageReference saveAfterEdit(){
        update selectedAccount;
        return null;
       
    }
    @RemoteAction
    public static List<AccountWrapper> getSearchSuggestions(String searchString,string selected,string fieldstosearch){
        system.debug('object is='+selected);
        string searchQuery='Select Id, '+fieldstosearch+' from '+selected+' where '+ fieldstosearch+' like \'%' +String.escapeSingleQuotes(searchString) + '%\'';
        system.debug('query is '+searchQuery);        
        List<AccountWrapper> accountWrappers = new List<AccountWrapper>();        
        List<sObject> searchObjects = Database.query(searchQuery);		       
        if(!searchObjects.isEmpty()){            
            for(SObject obj : searchObjects){                    
                system.debug('in loop');                   
                String NameOfRecord=(String)obj.get(fieldstosearch);
                String IdOfRecord=(String)obj.get('Id');
                accountWrappers.add(new AccountWrapper(NameOfRecord,IdOfRecord));  
            }         
        }
        return accountWrappers;  
    } 
    
}