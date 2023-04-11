public without sharing class DetectTextUsingEinstein_Controller {  
    
    public static FINAL String  OCR_API         = 'https://api.einstein.ai/v2/vision/ocr';
    public static FINAL String  OCR_MODEL       = 'OCRModel';
    public static FINAL String  OCR_MODEL_TABEL = 'tabulatev2';
    
    @AuraEnabled  
    public static EinsteinOCRResponse DetectTextFromImage(String base64String,String imageURL,boolean isBase64,boolean isTableDetection){
        String result ;
        
        String MODAL = '';
        if(isTableDetection == true){
            MODAL = OCR_MODEL_TABEL;
        }
        else{
             MODAL = OCR_MODEL;
        }
       
        if(isBase64 == true){
            result = Vision.predictBase64(OCR_API, base64String, MODAL, isBase64);  //choose file from lightning file but image doesn't contains table           
        }
        else if(isBase64 == false){
            result = Vision.predictUrl(OCR_API, imageURL, MODAL, isBase64); //choose file from Url file but image doesn't contains table
        }        
        return parseResponse(result);
    }    
    private static EinsteinOCRResponse parseResponse(String ressult){
        EinsteinOCRResponse response = (EinsteinOCRResponse)System.JSON.deserialize(ressult, EinsteinOCRResponse.class);
        for(probabilities prob : response.probabilities){
            System.debug(System.LoggingLevel.DEBUG, prob.label);
        }
        return response;
    }
    public class EinsteinOCRResponse {
        @AuraEnabled  public String task;	
        @AuraEnabled  public List<Probabilities> probabilities;        
    }
    public class Probabilities {
        @AuraEnabled  public Double probability;
        @AuraEnabled  public String label;	
        @AuraEnabled  public BoundingBox boundingBox;
    }
    public class BoundingBox {
        @AuraEnabled  public Integer minX;	
        @AuraEnabled  public Integer minY;	
        @AuraEnabled  public Integer maxX;	
        @AuraEnabled  public Integer maxY;	
    }
    
 /************************************************************************************************/   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   
    /*@AuraEnabled
    public static List<Probabilities> DetectTextFromImage(String base64String,String imageURL,boolean isUrl){
       	HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://api.einstein.ai/v2/vision/ocr');
        req.setHeader('content-type', 'multipart/form-data; charset="UTF-8"; boundary="1ff13444ed8140c7a32fc4e6451aa76d"');
        req.setHeader('Authorization', 'Bearer '+getAccessToken()); //replace token with your access token
        
        req.setHeader('Cache-Control', 'no-cache');
        string form64 = '';
        
        form64 += HttpFormBuilder.WriteBoundary();
        
        if(isUrl == true){
            form64 += HttpFormBuilder.WriteBodyParameter('sampleLocation', imageURL);
        }
        else{
            form64 += HttpFormBuilder.WriteBodyParameter('sampleBase64Content', base64String);
        }       
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('modelId', 'OCRModel');
        form64 += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);
        
        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        
        req.setBodyAsBlob(formBlob);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Content-Length', contentLength);
        req.setTimeout(60*1000);
        
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        
        System.debug('=======OCR Detail Set ==========='); 
        system.debug('status code == '+res.getStatus());
        system.debug('status code == '+res.getStatusCode());
        system.debug('body == '+res.getBody());
        
        ocrWrapper obj = ( ocrWrapper )JSON.deserialize(res.getBody(), ocrWrapper.class);
       
		return obj.probabilities;       
            
    }
    
    public class ocrWrapper {
        @AuraEnabled public string message{get;set;}
        @AuraEnabled public string objects{get;set;}
        @AuraEnabled public string sampleId{get;set;}
        @AuraEnabled public string status{get;set;}
        @AuraEnabled  public List<Probabilities> probabilities{get;set;}
        
    }
    public class Probabilities {
        @AuraEnabled public string label{get;set;}
        @AuraEnabled public string probability{get;set;}
    }*/ 
    /*public static string createDataSet(String imageUrl){
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://api.einstein.ai/v2/vision/datasets/upload');
        req.setHeader('content-type', 'multipart/form-data; charset="UTF-8"; boundary="1ff13444ed8140c7a32fc4e6451aa76d"');
        req.setHeader('Authorization', 'Bearer '+getAccessToken()); //replace token with your access token
        
        req.setHeader('Cache-Control', 'no-cache');
        string form64 = '';
        
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('path', imageUrl);
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('type', 'image');
        form64 += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);
        
        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        
        req.setBodyAsBlob(formBlob);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Content-Length', contentLength);
        req.setTimeout(60*1000);
        
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
       
        String dataSetId = '';
        Map<String,Object> answerMap = ( Map<String,Object> )JSON.deserializeUntyped(res.getBody()); 
        for(String key : answerMap.keyset()){            
            system.debug(key + ' : '+string.valueOf(answerMap.get(key)));  
            if( key == 'id' ){
                 dataSetId = string.valueOf(answerMap.get(key));
            }
        }
        if(dataSetId != '' && dataSetId != null){
          String trainDataSet_body =   trainDataSet(dataSetId);
            Map<String,Object> answerMap2 = ( Map<String,Object> )JSON.deserializeUntyped(trainDataSet_body); 
            System.debug('=======Train Data Set ===========');
            for(String key : answerMap2.keyset()){            
                system.debug(key + ' : '+string.valueOf(answerMap2.get(key)));                
            }
        }
        return '';
    }
    public static string trainDataSet(String dataSetId){
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://api.einstein.ai/v2/vision/train');
        req.setHeader('content-type', 'multipart/form-data; charset="UTF-8"; boundary="1ff13444ed8140c7a32fc4e6451aa76d"');
        req.setHeader('Authorization', 'Bearer '+getAccessToken());
        
        req.setHeader('Cache-Control', 'no-cache');
        //  Compose the form
        string form64 = '';
        
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('name','Car vs Bike Model');
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('datasetId', dataSetId);
        form64 += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);
        
        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        
        req.setBodyAsBlob(formBlob);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Content-Length', contentLength);
        req.setTimeout(60*1000);
        
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        resp = res.getBody();
        //system.debug(resp);
        return res.getBody();        
    }*/     
}