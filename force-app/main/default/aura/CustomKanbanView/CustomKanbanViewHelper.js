({
    initHelper : function(component, event, helper) {
        var action = component.get("c.getInitialData");
        action.setParams({
            "sObjectName" : component.get("v.sObjectName"),
            "listOfField" : component.get("v.listOfField"),
            "kanbanField" : component.get("v.kanbanField"),
            "limitOfRecord" : component.get("v.limitOfRecord")            
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {                           
                var result = response.getReturnValue();  
                component.set("v.listOfRecords",result.listOfsObject);
                component.set("v.listOfStatus",result.listOfPicklistWrapper);
            } else{
                alert("error");
            } 
        });
        $A.enqueueAction(action);
    },
    detectBrowser : function() {
        var sBrowser, sUsrAg = navigator.userAgent;
        
        if(sUsrAg.indexOf("Chrome") > -1) {
            sBrowser = "Google Chrome";
        } else if (sUsrAg.indexOf("Safari") > -1) {
            sBrowser = "Apple Safari";
        } else if (sUsrAg.indexOf("Opera") > -1) {
            sBrowser = "Opera";
        } else if (sUsrAg.indexOf("Firefox") > -1) {
            sBrowser = "Mozilla Firefox";
        } else if (sUsrAg.indexOf("MSIE") > -1) {
            sBrowser = "Microsoft Internet Explorer";
        } else {
            sBrowser = "unknown";
        }
        return sBrowser;
    },
    storyUpdateHelper : function(component,event,helper,newStatus,recordId){
        var listOfRecord = component.get("v.listOfRecords");
        for(var i = 0 ; i < listOfRecord.length ; i++){
            if(listOfRecord[i].Id == recordId){
                listOfRecord[i].Status__c = newStatus;
            }
        }
        component.set("v.listOfRecords",listOfRecord);
    },
    
})