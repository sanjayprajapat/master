/*
*Classname: Pagination_AllsobejctsAndFieldsTest
*Purpose: 	To Test BM_Project1class
*Date:		22th April 2020
*Author: 	Sanjay Prajapat
*/
@isTest   
Private class Pagination_AllsobejctsAndFieldsTest {
    /*
*MethodName: testFetchFields
*Purpose: 	To Test testFetchFields Method and getholdselectedobject Method.
*Parameter:	Void
*Return: 	Void
*/
    @isTest
    private static void testFetchFields(){
        Pagination_AllsobjectsAndFields obj1=new Pagination_AllsobjectsAndFields();
        //test old and selected object values and selected!=none
        //Test Selected Object is Not None
        obj1.selected='Account';             
        obj1.fetchFields();
        //test selected=none
        obj1.selected='None';       
        obj1.fetchFields();
        //Test Selected and Old Object are Diffrent
        obj1.oldSelectedObj='contact';
        obj1.fetchFields();
        //Test getholdselectedobject Method
        obj1.getHoldSelectedObject();
    }
    /*
*MethodName: testaddFields
*Purpose: 	To Test testaddFields Method.
*Parameter:	Void
*Return: 	Void
*/
    @isTest()
    private static void testAddFields(){        
        Pagination_AllsobjectsAndFields obj2=new Pagination_AllsobjectsAndFields();       
        obj2.selected='Account';
        obj2.oldSelectedObj='contact';
        obj2.fetchFields();        
        //test leftpanel have values        
        obj2.leftPanel=new list<string>();
        system.debug('map='+ obj2.mapOfFields);        
        for(System.SelectOption op: obj2.listOfAllFields){
            obj2.leftPanel.add(op.getValue());  
            break;
        }
        system.debug('left panel='+ obj2.leftpanel);
        obj2.addFields();
        //test leftpanel size is 0 or null        
        obj2.leftPanel=new list<string>();       
        for(System.SelectOption op: obj2.listOfAllFields){
            obj2.leftpanel.add(op.getValue());  
            break;
        }        
        obj2.leftpanel.remove(0);
        system.debug('left panel removed'+obj2.leftpanel);
        obj2.addFields();
    }
    /*
*MethodName: testRemoveFields
*Purpose: 	To Test testRemoveFields and Process Method.
*Parameter:	Void
*Return: 	Void
*/
    @isTest
    private static void testRemoveFields(){        
        Pagination_AllsobjectsAndFields obj3=new Pagination_AllsobjectsAndFields();        
        obj3.selected='Account';
        obj3.oldSelectedObj='contact';
        obj3.fetchFields();
        //add all Fields to ListofFieldstoRight
        obj3.ListofFieldstoRight.addAll(obj3.listOfAllFields);
        //test rightPanel have values        
        obj3.rightPanel=new list<string>();
        for(System.SelectOption op: obj3.ListofFieldstoRight){
            obj3.rightPanel.add(op.getValue());
            //obj3.ListofFieldstoRight.add(new selectoption(op.getValue(),op.getLabel()));
            break;
        }
        obj3.removeFields();        
        //test rightPanel size is 0 or null
        obj3.rightPanel=new list<string>();       
        for(System.SelectOption op: obj3.listOfAllFields){
            obj3.rightPanel.add(op.getValue()); 
            obj3.ListofFieldstoRight.add(new selectoption(op.getValue(),op.getLabel()));           
            break;
        }        
        obj3.rightPanel.remove(0);
        system.debug('right panel removed'+obj3.rightPanel);
        obj3.removeFields();        
        //Test Process Button 
        obj3.processButton();
        obj3.ListofFieldstoRight.clear();
        obj3.processButton();
        //Test Reset Method
        obj3.reset();
    }
}