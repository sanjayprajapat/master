public class GoogleCloudIntegrationController {
    
    public static Google_Config__mdt googleConfig { get; set; }
    public static Google_Token__mdt googleToken   { get; set; }
    public FINAL String baseURL = System.URL.getSalesforceBaseURL().toExternalForm()+'/';
    
    private static FINAL String END_POINT    = 'https://vision.googleapis.com/v1/images:annotate';
    private static FINAL String CONTENT_TYPE = 'application/json';
    private static FINAL String TOKEN_TYPE   = 'Bearer ';
    private static FINAL String GC_MODEL     = 'builtin/stable';
    
    @AuraEnabled
    public static Boolean checkIsTokenValid(){
        Boolean isExpired = false;
        String result = getValueFromUserPreference('expires_in_time');
        if(result != null && result != ''){
            dateTime expires_in_time = DateTime.valueOf(result);
            if(expires_in_time < System.now()){
                isExpired = true;
            }
        }
        return isExpired;
    }
    public static String getValueFromUserPreference(String fieldName){
        String value;
        List<User_Preference__c> listOfUserPreference = [SELECT ID,Name,Google_Cloud_Vision_Detail__c,User__c FROM User_Preference__c 
                                                         WHERE User__c =: UserInfo.getUserId()];
        if(listOfUserPreference.size() > 0 && listOfUserPreference != null){
            if(listOfUserPreference[0].Google_Cloud_Vision_Detail__c != null && listOfUserPreference[0].Google_Cloud_Vision_Detail__c != ''){
                Map<String,String> googleClouVisionMap = (Map<String,String>)JSON.deserialize(listOfUserPreference[0].Google_Cloud_Vision_Detail__c, Map<String,String>.class);
                
                if(!googleClouVisionMap.isEmpty()){
                    if(googleClouVisionMap.containsKey(fieldName)){
                        if(fieldName == 'expires_in_time'){
                            dateTime expires_in_time = DateTime.valueOf(googleClouVisionMap.get(fieldName));
                            value = String.valueOf(expires_in_time);
                        }
                        else{
                            value = googleClouVisionMap.get(fieldName);
                        }    
                    }
                }
                
            } 
        }
        return value;
    }
    
    @AuraEnabled
    public static void getAutoCodeHandler(){   
        googleConfig = Google_Config__mdt.getInstance('Google_Cloud_1');
        
        String authURL = googleConfig.authorize_uri__c+
            '?client_id='		+googleConfig.client_id__c+'&'+
            'response_type='	+googleConfig.response_type__c+'&'+
            'scope='			+googleConfig.scope__c+'&'+
            'access_type='		+googleConfig.access_type__c+'&'+
            'prompt='			+googleConfig.prompt__c+'&'+
            'redirect_uri='		+googleConfig.redirect_uri__c;
        
        PageReference pageRef = new PageReference(authURL);
        //pageRef.setRedirect(true);
        aura.redirect(pageRef);
        
    }
    
    @AuraEnabled
    public static accessTokenWrapper getAccessToken(String authCode){
        accessTokenWrapper wrapper = new accessTokenWrapper();
        User_Preference__c userPreference = new User_Preference__c();
        googleConfig = Google_Config__mdt.getInstance('Google_Cloud_1');
        String errorMessage = '';              
        String requestBody = 'code='+authCode+'&'+
            				'client_id='+googleConfig.client_id__c+'&'+
            				'client_secret='+googleConfig.client_secret__c+'&'+
            				'redirect_uri='+googleConfig.redirect_uri__c+'&'+
            				'grant_type='+googleConfig.grant_type__c;        
        HttpRequest httpReq = prepareRequest(googleConfig.Token_URL__c,'POST',requestBody,googleConfig.Content_Type__c);        
        HttpResponse httpRes = new HttpResponse();
        try{
            httpRes = (new Http()).send(httpReq);           
            if(httpRes.getStatusCode() == 200){                
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());               
                if(!responseMap.isEmpty()){
                    updateUserPreference(responseMap);
                }                
                wrapper.access_token = (String)responseMap.get('access_token');
                wrapper.refresh_token = (String)responseMap.get('refresh_token');
                wrapper.expires_in = String.valueOf(responseMap.get('expires_in'));
                wrapper.scope = (String)responseMap.get('scope');
                wrapper.message = 'SUCCESS';
                
            }
            else{
                errorMessage = 'Unexpected Error while communicating with Google API.'+
                    'Status : '+httpRes.getStatus()+
                    ' and Status Code : '+httpRes.getStatuscode()+
                    ' and error message :'+httpRes.getBody();
            }
        }
        catch(System.CalloutException ex){
            if(String.valueOf(ex).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'+' Remote Site Setting and add '+' '+ 'https://www.googleapis.com/' +' Endpoint';
                throw new AuraHandledException(errorMessage);
            }
        }
        catch(System.Exception ex){
            errorMessage = 'System error : '+ex.getMessage() + ' at line number '+ex.getLineNumber();
            throw new AuraHandledException(errorMessage);        
        }  
        if(errorMessage != null && errorMessage != ''){
            throw new AuraHandledException(errorMessage);
        }
        system.debug('wrapper === '+wrapper);
        return wrapper;
    }
    
    public static Map<String, Object> doRefreshToken(){
        User_Preference__c userPreference = new User_Preference__c();
        String errorMessage = '';
        googleConfig = Google_Config__mdt.getInstance('Google_Cloud_1');
        String refresh_token = getValueFromUserPreference('refresh_token');
        
        String requestBody = 'client_id='+googleConfig.client_id__c+'&'+
            				'client_secret='+googleConfig.client_secret__c+'&'+
            				'refresh_token='+refresh_token+'&'+
            				'grant_type=refresh_token';        
        HttpRequest httpReq = prepareRequest(googleConfig.Token_URL__c,'POST',requestBody,googleConfig.Content_Type__c);        
        HttpResponse httpRes = new HttpResponse();        
        Map<String, Object> responseMap = new Map<String, Object>();        
        try{
            httpRes = (new Http()).send(httpReq);
            if(httpRes.getStatusCode() == 200){                
                responseMap = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());                              
            }
            else{
                errorMessage = 'Unexpected Error while communicating with Google API. '+'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();                
            }
        }
        catch(System.CalloutException ex){
            if(String.valueOf(ex).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                    +' Remote Site Setting and add '+' '+ 'https://www.googleapis.com/' +' Endpoint';
                 throw new AuraHandledException(errorMessage);                
            }
        }
        catch(System.Exception ex){                        
            errorMessage = 'System Error : '+ex.getMessage() + ' at '+ex.getLineNumber();
            throw new AuraHandledException(errorMessage);            
        }
        if(errorMessage != null && errorMessage != ''){
            throw new AuraHandledException(errorMessage);
        }
        return responseMap;
    }	   
    public static void updateUserPreference(Map<String,object> responseMap){
        
        
        Map<String,String> mapOfGoogleToken = new Map<String,String>();
        mapOfGoogleToken.put('access_token',(String)responseMap.get('access_token'));
        Integer seconds = (Integer)responseMap.get('expires_in');
        mapOfGoogleToken.put('expires_in',String.valueOf(seconds));
        mapOfGoogleToken.put('expires_in_time',String.valueOf(System.now().addSeconds(seconds)));
        mapOfGoogleToken.put('External_Id','GoogleToken');
        mapOfGoogleToken.put('refresh_token',(String)responseMap.get('refresh_token'));
        mapOfGoogleToken.put('scope',(String)(String)responseMap.get('scope'));
        
        system.debug('mapOfGoogleToken === '+mapOfGoogleToken);
        List<User_Preference__c> listOfUserPreference = [SELECT ID,Name,Google_Cloud_Vision_Detail__c,User__c FROM User_Preference__c 
                                                         WHERE User__c =: UserInfo.getUserId()];
        if(listOfUserPreference.size() > 0 && listOfUserPreference != null){
            listOfUserPreference[0].Google_Cloud_Vision_Detail__c = JSON.serialize(mapOfGoogleToken);
            system.debug('Google_Cloud_Vision_Detail__c === '+listOfUserPreference[0].Google_Cloud_Vision_Detail__c);
            try{
                Update listOfUserPreference; 
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        else{
            User_Preference__c userPreference = new User_Preference__c();
            userPreference.Google_Cloud_Vision_Detail__c = JSON.serialize(mapOfGoogleToken);
            userPreference.User__c = UserInfo.getUserId();
            try{
                Insert userPreference; 
            }
            catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
    
    
    public static HttpRequest prepareRequest(String endPoint, String Method, String Body, String contentType){
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endPoint);
        httpReq.setMethod(Method);
        httpReq.setHeader('Content-Type',contentType);
        if(!String.isBlank(body)){
            httpReq.setBody(body);
        }
        return httpReq;
        
    }
    
    public class accessTokenWrapper{
        @AuraEnabled public String access_token {get;set;}
        @AuraEnabled public String expires_in {get;set;}
        @AuraEnabled public String refresh_token {get;set;}
        @AuraEnabled public String scope {get;set;}
        @AuraEnabled public String message {get;set;}
    }
    
    
    
    
    /***********************Text recognisation***********************************/
    public class ResponseWrapper {
        @AuraEnabled public String response { get; set; }
        @AuraEnabled public String error    { get; set; }
    } 
    
    @future
    private static void insertImageDetData(String response, String base64String){
        
        List<Image_Detection__c> imageDitList = new List<Image_Detection__c>();
        Image_Detection__c parentImg = new Image_Detection__c();
        
        if(!String.isBlank(response)){
            
            TextDetection text = (TextDetection)System.JSON.deserialize(response, TextDetection.class);
            
            List<TextDetection.Responses> responseList = text.responses;
            
            if(responseList != null && !responseList.isEmpty()){
                List<TextDetection.TextAnnotations> annotations = responseList.get(0).textAnnotations;
                for(TextDetection.TextAnnotations ann : annotations){
                    Image_Detection__c img = new Image_Detection__c();
                    img.Name      = ann.description;
                    img.Locale__c = ann.locale;
                    img.External_Id__c = ann.description;
                    if(String.isBlank(ann.locale)){
                        imageDitList.add(img);
                    }else{
                        parentImg = img;
                    }
                    
                }
            }
        }
        
        Database.upsert(parentImg, Image_Detection__c.Name, false);
        
        for(Image_Detection__c im: imageDitList){
            if( parentImg.Id != null ){
                im.Parent__c = parentImg.Id;
            }
        }
        
        Database.upsert(imageDitList, Image_Detection__c.Name, false);
        
    }
    
    @AuraEnabled
    public static List<Image_Detection__c> detectTextFromImage(String base64String, String imageURL, String gScURL, String type){
        
        ResponseWrapper wrapper = doCallGcCloudAPI(base64String, imageURL, gScURL, type);
        
        List<Image_Detection__c> imageDitList = new List<Image_Detection__c>();
        
        if(!String.isBlank(wrapper.response)){
            
            TextDetection text = (TextDetection)System.JSON.deserialize(wrapper.response, TextDetection.class);
            
            List<TextDetection.Responses> responseList = text.responses;
            
            if(responseList != null && !responseList.isEmpty()){
                List<TextDetection.TextAnnotations> annotations = responseList.get(0).textAnnotations;
                for(TextDetection.TextAnnotations ann : annotations){
                    
                    Image_Detection__c img = new Image_Detection__c();
                    img.Name      = ann.description;
                    img.Locale__c = ann.locale;
                    img.External_Id__c = ann.description;
                    
                    imageDitList.add(img);
                }
            }
            
            insertImageDetData(wrapper.response, base64String );
            
        }
        return imageDitList;
        
    }
    
    private static ResponseWrapper doCallGcCloudAPI(String base64String, String imageURL, String gScURL, String type){
        
        String requestBody = prepareBody(base64String, imageURL, gScURL, type);        
        String accessToken = getValueFromUserPreference('access_token'); 
        system.debug('accessToken === '+accessToken);
        HttpRequest httpReq = prepareRequest(END_POINT,'POST',requestBody,CONTENT_TYPE);
        httpReq.setHeader('Accept', CONTENT_TYPE);
        
        Boolean isExpired = checkIsTokenValid();
        Map<String, object> tokenMap;
        if(isExpired){
            tokenMap = doRefreshToken();
            if(tokenMap != null){
                accessToken = (String)tokenMap.get('access_token');
                system.debug('accessToken after refresh == '+accessToken);
            }            
        }
        if(isExpired && ( tokenMap == null || tokenMap.size() == 0 ) ){
            return null;
        }        
        httpReq.setHeader('Authorization', TOKEN_TYPE+accessToken);        
        ResponseWrapper wrappper = new ResponseWrapper();        
        try{
            wrappper =  sendRequest(httpReq);            
        }
        catch(Exception e){
             throw new AuraHandledException('System error : '+e.getMessage() + ' at line number '+e.getLineNumber());
        }       
        if(wrappper.error != null && wrappper.error != ''){
             throw new AuraHandledException(wrappper.error);
        }
        return wrappper;
    }
    public static ResponseWrapper sendRequest(HttpRequest httpReq){
        
        HttpResponse httpRes = new HttpResponse();
        String errorMessage = '';               
        ResponseWrapper wrapper = new ResponseWrapper();        
        httpRes = (new Http()).send(httpReq);           
        if(httpRes.getStatusCode() == 200){
            wrapper.response = httpRes.getBody();
        }
        else{
            errorMessage = 'Error: Unexpected Error while communicating with Google API. '+'Status: '+httpRes.getStatus()+
                ' and Status Code: '+httpRes.getStatusCode()+' Response:: '+httpRes.getBody();
            wrapper.error = errorMessage;
        }       
        return wrapper;
    }
     private static String prepareBody(String base64String, String imageURL, String gScURL, String type){
    
        String content = String.isBlank(base64String) ? '""' : '"'+base64String+'"';
        String imgURL  = String.isBlank(imageURL)     ? '""' : '"'+imageURL+'"';
        String gcURL   = String.isBlank(gScURL)       ? '""' : '"'+gScURL+'"';
        
        String requestBody = '{'+
          '"requests": ['+
            '{'+
              '"features": ['+
                '{'+
                  '"model": "'+GC_MODEL+'",'+
                  '"type": "'+type+'",'+
                  '"maxResults": 10'+
                '}'+
              '],'+
              '"image": {'+
                '"source": {'+
                  '"imageUri": '+imgURL+','+
                  '"gcsImageUri": '+gcURL+
                '},'+
                '"content": '+content+
              '}'+
            '}'+
          ']'+
        '}';
        return requestBody;
    }
}