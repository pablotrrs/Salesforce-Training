@IsTest public class CaseHelperTest {
    @testSetup static void methodName() {
        Contact contacto = new Contact(
            LastName = 'Contacto 1'
        );
        insert contacto;

        insert new Task(
            Subject = 'Email',
            WhoId = contacto.Id
        );

        Case casoHijo = Build.aCase()
                        .withResultado('Todo')
                        .build();
        insert casoHijo;

        insert Build.aCase()
                    .withCase(casoHijo)
                    .withResultado('Todo')
                    .build();

        Account account1 = new Account(
                        Name = 'Account 1'
        );
        insert account1;

        List<Case> casesToInsert = new List<Case>();
        for(Integer i = 0; i < 2; i++) {
            Case caso = Build.aCase()
                        .withAccountId(account1.Id)
                        .withType('Muestra')
                        .withStatus('New')
                        .build();
            casesToInsert.add(caso);
        }
        insert casesToInsert;
    }

    @isTest static void taskSinNadaAsignadoYCreadaConUnaDiferenciaDeDosMinutosConElCasoSeAsignaAutomaticamenteAlMismo() {
        Contact contacto = [
            SELECT Id
            FROM Contact
            WHERE LastName = 'Contacto 1'
        ];

        Case caso = Build.aCase()
                    .withContactId(contacto.Id)
                    .build();

        Test.startTest();
        insert caso;
        Test.stopTest();
        
        Task task = [
            SELECT Id, Subject, WhoId, WhatId, CreatedDate
            FROM Task
            WHERE WhoId = :contacto.Id
            LIMIT 1
        ];

        System.assertEquals(task.whoId, contacto.Id, 'La task no se asigno al mismo contacto.');
        System.assertEquals(caso.contactId, contacto.Id, 'El caso no esta asignado al contacto.');
        System.assertEquals(task.WhatId, caso.Id, 'La task no se asigno al caso.');
    }

    @isTest static void taskSinNadaAsignadoYCreadaConUnaDiferenciaDeCuatroMinutosConElCasoNoSeAsignaNada() {
        Contact contacto = [
            SELECT Id
            FROM Contact
            WHERE LastName = 'Contacto 1'
        ];

        Task task = [
            SELECT Id, Subject, WhoId, WhatId, CreatedDate
            FROM Task
            WHERE Subject = 'Email'
                AND WhoId = :contacto.Id
            LIMIT 1
        ];

        DateTime now = DateTime.now().addMinutes(-4);
        Test.setCreatedDate(task.Id, now);

        Case caso = Build.aCase()
                    .withContactId(contacto.Id)
                    .build();

        Test.startTest();
        insert caso;
        Test.stopTest();

        task = [
            SELECT Id, Subject, WhoId, WhatId, CreatedDate
            FROM Task
            WHERE Subject = 'Email'
                AND WhoId = :contacto.Id
            LIMIT 1
        ];

        System.assertEquals(task.whoId, contacto.Id, 'La task no se asigno al mismo contacto.');
        System.assertEquals(caso.contactId, contacto.Id, 'El caso no esta asignado al contacto.');
        System.assertEquals(task.WhatId, null, 'La task tiene asignada algun caso.');
        System.assertEquals(task.CreatedDate, now, 'No se modifico el tiempo de creacion de la task.');
    }

    @isTest static void alActualizarElCampoResultadoDeUnCasoConAlgo_SiTieneUnCasoAsociadoConEl_SeTieneQueModificarElCampoResultadoDelSegundoConElValorQueTieneElPrimeroEnElMismoCampo() {
        Case casoHijo = [
            SELECT Id, Resultado__c
            FROM Case
            WHERE Resultado__c = 'Todo'
            LIMIT 1
        ];

        Case casoPadre = [
            SELECT Id, Resultado__c, Case__c
            FROM Case
            WHERE Case__c = :casoHijo.Id
        ];
        
        Test.startTest();
        casoPadre.Resultado__c = 'test1';
        update casoPadre;
        Test.stopTest();

        casoHijo = [
            SELECT Id, Resultado__c
            FROM Case
            WHERE Id = :casoHijo.Id
            LIMIT 1
        ];

        System.assertEquals(casoHijo.Resultado__c, casoPadre.Resultado__c, 'No se actualizo el campo resultado del caso asociado (hijo) con lo que contiene el padre.');
    }

    @isTest static void alDejarEnBlancoElCampoResultadoDeUnCaso_SiTieneUnCasoAsociadoConEl_SeTieneQueDejarEnBlancoElCampoResultadoDelSegundoTambien() {
        Case casoHijo = [
            SELECT Id, Resultado__c
            FROM Case
            WHERE Resultado__c = 'Todo'
            LIMIT 1
        ];

        Case casoPadre = [
            SELECT Id, Resultado__c, Case__c
            FROM Case
            WHERE Case__c = :casoHijo.Id
        ];
        
        Test.startTest();
        casoPadre.Resultado__c = 'null';
        update casoPadre;
        Test.stopTest();

        casoHijo = [
            SELECT Id, Resultado__c
            FROM Case
            WHERE Id = :casoHijo.Id
            LIMIT 1
        ];

        System.assertEquals(casoHijo.Resultado__c, casoPadre.Resultado__c, 'No se actualizo el campo resultado del caso asociado (hijo) con lo que contiene el padre.');
    }

    // Ejercicio 6
    @isTest static void siEnElMesUnClienteLevantoMasDeDosCasosDeTipoMuestras_ElTerceroYLosSiguientesDelMesSePasanAEstadoNecesitaAprobacion() {
        Account account1 = [
            SELECT Id, Name
            FROM Account
            WHERE Name = 'Account 1'
            LIMIT 1
        ];

        List<Case> casesToInsert = new List<Case>();
        for(Integer i = 0; i < 4; i++) {
            Case caso = Build.aCase()
                        .withAccountId(account1.Id)
                        .withType('Muestra')
                        .withStatus('New')
                        .build();
            casesToInsert.add(caso);
        }

        Test.startTest();
        insert casesToInsert;
        Test.stopTest();

        Integer thisMonth = DateTime.now().month();
        Integer thisYear = DateTime.now().year();

        List<Case> cases = [
            SELECT Id, AccountId, Type, Status
            FROM Case
            WHERE AccountId =: account1.Id
            AND CALENDAR_MONTH(CreatedDate) = :thisMonth 
            AND CALENDAR_YEAR(CreatedDate) = :thisYear
        ];

        List<Case> newCases = new List<Case>();
        List<Case> needApprovalCases = new List<Case>();
        for(Case caso : cases) {
            if (caso.Type == 'Muestra' && caso.Status == 'New') {
                newCases.add(caso);
            }
            else {
                needApprovalCases.add(caso);
            }
        }

        System.assertEquals(2, newCases.size(), 'No hay 2 casos de tipo Muestra con el estado New.');
        System.assertEquals(4, needApprovalCases.size(), 'No hay 4 casos de tipo Muestra con el estado Necesita Aprobacion.');
    }

    @isTest static void siEnElMesUnClienteLevantoMasDeDosCasosDeTipoMuestras_ElTerceroYLosSiguientesDelMesSePasanAEstadoNecesitaAprobacion_VersionCasosConDiferentesCuentas() {
        Account account1 = [
            SELECT Id, Name
            FROM Account
            WHERE Name = 'Account 1'
            LIMIT 1
        ];

        Account account2 = new Account(
            Name = 'Account 2'
        );
        insert account2;
        
        List<Case> casesToInsert = new List<Case>();
        for(Integer i = 0; i < 3; i++) {
            Case caso = Build.aCase()
                        .withAccountId(account2.Id)
                        .withType('Muestra')
                        .withStatus('New')
                        .build();
            casesToInsert.add(caso);
        }
        insert casesToInsert;

        casesToInsert = new List<Case>();
        for(Integer i = 0; i < 4; i++) {
            Case caso = Build.aCase()
                        .withAccountId(account1.Id)
                        .withType('Muestra')
                        .withStatus('New')
                        .build();
            casesToInsert.add(caso);
        }

        List<Case> casesToInsert2 = new List<Case>();
        for(Integer i = 0; i < 4; i++) {
            Case caso = Build.aCase()
                        .withAccountId(account2.Id)
                        .withType('Muestra')
                        .withStatus('New')
                        .build();
            casesToInsert2.add(caso);
        }

        Test.startTest();
        insert casesToInsert;
        insert casesToInsert2;
        Test.stopTest();

        Integer thisMonth = DateTime.now().month();
        Integer thisYear = DateTime.now().year();

        List<Case> cases = [
            SELECT Id, AccountId, Type, Status
            FROM Case
            WHERE AccountId =: account1.Id
            AND CALENDAR_MONTH(CreatedDate) = :thisMonth 
            AND CALENDAR_YEAR(CreatedDate) = :thisYear
        ];

        List<Case> cases2 = [
            SELECT Id, AccountId, Type, Status
            FROM Case
            WHERE AccountId =: account2.Id
            AND CALENDAR_MONTH(CreatedDate) = :thisMonth 
            AND CALENDAR_YEAR(CreatedDate) = :thisYear
        ];

        List<Case> newCases = new List<Case>();
        List<Case> needApprovalCases = new List<Case>();
        for(Case caso : cases) {
            if (caso.Type == 'Muestra' && caso.Status == 'New') {
                newCases.add(caso);
            }
            else {
                needApprovalCases.add(caso);
            }
        }

        System.assertEquals(2, newCases.size(), 'No hay 2 casos de tipo Muestra con el estado New.');
        System.assertEquals(4, needApprovalCases.size(), 'No hay 4 casos de tipo Muestra con el estado Necesita Aprobacion.');

        newCases = new List<Case>();
        needApprovalCases = new List<Case>();
        for(Case caso : cases2) {
            if (caso.Type == 'Muestra' && caso.Status == 'New') {
                newCases.add(caso);
            }
            else {
                needApprovalCases.add(caso);
            }
        }

        System.assertEquals(2, newCases.size(), 'No hay 2 casos de tipo Muestra con el estado New.');
        System.assertEquals(5, needApprovalCases.size(), 'No hay 4 casos de tipo Muestra con el estado Necesita Aprobacion.');
    }
}