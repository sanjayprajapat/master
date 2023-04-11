({
    handleReceiveMessage: function (component, event, helper) {
        if (event != null && event.getParam('isOpen')!= undefined && event.getParam('componentName') != undefined) {                      
            const isOpen = event.getParam('isOpen');            
            const componentName = event.getParam('componentName');
            component.set("v.isOpen",isOpen);
            component.set("v.componentName",componentName);
        }
    },
    handleSendMessage: function(component, event, helper) {
        let myMessage = component.get("v.myMessage");
        const payload = {
            source: "Aura Component",
            messageBody: myMessage
        };
        component.find("lmsDemohannel").publish(payload);
    },
})