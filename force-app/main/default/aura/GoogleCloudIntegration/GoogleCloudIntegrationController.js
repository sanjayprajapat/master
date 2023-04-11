({
    getAuthCode : function(component, event, helper) {       
        helper.getAutoCodeHelper(component, event, helper);
    },
    doInit : function(component, event, helper) {
        var listOfActionType = [            
            { label: 'TEXT DETECTION', value: 'TEXT_DETECTION' },
            { label: 'DOCUMENT TEXT DETECTION', value: 'DOCUMENT_TEXT_DETECTION' },
            /*{ label: 'OBJECT SEARCH', value: 'OBJECT_LOCALIZATION' },
            { label: 'SAFE SEARCH DETECTION', value: 'SAFE_SEARCH_DETECTION' }*/                   
        ];
        component.set("v.listOfActionType",listOfActionType);
        
        helper.checkTokenHelper(component, event, helper);
        var isTokenExpired =  component.get("v.isTokenExpired") ;
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const code = urlParams.get('code')
        console.log('Access code from URl  = '+code);
        if(code){
            helper.getAccessTokenHelper(component, event, helper,code);
        }        
    },
    uploadImage : function(component, event,helper){
        helper.readFileAsBinary(component, event, helper);
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
})