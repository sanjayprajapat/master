({
   
    // =============  this function will fetch records =============================
    doInit : function(component, event, helper) {
        // Setting column information.To make a column sortable,set sortable as true on component load
        component.set("v.accountColumns",[
            {
                label : 'Name',
                fieldName : 'Name',
                type : 'text',
                sortable : true
            },
            {
                label : 'Account Source',
                fieldName : 'AccountSource',
                type : 'text',
                sortable : true
            },
            {
                label : 'Account Number',
                fieldName : 'AccountNumber',
                type : 'text',
                sortable : true
            }
        ]);
       
        var page = component.get("v.page") || 1;  
        console.log("page = "+page);
        var recordToDisply = component.find("recordSize").get("v.value");  
        console.log("recordToDisply = "+recordToDisply);
        var sortByFieldName = component.get("v.sortBy");
        console.log("sortByFieldName = "+sortByFieldName);
        var sortDirection = component.get("v.sortDirection");
        console.log("sortDirection = "+sortDirection);
        // call helper function to fetch account data from apex
        helper.getAccounts(component, event, page, recordToDisply, sortByFieldName, sortDirection);
    },
   
   
    // =================== first, previous, next, last button click =================
    gotoFirstPage : function(component, event, helper) {  
        component.set("v.page",1);
        var recordToDisply = component.find("recordSize").get("v.value");  
        console.log("recordToDisply = "+recordToDisply);
        var sortByFieldName = component.get("v.sortBy");
        console.log("sortByFieldName = "+sortByFieldName);
        var sortDirection = component.get("v.sortDirection");
        console.log("sortDirection = "+sortDirection);
        // call helper function to fetch account data from apex
        helper.getAccounts(component, event, 1, recordToDisply, sortByFieldName, sortDirection);
    },  
   
    gotoPreviousPage: function(component, event, helper) {  
        var recordToDisply = component.find("recordSize").get("v.value");  
        console.log("recordToDisply = "+recordToDisply);
        component.set("v.page", component.get("v.page") - 1);  
        var sortByFieldName = component.get("v.sortBy");
        console.log("sortByFieldName = "+sortByFieldName);
        var sortDirection = component.get("v.sortDirection");
        console.log("sortDirection = "+sortDirection);
        // call helper function to fetch account data from apex
        helper.getAccounts(component, event, component.get("v.page"), recordToDisply, sortByFieldName, sortDirection);
    },  
   
    gotoNextPage: function(component, event, helper) {  
        var recordToDisply = component.find("recordSize").get("v.value");
        console.log("recordToDisply = "+recordToDisply);
        component.set("v.page", component.get("v.page") + 1);  
        var sortByFieldName = component.get("v.sortBy");
        console.log("sortByFieldName = "+sortByFieldName);
        var sortDirection = component.get("v.sortDirection");
        console.log("sortDirection = "+sortDirection);
        // call helper function to fetch account data from apex
        helper.getAccounts(component, event, component.get("v.page"), recordToDisply, sortByFieldName, sortDirection);
    },
   
    gotoLastPage : function(component, event, helper) {  
        var recordToDisply = component.find("recordSize").get("v.value");
        console.log("recordToDisply = "+recordToDisply);
        component.set("v.page",component.get("v.pages"));
        var sortByFieldName = component.get("v.sortBy");
        console.log("sortByFieldName = "+sortByFieldName);
        var sortDirection = component.get("v.sortDirection");
        console.log("sortDirection = "+sortDirection);
        // call helper function to fetch account data from apex
        helper.getAccounts(component, event, component.get("v.page"), recordToDisply, sortByFieldName, sortDirection);
    },  
   
    // ======= Click on picklist to change the value of Page Size ==================
    onSelectChange: function(component, event, helper) {  
        var page = 1  
        var recordToDisply = component.find("recordSize").get("v.value");  
        var sortByFieldName = component.get("v.sortBy");
        console.log("sortByFieldName = "+sortByFieldName);
        var sortDirection = component.get("v.sortDirection");
        console.log("sortDirection = "+sortDirection);
        // call helper function to fetch account data from apex
        helper.getAccounts(component, event, page, recordToDisply, sortByFieldName, sortDirection);
    },  
   
    // =======  Sorting functionality  =========================================
    //Method gets called by onsort action,
    handleSort : function(component,event,helper){
        //Returns the field which has to be sorted
        var sortByFieldName = event.getParam("fieldName");
        console.log("sortByFieldName = "+sortByFieldName);
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        console.log("sortDirection = "+sortDirection);
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortByFieldName);
        component.set("v.sortDirection",sortDirection);
        var page = component.get("v.page");  
        console.log("page = "+page);
        var recordToDisply = component.find("recordSize").get("v.value");  
        console.log("recordToDisply = "+recordToDisply);
        // call helper function to fetch account data from apex in Sorted Format
        helper.getAccounts(component, event, page, recordToDisply, sortByFieldName, sortDirection);
    },
   
   
})