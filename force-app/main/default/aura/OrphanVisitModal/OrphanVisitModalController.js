({
	doInit: function(component, event, helper){
        console.log(component.get('v.recordId'));
        const flow = component.find("flowData");
        var inputVariables = [
            {
                name:"recordId",
                type:"String",
                value:component.get("v.recordId")
            }];         
        flow.startFlow("Orphan_Visit_Form_on_Visit", inputVariables);
    },
    statusChange: function(c, e, h) {
        h.statusChange_helper(c,e,h);
    }
})