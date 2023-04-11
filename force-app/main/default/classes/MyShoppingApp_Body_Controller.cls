public without sharing class MyShoppingApp_Body_Controller {

    @AuraEnabled 
    public static userDetailWrapper getAllProductList(boolean isGuest){
        String query  = '';
        if(isGuest == true){
            query = 'Select Id,Name,Price__c,Product_Description__c, Discount__c,Discount_Type__c,'+
                    'Discount_Up_to__c,RecordTypeId,Quantity__c  FROM Product__c';           
        }
        else{
            user us = [Select id,name,accountId,contactId From User where Id =: UserInfo.getUserId()];
            if(us.accountId != null){
                Id accId = us.accountId;
                query = 'Select Id,Name,Price__c,Product_Description__c, Discount__c,Discount_Type__c,'+
                'Discount_Up_to__c,RecordTypeId,Quantity__c ,(SELECT Id,Name,Account__c,Contact__c,Product__c,Quantity__c FROM Carts__r WHERE Account__c =:accId ) FROM Product__c';  
            }
            else{
                query = 'Select Id,Name,Price__c,Product_Description__c, Discount__c,Discount_Type__c,'+
                'Discount_Up_to__c,RecordTypeId ,Quantity__c FROM Product__c';  
            }
           
        }       
        List<Product__c> listOfProducts = Database.query(query);

        List<Id> listOfProductId = new List<Id>();
        for(Product__c product : listOfProducts){
            listOfProductId.add(product.Id);
        }
       
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Product__c.getRecordTypeInfosByName();
        Map<Id,String> recordTypeMap = New  Map<Id,String>();
        for(String key : recordTypes.keySet()){           
            recordTypeMap.put(recordTypes.get(key).getRecordTypeId(),key);
           
        }
        return (new userDetailWrapper(listOfProducts , recordTypeMap ,retriveStoryDocuments(listOfProductId)));

    }
    public class userDetailWrapper{
        @AuraEnabled 
        public List<Product__c> listOfProducts {get;set;}
        @AuraEnabled 
        public Map<Id,String> recordTypeMap {get;set;}
        @AuraEnabled 
        public Map<Id,List<Id>> mapOfProductAndImage {get;set;}

        public userDetailWrapper( List<Product__c> listOfProducts , Map<Id,String> recordTypeMap ,Map<Id,List<Id>> mapOfProductAndImage ){
            this.listOfProducts = listOfProducts;
            this.recordTypeMap = recordTypeMap;
            this.mapOfProductAndImage = mapOfProductAndImage;
        }
    }
    @AuraEnabled 
    public static  Map<Id,List<String>> retriveStoryDocuments(List<Id> listOfRecordId){ //List<Product__c> listOfProducts

        /* Set<Id> setOfId = new Set<id>();
        for(Product__c pd : listOfProducts){
            setOfId.add(pd.id);
        }*/

        List<ContentDocumentLink> projectDocument = [SELECT ContentDocumentId, Id, LinkedEntityId, ContentDocument.Title, 
                                                     ContentDocument.Description, ContentDocument.ParentId , ContentDocument.CreatedDate
                                                     FROM ContentDocumentLink WHERE LinkedEntityId IN : listOfRecordId]; 

        Map<Id,Id> mapOfLinkedEntityContentDocument = new Map<Id,Id> ();
        Set<Id> listOfAllContentDocumentId = new Set<Id>();

        for(ContentDocumentLink cdLink : projectDocument){   
            listOfAllContentDocumentId.add(cdLink.ContentDocumentId);           
            mapOfLinkedEntityContentDocument.put(cdLink.ContentDocumentId , cdLink.LinkedEntityId);
        }
        List<ContentVersion> listContentVersion  =   [SELECT Id,Title,ContentUrl,FileType,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId 
                                                        IN :  listOfAllContentDocumentId]; 
                                                        
        Map<Id,List<String>> MapofTemp = new Map<Id,List<String>>();
    
        for(ContentVersion conVer : listContentVersion){
            if( mapOfLinkedEntityContentDocument.containsKey(conVer.ContentDocumentId)   && 
                !MapofTemp.containsKey(mapOfLinkedEntityContentDocument.get(conVer.ContentDocumentId))){

                MapofTemp.put(mapOfLinkedEntityContentDocument.get(conVer.ContentDocumentId) , new List<String>());
            }
            MapofTemp.get(mapOfLinkedEntityContentDocument.get(conVer.ContentDocumentId)).add('/sfc/servlet.shepherd/version/download/'+conVer.Id);
        }  
        
        return MapofTemp;
        
    }
}