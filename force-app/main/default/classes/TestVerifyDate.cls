@isTest
private class TestVerifyDate{
    @isTest static void testDt1GtrDt2(){
        Date d2 = system.today();
        Date d1 = d2.addDays(10);
        
        Date dt = VerifyDate.CheckDates(d1, d2);
        Date testDt = Date.newInstance(2017, 7, 31);
        System.assertEquals(dt, testDt);
    }
    
    @isTest static void testDt2Within30dayOfDt1(){
        Date d1 = system.today();
        Date d2 = d1.addDays(10);
        
        Date dt = VerifyDate.CheckDates(d1, d2);
        System.assertEquals(dt, d2);
    }
}