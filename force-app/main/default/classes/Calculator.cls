public class Calculator {
    public integer a{get;set;}
    public integer b{get;set;}
    public String Opp{get;set;}
    public integer result{get;set;}
    
    public pageReference showdata()
    {
        result=a+b;
        opp='Addition';
        return null;
    }
    public pageReference showdata1()
    {
        result=a-b;
        opp='Substraction';
        return null;
    }

}