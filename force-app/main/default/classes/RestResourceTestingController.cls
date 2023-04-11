@RestResource(urlMapping='/Account/*')
global class RestResourceTestingController {
    
    @HttpGet
    global static Account doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); // /services/apexrest/Account/0017F00003D7I9UQAV
        //Map<String,String> paramsMap = RestContext.request.params;// /services/apexrest/Account/?id=0017F00003D7I9UQAV
        //String accid=paramsMap.get('id');
        Account result = [SELECT Id, Name, Phone, Website FROM Account WHERE Id = :accountId];
        return result;
    }
    @HttpPost
    global static String doPost(String name,
                                String phone, String website) {
                                    Account account = new Account();
                                    account.Name = name;
                                    account.phone = phone;
                                    account.website = website;
                                    insert account;
                                    return account.Id;
                                }
    @HttpDelete
    global static void doDelete() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Account account = [SELECT Id FROM Account WHERE Id = :accountId];
        delete account;
    }
    @httpPut
    global static Account doPutMethod(String Name, Integer AnnualRevenue){
        Map<String,String> paramsMap = RestContext.request.params;
        String accid = paramsMap.get('id');
        Account acc= new Account(Name =name, AnnualRevenue = annualrevenue, Id =accid);
        update acc;
        return acc;
    }
    
}