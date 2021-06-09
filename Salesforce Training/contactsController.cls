public with sharing class contactsController {    
    @AuraEnabled
    public static Contact getCharacterData(Integer id){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://swapi.dev/api/people/' + id + '/');
        request.setMethod('GET');
		request.setHeader('Accept', 'application/json');
        HttpResponse response = http.send(request);
        
        Contact contact = new Contact();
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            
            String fullname = (String) results.get('name');
			List<String> fullnamesplitted = fullname.split(' ');
            Integer lenght = fullnamesplitted.size();
            String firstsNames = '';
            if (lenght == 1) {
                contact.FirstName = (String) results.get('name');
            }
            for (integer i = 0; i < fullnamesplitted.size() - 1; i++) {
                firstsNames += fullnamesplitted.get(i);
                if (i != fullnamesplitted.size() - 2) {
                    firstsNames += ' ';
                }
                contact.FirstName = firstsNames;
            }          
            if (lenght != 1) {
            	contact.LastName = fullnamesplitted.get(lenght - 1);    
            } else {
                contact.LastName = 'NL';    
            }
            
            contact.Altura__c = (String) results.get('height');
            contact.Genero__c = (String) results.get('gender');
            contact.Color_de_cabello__c = (String) results.get('hair_color');
            contact.Color_de_ojos__c = (String) results.get('eye_color');
            contact.URL__c = (String) results.get('url');
            contact.Planeta__c = (String) results.get('homeworld');
            contact.Numero_de_Personaje__c = id;
        }

        return contact;
    }
       
    @AuraEnabled
    public static Integer getCharactersCount(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://swapi.dev/api/people/');
        request.setMethod('GET');
		request.setHeader('Accept', 'application/json');
        HttpResponse response = http.send(request);
        Integer lenght = 0;
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            lenght = (Integer) results.get('count');
        }
        
        return lenght;
    }
    
    @AuraEnabled
    public static List<Contact> getContacts() {       
        return [
            SELECT Id, FirstName, LastName, Altura__c, Genero__c, Color_de_cabello__c,
                       Color_de_ojos__c, URL__c, Planeta__c, Numero_de_Personaje__c
            FROM Contact 
            WHERE Numero_de_Personaje__c != null];
    }
       
    @AuraEnabled
    public static Contact saveContact(String contact) {
        Contact newContact = (Contact) JSON.deserializeStrict(contact, Contact.class);
        List<Contact> savedContact = [
            SELECT Id, Name, Altura__c, Genero__c, Color_de_cabello__c,
                       Color_de_ojos__c, URL__c, Planeta__c, Numero_de_Personaje__c 
            FROM Contact  
            WHERE Numero_de_Personaje__c = :newContact.Numero_de_Personaje__c
        ];

        if (!savedContact.isEmpty()) {
            Contact oldContact = savedContact.get(0);
			newContact.Id = oldContact.Id;
         } 
         
    	upsert newContact;
        return newContact;    
    }
        
    @AuraEnabled
    public static boolean contactExists(Integer characterNumber) {
        List<Contact> savedContacts = [
            SELECT Numero_de_Personaje__c 
            FROM Contact  
            WHERE Numero_de_Personaje__c = :characterNumber];
		return savedContacts.size() != 0;
    }
}