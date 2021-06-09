({
    searchCharacter: function(component, event, helper) {
        helper.searchCharacter(component, event);
    },
    obtainCharactersCount: function(component, event, helper) {
        helper.obtainCharactersCount(component);
    },
    loadContacts: function(component, event, helper) {
        helper.loadContacts(component);
    },
    checkExistence: function(component, event, helper) {
        helper.checkExistence(component, event);
    },
    createContact: function(component, event, helper) {
        helper.createContact(component, event.getParams().contact);
    },
    updateContact: function(component, event, helper) {
        helper.updateContact(component, event.getParams().contact);
    }
});