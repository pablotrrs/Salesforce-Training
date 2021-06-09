@IsTest global class contactsControllerTest {
    @isTest static void seTraenLosDatosDelPersonajeDeSWAPI() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('getCharacter19Data');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Contact contact = Build.aContact()
                        .withFirstName('Jek Tono')
                        .withLastName('Porkins')
                        .withAltura('180')
                        .withGenero('male')
                        .withColordeCabello('brown')
                        .withColordeojos('blue')
                        .withURL('http://swapi.dev/api/people/19/')
                        .withPlaneta('http://swapi.dev/api/planets/26/')
                        .withNumerodePersonaje(19)
                        .build();
        
        Test.startTest();
        Contact controllerContact = contactsController.getCharacterData(19);
        
        System.assertEquals(contact.Altura__c, controllerContact.Altura__c);
        System.assertEquals(contact.Genero__c, controllerContact.Genero__c);
        System.assertEquals(contact.Color_de_cabello__c, controllerContact.Color_de_cabello__c);
        System.assertEquals(contact.Color_de_ojos__c, controllerContact.Color_de_ojos__c);
        System.assertEquals(contact.URL__c, controllerContact.URL__c);
        System.assertEquals(contact.Planeta__c, controllerContact.Planeta__c);
        System.assertEquals(contact.Numero_de_Personaje__c, controllerContact.Numero_de_Personaje__c);
        Test.stopTest();
    }
    
    @isTest static void seTraenLosDatosDelPersonajeDeSWAPI_VersionPersonajeSinApellido() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('getCharacter3Data');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Contact contact = Build.aContact()
                        .withFirstName('R2-D2')
                        .withLastName('NL')
                        .withAltura('96')
                        .withGenero('n/a')
                        .withColordeCabello('n/a')
                        .withColordeojos('red')
                        .withURL('http://swapi.dev/api/people/3/')
                        .withPlaneta('http://swapi.dev/api/planets/8/')
                        .withNumerodePersonaje(3)
                        .build();
        
        Test.startTest();
        Contact controllerContact = contactsController.getCharacterData(3);
        
        System.assertEquals(contact.Altura__c, controllerContact.Altura__c);
        System.assertEquals(contact.Genero__c, controllerContact.Genero__c);
        System.assertEquals(contact.Color_de_cabello__c, controllerContact.Color_de_cabello__c);
        System.assertEquals(contact.Color_de_ojos__c, controllerContact.Color_de_ojos__c);
        System.assertEquals(contact.URL__c, controllerContact.URL__c);
        System.assertEquals(contact.Planeta__c, controllerContact.Planeta__c);
        System.assertEquals(contact.Numero_de_Personaje__c, controllerContact.Numero_de_Personaje__c);
        Test.stopTest();
    }
    
    @isTest static void seTraeLaCantidadDePersonajesDisponiblesEnSWAPI() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('getCharactersCount');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);   
        
        Test.startTest();
        System.assertEquals(82, contactsController.getCharactersCount());
        Test.stopTest();
    }
    
    @isTest static void contactosSonTraidos() {
    	List<Contact> contactsToInsert = new List<Contact>();
    	for (Integer i = 0; i < 10; i++) {
            Contact contact = Build.aContact()
                			.withFirstName('Name' + i)
                            .withLastName('Lastname' + i)
                            .withAltura('1' + i)
                            .withGenero('Masculino')
                            .withColordeCabello('Negro')
                            .withColordeojos('Verdes')
                            .withURL('https://www.google.com')
                            .withPlaneta('Marte')
                            .withNumerodePersonaje(i)
                        	.build();
            contactsToInsert.add(contact);
    	}
        insert contactsToInsert;
        
        Test.startTest();
    	List<Contact> contacts = [
            SELECT Id, FirstName, LastName, Altura__c, Genero__c, Color_de_cabello__c,
                       Color_de_ojos__c, URL__c, Planeta__c, Numero_de_Personaje__c
            FROM Contact 
            WHERE Numero_de_Personaje__c != null 
        ];

        System.assertEquals(contacts, contactsController.getContacts());
        Test.stopTest();
    }
    
    @isTest static void contactoEsGuardadoEnLaBaseDeDatos() {
        Contact contact = Build.aContact()
                        .withFirstName('Juan')
                        .withLastName('Carlos')
                        .withAltura('180')
                        .withGenero('Masculino')
                        .withColordeCabello('Negro')
                        .withColordeojos('Verdes')
                        .withURL('https://www.google.com')
                        .withPlaneta('Marte')
                        .withNumerodePersonaje(1)
                        .build();
        
      	String serializedContact = JSON.serialize(contact);
        
        Test.startTest();
        Contact controllerContact = contactsController.saveContact(serializedContact);
        
        Contact queryContact = [
            SELECT Id, Name, Altura__c, Genero__c, Color_de_cabello__c,
                       Color_de_ojos__c, URL__c, Planeta__c, Numero_de_Personaje__c 
            FROM Contact  
            WHERE Numero_de_Personaje__c = :contact.Numero_de_Personaje__c
        ];
        
        System.assertEquals(queryContact.Id, controllerContact.Id);
        System.assertEquals(queryContact.Altura__c, controllerContact.Altura__c);
        System.assertEquals(queryContact.Genero__c, controllerContact.Genero__c);
        System.assertEquals(queryContact.Color_de_cabello__c, controllerContact.Color_de_cabello__c);
        System.assertEquals(queryContact.Color_de_ojos__c, controllerContact.Color_de_ojos__c);
        System.assertEquals(queryContact.URL__c, controllerContact.URL__c);
        System.assertEquals(queryContact.Planeta__c, controllerContact.Planeta__c);
        System.assertEquals(queryContact.Numero_de_Personaje__c, controllerContact.Numero_de_Personaje__c);
        Test.stopTest();
    }
    
        @isTest static void contactoGuardadoEsActualizadoEnLaBaseDeDatos() {
        Contact contact = Build.aContact()
                        .withFirstName('Juan')
                        .withLastName('Carlos')
                        .withAltura('180')
                        .withGenero('Masculino')
                        .withColordeCabello('Negro')
                        .withColordeojos('Verdes')
                        .withURL('https://www.google.com')
                        .withPlaneta('Marte')
                        .withNumerodePersonaje(1)
                        .build();
        insert contact;
            
        contact = Build.aContact()
                .withFirstName('Pedro')
                .withLastName('Diaz')
                .withAltura('180')
                .withGenero('Masculino')
                .withColordeCabello('Negro')
                .withColordeojos('Azules')
                .withURL('https://www.google.com')
                .withPlaneta('Marte')
                .withNumerodePersonaje(1)
                .build();
        
      	String serializedContact = JSON.serialize(contact);
        
        Test.startTest();
        Contact controllerContact = contactsController.saveContact(serializedContact);
        
        Contact queryContact = [
            SELECT Id, Name, Altura__c, Genero__c, Color_de_cabello__c,
                       Color_de_ojos__c, URL__c, Planeta__c, Numero_de_Personaje__c 
            FROM Contact  
            WHERE Numero_de_Personaje__c = :contact.Numero_de_Personaje__c
        ];
        
        System.assertEquals(queryContact.Id, controllerContact.Id);
        System.assertEquals(queryContact.Altura__c, controllerContact.Altura__c);
        System.assertEquals(queryContact.Genero__c, controllerContact.Genero__c);
        System.assertEquals(queryContact.Color_de_cabello__c, controllerContact.Color_de_cabello__c);
        System.assertEquals(queryContact.Color_de_ojos__c, controllerContact.Color_de_ojos__c);
        System.assertEquals(queryContact.URL__c, controllerContact.URL__c);
        System.assertEquals(queryContact.Planeta__c, controllerContact.Planeta__c);
        System.assertEquals(queryContact.Numero_de_Personaje__c, controllerContact.Numero_de_Personaje__c);
        Test.stopTest();
    }
    
    @isTest static void contactoYaExisteEnLaBaseDeDatos() {
        Contact contact = Build.aContact()
                        .withFirstName('Juan')
                        .withLastName('Carlos')
                        .withAltura('180')
                        .withGenero('Masculino')
                        .withColordeCabello('Negro')
                        .withColordeojos('Verdes')
                        .withURL('https://www.google.com')
                        .withPlaneta('Marte')
                        .withNumerodePersonaje(1)
                        .build();
 
        insert contact;
        
        Test.startTest();
        System.assertEquals(true, contactsController.contactExists(1));
        System.assertEquals(false, contactsController.contactExists(10000000));
        Test.stopTest();
    }
}