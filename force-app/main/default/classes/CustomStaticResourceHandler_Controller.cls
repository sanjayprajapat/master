public class CustomStaticResourceHandler_Controller {  
   /* @AuraEnabled
    public static string getAllStaticResource() {
        Blob jsonContentAsBlob = [
            SELECT Body 
            FROM StaticResource 
            WHERE Name = 'myShoppingApp_bodyResources'
        ].Body;       
       return EncodingUtil.base64Encode(jsonContentAsBlob);       
    }*/
    @AuraEnabled
    public static StaticResource getAllStaticResource() {
        StaticResource st = [Select id,name,body,ContentType from StaticResource where Name = 'myShoppingApp_bodyResources'];
    	return st;
    }
    
}