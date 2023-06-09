public class Vision { 
    public static FINAL STRING OAUTH_END_POINT = 'https://api.einstein.ai/v2/oauth2/token';
    public static FINAL String  OCR_MODEL       = 'OCRModel';
    public static FINAL String  OCR_MODEL_TABEL = 'tabulatev2';
    
    
    public static String getAccessToken() {
        // Ignore the File upload part and "jwt.pkcs" if you used a Salesforce certificate to sign up 
        // for an Einstein Platform account
        ContentVersion base64Content = [SELECT Title, VersionData FROM ContentVersion where Title='einstein_platform' OR  Title='predictive_services' ORDER BY Title LIMIT 1];
        String keyContents = base64Content.VersionData.tostring();
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');
        
        
        JWT jwt = new JWT('RS256');// Get a new token
        // jwt.cert = 'JWTCert'; // Uncomment this if you used a Salesforce certificate to sign up for an Einstein Platform account
        jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
        jwt.iss = 'developer.force.com';
        jwt.sub = 'sanjayprajapat519@gmail.com';
        jwt.aud = OAUTH_END_POINT;
        jwt.exp = '3600';
        String access_token = JWTBearerFlow.getAccessToken(OAUTH_END_POINT, jwt);        
        return access_token;    
    } 
    
    public static String predictUrl(String endPoint, String sample, String model, boolean isBase64) {
        return predictInternal(endPoint, sample, model, isBase64);
    }
    
    public static String predictBase64(String endPoint, String sample, String model, boolean isBase64) {
        return predictInternal(endPoint, sample, model, isBase64);
    }
    
    public static String predictBlob(String endPoint, blob fileBlob, String model, boolean isBase64) {
        return predictInternal(endPoint , EncodingUtil.base64Encode(fileBlob), model, isBase64);
    }    
    private static String predictInternal(String endPoint, String sample, String model,boolean isBase64) {        
        String access_token = getAccessToken();
        
        string contentType = HttpFormBuilder.GetContentType();
        
        string form64 = ''; //  Compose the form
        
        form64 += HttpFormBuilder.WriteBoundary();
        
        if(model == OCR_MODEL){
            form64 += HttpFormBuilder.WriteBodyParameter('task', EncodingUtil.urlEncode('text', 'UTF-8'));
            form64 += HttpFormBuilder.WriteBoundary();    
        }
        else{
            form64 += HttpFormBuilder.WriteBodyParameter('task', EncodingUtil.urlEncode('table', 'UTF-8'));
            form64 += HttpFormBuilder.WriteBoundary();            
        }   
        form64 += HttpFormBuilder.WriteBodyParameter('modelId', EncodingUtil.urlEncode(model, 'UTF-8'));
        form64 += HttpFormBuilder.WriteBoundary();
        
        if(isBase64) {
            form64 += HttpFormBuilder.WriteBodyParameter('sampleBase64Content', sample);
        } else {
            form64 += HttpFormBuilder.WriteBodyParameter('sampleLocation', sample);
        }
        form64 += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);
        
        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        
        HttpRequest httpRequest = new HttpRequest(); //  Compose the http request
        
        httpRequest.setBodyAsBlob(formBlob);
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Length', contentLength);
        httpRequest.setHeader('Content-Type', contentType);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization','Bearer ' + access_token);
        httpRequest.setEndpoint(endPoint);
        
        Http http = new Http();
        try {
            HTTPResponse res = http.send(httpRequest);           
            if (res.getStatusCode() == 200) {
                return res.getBody();
            }
            else{
                throw new AuraHandledException(res.getBody()); 
            }
        } catch(System.CalloutException e) {
            System.debug('ERROR:' + e);
            throw new AuraHandledException(e.getStackTraceString());            
        }        
    }
}