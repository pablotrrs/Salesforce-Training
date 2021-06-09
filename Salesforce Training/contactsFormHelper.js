({
    checkNAFields: function(component, newContact) {
        let contactname = newContact.FirstName;
        let contactsurname = newContact.LastName;
        if (contactsurname == "S/A") {
            contactsurname = "";
        }
        if (contactname == undefined || contactname == null || contactname == "") {
            component.set("v.nonExistentCharacter", true);
        } else {
            component
            .find("charactername")
            .set("v.value", contactname + " " + contactsurname);
            component.set("v.newContact", newContact);
            let validCharacter = component
            .find("characterform")
            .reduce(function(validSoFar, inputCmp) {
                inputCmp.set("v.disabled", true);
                if (
                    inputCmp.get("v.value") == "n/a" ||
                    inputCmp.get("v.value") == "know"
                ) {
                    inputCmp.set("v.disabled", false);
                    inputCmp.set("v.value", "");
                }
                return validSoFar && true;
            }, true);
        }
    },
    searchCharacter: function(component, newContact, num_character) {
        let newEvent = component.getEvent("searchCharacter");
        newEvent.setParams({ numcharacter: num_character, contact: newContact });
        newEvent.fire();
    },
    checkExistence: function(component, newContact) {
        let createEvent = component.getEvent("checkExistence");
        createEvent.setParams({ contact: newContact });
        createEvent.fire(); 
    },
    fireConfirmEvent: function(component, updatedContact) {
        let createEvent = component.getEvent("updateContact");
        createEvent.setParams({ contact: updatedContact});
        createEvent.fire();
    }
});