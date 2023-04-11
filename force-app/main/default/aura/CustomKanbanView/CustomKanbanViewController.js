({
    initHandler : function(component, event, helper) {
        helper.initHelper(component, event, helper);
    },
    allowDrop: function(component, event, helper){
        event.preventDefault();
    },
    drag: function(component, event, helper){
        var parentId = ''
        var startId = '';
        if(helper.detectBrowser() == "Mozilla Firefox"){
            startId = event.target.dataset.dragId;
            parentId= document.getElementById(event.target.dataset.dragId).parentElement.id;
            event.dataTransfer.setData('Text', component.id);
            
        }else{
            startId = event.target.id;
            parentId= document.getElementById(event.target.id).parentElement.id;
        }  
        console.log('startId === '+startId);
        console.log('parentId ==='+parentId);
        component.set("v.startId", startId);
        component.set("v.containerId",parentId);        
    },
    
    drop: function(component, event, helper){
        var drag = component.get("v.startId");// StoryId
        console.log('drag === '+drag);
        
        var storyOldStatus = drag.split('#')[0];
        console.log('storyOldStatus === '+storyOldStatus);
        
        var targetDiv = event.currentTarget.id; // drop div id
        console.log('targetDiv === '+targetDiv);
        
        if(targetDiv.includes('@')){
            targetDiv = targetDiv.split('@')[0];
        }
        console.log('targetDiv === '+targetDiv);
        
        var storyStatusToBeChanged;
        var listOfStatus = component.get('v.listOfStatus');
        for(var i = 0 ; i < listOfStatus.length ; i++){
            if(listOfStatus[i].valueWithoutSpace == targetDiv){
                storyStatusToBeChanged = listOfStatus[i].value;
                break;
            }
        }
        
        if(!$A.util.isEmpty(storyStatusToBeChanged) && storyOldStatus != storyStatusToBeChanged){            
            event.preventDefault();           
            //alert(storyStatusToBeChanged);
            helper.storyUpdateHelper(component,event,helper,storyStatusToBeChanged,drag.split('#')[1]);
        }
    },    
    
})