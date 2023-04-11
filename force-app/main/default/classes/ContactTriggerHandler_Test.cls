/*
*Classname: ContactTriggerHandler_Test
*Purpose: 	To Test ContactTrigger
*Date:		30th April , 2020
*Author: 	Sanjay Prajapat
*/
@isTest
public class ContactTriggerHandler_Test {
    /*
	*MethodName:createAcc
	*Purpose:  To Create Dummy Account For Testing
	*Parameter:	Void
	*Return: 	Void
	*/    
    Public static void createAcc(){     
        List<Account> listOfAccount=new List<Account>();
        Account Ac1=new Account();
        Ac1.Name='Final Test Account';
        listOfAccount.add(Ac1);
        Account Ac2=new Account(); 
        Ac2.Name='Test Trigger 2';
        listOfAccount.add(Ac2);
        insert  listOfAccount;
        system.debug('Account Inserted'); 
    }
    /*
	*MethodName:createContacts
	*Purpose:  To Create Dummy Contacts of Above Created Account For Testing
	*Parameter:	Void
	*Return: 	Void
	*/    
    Public Static void createContacts(){
        ContactTriggerHandler_Test.createAcc();       
        Account Acc1=[SELECT Id,Name FROM Account Where Name='Final Test Account' ];
        Account Acc2=[SELECT Id,Name FROM Account Where Name='Test Trigger 2' ];              
        List<Contact> listOfCon = new List<Contact>();
        Contact con;
        //Test Bulk Insertion of Contact in Two Account        
        For(Integer i=1;i<=5;i++){
            con=new Contact();
            con.LastName='Test '+ i;
            con.AccountId=Acc1.id;            
            listOfCon.add(con); 
            
            con=new Contact();
            con.LastName='Test '+ i;
            con.AccountId=Acc2.id;			    
            listOfCon.add(con); 
        }
        Insert  listOfCon;        
    }
    /*
	*MethodName:testBulkInsert
	*Purpose:  To Test Bulk Insertion
	*Parameter:	Void
	*Return: 	Void
	*/    
    @isTest
    private static void testBulkInsert(){
        Test.startTest();
        ContactTriggerHandler_Test.createContacts();        
        Account Acc1=[SELECT Id,Name FROM Account Where Name='Final Test Account' ];
        Account Acc2=[SELECT Id,Name FROM Account Where Name='Test Trigger 2' ];        
        list<Contact> ListAfterInsertion=[Select id,LastName,Sequence_Number__c,AccountId From Contact
                                          Where AccountId=:Acc1.id Order by Sequence_Number__c];
        integer count=1;
        for(Contact cc:ListAfterInsertion){            
            System.assertEquals(count, cc.Sequence_Number__c,'Sequence Number is Right');
            count++;
        }
        Test.stopTest();
    }
    /*
	*MethodName:testAlreadySeqNo
	*Purpose:  To Test New Contact having Existing Sequence Number
	*Parameter:	Void
	*Return: 	Void
	*/    
    @isTest
    Private Static void testAlreadySeqNo(){
        Test.startTest();
        //Test if Seqeunce Number is already Exist        	
        ContactTriggerHandler_Test.createAcc();
        Account Acc1=[SELECT Id,Name FROM Account Where Name='Final Test Account' ];
        List<Contact> listOfTestCon=new List<Contact>();        	
        contact conExist=new contact();
        conExist.LastName='Test Exist 1';
        conExist.AccountId=Acc1.Id;
        conExist.Sequence_Number__c=1;
        Insert conExist;
        
        RecursiveTriggerController.run=true;	
        contact conExist1=new contact();
        conExist1.LastName='Test Exist 2';
        conExist1.AccountId=Acc1.Id;
        conExist1.Sequence_Number__c=2;
        listOfTestCon.add(conExist1);
        
        contact conExist2=new contact();
        conExist2.LastName='Test Exist 3 ';
        conExist2.AccountId=Acc1.Id;
        conExist2.Sequence_Number__c=1;
        listOfTestCon.add(conExist2);
        insert listOfTestCon;
        listOfTestCon.clear();
        
        listOfTestCon=[Select id,LastName,Sequence_Number__c,AccountId From Contact
                       Where AccountId=:Acc1.id Order by Sequence_Number__c];
        for(Contact cc:listOfTestCon){
            if(cc.LastName=='Test Exist 1'){
                system.assertEquals(2, cc.Sequence_Number__c,'Test 1 Passed');
            }
            if(cc.LastName=='Test Exist 2'){
                system.assertEquals(3, cc.Sequence_Number__c,'Test 1 Passed');
            }
            if(cc.LastName=='Test Exist 3'){
                system.assertEquals(1, cc.Sequence_Number__c,'Test 1 Passed');
            }            	
        }
        Test.stopTest();
    }
    /*
	*MethodName:testErrorInInsert
	*Purpose:  To Test Error in Inserting When SN is 0 or Negative
	*Parameter:	Void
	*Return: 	Void
	*/    
    @isTest
    Private Static void testErrorInInsert(){
        Test.startTest();
        //Test If SN is 0 or Negative
        ContactTriggerHandler_Test.createAcc();
        Account Acc1=[SELECT Id,Name FROM Account Where Name='Final Test Account' ];
        RecursiveTriggerController.run=true;        
        contact ConError=new contact();
        ConError.LastName='Test';
        ConError.AccountId=acc1.Id;
        ConError.Sequence_Number__c=0;
        try{
            insert ConError;
        }
        catch(Exception e){
            System.debug('Custom Error Fired');
        }
        Test.stopTest();
        
    }
    /*
	*MethodName:testAfterDelete
	*Purpose:  To Test Sequence Number After Delete Contacts
	*Parameter:	Void
	*Return: 	Void
	*/    
    @isTest
    Private Static void testAfterDelete(){
        Test.startTest();            
        ContactTriggerHandler_Test.createContacts();
        Account Acc=[SELECT Id,Name FROM Account Where Name='Final Test Account' ];
        list<Contact> ListAfterInsertion=[Select id,LastName,Sequence_Number__c,AccountId From Contact
                                          Where AccountId=:Acc.id Order by Sequence_Number__c];
        list<contact> listOfDeleteCon=new list<Contact>();
        for(contact con:ListAfterInsertion){
            if(con.LastName=='Test 1' || con.lastName=='Test 5'){
                listOfDeleteCon.add(con); 
            }
        }
        RecursiveTriggerController.run=true;
        Delete listOfDeleteCon;
        system.debug(ListAfterInsertion.size());
        Test.stopTest();
    }
    /*
	*MethodName:testAfterUndelete
	*Purpose:  To Test After Undelete Contacts From RecycleBin
	*Parameter:	Void
	*Return: 	Void
	*/    
    @isTest
    Private Static void testAfterUndelete(){
        Test.startTest();
        ContactTriggerHandler_Test.createContacts();
        Account Acc1=[SELECT Id,Name FROM Account Where Name='Final Test Account' ];
        Account Acc2=[SELECT Id,Name FROM Account Where Name='Test Trigger 2' ];
        list<Contact> ListAfterInsertion=[Select id,LastName,Sequence_Number__c,AccountId From Contact
                                          Where AccountId=:Acc1.id OR AccountId=:Acc2.id Order by Sequence_Number__c];
        list<contact> listOfDeleteCon=new list<Contact>();
        for(contact con:ListAfterInsertion){
            if((con.LastName=='Test 2' || con.lastName=='Test 5') && con.AccountId==Acc1.id){
                listOfDeleteCon.add(con); 
            }
            if((con.LastName=='Test 2' || con.lastName=='Test 4') && con.AccountId==Acc2.id){
                listOfDeleteCon.add(con); 
            }
        }
        RecursiveTriggerController.run=true;
        Delete listOfDeleteCon;
        //Undelete Contacts
        RecursiveTriggerController.run=true;
        UnDelete listOfDeleteCon;        
        
        list<Contact> ListAfterUndelete=[Select id,LastName,Sequence_Number__c,AccountId From Contact
                                         Where AccountId=:Acc1.id OR AccountId=:Acc2.id Order by Sequence_Number__c];
        for(contact con:ListAfterUndelete){
            if(con.LastName=='Test 2' && con.AccountId==Acc1.id){                    
                System.assertEquals(4, con.Sequence_Number__c,'Test 1 in Undelete Passed');
            }
            if(con.LastName=='Test 5' && con.AccountId==Acc1.id){                     
                System.assertEquals(5, con.Sequence_Number__c,'Test 2 in Undelete Passed');
            }
            if(con.LastName=='Test 2' && con.AccountId==Acc2.id){                    
                System.assertEquals(4, con.Sequence_Number__c,'Test 3 in Undelete Passed'); 
            }
            if(con.LastName=='Test 4' && con.AccountId==Acc2.id){
                System.assertEquals(5, con.Sequence_Number__c,'Test 4 in Undelete Passed');
            }
        }
        Test.stopTest();
    }
    /*
	*MethodName:testBulkUpdate
	*Purpose:  To Test Bulk Update 
	*Parameter:	Void
	*Return: 	Void
	*/    
    @isTest
    Private Static void testBulkUpdate(){        
        ContactTriggerHandler_Test.createContacts();
        Account Acc1=[SELECT Id,Name FROM Account Where Name='Final Test Account' ];
        Account Acc2=[SELECT Id,Name FROM Account Where Name='Test Trigger 2' ];
        list<Contact> ListAfterInsertion=[Select id,LastName,Sequence_Number__c,AccountId From Contact
                                          Where AccountId=:Acc1.id OR AccountId=:Acc2.id Order by Sequence_Number__c];
        List<Contact> listofConToUpdate=new List<Contact>();
        for(Contact con:ListAfterInsertion){
            if(con.LastName=='Test 2' && con.AccountId==Acc1.id){                    
                con.Sequence_Number__c=5;
                listofConToUpdate.add(con);
            }
            if(con.LastName=='Test 5' && con.AccountId==Acc1.id){                     
                con.Sequence_Number__c=1;
                listofConToUpdate.add(con);
            }
            if(con.LastName=='Test 2' && con.AccountId==Acc2.id){                    
                con.Sequence_Number__c=3;
                listofConToUpdate.add(con);
            }
            if(con.LastName=='Test 4' && con.AccountId==Acc2.id){
                con.Sequence_Number__c=1;
                listofConToUpdate.add(con);
            }
        }
        RecursiveTriggerController.run=true;
        try{
            Update listofConToUpdate;
        }
        catch(Exception e){
            System.debug('Error in update='+e);
        }
        
    }
    /*
	*MethodName:TestReparenting
	*Purpose:  To Test After Re-Parenting Account of Contact
	*Parameter:	Void
	*Return: 	Void
	*/    
    @isTest
    Private Static void TestReparenting(){
        ContactTriggerHandler_Test.createContacts();
        Account Acc1=[SELECT Id,Name FROM Account Where Name='Final Test Account' ];
        Account Acc2=[SELECT Id,Name FROM Account Where Name='Test Trigger 2' ];
        list<Contact> ListAfterInsertion=[Select id,LastName,Sequence_Number__c,AccountId From Contact
                                          Where AccountId=:Acc1.id OR AccountId=:Acc2.id Order by Sequence_Number__c];
        
        Account ParentAccount=new Account();
        ParentAccount.name='sForce';
        Insert ParentAccount;
        
        Account ParentAcc1=[SELECT Id,Name FROM Account Where Name='sForce' ];
        list<Contact> listOfCon =new List<Contact>();
        Contact conOfParent;
        for(Integer i=1;i<=5;i++){
            conOfParent=new Contact();
            conOfParent.lastName='sForce '+i;
            conOfParent.AccountId=ParentAcc1.Id;
            listOfCon.add(conOfParent);
        }
        Insert listOfCon;
        
        List<Contact> listofConToUpdate=new List<Contact>();
        for(Contact con:ListAfterInsertion){
            if(con.LastName=='Test 2' && con.AccountId==Acc1.id){ 
                con.LastName='Test 2 of Account 1';               
                con.AccountId=ParentAcc1.Id;
                listofConToUpdate.add(con);
            }
            if(con.LastName=='Test 5' && con.AccountId==Acc1.id){
                con.LastName='Test 5 of Account 1';                
                con.AccountId=ParentAcc1.Id;
                listofConToUpdate.add(con);
            }
            if(con.LastName=='Test 2' && con.AccountId==Acc2.id){
                con.LastName='Test 2 of Account 2';                
                con.AccountId=ParentAcc1.Id;
                listofConToUpdate.add(con);
            }
            if(con.LastName=='Test 4' && con.AccountId==Acc2.id){
                con.LastName='Test 4 of Account 2';                
                con.AccountId=ParentAcc1.Id;
                listofConToUpdate.add(con);
            }
        }
        RecursiveTriggerController.run=true;
        try{
            Update listofConToUpdate;
        }
        catch(Exception e){
            System.debug('Error in update='+e);
        }
        
        list<Contact> ListAfterUndelete=[Select id,LastName,Sequence_Number__c,AccountId From Contact
                                         Where AccountId=:ParentAcc1.id Order by Sequence_Number__c ASC];
         system.debug('Re-Seq------------------------');
        for(contact con:ListAfterUndelete){
            if(con.LastName=='Test 2 of Account 1'){
                system.debug(con.Sequence_Number__c);
                System.assertEquals(6, con.Sequence_Number__c,'Test 1 in Re-Parenting Passed');
            }
            if(con.LastName=='Test 5 of Account 1'){
                system.debug(con.Sequence_Number__c);
                System.assertEquals(9, con.Sequence_Number__c,'Test 2 in Re-Parenting Passed');
            }
            if(con.LastName=='Test 2 of Account 2'){
                system.debug(con.Sequence_Number__c);
                System.assertEquals(7, con.Sequence_Number__c,'Test 3 in Re-Parenting Passed'); 
            }
            if(con.LastName=='Test 4 of Account 1'){
                system.debug(con.Sequence_Number__c);
                System.assertEquals(8, con.Sequence_Number__c,'Test 4 in Re-Parenting Passed');
            }
        }
    }
    /*
	*MethodName:testErrorOrnullInUpdate
	*Purpose:  To Test if Updated Conatct having SN 0 Or Negative or Null
	*Parameter:	Void
	*Return: 	Void
	*/    
    @isTest
    Private Static void testErrorOrnullInUpdate(){
        Test.startTest();
            ContactTriggerHandler_Test.createContacts();
            Account Acc1=[SELECT Id,Name FROM Account Where Name='Final Test Account' ];
            Account Acc2=[SELECT Id,Name FROM Account Where Name='Test Trigger 2' ];
            list<Contact> ListAfterInsertion=[Select id,LastName,Sequence_Number__c,AccountId From Contact
                                              Where AccountId=:Acc1.id OR AccountId=:Acc2.id Order by Sequence_Number__c ASC]; 
            List<Contact> listofConToUpdate=new List<Contact>();
            for(Contact con:ListAfterInsertion){
                if(con.LastName=='Test 2' && con.AccountId==Acc1.id){                    
                    con.Sequence_Number__c=null;
                    listofConToUpdate.add(con);
                }
                if(con.LastName=='Test 5' && con.AccountId==Acc1.id){                     
                    con.Sequence_Number__c=15;
                    listofConToUpdate.add(con);
                }
                if(con.LastName=='Test 2' && con.AccountId==Acc2.id){                    
                    con.Sequence_Number__c=null;
                    listofConToUpdate.add(con);
                }
                if(con.LastName=='Test 4' && con.AccountId==Acc2.id){
                    con.Sequence_Number__c=120;
                    listofConToUpdate.add(con);
                }
            }
            RecursiveTriggerController.run=true;
            Update listofConToUpdate;
            
            list<Contact> ListAfterUpdate=[Select id,LastName,Sequence_Number__c,AccountId From Contact
                                              Where AccountId=:Acc1.id OR AccountId=:Acc2.id Order by Sequence_Number__c];
            for(Contact con:ListAfterUpdate){
                if(con.LastName=='Test 2' && con.AccountId==Acc1.id){                    
                    System.assertEquals(2, con.Sequence_Number__c,'Test 1 for Null Or Error in Update Has Passed');
                }
                if(con.LastName=='Test 5' && con.AccountId==Acc1.id){                     
                    System.assertEquals(5, con.Sequence_Number__c,'Test 2 for Null Or Error in Update Has Passed');
                }
                if(con.LastName=='Test 2' && con.AccountId==Acc2.id){                    
                    System.assertEquals(2, con.Sequence_Number__c,'Test 3 for Null Or Error in Update Has Passed');
                }
                if(con.LastName=='Test 4' && con.AccountId==Acc2.id){
                    System.assertEquals(4, con.Sequence_Number__c,'Test 4 for Null Or Error in Update Has Passed');
                }
            } 
        Test.stopTest();
    }
}