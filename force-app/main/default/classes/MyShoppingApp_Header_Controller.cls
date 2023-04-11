public without sharing class MyShoppingApp_Header_Controller {
    public MyShoppingApp_Header_Controller() {

    }
    public class ResponseWrapper{
        @AuraEnabled
        public User userInfo {get;set;}
        @AuraEnabled
        public String userInitials {get;set;}
        @AuraEnabled
        public integer currentHour {get;set;}
        @AuraEnabled
        public List<Cart__c> listOfCartItems {get;set;}
        @AuraEnabled
        public integer countOfCartItems {get;set;}
    }

    @AuraEnabled
    public static ResponseWrapper getUserDetails(){
        ResponseWrapper obj = new ResponseWrapper(); 

        User currentUser = [SELECT Id, FirstName,LastName,Contact.FirstName,ContactId,Contact.LastName,Contact.Name,Contact.Email,
                            Name,Email,accountId FROM User WHERE  Id =: UserInfo.getUserId()];

        obj.userInfo = currentUser;

        if(!String.isBlank(currentUser.Contact.FirstName) || !String.isBlank(currentUser.Contact.LastName)){
            obj.userInitials = MyShoppingApp_Header_Controller.createInitials(currentUser.Contact.FirstName,currentUser.Contact.LastName);
        }
        else{
            obj.userInitials = MyShoppingApp_Header_Controller.createInitials(currentUser.FirstName,currentUser.LastName);
        }
        
        if(currentUser.ContactId != null){
            obj.listOfCartItems = [SELECT Id,Name,Account__c,Contact__c,Product__c,Quantity__c FROM Cart__c WHERE Contact__c =:currentUser.ContactId];
            obj.countOfCartItems = obj.listOfCartItems.size();                      
        }
       
        TimeZone tz = UserInfo.getTimeZone();
        DateTime dt = Datetime.now(); 
        dt.addSeconds((tz.getOffset(dt)/1000));
        obj.currentHour = dt.hour();  

        return obj;
        
    }
    public static String createInitials(String firstName, String lastName){
        
        String initials = '';
        if(	(lastName != '' || lastName != null) && (firstName == '' || firstName == null) ){
            initials = lastName.substring(0, 2);
        }
        else if( (firstName != '' || firstName != null) && (lastName == '' || lastName == null) ){
            initials = firstName.substring(0, 2);
        }else {
            initials = firstName.substring(0, 1) + lastName.substring(0, 1);
        }       
        return initials;
    }
}