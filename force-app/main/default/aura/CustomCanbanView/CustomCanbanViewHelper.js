({
	updatePickVal : function(component, recId, pField, pVal) {
        
		var action = component.get("c.getUpdateStage");
        action.setParams({
            "recId":recId,
            "kanbanField":pField,
            "kanbanNewValue":pVal
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                document.getElementById(recId).style.backgroundColor = "#04844b";
                setTimeout(function(){ document.getElementById(recId).style.backgroundColor = ""; }, 300);
            }
        });
        $A.enqueueAction(action);
	},
    countStages : function(component, helper, WrapperData) {
       
        var pickListValues = WrapperData.pickVals;
        var listOfRecords = WrapperData.records;        
        var count;
        var listOfCounts = [];
        for(var i = 0; i < pickListValues.length ; i++){  
            count=0;
            for(var j = 0 ; j < listOfRecords.length;j++ ){
                if(pickListValues[i] == listOfRecords[j].StageName){
                    count++;
                }                
            }
            listOfCounts.push(pickListValues[i]+ ' ' +'('+count+')');
        }
        component.set("v.kanbanPicklistWithCount",listOfCounts);
        console.log("list with count = "+component.get("v.kanbanPicklistWithCount"));
    }    
})