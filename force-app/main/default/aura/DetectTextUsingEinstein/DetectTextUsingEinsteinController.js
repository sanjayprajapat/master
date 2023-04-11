({
    initHandler : function(component, event, helper) {
        var listOfActionType = [            
            { label: 'CHOOSE FROM STORAGE', value: 'SELECT_IMAGE' },
            { label: 'PASTE URL OF IMAGE', value: 'PASTE_URL' }
        ];
        component.set("v.listOfActionType",listOfActionType);
    },
    
    uploadImage : function(component, event,helper){
        var actionType = component.get("v.actionType");      
        component.set("v.listOfResult",'');
        if(actionType == 'PASTE_URL' ){
            var pasteUrl = component.get("v.pasteUrl");
            helper.readBinaryFile(component, event, helper, '',pasteUrl,false);
        }       
        else{
            helper.readFileAsBinary(component, event, helper); 
        }
        
    },
    handleFilesChange : function(component, event,helper){
        var files = component.get("v.fileList"); 
        if(files[0].size < 1500000){
            var objFileReader = new FileReader();
            objFileReader.onload = $A.getCallback(function() {                
                //assign all the result into fileContent Variable
                var fileContents = objFileReader.result;
                component.set("v.selectedImageURL",fileContents);               
                
            });
            objFileReader.readAsDataURL(files[0]); 
            
        }
        else{           
            component.set("v.showMessage",true);
            component.set("v.message",'File size is more than 3 MB');
        }
    }, 
    handleInputBox: function(component, event,helper){        
        component.set("v.selectedImageURL",component.get("v.pasteUrl"));  
    },
    handleImageContent: function(component, event,helper){        
        var actionType = component.get("v.actionType");
        component.set("v.selectedImageURL" ,'');
        component.set("v.listOfResult",'');
        
        if(actionType == 'SELECT_IMAGE'){
            component.set("v.pasteUrl",'');
        }
        else{
            component.set("v.fileList",'');
        }        
    }
})