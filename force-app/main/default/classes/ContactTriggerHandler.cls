/*
*Classname: ContactTriggerHandler
*Purpose: 	To Handle ContactTrigger
*Date:		30th April , 2020
*Author: 	Sanjay Prajapat
*/
public class ContactTriggerHandler {
    /*
	*MethodName:ContactTriggerHandler
	*Purpose:  To Allocate Memory and set Default Values
	*Parameter:	Void
	*Return: 	Void
	*/    
    public ContactTriggerHandler(){
        System.debug('Contructor of ContactTriggerHandler Called');
    }
    /*
	*MethodName:beforeInsert
	*Purpose:  To Manage Sequence Number Before Inserting Contact
	*Parameter:	List of New Contact from Trigger
	*Return: 	Void
	*/
    /*Logic: First we Pass List of New Contact from Trigger then we filter contact which have account id so we will pass into set
	*Because it will not Insert Duplicate Values Using of Filter Not Null Value we can add Sequence Number only on those 
	*Account which have contacts other will be empty or Null.After we fire query of Related Contact on Account so we get a list of accounts 
	*with Their Contacts.After we Put it into Map of Id and Size of Contact,so we can update after increment of Sequence Number
	*/     
    public void beforeInsert(list<contact> listOfNewCon){
        if(RecursiveTriggerController.toStopRecursion()){
            //To Store Acc ID and Related Contact Size
            map<id,Integer> mapOfContactsSize=new Map<id,Integer>();
            //To store Acc Id and related Contact's List
            map<id,list<Contact>> mapOfContacts=new Map<id,list<Contact>>();
            //get contacts from Map
            list<contact> listOfConTemp =new list<contact>();      
            //set not allowed duplicates so add account id in it
            set<id> setOfAccId=new set<id>();
            //filter Account Id from Contact
            for(contact c:listOfNewCon){
                if(c.AccountId!=null){
                    setOfAccId.add(c.AccountId);
                } 
            }
            //Fire Query to get Related Contacts of Account
            List<Account> listOfAccWithContacts = [SELECT id, Name,
                                                   (SELECT id, LastName, Accountid, Sequence_Number__c FROM Contacts ORDER BY Sequence_Number__c ASC )
                                                   FROM Account WHERE id IN :(setOfAccId)];        
            system.debug('listOfAccWithContacts='+listOfAccWithContacts);
            //Put Value into Map in which Id is Account Id and Value is Size of Realted Contacts from List
            //we take size because if we take list of contacts then their is difficult to update sequence number because 
            //how can take size without inserting contact of all contacts with new contacts because it will update after insert.
            for(account acc:listOfAccWithContacts){
                system.debug('Account Name='+acc.name);
                system.debug('Contact Size='+acc.contacts.size());
                mapOfContactsSize.put(acc.id,acc.contacts.size());
                mapOfContacts.put(acc.id,acc.contacts);
            }
            system.debug('Contacts:'+mapOfContacts);
            //for bulk update when existing seqeunce number Insert so we need to update executed newconlist,
            //so we store all contacts and when this situation come we increment executed contacts
            list<contact> listOfTempNewCon=new list<contact>();
            //to Add Sequence Number to Contacts                     
            for(contact newCon:listOfNewCon){
                if(newCon.Sequence_Number__c<=0){
                    newCon.Sequence_Number__c.addError('Invalid Sequence Number!Please Insert Greater Then 0');
                }
                else if(mapOfContactsSize.containsKey(newCon.AccountId)){                
                    Integer sizeOfContacts=(mapOfContactsSize.get(newCon.AccountId));
                    //Insert Contact with Sequence Number That Already Exists                                   
                    if(newCon.Sequence_Number__c<=sizeOfContacts ){                  
                        Decimal sqNumber=newCon.Sequence_Number__c;                                       
                        listOfConTemp=mapOfContacts.get(newCon.AccountId);                  
                        Integer index;
                        //update existing records
                        /*for(index=(Integer)sqNumber-1; index <listOfConTemp.size(); index++){                        
                            contact cc=listOfConTemp[index];
                            cc.Sequence_Number__c=(++sqNumber);  
                            //***for bulk insert should put incremnt size of CONTACT in map
                        }*/
                        for(contact cc:listOfConTemp){
                            if(cc.Sequence_Number__c>=newCon.Sequence_Number__c){
                                cc.Sequence_Number__c++;
                            }
                        }
                        //update executed new contacts 
                        for(contact c:listOfTempNewCon){
                            c.Sequence_Number__c=c.Sequence_Number__c+1;
                        }
						//update size of contacts for new sequence number                       
                        mapOfContactsSize.remove(newCon.AccountId);
                        mapOfContactsSize.put(newCon.AccountId,sizeOfContacts+1); 
                    }
                    else{                                       
                        //New Sequence Inserting
                        sizeOfContacts=(mapOfContactsSize.get(newCon.AccountId));                             
                        //prepix Opeteror for remove Seq Number 0 for first
                        system.debug('size of '+sizeOfContacts);  
                        newCon.Sequence_Number__c=(++sizeOfContacts);
                        mapOfContactsSize.remove(newCon.AccountId);
                        mapOfContactsSize.put(newCon.AccountId,sizeOfContacts);
                        //store new sequence number contacts
                        listOfTempNewCon.add(newCon);
                    } 
                }                   
            }
            //update Contact With Swapped SN
            if(listOfConTemp.size()>0){
                 Update listOfConTemp;
            }           
        }
    }//End Block of BeforeInsert()
    
    /*
	*MethodName:beforeUpdate
	*Purpose:  To Manage Sequence Number Before Updating Contact
	*Parameter:	List of Old Version of Contact, List of New Version of Contact,Map of Contact id and Old Version of Contact from Trigger
	*Return: 	Void
	*/  
    public void beforeUpdate(list<contact> listOfNewCon,list<contact> listOfOldCon,Map<id,Contact> oldMapOfContacts ){
        //to stop recursion of update trigger
        //system.debug('Recursion='+RecursiveTriggerController.toStopRecursion());          	
        if(RecursiveTriggerController.toStopRecursion()){            
            map<id,Integer> mapOfContactsSize=new Map<id,Integer>();           
            set<id> setOfOldAccount=new set<Id>();
            set<id> setOfNewAccount=new set<Id>();
            set<id> setOfAccId=new set<id>();           
            boolean isReParent=false;
            
            //Fire Query to get Related Contacts of Account
            List<Account> listOfAccWithContacts = [SELECT id, Name,
                                                   (SELECT id,Firstname, LastName, Accountid, Sequence_Number__c FROM Contacts ORDER BY Sequence_Number__c ASC )
                                                   FROM Account]; 
            for(account acc:listOfAccWithContacts){
                mapOfContactsSize.put(acc.id,acc.contacts.size());                
            }
            system.debug('Map with Id and Contact Size');
            system.debug(mapOfContactsSize);
            //filter account ids of contacts in which updates are make
            for(Contact oldCon:listOfOldCon){
                for(contact newCon:listOfNewCon){
                    system.debug('NewCon=='+newCon.Sequence_Number__c);
                    //if New SN if 0 or Negative
                    if(newCon.Sequence_Number__c<=0){
                        newCon.Sequence_Number__c=oldCon.Sequence_Number__c;
                        newCon.Sequence_Number__c.addError('Invalid Number!Sequence Number Can Not be Nagative or Zero');
                    }																														//c=1 now c=0 or -1
                    if(oldCon.id==newCon.id && oldCon.AccountId==newCon.AccountId && oldCon.Sequence_Number__c !=NewCon.Sequence_Number__c && NewCon.Sequence_Number__c>0   ){ //
                        setOfAccId.add(oldCon.AccountId);
                    }
                    //if New SN is Null
                    if(newCon.Sequence_Number__c==null && Newcon.id==OldCon.Id){
                        newCon.Sequence_Number__c=oldCon.Sequence_Number__c;
                    }
                    //If New SN is More Then Size of Contacts
                    if(newCon.Sequence_Number__c > mapOfContactsSize.get(newCon.AccountId) && Newcon.id==OldCon.Id){
                        newCon.Sequence_Number__c = oldCon.Sequence_Number__c;                        
                    }    
                    //in case of Re-Parenting
                    if(oldCon.id == newCon.id && oldCon.Accountid != newCon.Accountid){
                        /*Integer Size=mapOfContactsSize.get(newCon.Accountid);
                        newCon.Sequence_Number__c=Size+1;
                        mapOfContactsSize.remove(newCon.Accountid); 
                        mapOfContactsSize.put(newCon.Accountid,Size);*/                       
                        setOfOldAccount.add(oldCon.Accountid);
                        setOfNewAccount.add(newCon.Accountid);
                        isReParent = true;
                    }
                }
            }            
            System.debug('Updatabel Account');
            System.debug(setOfAccId);
            
            if(setOfAccId.size()>0){
              	Map<Id,list<Contact>> mapOfContacts=new Map<ID,list<Contact>>();
                list<contact> listOfConToUpdate=new list<Contact>(); //editing           
                list<Account> listOfUpdatableAccount=new list<Account>();             
                //export only those accounts and related contacts which are update action
                for(id idOfAcc:setOfAccId){
                    for(account aa:listOfAccWithContacts){
                        if(aa.id==idOfAcc){
                            listOfUpdatableAccount.add(aa);
                        }
                    }
                }
                system.debug('size of listOfUpdatableAccount list='+listOfUpdatableAccount.size());
                //Fetch only those account and contacts which have update action
                /*listOfUpdatableAccount=[SELECT Id, Name, (SELECT id,Name, LastName, AccountId, Sequence_Number__c FROM Contacts ORDER BY Sequence_Number__C ASC)
				FROM Account WHERE Id IN:(setOfAccId)];*/
				system.debug('size of real account list='+listOfUpdatableAccount.size());            
                //Accoutn id and Related Contacts put in to a map                
                for(Account acc:listOfUpdatableAccount){
                    list<Contact> listOfContacts=new list<Contact>();
                    listOfContacts.clear();
                    for(contact con:acc.Contacts){
                        listOfContacts.add(con);
                    }
                    mapOfContacts.put(acc.id,listOfContacts);
                }
                system.debug('Map Of Contacts with Account Id Which Will be Update');
                system.debug(mapOfContacts.keySet()+' and Values size '+mapOfContacts.values());                
                //Iterate new list of contacts
                for(contact newCon:listOfNewCon){
                    //if any contact have error in seq number then it will not added in setofaccid and mapofcontacts will not have
                    //list of that account's contacts,but newlist have that account id so it will fire error because of null value
                    //so we can handle that error using below                     
                    if(mapOfContacts.get(newCon.AccountId)!=null){
                        //to update old all contacts between new and old sequence number
                        for(contact oldCon:mapOfContacts.get(newCon.AccountId)){
                            //check new Sn is in Increment or Decrement for Decrement this like a=4 now a=2;
                            if((oldMapOfContacts.get(newCon.id).Sequence_Number__c) >= newCOn.Sequence_Number__c){                                
                                if(newCon.id == oldCon.id){
                                    break;
                                }else if(newCon.Sequence_Number__c <= oldCon.Sequence_Number__c){                              
                                    oldCon.Sequence_Number__c =  oldCon.Sequence_Number__c + 1;
                                    //update if list Already has Element in case of bulk update on same account
                                    if(listOfConToUpdate.contains(oldCon)){
                                        listOfConToUpdate.remove(listOfConToUpdate.indexOf(oldCon));
                                        listOfConToUpdate.add(oldCon);
                                    }
                                    else{
                                        listOfConToUpdate.add(oldCon); 
                                    }
                                                                      
                                }
                            }
                            //For Increment This like a=2 and now a=5
                            else{                                  
                                if(oldCon.Sequence_Number__c > newCon.Sequence_Number__c){                            
                                    break;
                                }else if((oldCon.Sequence_Number__c > oldMapOfContacts.get(newCon.Id).Sequence_Number__c) && (oldCon.Sequence_Number__c <= newCon.Sequence_Number__c)){
                                    oldCon.Sequence_Number__c =  oldCon.Sequence_Number__c - 1;
                                    //update if list Already has Element in case of bulk update on same account
                                    if(listOfConToUpdate.contains(oldCon)){
                                        listOfConToUpdate.remove(listOfConToUpdate.indexOf(oldCon));
                                        listOfConToUpdate.add(oldCon);
                                    }
                                    else{
                                        listOfConToUpdate.add(oldCon); 
                                    }                                                    
                                                                    
                                }       
                            }
                        }
                    }
                }
                //remove self Referance Error By Removing listOfNewCon contacts
                list<contact> removeNewCon=new List<contact>();
                removeNewCon.addAll(listOfConToUpdate);
                if(listOfConToUpdate.size()>0){
                    for(contact c:listOfNewCon){
                        for(contact uc:removeNewCon){
                            if(c.Id ==uc.Id){
                                listOfConToUpdate.remove(listOfConToUpdate.indexOf(uc));                                
                            }                                
                        }                        
                    }
                     update listOfConToUpdate;	//remove newcon list from it for remove error pending task
                }               	                
            }
            //--------------------------------------Re-Parenting Case---------------------------------------------------------------------------
            if(isReParent==true){
                //---------------------------------Added at Last Position in New Account--------------------------------------------------------
                system.debug('Enter in to Re parent');
                List<Account> listOfReParentAccount = new List<Account>();                
                list<account> listOfReArrangeAcc=new List<account>();
                list<contact> listOfUpdateCon=new list<contact>();
                
                listOfReParentAccount = [SELECT id, Name, (SELECT id, LastName, Accountid, Sequence_Number__c FROM Contacts ORDER BY Sequence_Number__c ASC)
                                    	FROM Account WHERE id IN:(setOfNewAccount)];
                
                for(Account acc: listOfReParentAccount){
                    Decimal SeqNo = acc.Contacts.size();
                    for(Contact con: listOfNewCon){                        
                        if(con.AccountId == acc.id){
                            con.Sequence_Number__c = ++SeqNo;                            
                        }
                    }
                }
               //-------------------------------------Re-Arrange Sequence Number to Previous Account After Re-Parent--------------------------------
                listOfReArrangeAcc = [SELECT id, Name, (SELECT id, LastName, Accountid, Sequence_Number__c FROM Contacts WHERE id Not IN :listOfNewCon ORDER BY Sequence_Number__c ASC)
                                         FROM Account WHERE id IN:(setOfOldAccount)];
                for(Account aa:listOfReArrangeAcc){
                    Integer size=1;
                    for(contact cc:aa.contacts){
                        cc.Sequence_Number__c=size++;                               
                        listOfUpdateCon.add(cc);
                        system.debug('con'+cc);                                              
                    }
                }
                update listOfUpdateCon;
            }
        }       
    }//End Block of BeforeUpdate() 
    /*
	*MethodName:afterDelete
	*Purpose:  To Manage Sequence Number After Delete Contact
	*Parameter:	List of Old Version of Contact from Trigger
	*Return: 	Void
	*/  
    public void afterDelete(list<contact> listOfOldCon){
        if(RecursiveTriggerController.toStopRecursion()){            
            Set<id> setOfAccId=new Set<id>();
            list<Account> listOfAccWithContacts=new list<Account>();           
            List<contact> listOfContactAfterDel=new List<Contact>();
            for(Contact con:listOfOldCon){
                setOfAccId.add(con.AccountId);
            }
            if(setOfAccId.size()>0){
            	listOfAccWithContacts=[SELECT id, Name, (SELECT id, LastName, Accountid, Sequence_Number__c FROM Contacts ORDER BY Sequence_Number__c ASC)
                                   		FROM Account WHERE id IN:(setOfAccId)];
            }
            for(Account acc:listOfAccWithContacts){
                Integer size=1;
                for(Contact con:acc.contacts){
                    con.Sequence_Number__c=size++;
                    system.debug(con);
                    listOfContactAfterDel.add(con);
                }
                
            }
            if(listOfContactAfterDel.size()>0){
                Update listOfContactAfterDel;
            }
            
        }
    }//End Block of afterDelete()
    /*
	*MethodName:afterUndelete
	*Purpose:  To Manage Sequence Number After Delete Contact
	*Parameter:	List of New Version of Contact from Trigger
	*Return: 	Void
	*/  
    public void afterUndelete(list<contact> listOfNewCon){
        if(RecursiveTriggerController.toStopRecursion()){ 
            set<id> setOfAccId=new set<Id>();
            List<Account> listOfAccWithContact =new List<Account>();
            Map<Id,Decimal> mapOfConAndSize=new Map<Id,Decimal>();
            Map<Id,Decimal> mapOfConAndSizeInUndelete=new Map<Id,Decimal>();
            for(Contact con:listOfNewCon){
                if(con.AccountId!=null){
                    setOfAccId.add(con.AccountId);
                }
            }
            listOfAccWithContact=[SELECT id, Name, (SELECT id, LastName, Accountid, Sequence_Number__c FROM Contacts ORDER BY Sequence_Number__c ASC)
                                 FROM Account WHERE id IN:(setOfAccId)];
            
            for(account a:listOfAccWithContact){
                for(contact c:a.contacts){
                    system.debug(c.LastName+' '+c.Sequence_Number__c);
                }
            }
            
            for(Account acc:listOfAccWithContact){
                mapOfConAndSize.put(acc.id,acc.contacts.size());
            }
            for(Id Ids:setOfAccId){
                decimal size=0;   
                for(Contact cc:listOfNewCon){                                     
                    if(ids==cc.AccountId){
                        size=size+1;                        
                    }
                }
                mapOfConAndSizeInUndelete.put(Ids,size);
            }
            list<contact> updateList=new list<contact>();
            for(Contact newCon:listOfNewCon){
                if(mapOfConAndSize.containsKey(NewCon.AccountId)){
                    Decimal sizeOfUndelete=mapOfConAndSizeInUndelete.get(newCon.AccountId);
                    Decimal Size=mapOfConAndSize.get(newCon.AccountId)-mapOfConAndSizeInUndelete.get(newCon.AccountId)+1;
                    system.debug('size is '+size);
                    contact newContact=new Contact(id=newCon.Id,AccountId=newCon.AccountId);                
                    newContact.Sequence_Number__c=Size;                   
                    updateList.add(newContact);
                    mapOfConAndSizeInUndelete.remove(newCon.AccountId);
                    mapOfConAndSizeInUndelete.put(newCon.AccountId,sizeOfUndelete-1);
                }
            }
            update updateList;
        }
    }
}//End Block Of Class