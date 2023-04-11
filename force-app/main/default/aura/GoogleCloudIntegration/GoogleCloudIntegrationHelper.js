({
    checkTokenHelper : function(component, event, helper) {
        this.showSpinner(component, event, helper);
        var action = component.get("c.checkIsTokenValid");  
        action.setParams({              
        });  
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                this.hideSpinner(component, event, helper);
                var result = response.getReturnValue();                  
                component.set("v.isTokenExpired",result);
                if(result){
                    component.set("v.buttonLabel",'Authorize');
                }
                else{
                    this.hideSpinner(component, event, helper);
                    component.set("v.showMessage",true); 
                    component.set("v.message",'You are already authorized'); 
                    component.set("v.buttonLabel",'Authorized');
                }
                
            }
            else if (state === 'ERROR'){  
                this.hideSpinner(component, event, helper);
                var errors = response.getError();
                if (errors) {
                    if (Array.isArray(errors) && errors[0] && errors[0].message) {
                        component.set("v.showError",true); 
                        component.set("v.error",errors[0].message); 
                        console.log('Error while checking token validation = '+errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);  
        
    },
    getAutoCodeHelper : function(component, event, helper) {
        this.showSpinner(component, event, helper);
        var action = component.get("c.getAutoCodeHandler");  
        action.setParams({              
        });  
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                this.hideSpinner(component, event, helper);
                
            }
            else if (state === 'ERROR'){    
                this.hideSpinner(component, event, helper);
                var errors = response.getError();
                if (errors) {
                    if (Array.isArray(errors) && errors[0] && errors[0].message) {
                        component.set("v.showError",true); 
                        component.set("v.error",errors[0].message); 
                        console.log('Error while Getting Access Code = '+errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);  
        
    },
    getAccessTokenHelper : function(component, event, helper,code) {
        var action = component.get("c.getAccessToken");  
        action.setParams({
            "authCode":code,
        });  
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();                
                console.log('Access token is here ---->',result);
                component.set("v.showMessage",true); 
                component.set("v.message",'Authorization successfully'); 
                component.set("v.isTokenExpired",false);
                component.set("v.buttonLabel",'Authorized');
                
            }
            else if (state === 'ERROR'){                
                var errors = response.getError();
                if (errors) {
                    if (Array.isArray(errors) && errors[0] && errors[0].message) {
                        component.set("v.showError",true); 
                        component.set("v.error",errors[0].message); 
                        console.log(errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);  
        
    },
    readFileAsBinary : function(component, event, helper) {
        var files = component.get("v.fileList"); 
        var objFileReader = new FileReader();
        objFileReader.onloadend = (() => {
            var fileContents = objFileReader.result;
            let base64 = 'base64,';
            var content = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(content);
            this.readBinaryFile(component, event, helper,fileContents,'','', '');
        });
        objFileReader.readAsDataURL(files[0]); 
    },
    
    
    readBinaryFile : function(component, event, helper,binaryData, imageURL, gcImageURL, taskType){ 
        this.showSpinner(component, event, helper);        
        component.set("v.showError",false); 
        component.set("v.error",''); 
        
        var action = component.get("c.detectTextFromImage");  
        action.setParams({
            "base64String":binaryData,
            "imageURL":'',
            "gScURL":'',
            "type":component.get("v.actionType")         
        });  
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                this.hideSpinner(component, event, helper);
                var result = response.getReturnValue();                
                console.log('readBinaryFile is here ---->',result);
                component.set("v.showMessage",true); 
                component.set("v.message",'Image Scan successfully');               
            }
            else if (state === 'ERROR'){   
                this.hideSpinner(component, event, helper);
                var errors = response.getError();
                if (errors) {
                    if (Array.isArray(errors) && errors[0] && errors[0].message) {
                        component.set("v.showError",true); 
                        component.set("v.error",errors[0].message); 
                        console.log(errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);         
    },
    // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {       
        component.set("v.spinner", true); 
    },
    
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){        
        component.set("v.spinner", false);
    }
})