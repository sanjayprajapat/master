({
    getAccounts : function(component, event, page, recordToDisply, sortByFieldName, sortDirection){
        var action = component.get("c.fetchAccount");  
        action.setParams({  
            "pageNumber": page,  
            "recordToDisply": recordToDisply,  
            "sortField": sortByFieldName,  
            "sortDirection": sortDirection  
        });  
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();  
                console.log('result ---->' + JSON.stringify(result));
                console.log("Account List = "+result.accounts);
                console.log("Current Page = "+result.page);
                console.log("Total records = "+result.total);
                console.log("Total Page = "+Math.ceil(result.total / recordToDisply));
                component.set("v.accountData", result.accounts);  
                component.set("v.page", result.page);  
                component.set("v.total", result.total);  
                component.set("v.pages", Math.ceil(result.total / recordToDisply));  
            }else{
                console.log('Error In Fetch Account Record State');  
            }
        });
        $A.enqueueAction(action);  
    }
})