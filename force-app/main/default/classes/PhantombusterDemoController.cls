public class PhantombusterDemoController {
    
    
    
    public static void doAuthentication(){
        HttpRequest httpRequest = new HttpRequest();       
        httpRequest.setHeader('X-Phantombuster-Key-1', 'bvmTAfOLtI0QGlhuxGiYAStMDC38l3mGWeQbLlh6dBg');        
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);       
        httpRequest.setEndpoint('https://phantombuster.com/api/v1/agent/2687201259188131/launch');
        
        Http http = new Http();
        try {
            HTTPResponse res = http.send(httpRequest);           
            if (res.getStatusCode() == 200) {
                system.debug('SUCCESS Authentication=== '+res.getBody());
                doFetchAgentOutput();
                //resultWrapper response = (resultWrapper)System.JSON.deserialize(res.getBody(), resultWrapper.class);
                //doFetchContainer(response.data.containerId);
            }
            else{
                 system.debug('FAILED Authentication=== '+res.getBody());
            }
        } catch(System.CalloutException e) {
            System.debug('ERROR:Authentication' + e);
            throw new AuraHandledException(e.getStackTraceString());            
        }        
    }
    
    public static void doFetchAgentOutput(){
        HttpRequest httpRequest = new HttpRequest();       
        httpRequest.setHeader('X-Phantombuster-Key-1', 'bvmTAfOLtI0QGlhuxGiYAStMDC38l3mGWeQbLlh6dBg');   
        httpRequest.setHeader('Accept', 'application/json');
        httpRequest.setMethod('GET');
        httpRequest.setTimeout(120000);       
        httpRequest.setEndpoint('https://api.phantombuster.com/api/v2/agents/fetch-output?id=2687201259188131');
        
        Http http = new Http();
        try {
            HTTPResponse res = http.send(httpRequest);           
            if (res.getStatusCode() == 200) {
                system.debug('SUCCESS Agent output=== '+res.getBody());
            }
            else{
                system.debug('FAILED Agent output=== '+res.getBody());
            }
        } catch(System.CalloutException e) {
            System.debug('ERROR:Agent output' + e);
            throw new AuraHandledException(e.getStackTraceString());            
        }        
    }
    
    public static void doFetchContainer(String containerId){
        HttpRequest httpRequest = new HttpRequest();       
        httpRequest.setHeader('X-Phantombuster-Key-1', 'bvmTAfOLtI0QGlhuxGiYAStMDC38l3mGWeQbLlh6dBg');   
        httpRequest.setHeader('Accept', 'application/json');
        httpRequest.setMethod('GET');
        httpRequest.setTimeout(120000);       
        httpRequest.setEndpoint('https://api.phantombuster.com/api/v2/containers/fetch-output?id='+containerId);
        
        Http http = new Http();
        try {
            HTTPResponse res = http.send(httpRequest);           
            if (res.getStatusCode() == 200) {
                system.debug('SUCCESS Conatiner=== '+res.getBody());
            }
            else{
                system.debug('FAILED Conatiner=== '+res.getBody());
            }
        } catch(System.CalloutException e) {
            System.debug('ERROR:Conatiner' + e);
            throw new AuraHandledException(e.getStackTraceString());            
        }        
    }
    
    public class resultWrapper{
        public  String status{get;set;} 
        public  data data{get;set;} 
    }
    public class data{
        public  String containerId{get;set;}  
    }
}