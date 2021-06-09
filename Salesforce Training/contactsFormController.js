({
    searchCharacter: function(component, event, helper) {
        let num_character = component.find("num_character").get("v.value");
        let validnumber =
            num_character != "" &&
            component.find("num_character").get("v.validity").valid == true;
        if (validnumber) {
            helper.searchCharacter(component, component.get("v.newContact"), num_character);
        }
    },
    handleUpdateContact: function(component, event, helper) {
        helper.checkNAFields(component, event.getParams().contact);
    },
    clickCreate: function(component, event, helper) {
        helper.checkExistence(component, component.get("v.newContact")); 
    },
    handleUpdateCount: function(component, event, helper) {
        component.find("num_character").set("v.max", event.getParams().count);
    },
    handleconfirmCreation: function(component, event, helper) {
        component.set("v.confirmCreation", true);
    },
    handleConfirmOk: function(component, helper) {
        component.set("v.confirmCreation", false);
        component.set("v.nonExistentCharacter", false);
    },
    handleConfirmDialog: function(component, event, helper) {
        component.set("v.confirmDialog", true);
    },
    handleConfirmDialogYes: function(component, event, helper) {
        component.set("v.confirmDialog", false);
        helper.fireConfirmEvent(component, component.get("v.newContact"));
    },
    handleConfirmDialogNo: function(component, helper) {
        component.set("v.confirmDialog", false);
    }
});