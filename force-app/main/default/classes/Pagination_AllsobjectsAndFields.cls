/*
*Classname: Pagination_AllsobjectsAndFields
*Purpose: 	To get all SObjects of The Org and get Fields of selected object and also get Records of selected fields,To Create Pagination From StandardSetController and Add First, Last, Next, Previous Button ,
			also add Pipcklist to Chnage Page Size to Show Records.
*Date:		2nd April 2020
*Author: 	Sanjay Prajapat
*/
public class Pagination_AllsobjectsAndFields {
    //--------------------------------------Fetch List of Sobjects--------------------------------------------------------------------------------------------
    //map for listOfSobjects 
    public Map<string,schema.SObjectType> mapOfObjects	=schema.getGlobalDescribe();
    //get all objects in list for picklist
    public list<selectoption> listOfSobjects {get;set;}
    //get selected object from vf page
    public string selected	{get;set;}   									
    //-------------------------------------Fetch List of Fields---------------------------------------------------------------------------------------
    //map for fieldslist
    public map<string,Schema.SObjectField>	mapOfFields=new  map<string,Schema.SObjectField>();
    ////get all fields in list for picklist
    public list<selectoption> listOfAllFields {get;set;}
    //--------------------------------------Send Vales to Panel and Adjustment Panel -------------------------------------------------------------------------------------
    //Get Selected Fields From Left Panel on Vf Page
    public list<string> leftPanel {get;set;}
    //Get selected fields from Right panel on Vf Page
    public list<string>	rightPanel {get;set;}    					
    //for add selected fields from left panel to rigth panel
    public list<selectoption> ListofFieldstoRight	{get;set;}						
   // for hide and unhide panel in vf page
    public  boolean	showPanel {get;set;}
    //-------------------------------------Send List of Fields to Component and Adjustment of Buttons-------------------------------------------------------------------------
    //Get list of Fields Value(API Name) to Send to Component
    public list<string> listOfFieldsToCom {get;set;}
    //Get list of Fields Label(Label Name) to Send to Component//This is Not Working,so Useless
    public list<string>	listOfFieldsLabelToCom	{get;set;}
    //To ReRender Component on vf also Decide When send Values
    public boolean 	showCom	{get;set;}    
    //To Hold Old Object Value
    public string oldSelectedObj {get;set;}
    //get list of fields which are unsortable
    public list<string> ListOfUnsortableFields {get;set;}
    //show and hide error panel
    public static boolean errormsg {get;set;} 
    //Create Label of Object Name
    Public String ObejctLabelName {Set;get;}
    public static boolean jsVar{set;get;}
//---------------------------------------------------------------------------------------------------------------------------------------------------   
    /*
	*ConstructorName:Pagination_StandradSetController
	*Purpose:		 To Get Object List on Launching of Vf Page ,To Initialize list of all object and list of all fields StandardSetController and Class Members,Set PageSize,Page Number for First Launching of Page.
	*Parameter:		 Void
	*Return: 		 Void
	*/
    public Pagination_AllsobjectsAndFields(){ 	 
        //List of Sobjects
        listOfSobjects=new list<selectoption>();
        //List Of Fields
        listOfAllFields=new list<selectoption>();
        //List of fields for add to Right Panel
        ListofFieldstoRight=new list<selectoption>();
        // list of fields Value for Component
        listOfFieldsToCom=new list<string>();
        // list of fields Label for Component
        listOfFieldsLabelToCom=new list<string>();
        selectoption None=new selectoption('None','--None--');        
        listOfAllFields.add(None);
        //Stop to send Data to Component 
        showCom=false;
        //for contains unsortable fields
        ListOfUnsortableFields=new list<string>();
        errormsg=true;
		leftPanel=new list<String>();
		rightPanel=new list<String>();       
        //Get All Sobjects in Obejctlist
        for(schema.SobjectType sObj : mapOfObjects.values()){
            if(sObj.getDescribe().isAccessible() && sObj.getDescribe().isDeletable() && sObj.getDescribe().isQueryable() && 
               sObj.getDescribe().isUndeletable() && sObj.getDescribe().isUpdateable() && sObj.getDescribe().iscreateable() &&
               sObj.getDescribe().issearchable() && sObj.getDescribe().getLabel()!='Note' && sObj.getDescribe().getLabel()!='Attachment'){
                   if(sObj.getDescribe().getName().contains('__c')){
                       //localname is api name and label is name of sobject
                       listOfSobjects.add(new SelectOption(sObj.getDescribe().getLocalName(),sObj.getDescribe().getLabel())); //for custom object                                       
                   }
                   else{
                       listOfSobjects.add(new SelectOption(sObj.getDescribe().getLocalName(),sObj.getDescribe().getLocalName()));  //for standard object                 
                   }
               }
        }        
        //if object list Have More Then 0 Records
        if(listOfSobjects.size()>0){           
            listOfSobjects.sort();
            listOfSobjects.add(0, None);       
        }
    }
    /*
	*MethodName:reset
	*Purpose: 	To Reset Page.
	*Parameter:	Void
	*Return: 	Void
	*/    
    public void reset(){
        listOfAllFields.clear();
        ListofFieldstoRight.clear();        
        showCom=false;
        showPanel=false;      
        errormsg=true;
        selectoption sp=new selectoption('None','--None--');
        //after reset it show object list again
        if(listOfSobjects.size()>0){
            listOfSobjects.sort();
            listOfSobjects.add(0, sp);
            selected='';            
        } 
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM ,'You! Clicked on Reset');
         ApexPages.addMessage(myMsg);        
    }
	/*
	*MethodName:holdselectedobject
	*Purpose: 	To Hold Selected Object Value for action after change object from picklist
	*Parameter:	Void
	*Return: 	Void
	*/
    public void getHoldSelectedObject(){
        oldSelectedObj=selected;
    }    
    /*
	*MethodName:fetchFields
	*Purpose: 	To get all Fields of Selected Object.
	*Parameter:	Void
	*Return: 	Void
	*/    
    public void fetchFields(){
        //Remove Object 's '__c' and Replace '_' with Space to Show Only Name on vf
        ObejctLabelName=selected.removeEnd('__c');
        ObejctLabelName=ObejctLabelName.replaceAll('_',' ');
        system.debug('Object Label Name='+ObejctLabelName);
        selectoption sp=new selectoption('None','--None--');
        showCom=false;        
        listOfAllFields.clear();
        ListofFieldstoRight.clear();
        //if Object Change after Click On Process Button then it will Hide Panel,Add,Remove,Process Button
        if(oldSelectedObj!=selected){
            showCom=false;
            showPanel=false;
        }
        //Fetch Fields of Selected Object
        if(selected!='None'){ 
            listOfAllFields.clear();
            showPanel=true;                 
            mapOfFields=mapOfObjects.get(selected).getDescribe().fields.getMap();            
            Set<String> fieldnames=mapOfFields.keySet();            
            for(String keys:fieldnames){                
                Schema.DescribeFieldResult fldResult = mapOfFields.get(keys).getDescribe();                
                if(fldResult.isAccessible() && fldResult.isUpdateable()){                                                   
                    listOfAllFields.add(new SelectOption(fldResult.getName(),fldResult.getLabel())); 
                } 
                //for filtering unsortablefields
                if(!fldResult.isSortable()){
                    ListOfUnsortableFields.add(fldResult.getLocalName());
                }
            }
            if(listOfAllFields.size()>0 || listOfAllFields !=null ){              
                listOfAllFields.sort();
            }            
        } 
        //if selected Object is None Then Following Will Be Hide
        else{
            showCom=false;
            showPanel=false;
            listOfAllFields.clear();
        	ListofFieldstoRight.clear();          
            leftPanel.clear();
            rightPanel.clear();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING ,'Please! Select at Least One Object');
        	ApexPages.addMessage(myMsg);
        }
    }
	/*
	*MethodName:addfields
	*Purpose: 	To add selected Fields to Right Panel and Remove These Fields from Left Panel.
	*Parameter:	Void
	*Return: 	Void
	*/
    public void addFields(){
        errormsg=true;
        showCom=false;
		//Loop for Add All Selected Fields From Left to Right Panel and Remove from Left Panel        
        for(string s:leftPanel){            
            ListofFieldstoRight.add(new selectoption(s,mapOfFields.get(s).getDescribe().getLabel()));   
            listOfAllFields.remove(listOfAllFields.indexOf(new SelectOption(s,mapOfFields.get(s).getDescribe().getLabel())));
        }
        //if selected one or More Fields from Left Panel
        if(leftPanel.size()>0){
            listOfAllFields.sort();
        }
        //No Any Field Selected From Left Panel Then it Will Give Error Message
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please! Select at Least One Field to Add');
            ApexPages.addMessage(myMsg);
            system.debug('error message'+myMsg);
        }
        //After Added selected Fields will Be Unselected      
        leftPanel=null;        
        system.debug('fields in right'+ListofFieldstoRight);
        system.debug('Fields in left'+listOfAllFields);
    }
    /*
	*MethodName:removeFields
	*Purpose: 	To remove selected Fields from Right Panel and add again These Fields to Left Panel.
	*Parameter:	Void
	*Return: 	Void
	*/    
    public void removeFields(){
       errormsg=true;
       showCom=false;
       //Loop for Remove All Selected Fields From Right Panel and Add To Left Panel  
        for(string s:rightPanel){            
            listOfAllFields.add(new SelectOption(s,mapOfFields.get(s).getDescribe().getLabel()));
            ListofFieldstoRight.remove(ListofFieldstoRight.indexOf(new SelectOption(s,mapOfFields.get(s).getDescribe().getLabel())));
        } 
        if(rightPanel.size()>0){            
            listOfAllFields.sort();
        }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please! Select at Least One Field to Remove');
            ApexPages.addMessage(myMsg);
            system.debug('error message'+myMsg);
        }               
        rightPanel=null;
    }
    /*
	*MethodName:processButton
	*Purpose: 	Get Records of Selected Fields when Clicking on Process Button.
	*Parameter:	Void
	*Return: 	Void
	*/    
    public void processButton(){
        errormsg=true;
       	// listOfFieldsToCom=new list<string>();
       	listOfFieldsToCom.clear();
        listOfFieldsLabelToCom.clear();
        if(ListofFieldstoRight.size()>0 ){
            jsVar=true;
            showCom=true;
            //after add selected value seprate label and value of field to send to component
            for(system.selectoption sc:ListofFieldstoRight){           
                listOfFieldsToCom.add(sc.getValue());
                listOfFieldsLabelToCom.add(sc.getLabel());				         
            }
        }
        else{
            showCom=false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please! Select at Least One Field to Proccess');
            ApexPages.addMessage(myMsg);
        }       
        system.debug('fields in Processbutton '+listOfFieldsToCom);
        system.debug('Selected Object='+selected);
    } 
}