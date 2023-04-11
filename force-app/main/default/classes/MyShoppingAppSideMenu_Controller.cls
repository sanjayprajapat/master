public with sharing class MyShoppingAppSideMenu_Controller {
    public MyShoppingAppSideMenu_Controller() {

    }
    @AuraEnabled   
    Public static user getUserDetails()
     {
         User u = [Select SmallPhotoUrl, FullPhotoUrl ,Name,email
                    From User where id=:Userinfo.getUserid()]; 
                    return u;       
     }
}