public without sharing class MyShoppingApp_Cart_Controller {
    public MyShoppingApp_Cart_Controller() {

    }
    @AuraEnabled
    public static ResponseWrapper getCartItems(){
        ResponseWrapper response = new ResponseWrapper();
        List<cart__c> listOfCartItems = new  List<cart__c>();
        Map<Id,List<String>> mapOfDocuments = new Map<Id,List<String>>();

        User currentUser = [SELECT Id, FirstName,LastName,Contact.FirstName,ContactId,Contact.LastName,Contact.Name,Contact.Email,
                            Name,Email,accountId FROM User WHERE  Id =: UserInfo.getUserId()];
        if(currentUser.accountId != null){
           listOfCartItems = [SELECT Id,Name,Account__c,Contact__c,Quantity__c,
                                            Product__c,Product__r.Name,Product__r.Price__c,Product__r.Discount__c,
                                            Product__r.Discount_Up_to__c , Product__r.Quantity__c
                                            FROM Cart__c WHERE Account__c =:currentUser.accountId];
        List<Id> listOfProduct = new List<Id>();
        for(cart__c item : listOfCartItems){
            listOfProduct.add(item.Product__c);
            if(item.Quantity__c == null){
                item.Quantity__c = 0;
            }
            if(item.Product__r.Quantity__c == null){
                item.Product__r.Quantity__c = 0;
            }
            if(item.Product__r.Discount_Up_to__c == null){
                item.Product__r.Discount_Up_to__c = 0;
            }
        }
       
        if(listOfCartItems.size() > 0){
            mapOfDocuments =  MyShoppingApp_Body_Controller.retriveStoryDocuments(listOfProduct);
        }
        response.listOfCartItems = listOfCartItems;
        response.mapOfDocuments =  mapOfDocuments;                                  
        }
        return response;

    }

    public class ResponseWrapper{
        @AuraEnabled
        public List<cart__c> listOfCartItems {get;set;}
        @AuraEnabled
        public Map<Id,List<String>> mapOfDocuments {get;set;}
    }
    @AuraEnabled
    public static string updateCart(cart__c cartItem){
        try {
            update cartItem;
            return 'SUCCESS';
        }
         catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string deleteCartItemRecord(String recordId){
        try {
            DELETE [SELECT Id,Name FROM Cart__c WHERE Id =: recordId];
            return 'SUCCESS';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}