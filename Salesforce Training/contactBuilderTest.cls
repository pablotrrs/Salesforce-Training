@IsTest global class contactBuilderTest {
        @IsTest private static void sePuedeCrearUnContactConElBuilder() {
            Contact contact = Build.aContact()
                			.withFirstName('Juan')
                            .withLastName('Carlos')
                            .withAltura('180')
                            .withGenero('Masculino')
                            .withColordeCabello('Negro')
                            .withColordeojos('Verdes')
                            .withURL('https://www.google.com')
                            .withPlaneta('Marte')
                            .withNumerodePersonaje(3)
                        	.build();
            insert contact;

            System.assertEquals(contact.FirstName, 'Juan');
            System.assertEquals(contact.LastName, 'Carlos');
            System.assertEquals(contact.Altura__c, '180');
            System.assertEquals(contact.Genero__c, 'Masculino');
            System.assertEquals(contact.Color_de_cabello__c, 'Negro');
            System.assertEquals(contact.Color_de_ojos__c, 'Verdes');
            System.assertEquals(contact.URL__c, 'https://www.google.com');
            System.assertEquals(contact.Planeta__c, 'Marte');
            System.assertEquals(contact.Numero_de_Personaje__c, 3);
        }
}