public without sharing class MyShoppingApp_LoginController {
    public MyShoppingApp_LoginController() {

    }
    @AuraEnabled
    public static loginWrapper login(String uName, String pass, String startUrl123) {        
        loginWrapper loginWrap = new loginWrapper();
        if(UserInfo.getSessionId() == null || UserInfo.getSessionId() == ''){
            try{
                ApexPages.PageReference pageRef = Site.login(uName, pass,'/s/');           
               // aura.redirect(pageRef);
                loginWrap.status = 'SUCCESS';  
                loginWrap.message =  'Logged in Successfully';
                loginWrap.returnUrl = pageRef.getUrl();
            }
            catch (Exception ex) {
                system.debug('ex '+ex.getMessage()); 
                loginWrap.status = 'ERROR';               
                loginWrap.message =  ex.getMessage();            
            }
        }
        else{
            loginWrap.status = 'FAILED';
            loginWrap.message =  'You are already logged in please wait we are redirecting you to home.';
            loginWrap.returnUrl = '/';
        }
        return loginWrap;
    } 
    public class loginWrapper{
        @AuraEnabled public  String message {get;set;}
        @AuraEnabled public  String status {get;set;}
        @AuraEnabled public  String returnUrl {get;set;}        
    }   
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }
    
    @AuraEnabled
    public static String getMyCustomData() {
        List<Organization> orgList = [SELECT IsSandbox FROM Organization LIMIT 1];
        String isProduction = orgList[0].IsSandbox?'false':'true';
        return System.URL.getSalesforceBaseUrl().toExternalForm()+'==='+Network.getNetworkId()+'==='+UserInfo.getOrganizationId()+'==='+isProduction;
    }
    
    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() { 
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }
    
    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }
    
    @AuraEnabled
    public static String getForgotPasswordUrl() {
        try{
            Auth.AuthConfiguration authConfig = getAuthConfig();
            if(Test.isRunningTest())
                return null;
            return authConfig.getForgotPasswordUrl();
        }catch (Exception ex) {
            return ex.getMessage();            
        }        
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;        
    }
    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        
        try 
        {
            System.debug(Site.isValidUsername(username));
            
            if(test.isRunningTest()){
                if(username == ''){
                    throw new NullPointerException();
                }
            }
            if(!Site.isValidUsername(username)) {
                
                return 'We can’t find a username that matches what you entered. Verify that your username is an email address (for example, username@company.com).';
            }
            else {
                Site.forgotPassword(username);
                return 'success';
            }             
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }
}