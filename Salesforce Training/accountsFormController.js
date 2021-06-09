({
    handleUpdateCases: function (component, event, helper) {
        let eventCases = event.getParams().cases;
        component.set("v.cases", eventCases);
        component.set("v.selectedCases", null);
        component.set('v.columns', [
            { label: 'Case Number', fieldName: 'CaseNumber', type: 'text' },
            { label: 'Date/Time Opened', fieldName: 'CreatedDate', type: 'Date' }
        ]);
    },
    closeCases: function (component, event, helper) {
        let selectedCases = component.find('casesTable').getSelectedRows();
        component.set("v.selectedCases", selectedCases);
    },
    saveCases: function (component, event, helper) {
        let validInput = true;
        let closingReasons = component.find('closingReason');
        let closingReasonsType = typeof component.find('closingReason').length;
        
        if (closingReasons === undefined) {
            return;
        }
        
        if(closingReasonsType == 'undefined') {
            validInput = closingReasons.get("v.validity").valid;
            closingReasons.showHelpMessageIfInvalid();
        }
        else if(closingReasonsType == 'number') {
            validInput = closingReasons
            .reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true);
        }
        if(validInput){
            let selectedCases = component.find('casesTable').getSelectedRows();
            helper.saveCases(component, selectedCases, closingReasons);
        }
    }
});