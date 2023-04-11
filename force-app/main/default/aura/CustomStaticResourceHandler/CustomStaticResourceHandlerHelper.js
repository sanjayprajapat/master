({
    getBase64 : function(component, event, helper,file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.readAsDataURL(file);
            reader.onload = () => resolve(reader.result);
            reader.onerror = error => reject(error);
        });
    },
    doInitHelper : function(component, event, helper) {
        var action = component.get("c.getAllStaticResource");
        action.setParams({            
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(typeof result.Body);                
                
                // Decode the String
                var encodedString = btoa(result.Body);
                console.log('type of =='+typeof encodedString);                             
                
                
                // Decode the String
                var decodedString = atob(encodedString);
                console.log('type of =='+typeof decodedString);                 
                
                
               /* 
                var buffer = new ArrayBuffer(decodedString.length),
                    view = new Uint8Array(buffer);
                for(var i = 0; i < decodedString.length; i++){
                    view[i] = decodedString.charCodeAt(i);
                }
                
                var zip = new JSZip();
                zip.loadAsync(buffer, {base64: true}).then(function(content) {    
                    var reader = new FileReader();
                    reader.readAsArrayBuffer(result.Body);
                    reader.onload = function(e){
                        console.log(this.result)  
                    }
                    
                });********/                
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
        });
        $A.enqueueAction(action);
    }
})