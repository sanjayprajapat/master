trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, before insert) {
    if(Trigger.isbefore){
        if(Trigger.isInsert){
            ContentDocumentLinksHandler.processBeforeInsert(Trigger.new);
        }
    } 
    if(Trigger.isAfter){
        if(Trigger.isInsert){
             ContentDocumentLinksHandler.processAfterInsert(Trigger.new);
        }
    }
}