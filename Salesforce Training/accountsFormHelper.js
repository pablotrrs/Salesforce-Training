({
	saveCases : function(component, selectedCases, closingReasons) {
        for (let i = 0; i < closingReasons.length; i++) {
                selectedCases[i].Closing_Reason__c = closingReasons[i].get("v.value");
        }
        let event = component.getEvent("saveCases");
        event.setParams({
            cases: selectedCases
        });
        event.fire();
	}
})