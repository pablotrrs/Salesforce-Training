@IsTest public class LeadHelperTest {
    @testSetup static void methodName() {
        Lead lead = Build.aLead()
                    .withCompany('Company33')
                    .withLastName('LeadY')
                    .withEmail('emailtested@gmail.com')
                    .withStatus('Open - Not Contacted')
                    .build();
        insert lead;

        lead = Build.aLead()
                    .withCompany('Company1')
                    .withLastName('LeadX')
                    .withEmail('emailtest@gmail.com')
                    .withStatus('Open - Not Contacted')
                    .withDescripcionPersonalizada('A completar')
                    .withTextoAuxiliar('No hay ayuda')
                    .build();
        insert lead; 
    }
    @isTest static void leadInsertadoConExito() {
        Lead lead = Build.aLead()
                    .withCompany('Company1')
                    .withLastName('LeadX')
                    .withEmail('email@gmail.com')
                    .withStatus('Closed - Converted')
                    .build();
        
        Test.startTest();
        insert lead;
        Test.stopTest();

        List<Database.Error> errors = lead.getErrors();
        System.assertEquals(0, errors.size(), 'Hubo un error al intentar insertar el lead.');
    }

    @isTest static void leadActualizadoConExito() {
        Lead lead = [
            SELECT Id, Email
            FROM Lead
            WHERE LastName = 'LeadY'
            AND Company = 'Company33'
            LIMIT 1
        ];
        lead.Email = 'emailcambiado@gmail.com';

        Test.startTest();
        update lead;
        Test.stopTest();
    
        List<Database.Error> errors = lead.getErrors();
        System.assertEquals(0, errors.size(), 'Hubo un error al intentar actualizar el lead.');
    }

    @isTest static void leadConUnMismoMailEnLaBaseDeDatos() {
        Lead lead = Build.aLead()
                    .withCompany('Company26')
                    .withLastName('LeadZ')
                    .withEmail('emailtested@gmail.com')
                    .withStatus('Open - Not Contacted')
                    .build();
    
        Test.startTest();
        Database.SaveResult saveResult = Database.insert(lead, false);
        Test.stopTest();
        
        System.assertEquals(false, saveResult.isSuccess(), 'Se esperaba que el insert falle, pero no fallo.');
        System.assertEquals(System.Label.Lead_Email_Already_Exists, saveResult.getErrors()[0].getMessage(), 'No se obtuvo el mensaje de error esperado.');
    }

    @isTest static void bulkInsertandoLeadsConElMismoEmail() {
        List<Lead> leadsToInsert = new List<lead>();
        for (Integer i = 0; i < 5; i++) {
            Lead lead = Build.aLead()
                        .withCompany('Company ' + i)
                        .withLastName('Lead ' + i)
                        .withEmail('emailtested@gmail.com')
                        .withStatus('Open - Not Contacted')
                        .build();
            leadsToInsert.add(lead);
        }
    
        Test.startTest();
        DataBase.SaveResult[] saveResults = Database.insert(leadsToInsert, false);
        Test.stopTest();

        System.assertEquals(false, saveResults[0].isSuccess(), 'Se esperaba que el insert falle, pero no fallo.');
        System.assertEquals(System.Label.Lead_Email_Already_Exists, saveResults[0].getErrors()[0].getMessage(), 'No se obtuvo el mensaje de error esperado.');
    }

    @isTest static void bulkActualizandoLeadsConElMismoEmail() {
        List<Lead> leadsToInsert = new List<lead>();
        for (Integer i = 0; i < 5; i++) {
            Lead lead = Build.aLead()
                        .withCompany('Company ' + i)
                        .withLastName('Lead ' + i)
                        .withEmail('emailtest' + i + '@gmail.com')
                        .withStatus('Open - Not Contacted')
                        .build();
            leadsToInsert.add(lead);
        }
        insert leadsToInsert;

        List<Lead> leadsToUpdate = new List<lead>();
        leadsToInsert.get(0).Email = 'emailtested@gmail.com';
        leadsToInsert.get(1).Email = 'emailtested@gmail.com';

        leadsToUpdate.add(leadsToInsert.get(0));
        leadsToUpdate.add(leadsToInsert.get(1));
    
        Test.startTest();
        DataBase.SaveResult[] saveResults = Database.update(leadsToUpdate, false);
        Test.stopTest();

        System.assertEquals(false, saveResults[0].isSuccess(), 'Se esperaba que el insert falle, pero no fallo.');
        System.assertEquals(System.Label.Lead_Email_Already_Exists, saveResults[0].getErrors()[0].getMessage(), 'No se obtuvo el mensaje de error esperado.');
    }

    @isTest static void creacionDeLeadCreaUnaTareaAsociadaAlMismoConLosCamposDeTextoCopiadosDelLead() {
        Lead lead = Build.aLead()
                    .withCompany('Company1')
                    .withLastName('LeadX')
                    .withEmail('email@gmail.com')
                    .withStatus('Open - Not Contacted')
                    .withDescripcionPersonalizada('A completar')
                    .withTextoAuxiliar('No hay ayuda')
                    .build();

        Test.startTest();
        insert lead;    
        Test.stopTest();

        Task task = [
            SELECT Descripcion_Personalizada__c, Texto_Auxiliar__c, Creado_Con_Lead__c
            FROM Task
            WHERE WhoId =: lead.Id
            LIMIT 1
        ];

        System.assertEquals(lead.Descripcion_Personalizada__c, task.Descripcion_Personalizada__c, 'El campo Descripcion Personalizada de los objetos no coincide.');
        System.assertEquals(lead.Texto_Auxiliar__c, task.Texto_Auxiliar__c, 'El campo Texto Auxiliar de los objetos no coincide.');
        System.assertEquals(true, task.Creado_Con_Lead__c, 'La task no fue creada cuando se creo el Lead');
    }

    @isTest static void actualizacionDeLosCamposDelLeadCambiaTambienSolamenteLosDeLasTasksQueSeCreoConEl() {
        Lead lead = [
            SELECT Id, Descripcion_Personalizada__c, Texto_Auxiliar__c
            FROM Lead
            WHERE LastName = 'LeadX'
            AND Company = 'Company1'
            LIMIT 1
        ];

        Task taskInmutable = new Task(
                Subject = 'Email',
                WhoId = lead.Id,
                Descripcion_Personalizada__c = 'Esta descripcion no sera modificada',
                Texto_Auxiliar__c = 'Este texto auxiliar no sera modificado',
                Creado_Con_Lead__c = false
        );
        insert taskInmutable;

        lead.Descripcion_Personalizada__c = 'La descripcion fue cambiada';
        lead.Texto_Auxiliar__c = 'El texto auxiliar fue cambiado';

        Test.startTest();
        update lead;
        Test.stopTest();

        Task taskMutable = [
            SELECT Id, Descripcion_Personalizada__c, Texto_Auxiliar__c, Creado_Con_Lead__c
            FROM Task
            WHERE WhoId =: lead.Id
            LIMIT 1
        ];

        System.assertEquals('Esta descripcion no sera modificada', taskInmutable.Descripcion_Personalizada__c, 'Se modifico la descripcion de la task que no debia ser cambiada.');
        System.assertEquals('Este texto auxiliar no sera modificado', taskInmutable.Texto_Auxiliar__c, 'Se modifico el texto auxiliar de la task que no debia ser cambiada.');
        System.assertEquals(false, taskInmutable.Creado_Con_Lead__c, 'La task se creo junto al lead cuando no debia.');
        System.assertEquals(lead.Descripcion_Personalizada__c, taskMutable.Descripcion_Personalizada__c, 'No se modifico la descripcion de la task que si debia ser cambiada.');
        System.assertEquals(lead.Texto_Auxiliar__c, taskMutable.Texto_Auxiliar__c, 'No se modifico el texto auxiliar de la task que si debia ser cambiada.');
        System.assertEquals(true, taskMutable.Creado_Con_Lead__c, 'La task no se creo junto al lead cuando si debia.');
    }

    @isTest static void bulkActualizacionDeLosCamposDelLeadCambiaTambienSolamenteLosDeLasTasksQueSeJuntoConEl() {
        List<Lead> leads = new List<lead>();
        for (Integer i = 0; i < 5; i++) {
            Lead lead = Build.aLead()
                        .withCompany('Company ' + i)
                        .withLastName('Lead ' + i)
                        .withEmail('emailtest' + i + '@gmail.com')
                        .withStatus('Open - Not Contacted')
                        .build();
            leads.add(lead);
        }
        insert leads;
        
        List<Task> tasksInmutables = new List<Task>();
        for (Integer i = 0; i < 5; i++) {
            Task taskInmutable = new Task(
                Subject='Email',
                WhoId=leads.get(i).Id,
                Descripcion_Personalizada__c='Esta descripcion no sera modificada',
                Texto_Auxiliar__c='Este texto auxiliar no sera modificado',
                Creado_Con_Lead__c=false
            );
            tasksInmutables.add(taskInmutable);
        }
        insert tasksInmutables;

        List<Lead> leadsToUpdate = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            leads.get(i).Descripcion_Personalizada__c = 'La descripcion fue cambiada';
            leads.get(i).Texto_Auxiliar__c = 'El texto auxiliar fue cambiado';
            leadsToUpdate.add(leads.get(i));
        }

        Test.startTest();
        update leadsToUpdate;
        Test.stopTest();

        leads = [
            SELECT Id, Descripcion_Personalizada__c, Texto_Auxiliar__c
            FROM Lead
            WHERE LastName LIKE 'Lead '
            AND Company LIKE 'Company '
        ];

        Map<ID, Lead> leadByID = new Map<ID, Lead>();
        for (Lead lead : leads) {
            leadByID.put(lead.ID, lead);
        }
        
        List<Task> taskMutables = [
            SELECT Id, Descripcion_Personalizada__c, Texto_Auxiliar__c, Creado_Con_Lead__c, WhoId
            FROM Task
            WHERE WhoId IN :leadByID.keySet()
        ];

        for (Task taskInmutable : tasksInmutables) {
            System.assertEquals('Esta descripcion no sera modificada', taskInmutable.Descripcion_Personalizada__c, 'Se modifico la descripcion de la task que no debia ser cambiada.');
            System.assertEquals('Este texto auxiliar no sera modificado', taskInmutable.Texto_Auxiliar__c, 'Se modifico el texto auxiliar de la task que no debia ser cambiada.');
            System.assertEquals(false, taskInmutable.Creado_Con_Lead__c, 'La task se creo junto al lead cuando no debia.');         
        }

        for(Task taskMutable : taskMutables) {
            Lead lead = leadByID.get(taskMutable.WhoId);
            System.assertEquals(lead.Descripcion_Personalizada__c, taskMutable.Descripcion_Personalizada__c, 'No se modifico la descripcion de la task que si debia ser cambiada.');
            System.assertEquals(lead.Texto_Auxiliar__c, taskMutable.Texto_Auxiliar__c, 'No se modifico el texto auxiliar de la task que si debia ser cambiada.');
            System.assertEquals(true, taskMutable.Creado_Con_Lead__c, 'La task no se creo junto al lead cuando si debia.');
        }
    }
}