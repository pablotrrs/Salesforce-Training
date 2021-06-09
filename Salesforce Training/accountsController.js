({
    loadAccounts : function(component, event, helper) {
        helper.loadCases(component, component.get("v.ID"));
    },
    onChange: function (component, event, helper) {
        let accounts = component.get("v.accounts");
        let ID;
        for (let i = 0; i < accounts.length; i++) {
            if (component.get("v.accounts")[i].Name == component.find('select').get('v.value')) {
                ID = accounts[i].Id;
            }
        }    
        helper.loadCases(component, ID);
    },
    saveCases: function(component, event, helper) {
        helper.saveCases(component, event);
    }
})