public class ContentDocumentLinksHandler {
    public static void processBeforeInsert(List<ContentDocumentLink> newContentDocumentLinkList){
        for(ContentDocumentLink objContentDocuLink : newContentDocumentLinkList) {            
            If(String.isNotBlank(objContentDocuLink.LinkedEntityId)) {
                objContentDocuLink.Visibility='AllUsers';
            }
        }
    } 
    public static void processAfterInsert(List<ContentDocumentLink> newContentDocumentLinkList){
        Map<String,String> keys = new Map<String,String>();
        
        Map<String,Schema.SobjectType> describe = Schema.getGlobalDescribe();
        for(String s:describe.keyset())
            keys.put(describe.get(s).getDescribe().getKeyPrefix(),s);
        
        Set<Id> setContentDocumentIds = new Set<Id>();
        List<Product__c> productList = new List<Product__c>();        
        List<ContentDocumentLink> newTriggerList = new List<ContentDocumentLink>();
        Map<Id,List<String>> mapOfProducAndPublicUrl = new  Map<Id,List<String>>();
        
        for(ContentDocumentLink conDocumentLink : newContentDocumentLinkList){
            If(conDocumentLink.LinkedEntityId != null && keys.get(String.valueOf(conDocumentLink.LinkedEntityId).substring(0,3)) == 'Product__c'){
                setContentDocumentIds.add(conDocumentLink.ContentDocumentId);
                newTriggerList.add(conDocumentLink);
            }
        }
        If(setContentDocumentIds.size() > 0){
            Map<Id,ContentDocument> conDocsWithVersionMap = new Map<Id,ContentDocument>();
            for(ContentDocument conDocs : [Select Id,title,LatestPublishedVersionId From ContentDocument Where ID IN : setContentDocumentIds]){
                conDocsWithVersionMap.put(conDocs.Id, conDocs);
            }
            
            Map<ID,ContentDistribution > mapContentLinkWithDistribution = new MAP<ID,ContentDistribution >();
            
            for(ContentDocumentLink conDocumentLink : newTriggerList){
                ContentDistribution cd = new ContentDistribution();
                cd.name = conDocsWithVersionMap.get(conDocumentLink.ContentDocumentId).title;
                cd.ContentVersionId = conDocsWithVersionMap.get(conDocumentLink.ContentDocumentId).LatestPublishedVersionId;
                cd.PreferencesAllowOriginalDownload = true;               
                mapContentLinkWithDistribution.put(conDocumentLink.LinkedEntityId,cd);
            }
            If(mapContentLinkWithDistribution.size() > 0){
                Insert mapContentLinkWithDistribution.values();
                
                Map<Id,String> mapVersionWithDistributionURL = new Map<Id,String>();
                for(ContentDistribution conDistributions : [SELECT ContentVersionId,DistributionPublicUrl FROM ContentDistribution WHERE ID = : mapContentLinkWithDistribution.values()] ){
                    mapVersionWithDistributionURL.put(conDistributions.ContentVersionId,conDistributions.DistributionPublicUrl );
                }
                
                for(ContentDocumentLink conDocumentLink : newTriggerList){
                    If(mapVersionWithDistributionURL.get(conDocsWithVersionMap.get(conDocumentLink.ContentDocumentId).LatestPublishedVersionId) != null){
                        String distributionURL = mapVersionWithDistributionURL.get(conDocsWithVersionMap.get(conDocumentLink.ContentDocumentId).LatestPublishedVersionId);
                        if(!mapOfProducAndPublicUrl.containskey(conDocumentLink.LinkedEntityId)){
                            mapOfProducAndPublicUrl.put(conDocumentLink.LinkedEntityId , new List<String>());
                        }
                        mapOfProducAndPublicUrl.get(conDocumentLink.LinkedEntityId).add(distributionURL);
                    }
                }
            }
            
            if(!mapOfProducAndPublicUrl.isEmpty()){
                
                productList =  [SELECT ID,Name,Public_Image_Urls__c FROM Product__c WHERE ID IN : mapOfProducAndPublicUrl.keySet()];
                for(Product__c product  : productList){
                    Map<Integer,String> mapOfTemp = new Map<Integer,String>();
                    if(product.Public_Image_Urls__c != null && product.Public_Image_Urls__c != ''){
                        mapOfTemp = ( Map<Integer,String> )JSON.deserialize(product.Public_Image_Urls__c, Map<Integer,String>.class);
                        Integer count = mapOfTemp.keySet().size() - 1;
                        for(String urls : mapOfProducAndPublicUrl.get(product.Id)){                           
                            mapOfTemp.put(count, urls);
                            count++;
                        }
                    }
                    else{
                        Integer count = 0;
                        for(String urls : mapOfProducAndPublicUrl.get(product.Id)){                           
                            mapOfTemp.put(count, urls);
                            count++;
                        }
                    }
                    product.Public_Image_Urls__c = JSON.serialize(mapOfTemp);
                }  
            }
            If(productList.size() > 0)
                update productList;             
            
        }
    }    
   
}