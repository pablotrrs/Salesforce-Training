({
    searchCharacter: function(component, event) {
        let action = component.get("c.getCharacterData");
        let idEvent = Number(event.getParams().numcharacter);
        action.setParams({
            id: idEvent
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let newContact = event.getParams().contact;
                let character = response.getReturnValue();
                this.updateAndReturnCharacter(component, idEvent, character);
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    updateAndReturnCharacter: function(component, numCharacter, character) {
        character.Numero_de_Personaje__c = numCharacter;
        let event = $A.get("e.c:returnContactEvent");
        event.setParams({
            contact: character
        });
        event.fire();
    },
    obtainCharactersCount: function(component) {
        let action = component.get("c.getCharactersCount");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let count = response.getReturnValue();
                let newEvent = $A.get("e.c:contactsItemUpdateEvent");
                newEvent.setParams({
                    count: count
                });
                newEvent.fire();
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    checkExistence: function(component, event) {
        let action = component.get("c.contactExists");
        action.setParams({
            characternumber: event.getParams().contact.Numero_de_Personaje__c
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() == true) {
                    let createEvent = $A.get("e.c:confirmDialogEvent");
                    createEvent.fire();
                }
                else {
                    this.createContact(component, event.getParams().contact);
                }
            }
        });
        $A.enqueueAction(action);
    },
    createContact: function(component, contact) {
        let action = component.get("c.saveContact");
        action.setParams({
            contact: JSON.stringify(contact)
        });
        if (contact.FirstName != null) {
            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let contacts = component.get("v.contacts");
                    contacts.push(response.getReturnValue());
                    component.set("v.contacts", contacts);
                    let event = $A.get("e.c:confirmCreationEvent");
                    event.fire();
                } else {
                    console.log("Failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
        }
    },
    updateContact: function(component, contact) {
        let action = component.get("c.saveContact");
        action.setParams({
            contact: JSON.stringify(contact)
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let updatedContact = response.getReturnValue();
                let contacts = component.get("v.contacts");
                let index = 0;
                for (let i = 0; i < contacts.length; i++) {
                    if (
                        contacts[i].Numero_de_Personaje__c ==
                        updatedContact.Numero_de_Personaje__c
                    ) {
                        index = i;
                    }
                }
                contacts[index] = updatedContact;
                component.set("v.contacts", contacts);
                let event = $A.get("e.c:confirmCreationEvent");
                event.fire();
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    loadContacts: function(component) {
        let action = component.get("c.getContacts");
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.contacts", response.getReturnValue());
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    }
});