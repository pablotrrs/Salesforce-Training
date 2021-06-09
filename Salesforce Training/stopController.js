({
    doInit: function(component, event, helper) {
		component.set("v.buttonType", "button");
        component.set("v.iconName", "utility:stop");
    },
    handleClick: function(component, event, helper) {
        helper.handleClick(component);
    }
})