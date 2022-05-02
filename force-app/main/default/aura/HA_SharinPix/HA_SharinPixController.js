({
    doInit: function(cmp) {
        // Set the attribute value. 
        // You could also fire an event here instead.
        console.log('**find*'+cmp.find("sharinpix-cmp"));
    },
    
    handleEvent : function(component, event, helper) {
        console.log('****'+event.getSource().getLocalId());
        console.log("Event name: ", event.getParam("name"));
            console.log("Payload: ", event.getParam("payload"));
        if(event.getSource().getLocalId() == "sharinpix-cmp") {
            console.log("Event name: ", event.getParam("name"));
            console.log("Payload: ", event.getParam("payload"));
        }
    }
})