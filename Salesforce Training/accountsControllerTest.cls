@IsTest public class accountsControllerTest {
    @testSetup static void methodName() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account account = new Account(
                Name = 'Account ' + i 
            );
            accounts.add(account);
        }
        insert accounts;

        Account account = accounts.get(0);

        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            Case caso = new Case(
                AccountId = account.Id
            );
            cases.add(caso);
        }
        insert cases;
    }

    @IsTest private static void requestDelComponenteTraeATodasLasCuentas() {
        Test.startTest();
        List<Account> accountsFromQuery = [
            SELECT Id, Name
            FROM Account
        ];
        List<Account> accountsFromController = accountsController.getAccounts();
        Test.stopTest();

        System.assertEquals(accountsFromQuery, accountsFromController, 'Las cuentas traidas no son todas las que se ingresaron.');
    }

    @IsTest private static void alSeleccionarUnaCuentaSeTraenTodosLosCasosAsociadosAElla() {
        Account account = [
            SELECT Id, Name
            FROM Account
            WHERE Name = 'Account 0'
            LIMIT 1
        ];

        Test.startTest();
        List<Case> casesFromQuery = [
            SELECT Id, CaseNumber, CreatedDate, Closing_Reason__c, AccountId
            FROM Case
            WHERE AccountId = :account.Id
        ];
        List<Case> casesFromController = accountsController.getRelatedCases(account.Id);
        Test.stopTest();

        System.assertEquals(casesFromQuery, casesFromController, 'No se trajeron todos los casos relacionados a la cuenta.');
    }
    
    @IsTest private static void alApretarGuardar_LosCasosSeGuardanEnLaBaseDeDatosConLosMotivosDeCierreIndicados() {
        Account account = [
            SELECT Id, Name
            FROM Account
            WHERE Name = 'Account 0'
            LIMIT 1
        ];

        Test.startTest();
        List<Case> casesFromController = accountsController.getRelatedCases(account.Id);
        for (Integer i = 0; i < casesFromController.size(); i++) {
            casesFromController.get(i).Closing_Reason__c = 'Cierre por motivo ' + i;
        }
        casesFromController = accountsController.save(casesFromController);
        Test.stopTest();

        List<Case> casesFromQuery = [
            SELECT Id, CaseNumber, CreatedDate, Closing_Reason__c
            FROM Case
            WHERE AccountId = :account.Id
        ]; 

        System.assertEquals(casesFromQuery, casesFromController, 'No se actualizaron los casos con el nuevo motivo de cierre.');
    }
}