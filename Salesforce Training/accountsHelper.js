({
    loadCases: function(component, ID){
        let action = component.get("c.getRelatedCases");
        action.setParams({
            accountID: ID
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let retrievedCases = response.getReturnValue();
                let event = $A.get("e.c:searchRelatedCasesApplicationEvent");
                event.setParams({
                    cases: retrievedCases
                });
                event.fire();
            } 
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);        
    },
    saveCases: function(component, event) {
        let action = component.get("c.save");
        action.setParams({
            cases: event.getParams().cases
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                this.showSuccessToast();
            } 
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);        
    },
    showSuccessToast : function(component, event, helper) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success!',
            message: 'The cases were updated successfully.',
            duration: '4000',
            key: 'info_alt',
            type: 'success',
            dismissible: 'pester'
        });
        toastEvent.fire();
    }
})