public without sharing class ProductCard_One_Controller {
    public ProductCard_One_Controller() {

    }
    @AuraEnabled
    public static string addToCart(Product__c product){
        user us = [Select id,name,accountId,contactId From User where id =: UserInfo.getUserId()];
        try {
            Cart__c cart = new Cart__c();
            cart.Product__c = product.Id;
            cart.Account__c =  us.accountId;   
            cart.contact__c =  us.contactId;
            cart.Quantity__c = 1;           
            Insert cart;
            return 'SUCCESS';
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '////////User is ==> '+us +'//////Product is ==>'+product);
        }
    }
    
}