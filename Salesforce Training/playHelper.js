({
    handleClick: function(component) {
        let event = component.getEvent("notifyClick");
        event.setParams({
            component: 'play'
        });
        event.fire();        
    }
})