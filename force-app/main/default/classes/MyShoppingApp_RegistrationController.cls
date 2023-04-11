public without sharing class MyShoppingApp_RegistrationController {
    public MyShoppingApp_RegistrationController() {

    }
    @AuraEnabled
    public static String getMyCustomData() {
        List<Organization> orgList = [SELECT IsSandbox FROM Organization LIMIT 1];
        System.debug(orgList);
        String isProduction = orgList[0].IsSandbox ? 'false':'true';
        System.debug(isProduction);
        return System.URL.getSalesforceBaseUrl().toExternalForm()+'==='+Network.getNetworkId()+'==='+UserInfo.getOrganizationId()+'==='+isProduction;
    }
    
    @AuraEnabled
    public static RegisterUserResponseWrapper registerUser(String firstName, String lastName, String emailAddress) {
        RegisterUserResponseWrapper resWrap = new RegisterUserResponseWrapper();
        Savepoint sp = Database.setSavepoint();
        string result = '';
        String accName = firstName+' '+lastName;
        system.debug('Label.Sanjay_Prajapat_Id ===='+Label.Sanjay_Prajapat_Id);
        try{
            Account acc = new Account(  
                Name = accName,
                ownerId = Label.Sanjay_Prajapat_Id
            );
            Database.DMLOptions dml0 = new Database.DMLOptions(); 
            dml0.DuplicateRuleHeader.allowSave = true;
            Database.SaveResult sr0 = Database.insert(acc, dml0);
            if(!sr0.isSuccess()){
                Database.rollback(sp);
                system.debug('Error in Account === '+sr0.errors[0].getMessage());
                resWrap.message = sr0.errors[0].getMessage();
                resWrap.status = 'Error';
                return resWrap;                             
            }
            Contact con = new Contact (
                FirstName = firstName,
                LastName  = lastName, 
                Email     = emailAddress,
                AccountId = acc.Id,
                ownerId   = Label.Sanjay_Prajapat_Id
            );
            
            Database.DMLOptions dml1 = new Database.DMLOptions(); 
            dml1.DuplicateRuleHeader.allowSave = true;
            Database.SaveResult sr1 = Database.insert(con, dml1);
            if(!sr1.isSuccess()){
                Database.rollback(sp);
                system.debug('Error in Conatct === '+sr1.errors[0].getMessage());
                resWrap.message = sr1.errors[0].getMessage();
                resWrap.status = 'Error';
                return resWrap;
            }            
            
            List<Profile> profile = [SELECT Id,Name FROM Profile WHERE Name ='My Community Plus Login User'];
            User communityUser = new User();
            communityUser.FirstName = con.FirstName;
            communityUser.LastName = con.LastName;
            communityUser.LocaleSidKey = 'en_US';
            communityUser.TimeZoneSidKey = 'America/New_York';
            if(con.Email != null){
                communityUser.Email = (con.Email).toLowerCase();
                communityUser.Username = communityUser.Email;
            }  
            communityUser.contactId = con.Id;           
            communityUser.alias = (communityUser.FirstName == null ? '' : communityUser.FirstName.substring(0,1) + '' + (communityUser.LastName.length() < 4 ? communityUser.LastName : communityUser.LastName.substring(0,4))).toLowerCase();
            communityUser.CommunityNickname = communityUser.FirstName == null ? '' : communityUser.FirstName.substring(0,1)+ '' + communityUser.LastName + ''+'001';//Kamesh-Changed NickName According Story S-3698 Format
            communityUser.emailencodingkey = 'UTF-8';
            communityUser.languagelocalekey = 'en_US';
            communityUser.ProfileId = profile[0].Id;

            system.debug('communityUser is ============================>'+communityUser);
            Id newCommUserId = Site.createExternalUser(communityUser, acc.Id, 'TestUser@123', true);            
            System.debug('communityUser==>'+newCommUserId);
            if(newCommUserId != null || newCommUserId != ''){
                AssignPermissionToUser(newCommUserId);
            }
            else{
                Database.rollback(sp);
            }
            if(newCommUserId != null){
                PageReference lgn = Site.login(communityUser.Username, 'TestUser@123','');
                aura.redirect(lgn);                
            }
            resWrap.message = 'Thanks for registering! Please check your email for next steps.';
            resWrap.status = 'Success';
            return resWrap;   
        }
        catch(Exception e){
            Database.rollback(sp);
            system.debug('Error in catch block is==============='+e.getMessage());
            resWrap.message = e.getMessage();
            resWrap.status = 'Error';
            return resWrap;           
        }       
    }
    @future
    public static void AssignPermissionToUser(Id userId){   
        
        List<PermissionSet> permissionSetList = [SELECT Id, ProfileId, Name, Label FROM PermissionSet WHERE Label='My Shopping App']; 
        List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
        for(PermissionSet pset : permissionSetList){
            permissionSetAssignmentList.add(new PermissionSetAssignment(
                PermissionSetid = pset.Id,
                AssigneeId = userId
            ));
        }
        if(permissionSetAssignmentList.size() > 0) 
            insert permissionSetAssignmentList;
        System.debug('AssignPermissionSetQueueable end 3');
    }
    public class RegisterUserResponseWrapper {
        @AuraEnabled public String message;
        @AuraEnabled public String status;
        @AuraEnabled public String storyId;
    }
}