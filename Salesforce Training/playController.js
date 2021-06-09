({	
    doInit: function(component, event, helper) {
		component.set("v.buttonType", "button");
        component.set("v.iconName", "utility:play");
    },
    handleClick: function(component, event, helper) {
        helper.handleClick(component);
        component.find("playButton").set("v.disabled", true);
    },
    handleButtonModification: function(component, event, helper) {
        if(event.getParams().button == 0) {
            component.find("playButton").set("v.disabled", event.getParams().disabled);
        }
    }
})