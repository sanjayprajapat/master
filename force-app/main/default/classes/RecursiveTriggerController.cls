public class RecursiveTriggerController {
    public static boolean run = true;
    public static boolean toStopRecursion(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
}