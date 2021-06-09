({
    waitingTimeId: null,
    handleClick: function(component, event) {
        let firingComponent = event.getParams().component; 
        if (firingComponent == 'play') {
            this.setStartTimeOnUI(component);
			this.fireEvent(1, false);
        }
        else if (firingComponent == 'pause') {
            component.set("v.timeIsDisplayed",false);
            window.clearTimeout(this.waitingTimeId);
			this.fireEvent(0, false);
        }
        else if (firingComponent == 'stop') {
            component.set("v.timeIsDisplayed",false);
            component.set("v.time", "00:00:00");
            window.clearTimeout(this.waitingTimeId);
			this.fireEvent(0, false);
            this.fireEvent(1, true);
         }
    },
    setStartTimeOnUI : function(component) {      
        component.set("v.timeIsDisplayed", true);
        let time = component.get("v.time");
        let splitedTime = time.split(":");
        let date = new Date();
        date.setHours(splitedTime[0]);
        date.setMinutes(splitedTime[1]);
        date.setSeconds(splitedTime[2]);;
        
        let date2 = new Date(date.valueOf() + 1000);
        let temporal = date2.toTimeString().split(" ");
        let finaLTime = temporal[0].split(":");
        
        component.set("v.time", finaLTime[0] + ":" + finaLTime[1] + ":" + finaLTime[2]);
        this.waitingTimeId = setTimeout($A.getCallback(() => this.setStartTimeOnUI(component)), 1000);
    },
    fireEvent: function(buttonNumber, disable) {
        event = $A.get("e.c:modifyButtonVisibilityApplicationEvent");
        event.setParams({
            button: buttonNumber,
            disabled: disable
        });
        event.fire();
    }
})