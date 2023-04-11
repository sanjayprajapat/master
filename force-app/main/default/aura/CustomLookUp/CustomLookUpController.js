({
    searchRecords : function(component, event, helper) {
        var searchText = event.getSource().get("v.value");
        var mainBox = component.find('mainBox');
        component.set("v.showSpinner", true);
        if(searchText.length > 0) {
            $A.util.addClass(mainBox, 'slds-is-open');
        }
        else {
            $A.util.removeClass(mainBox, 'slds-is-open');
        }
        var action = component.get("c.getResults");
        action.setParams({
            "ObjectName" : component.get("v.objectName"),
            "fieldName" : component.get("v.fieldName"),
            "searchString" : searchText
        });
        
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {
                component.set("v.listOfRecords", response.getReturnValue());
                if(component.get("v.listOfRecords").length == 0) {
                    console.log('No Record Found');
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(action);
    },
    
    setSelectedRecord : function(component, event, helper) {
        var searchText = event.currentTarget.id;
        var mainBox = component.find('mainBox');
        $A.util.removeClass(mainBox, 'slds-is-open');
        //component.set("v.selectRecordName", searchText);
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        component.set("v.selectRecordId", searchText);
        component.find('userinput').set("v.readonly", true);
    }, 
    
    resetData : function(component, event, helper) {
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");
        component.find('userinput').set("v.readonly", false);
    }
})