/*
*Classname: AllsobjectAndFieldsComponentController
*Purpose: 	get selected sobject and list of fields to add The pagination of custom component
*Date:		6th April 2020
*Author: 	Sanjay Prajapat
*/
public class AllsobjectAndFieldsComponentController {
    //get Selected Object
    public string selectedObjectName {set;get;}
    //get List of Fields Of selected Object
    public list<string> listOfFields {set;get;}
	//To Create Dynamic Query    
    //public string query	{set;get;}
    //Get Page Size(No of Records to Show on Page)
    Public Integer page_Size {set;get;}	
    //Get Page Number
    public Integer page_Number {set;get;}	
    //Get Total Page Number ,it will take Value of Total Records In Query
    public Integer total_Pages {set;get;}	
    //Create Reference of StandardSetController
    public Apexpages.StandardSetController st_Controller {set;get;}
    //To Store Records with Checkbox
    public list<Objectdescribewrapper> wrapperList {set;get;}
    //to Maintain state Checkboxes
    public Map<id,Objectdescribewrapper> mapOfSelectedRecord {set;get;}
    //Hold Old Object Value
    public string oldobj {set;get;}
    //Hold Old List of Fields
    public list<string> oldListOfFields {set;get;}
    //
    public integer temp {set;get;}
    //list of Alphabets for Sorting
    public list<string> alpha {set;get;}
    //Get Parameter from Vf Page
    public string parameterFromAlpha {set;get;}  
    //---------------------------------------------------Download CSV--------------------------------------------------------------------------
    //Create Rows for CSV File
    public string  csvString {set;get;}
    //Add Column Name in String For CSV
    public string listFields {set;get;}    
    //------------------------------------------------Edit Link and Edit Panel----------------------------------------------------------------------------*/
    //Create Temporary List Of Records
    public list<sobject> listofObjectsTemp	{set;get;}    
    //-----------------------------------------------------Sort Column Wise---------------------------------------------------------------------------------------//
    //To Sort Assending and Descending Sorting After Click on Column Name
    public String  sortOrder {get;set;}
    //For Comparing on vf Page for Up and Down Arrow According to Sorting Order
    //public String sortFieldName {get;set;}
    //list of unsoratble fields
   	public list<string>	listofUnSortablefields {set;get;}
    //for counting true checkboxes
    public integer countflag {set;get;}
    //true and false master checkbox
    public boolean masterCBox {set;get;}
	//list of Fields label    
    public list<string> listLabel {set;get;}
    
    public boolean jsVarEnable{set;get;}
    /*------------------------------------------------------------------------------------------------------------------------------//
    /*
	*MethodName:BM_Project1_controllerclass
	*Purpose:  To Allocate Memory and set Default Values
	*Parameter:	Void
	*Return: 	Void
	*/
    public AllsobjectAndFieldsComponentController(){        
       	Pagination_AllsobjectsAndFields.errormsg=false;
        wrapperList=new list<Objectdescribewrapper>(); 
        mapOfSelectedRecord=new Map<id,Objectdescribewrapper>();
        listofUnSortablefields=new list<String>();
        listofObjectsTemp=new list<sobject>();
        listLabel=new list<String>(); 
        jsVarEnable=Pagination_AllsobjectsAndFields.jsVar;
        page_Size=5; 
        temp=0;        
        alpha= new List<string>{'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z','Other', 'All'};
        //system.debug('contructor called');
    }
    /*
	*MethodName:getallFields
	*Purpose:  To Get Objectname and Fields Of Selected Object and Create Instance of Wrapper CLass and Add to wrapperList.
				This Method is a Property so it will Invoke automatically after click on process button
	*Parameter:	Void
	*Return: 	List of Wrapperclass (Type:Objectdescribewrapper)
	*/
    public list<Objectdescribewrapper> getallFields(){             
        System.debug('getallFields');
        system.debug('old fields=='+oldListOfFields);
        system.debug('new fields=='+listOfFields);
        system.debug('Label of Fields=='+listLabel);        
        //check list of fields or selected object is Same or New
        if(temp != 0 && oldListOfFields.size() != listOfFields.size() || oldobj != selectedObjectName){  
            st_Controller=null;
            System.debug('step 1'+temp);
        }
        if(st_Controller==null){
            page_size=5;
            system.debug('All Fields=='+listOfFields);
            //id StandardsetController is Null Create query and Get All Records From Controller
            createQuery();
        }
        temp++;
        countflag=0;
        system.debug('temp=='+temp);
      	//list<Objectdescribewrapper>   wrapperList=new list<Objectdescribewrapper>(); 
     	wrapperList.clear();
        system.debug('st_Controller Data in GetAll()='+st_Controller.getRecords()); 
        if(st_Controller.getResultSize()!=0){           
            for(sobject a:(list<sobject>)st_Controller.getRecords()){
                //Maintain Checkboxes
                if(mapOfSelectedRecord!=null && mapOfSelectedRecord.containsKey(a.id)){                   
                    wrapperList.add(mapOfSelectedRecord.get(a.id)); 
                    countflag++;
                }
                else{
                   	wrapperList.add(new Objectdescribewrapper(a,false));
                }
            }           
        }
        //select and deselect master checkbox
        if(countflag == page_Size){
            masterCBox = true;
        }
        else{
            masterCBox = false;
        }        
        system.debug('wrapperList in Controller== '+wrapperList);
        return wrapperList;
    }
    /*
	*MethodName:createQuery
	*Purpose:  To Create Dynamic Query and Get Records Through StandardSetController
	*Parameter:	Void
	*Return: 	Void
	*/
    public void createQuery(){ 
        st_Controller=null;
        system.debug('Query Created');
        oldListOfFields= new List<String>();        
        oldListOfFields=listOfFields.clone();
        oldobj=selectedObjectName;        
        string query='';
        query='select ';
        for(string s:listOfFields){
            query=query+s+',';
        }
        query=query.removeEnd(',');
        query=query+' from '+selectedObjectName;
        system.debug('query='+query);
        if(st_Controller==null){
            system.debug('Controller in createQuery()');
            //Set Default Page Number
            page_Number=1;
            //Create Instance of StandardSetController and Pass Query
            st_Controller=new Apexpages.StandardSetController(database.getQueryLocator(query));
            //Set Page Size from vf page
            st_Controller.setPageSize(page_Size);              
            total_Pages=st_Controller.getResultSize();
            //system.debug('Page size in Controller '+page_Size); 
           system.debug('st_Controller Data='+st_Controller.getRecords());
        }
    }
    /*
	*MethodName:firstPage
	*Purpose:  	To Redirect on Page first Page on Visualforce Page.
	*Parameter:	Void
	*Return: 	Void
	*/
    public void firstPage(){ 
        //Maintain State of Checkoxes
        maintainMap();
        //Redirect on First Page (inbuild Method)
        st_Controller.first();
        //Iterate wrapperList 
        getallFields();
        //Get Page Number
        page_Number = st_Controller.getPageNumber();
    }
    /*
	*MethodName:prevPage
	*Purpose:  	To Redirect on Page Previous on Visualforce Page.
	*Parameter:	Void
	*Return: 	Void
	*/
    public void prevPage(){ 
        maintainMap();        
        st_Controller.previous();      
        getallFields();   									
        page_Number = st_Controller.getPageNumber();
    }
    /*
	*MethodName:nextPage
	*Purpose:  	To Redirect on Page Next on Visualforce Page.
	*Parameter:	Void
	*Return: 	Void
	*/
    public void nextPage(){
        maintainMap();
        st_Controller.next();       
        getallFields();     									
        page_Number = st_Controller.getPageNumber();
    }    
    /*
	*MethodName:lastPage
	*Purpose:  	To Redirect on Page last on Visualforce Page.
	*Parameter:	Void
	*Return: 	Void
	*/
    public void lastPage(){
        maintainMap();
        st_Controller.last();
        getallFields(); 									
        page_Number = st_Controller.getPageNumber();
    } 
     /*
	*MethodName:CheckPrevious
	*Purpose:  	To Disable Previous Button on Visualforce Page.
	*Parameter:	Void
	*Return: 	Boolean
	*/
    public boolean getCheckPrevious(){       
        return st_Controller.getHasPrevious();
    }
     /*
	*MethodName:CheckNext
	*Purpose:  	To Disable Next Button on Visualforce Page.
	*Parameter:	Void
	*Return: 	Boolean
	*/
    public boolean getCheckNext(){
        return st_Controller.getHasNext();
    }
    /*
	*MethodName:maintainMap
	*Purpose: 	Maintain State of Checkbox While Changing Page Number.
	*Parameter:	Void
	*Return: 	Void
	*/
    public void maintainMap() { 
        for(Objectdescribewrapper  wrp : wrapperList){									
            if(wrp.flag){                
                mapOfSelectedRecord.put(wrp.obj.id, wrp);
            }
            if(wrp.flag == false && mapOfSelectedRecord.containsKey(wrp.obj.id)){
                mapOfSelectedRecord.remove(wrp.obj.id);
            }
        }
    }
    /*
	*MethodName:changePageSize
	*Purpose: 	To Chnage Page Size(No of Records to Show) From Picklist on Visualforce Page.
	*Parameter:	Void
	*Return: 	Void
	*/
    public void changePageSize(){
        maintainMap();
        st_Controller.setPageSize(page_Size); 										
        total_Pages=st_Controller.getResultSize();        
        page_Number = st_Controller.getPageNumber();
        getallFields(); 
    }
     /*
	*MethodName:deleteSelected
	*Purpose: 	To Delete Selected Records
	*Parameter:	Void
	*Return: 	Void
	*/
   public string msg {set;get;}
    public PageReference deleteSelected(){
        list<sobject> listForDelete=new list<sobject>(); 
        maintainMap();        
        if(!mapOfSelectedRecord.isEmpty() ){
            //get keys of map which have obj id of selected records
            for(id keys:mapOfSelectedRecord.keyset()){
                //add object to delete
                listForDelete.add(mapOfSelectedRecord.get(keys).obj);   
                //remove deletable object from wrapperList         
            }
            system.debug('deletable items='+mapOfSelectedRecord);           
            try{
                // if(listForDelete.size()>0){
                database.delete(listForDelete);
                createQuery();
                getallFields();                    
               	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'All Selected Deleted!!');
            	ApexPages.addMessage(myMsg);                  
                // }
            }
            catch(Exception e){
                system.debug('e');
                //msg=e.getMessage();                                
            }
            mapOfSelectedRecord.clear();                     
        }        
        else{
            msg='Nothing to Delete';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Select At Least One Record to Delete');
            ApexPages.addMessage(myMsg);
        }
        system.debug('items of wrapperList after remove '+wrapperList.size());
        return null;
    }
     /*
	*MethodName:sortRecords
	*Purpose:  	To Sort Records Alphabetically.
	*Parameter:	Void
	*Return: 	Void
	*/
    public void sortRecords(){       
        maintainMap();
        string query='Select ';
        //get parameter from vf page through alphabets list
        string getPara = ApexPages.currentPage().getParameters().get('alphabates');       
        system.debug('Test Parameter=='+getPara);
        //use in next Method for column sorting after alpha sorting
        parameterFromAlpha=getPara;
        //dynamic query
        string s='\''+getPara+'%\'';
        //create dynamic query
        for(string sc:listOfFields){           
            query=query+sc+','; 
        } 
        query=query.removeEnd(',');
        system.debug('list of Unsoratbel Fields'+listofUnSortablefields);
        system.debug('List of first Index Field'+listOfFields.get(0));        
        if(getPara=='All'){
            query=query+' From '+selectedObjectName;//' ORDER BY '+listOfFields.get(0);                   
            st_Controller=new Apexpages.StandardSetController(database.getQueryLocator(query));
            total_Pages=st_Controller.getResultSize();
            st_Controller.setPageSize(page_Size);
            getallFields(); 
        }
        else{
            //unsortable fields handles      
            if(listofUnSortablefields.contains(listOfFields.get(0))){ 
                system.debug('Enter in the house');
                //msg='This Field Type is Not Sortable.Please!!Select Another Field';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'This Field Type is Not Sortable.Please!! Remove This from First Place');
                ApexPages.addMessage(myMsg);
            }
            else{
                if(getPara=='Other'){ 
                    query=query+' From '+selectedObjectName+' ORDER BY '+listOfFields.get(0);                   
                    st_Controller=new Apexpages.StandardSetController(database.getQueryLocator(query));
                    total_Pages=st_Controller.getResultSize();
                    st_Controller.setPageSize(page_Size);
                    getallFields(); 
                }               
                else{
                    query=query+' From '+selectedObjectName+' where ' +  listOfFields.get(0)+ ' like ' +s;                 
                    st_Controller=new Apexpages.StandardSetController(database.getQueryLocator(query));
                    total_Pages=st_Controller.getResultSize();
                    st_Controller.setPageSize(page_Size);
                    getallFields();    
                }                
            }
        }
        system.debug('Query='+query);
    }
     /*
	*MethodName:sortColumn
	*Purpose:  	To Sort Records by Clicking on Header of Column.
	*Parameter:	Void
	*Return: 	Void
	*/
    public void sortColumn(){        
       	string queryForColumn='SELECT ';        
        maintainMap(); 
       	//get columnname as Parameter from column sorting
        String sortFieldName = ApexPages.currentPage().getParameters().get('columnname');        
        string s=' LIKE \''+parameterFromAlpha+'%\' ';
        for(string sc:listOfFields){           
            queryForColumn=queryForColumn+sc+','; 
        } 
        queryForColumn=queryForColumn.removeEnd(',');
        system.debug('list of Unsoratbel Fields'+listofUnSortablefields);
        system.debug('List of first Index Field'+sortFieldName);
        //unsortable fields handled
        if(listofUnSortablefields.contains(sortFieldName)){            
            msg='This Field Type is Not Sortable.Please!!Select Another Field';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'This Field Type is Not Sortable.Please!!Select Another Field');
            ApexPages.addMessage(myMsg);
        }
        else{
            if (sortOrder == 'ASC') {
                sortOrder = 'DESC';
                queryForColumn=queryForColumn+' From '+selectedObjectName+' ORDER BY '+ sortFieldName+' ' + sortOrder;           
                page_Number=1; 
                st_Controller=new Apexpages.StandardSetController(database.getQueryLocator(queryForColumn));
                st_Controller.setPageSize(page_Size);                     
                total_Pages=st_Controller.getResultSize();        
                getallFields();
            }
            else{
                sortOrder = 'ASC';
                queryForColumn=queryForColumn+' From '+selectedObjectName+' ORDER BY '+ sortFieldName+' ' + sortOrder;           
                page_Number=1; 
                st_Controller=new Apexpages.StandardSetController(database.getQueryLocator(queryForColumn));
                st_Controller.setPageSize(page_Size);                
                total_Pages=st_Controller.getResultSize();         
                getallFields();    
            }
        }  
	}    
    /*
	*MethodName:temp_PageNo
	*Purpose:  	To get page Number From vf Page.
	*Parameter:	Void
	*Return: 	Void
	*/
    //get and hold page number from inputbox on vf
    public integer temp_PageNo {set;get;}   
    public void getPageno(){
        temp_PageNo=page_Number;        
    }    
     /*
	*MethodName:enterPageNo
	*Purpose:  	To Validate Page Number Which Enter in Input Box In VF Page.
	*Parameter:	Void
	*Return: 	Void
	*/
    public void enterPageNo(){
		//get page number
        maintainMap(); 
        getPageno();
        integer sumOfPages=0;           
        st_Controller.setPageNumber(page_Number);
        page_Number=st_Controller.getPageNumber();       
        total_Pages=st_Controller.getResultSize();
        //Validate Enter Number for Jumping on Page Number
        if( math.mod(total_Pages, page_Size)==0){
            sumOfPages=(total_Pages/page_Size);
        }
        else{
            sumOfPages=(total_Pages/page_Size)+1;
        } 
        //Show Error Message if Number is Not Betwween 1 to Total Page
        if(temp_PageNo<=0 || temp_PageNo>sumOfPages){
            system.debug('apex message');           
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Out of Page Limit!!Please Enter Valid Page Number');
            ApexPages.addMessage(myMsg); 
        }
        else{
            getallFields(); 
        }
    }
    /*
	*MethodName:downloadCSV
	*Purpose:  	To Download CSV File of Selected Records.
	*Parameter:	Void
	*Return: 	Void
	*/
    public void downloadCSV(){        
        maintainMap(); 
        List<string> recordWithComa=new List<string>();
        listFields = String.join(listOfFields, ',');
        recordWithComa.add(listFields);       
        csvString='';
        //edtting after testing
        if(!mapOfSelectedRecord.isEmpty()){
            for(Objectdescribewrapper i : mapOfSelectedRecord.values()){
                String createrowstr='';
                if(i.flag == true ){
                    for(String fname: listOfFields){
                        if(listOfFields.indexOf(fname) == 0){ 
                            createrowstr = createrowstr + i.obj.get(fname);                           
                        }
                        else {
                            createrowstr =createrowstr +','+ i.obj.get(fname);  
                        }
                    }
                    recordWithComa.add(createrowstr);                  
                }
                csvString=String.join(recordWithComa,'\\n');
                system.debug('csvString'+csvString);
                mapOfSelectedRecord.clear();
            }
        }
        else{
            Apexpages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Select Atlest One Record to download CSV... '));
        }
    }
     /*
	*MethodName:editLink
	*Purpose:  	To Edit Selected Records and Show Edit Panel.
	*Parameter:	Void
	*Return: 	Void
	*/   
    public pagereference editLink(){     
     Id tempparaId = System.currentPagereference().getParameters().get('EditId');     
      for (Objectdescribewrapper wraobj:wrapperList){
          if(wraobj.obj.id==tempparaId){
              listofObjectsTemp.add(wraobj.obj);
          }
      }
        return null;
    }
    /*
	*MethodName:saveAfterEditandDel
	*Purpose:  	To Save Edited Records.
	*Parameter:	Void
	*Return: 	Void
	*/
     public PageReference saveAfterEditandDel(){ 
         update listofObjectsTemp;
         st_Controller.setPageSize(page_Size);
         createQuery();
         getallFields();  
         st_Controller.setPageNumber(page_Number);
         total_Pages=st_Controller.getResultSize();
         listofObjectsTemp.clear();
         return null;
     }    
    /*
	*MethodName:deleteLink
	*Purpose:  	To Delete Selected Records.
	*Parameter:	Void
	*Return: 	Void
	*/   
    public pagereference deleteLink() {        
       Id tempId = System.currentPagereference().getParameters().get('DeleteId');        
        try {
            Database.delete(tempId);
             createQuery();
        	 getallFields();           
            st_Controller.setPageNumber(page_Number);           
        } 
        catch (Exception ex) {            
            Apexpages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Delete Process Abborted !!'+ex));
        }
        return null;
    }
}