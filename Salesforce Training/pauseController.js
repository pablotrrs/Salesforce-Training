({
    doInit: function(component, event, helper) {
		component.set("v.buttonType", "button");
        component.set("v.iconName", "utility:pause");
    },
    handleClick: function(component, event, helper) {
        helper.handleClick(component);
        component.find("pauseButton").set("v.disabled", true);
    },
    handleButtonModification: function(component, event, helper) {
        if(event.getParams().button == 1) {
            component.find("pauseButton").set("v.disabled", event.getParams().disabled);
        }
    }
})