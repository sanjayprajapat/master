/*
*Classname: AllsobjectAndFieldsComponentTest
*Purpose: 	To Test BM_Project1class
*Date:		22th April 2020
*Author: 	Sanjay Prajapat
*/
@isTest
Private class AllsobjectAndFieldsComponentTest {
    /*
	*MethodName:createLeadRecords
	*Purpose:  	To Create Records For Testing.
	*Parameter:	Void
	*Return: 	Void
	*/
    public static void createLeadRecords(){
        Lead Testlead;
        list<lead> list1=new list<lead>();
        Testlead=new Lead();
        Testlead.LastName='Prajapat Test';
        Testlead.status='Closed-Converted';
        Testlead.Company='BM'; 
        Testlead.Email='';
        Testlead.Fax='';
        Lead Testlead2;
        Testlead2=new Lead();
        Testlead2.LastName='Prajapat Test 2';
        Testlead2.status='Closed-Converted';
        Testlead2.Company='BM 2'; 
        Testlead2.Email='';
        Testlead2.Fax='';
        list1.add(Testlead);
        list1.add(Testlead2);
        Database.insert(list1);
    }
    /*
	*MethodName:createAccRecords
	*Purpose:  	To Create Account Records For Testing.
	*Parameter:	Void
	*Return: 	Void
	*/
    public static void createAccRecords(){
        Account acc=new Account();
        acc.name='Test Account 1';
        acc.Phone='9950579807';        
        Account acc2=new Account();
        acc2.name='Test Account 2';
        acc2.Phone='7240550948';
        list<Account> list2=new List<Account>();
        list2.add(acc);
        list2.add(acc2);
        Database.insert(list2);
    } 
    /*
	*MethodName:testGetAllFields
	*Purpose:  	To Test getAllFields().
	*Parameter:	Void
	*Return: 	Void
	*/
    @isTest
    Private static void testGetAllFields(){
        AllsobjectAndFieldsComponentController obj1=new AllsobjectAndFieldsComponentController();
        createLeadRecords();       
        obj1.selectedObjectName='Lead';
        obj1.listOfFields=new list<string>{'Name','Status','Address', 'Company','Email','Fax'}; 
        obj1.oldlistOfFields=obj1.listOfFields.clone();
        //temp=0 and size of list will same but obj name is null and lead so false && true || true
        obj1.getallFields();
        system.debug('wrapper list data='+obj1.WrapperList);       
        obj1.firstPage();
        obj1.lastPage();
        obj1.prevPage();
        obj1.nextPage();
        obj1.getCheckNext();
        obj1.getCheckPrevious();
        obj1.Page_Size=20;
        obj1.changePageSize();        
        //Test MaintainMap()
        for(sobject a:(list<sobject>)obj1.st_controller.getRecords()){
            obj1.WrapperList.add(new Objectdescribewrapper(a,true));
            break;
        }
        obj1.maintainMap();
        obj1.getallFields();        
        for(sobject a:(list<sobject>)obj1.st_controller.getRecords()){
            obj1.WrapperList.add(new Objectdescribewrapper(a,false));
            break;
        }
        obj1.maintainMap();
        //temp is 1 and size also diff so true && true || false
        obj1.temp=1;
        obj1.oldlistOfFields.clear();
        obj1.getallFields();
        //if controller is null 
        obj1.selectedObjectName='Book__c';
        obj1.listOfFields.clear();
        obj1.listOfFields=new list<string>{'Name','Price__c','Book_Code__c'};
        obj1.getallFields();
        system.debug('wrapper list data='+obj1.WrapperList);
    }
    /*
	*MethodName:testDeleteSelected
	*Purpose:  	To Test Deleteselected()
	*Parameter:	Void
	*Return: 	Void
	*/
   @isTest
    private static void testDeleteSelected(){
        AllsobjectAndFieldsComponentController obj2=new AllsobjectAndFieldsComponentController();
        createLeadRecords(); 
        obj2.Page_Size=1;
        obj2.selectedObjectName='Lead';
        obj2.listOfFields=new list<string>{'Name','Status','Address', 'Company','Email','Fax'}; 
        obj2.oldlistOfFields=obj2.listOfFields.clone();
        //temp=0 and size of list will same but obj name is null and lead so false && true || true
        obj2.getallFields();
        //create temp list of records to checked true
        list<sobject> templistofsobject=new list<sobject>();
        templistofsobject.addAll((list<sobject>)obj2.st_controller.getRecords());      
        obj2.WrapperList.add(new Objectdescribewrapper(templistofsobject[0],true));
        //call nextpage()
        obj2.nextPage();
        //check checkkox
       	obj2.WrapperList.add(new Objectdescribewrapper(templistofsobject[1],true));
        //call last page
        obj2.lastPage();        
        obj2.deleteSelected();
        system.assertEquals(2, obj2.mapOfSelectedRecord.size(),'Test of selected records is Passes');
        //test is size of delete element is 0        
        obj2.mapOfSelectedRecord.clear();
        obj2.getallFields();
        obj2.deleteSelected();         
       
    }
    /*
	*MethodName:testEnterPageNo
	*Purpose:  	To Test EnterPageNod()
	*Parameter:	Void
	*Return: 	Void
	*/
    @isTest
    public static void testEnterPageNo(){
        AllsobjectAndFieldsComponentController obj3=new AllsobjectAndFieldsComponentController();
        createLeadRecords();
        //Apexpages.StandardSetController 		st_controller ;
        obj3.selectedObjectName='Lead';
        obj3.listOfFields=new list<string>{'Name','Status','Address', 'Company','Email','Fax'}; 
        obj3.oldlistOfFields=obj3.listOfFields.clone();
        //temp=0 and size of list will same but obj name is null and lead so false && true || true
        obj3.getallFields();
        obj3.Page_Size=1;
		obj3.temp_PageNo=2;        
        obj3.enterPageNo();
        obj3.page_Number=200;        
        obj3.enterPageNo();
        obj3.Page_Size=5;
        obj3.page_Number=1;        
        obj3.enterPageNo();
    }
    /*
	*MethodName:testDownloadCSV
	*Purpose:  	To Test DownloadCSV().
	*Parameter:	Void
	*Return: 	Void
	*/
    @isTest
    Private static void testDownloadCSV(){
        AllsobjectAndFieldsComponentController obj3=new AllsobjectAndFieldsComponentController();
        createLeadRecords();       
        obj3.selectedObjectName='Lead';
        obj3.listOfFields=new list<string>{'Name','Status','Address', 'Company','Email','Fax'}; 
        obj3.oldlistOfFields=obj3.listOfFields.clone();
        //temp=0 and size of list will same but obj name is null and lead so false && true || true       
        obj3.getallFields();
        //Test MaintainMap()
        for(sobject a:(list<sobject>)obj3.st_controller.getRecords()){
            obj3.WrapperList.add(new Objectdescribewrapper(a,true));
            break;
        }
        obj3.maintainMap();
        obj3.downloadCSV();
        //test error message
       	obj3.mapOfSelectedRecord.clear();
        obj3.getallFields();
      	obj3.downloadCSV();              
    }
    /*
	*MethodName:TestSortbyAlphaAll
	*Purpose:  	To Test SortbyAlphaAll()
	*Parameter:	Void
	*Return: 	Void
	*/    
    @isTest
    private static void TestSortbyAlphaAll(){              
        AllsobjectAndFieldsComponentController obj3=new AllsobjectAndFieldsComponentController();
        //Test Sorting Through Alphabets
        test.startTest();
        	createAccRecords();        	
        	obj3.selectedObjectName='Account';
        	obj3.listOfFields=new list<string>{'Name','Description','Phone'};        
       	 	obj3.listofUnSortablefields.add('Description');        	
        	obj3.getallFields();
        	//set page and its Parameter
        	PageReference pageRef = Page.Pagination_AllsobjectAndFieldsPage;
        	Test.setCurrentPage(pageRef);  
        	pageRef.getParameters().put('alphabates','All'); 
        	obj3.sortRecords();
        	pageRef.getParameters().put('alphabates','Other'); 
        	obj3.sortRecords(); 
        	pageRef.getParameters().put('alphabates','s'); 
        	obj3.sortRecords();
        	//Test if first fields is not Sortable
        	obj3.listOfFields.clear();
        	obj3.listOfFields.add('Description');
        	obj3.listOfFields.add('Name');
        	obj3.listOfFields.add('Phone');
        	obj3.sortRecords();       
        test.stopTest(); 
    }
    /*
	*MethodName:testSortColumn
	*Purpose:  	To test SortColumn().
	*Parameter:	Void
	*Return: 	Void
	*/
    @isTest
    private static void testSortColumn(){
        AllsobjectAndFieldsComponentController obj4=new AllsobjectAndFieldsComponentController();
        test.startTest();
        	createAccRecords();        	
        	obj4.selectedObjectName='Account';
        	obj4.listOfFields=new list<string>{'Description','Name','Phone'};        
       	 	obj4.listofUnSortablefields.add('Description');
        	obj4.getallFields();
        	PageReference pageRef = Page.Pagination_AllsobjectAndFieldsPage;
        	Test.setCurrentPage(pageRef);  
        	pageRef.getParameters().put('columnname','Description'); 
        	obj4.sortColumn();        
        	//Test if first fields is not Sortable
        	obj4.listOfFields.clear();
        	obj4.listOfFields.add('Name');
        	obj4.listOfFields.add('Description');
        	obj4.listOfFields.add('Phone');
        	pageRef.getParameters().put('columnname','Name'); 
        	obj4.sortOrder='ASC';
        	obj4.sortColumn();
        	obj4.sortOrder='DESC';
        	obj4.sortColumn(); 
          test.stopTest(); 
    }
    /*
	*MethodName:testEditLink
	*Purpose:  	To Test EditLink.
	*Parameter:	Void
	*Return: 	Void
	*/
    @isTest
    Private static void testEditLink(){
        AllsobjectAndFieldsComponentController obj5=new AllsobjectAndFieldsComponentController();
        test.startTest();
        	createAccRecords();        	
        	obj5.selectedObjectName='Account';
        	obj5.listOfFields=new list<string>{'Name','Description','Phone'};        
       	 	obj5.listofUnSortablefields.add('Description');
        	obj5.getallFields();
        	Id Id=obj5.wrapperList[0].obj.id;
        	PageReference pageRef = Page.Pagination_AllsobjectAndFieldsPage;
        	Test.setCurrentPage(pageRef);  
        	pageRef.getParameters().put('EditId',Id);
        	obj5.editLink();        
        	obj5.saveAfterEditandDel();
        	pageRef.getParameters().put('DeleteId',Id);
        	obj5.deleteLink();
        test.stopTest();
    }
}