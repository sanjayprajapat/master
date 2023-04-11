public class Objectdescribewrapper {
    public boolean flag 	{set;get;}
    public sobject obj		{set;get;}
    public Objectdescribewrapper(sobject obj,boolean flag){
        this.flag=flag;
        this.obj=obj;
    }

}