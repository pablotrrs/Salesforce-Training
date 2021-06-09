({
    handleClick: function(component) {
        let event = component.getEvent("notifyClick");
        event.setParams({
            component: 'pause'
        });        
        event.fire();        
    }
})