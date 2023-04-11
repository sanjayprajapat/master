({
    readFileAsBinary : function(component, event, helper) {
        var files = component.get("v.fileList"); 
        var objFileReader = new FileReader();
        objFileReader.onloadend = (() => {
            var fileContents = objFileReader.result;
            let base64 = 'base64,';
            var content = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(content);
            this.readBinaryFile(component, event, helper,fileContents,'',true);
        });
        objFileReader.readAsDataURL(files[0]);
    },
    
    
    readBinaryFile : function(component, event, helper, base64String,imageURL,isBase64){ 
       
        this.showSpinner(component, event, helper);        
        component.set("v.showError",false); 
        component.set("v.error",''); 
        
        var action = component.get("c.DetectTextFromImage");  
        action.setParams({
            'base64String'  	:   base64String,
            'imageURL'			:	imageURL,
            'isBase64'			:	isBase64,
            'isTableDetection'	:	component.get("v.isTableDetection")
        });  
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                this.hideSpinner(component, event, helper);
                var result = response.getReturnValue();                
                console.log('readBinaryFile is here ---->',result);
                component.set("v.showMessage",true); 
                component.set("v.message",'Image Scan successfully'); 
                component.set("v.listOfResult",result.probabilities);
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