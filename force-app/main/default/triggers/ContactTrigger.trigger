trigger ContactTrigger on Contact (before Insert,before update,after Delete,after Undelete) { 
    
    if(Trigger.isBefore && Trigger.isInsert){
        ContactTriggerHandler ct=new ContactTriggerHandler();
        ct.beforeInsert(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        system.debug('Update Trigger Launched ');        
        ContactTriggerHandler ct=new ContactTriggerHandler();
        ct.beforeUpdate(Trigger.new,Trigger.old,Trigger.oldMap);       
    }
    
    if(Trigger.isAfter && Trigger.isDelete){
        ContactTriggerHandler ct=new ContactTriggerHandler();
        ct.afterDelete(Trigger.old);
    }
    
    if(Trigger.isUndelete){
        ContactTriggerHandler ct=new ContactTriggerHandler();
        ct.afterUndelete(Trigger.new);
    }
}