public class ServerSidePaginationApexClass {@AuraEnabled
    public static AccountWrapper fetchAccount(Decimal pageNumber ,Integer recordToDisply, String sortField, String sortDirection){
        // Craete object of Wrapper Class
        AccountWrapper obj = new AccountWrapper();  
        Integer pageSize = recordToDisply;  // Record Display that how many record will display
        System.debug('pageSize = '+pageSize);
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
        System.debug('offset = '+offset);
        obj.pageSize = pageSize;
        obj.page = (Integer) pageNumber;  
        System.debug('Page Number = '+pageNumber);
        obj.total = [SELECT count() FROM account];  
        System.debug('Total Account = '+ obj.total);
        String query = 'SELECT Id, Name, AccountNumber, AccountSource FROM Account ORDER BY '+sortField+' '+sortDirection+' LIMIT '+recordToDisply+' OFFSET '+offset;  
        System.debug('Query =  ' + query);  
        obj.accounts = Database.Query(query);  
        return obj;
    }
   
   
    // Wrapper Class
    public class AccountWrapper{
        @AuraEnabled public Integer pageSize {get;set;}  
        @AuraEnabled public Integer page {get;set;}  
        @AuraEnabled public Integer total {get;set;}  
        @AuraEnabled public List<Account> accounts {get;set;}  
    }
}