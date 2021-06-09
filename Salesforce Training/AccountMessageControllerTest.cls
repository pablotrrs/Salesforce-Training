@IsTest global class AccountMessageControllerTest {
    @testSetup static void methodName() {
        List<Account> accountsToInsert = new List<Account>();
    	for (Integer i = 0; i < 10; i++) {
    		Account account = new Account(Name = 'User'+i);
            accountsToInsert.add(account);
    	}
        insert accountsToInsert;
    }

    @isTest static void cuentasSonTraidas() {      
        Test.startTest();  
        AccountMessageController AccountMessageController = new AccountMessageController();
        Test.stopTest();
    	
    	List<Account> accounts = [
            SELECT Name, Id 
            FROM Account
        ];

    	System.assertEquals(0, AccountMessageController.selectedAccounts.size(), 'Hay alguna cuenta seleccionada.');
        System.assertEquals(accounts.size(), AccountMessageController.allAccounts.size(), 'No se insertaron todas las cuentas esperadas.');
    }

    @isTest static void cuentasSonSeleccionadasConExito() {
    	List<Account> accounts = [
            SELECT Id, Name
            FROM Account
            WHERE Name LIKE 'User%'
        ];
        
        Account account1 = accounts.get(0);
        Account account2 = accounts.get(1);
        Account account3 = accounts.get(2);

        Test.startTest();
        AccountMessageController AccountMessageController = new AccountMessageController();
        AccountMessageController.selectedAccounts.add(new SelectOption(account1.Id, account1.Name));
        AccountMessageController.selectedAccounts.add(new SelectOption(account2.Id, account2.Name));
        AccountMessageController.selectedAccounts.add(new SelectOption(account3.Id, account3.Name));
        AccountMessageController.save();
        Test.stopTest();

        String message = 'Saved Accounts: ' + account1.Name + ' (' + account1.Id + '), '
                            + account2.Name + ' (' + account2.Id + '), ' + account3.Name + ' (' + account3.Id + ').';

        System.assertEquals(3, AccountMessageController.selectedAccounts.size(), 'No se seleccionaron todas las cuentas esperadas.');
        System.assertEquals(message, AccountMessageController.message, 'El mensaje recibido no coincide con el esperado.');
    }

    @isTest static void mensajeEsInsertadoEnLasCuentas() {
    	Account account = [
            SELECT Id, Name
            FROM Account
            WHERE Name = 'User0'
            LIMIT 1
        ];

        Mensaje__c mensaje = new Mensaje__c(
            Name = 'Mensaje test'
        );

        Test.startTest();
        AccountMessageController AccountMessageController = new AccountMessageController();
        AccountMessageController.selectedAccounts.add(new SelectOption(account.Id, account.Name));
        AccountMessageController.mensaje = mensaje;
        AccountMessageController.save();
        Test.stopTest();

        Account_Message__c accountMessage = [
            SELECT Id, Account__c, Mensaje__c
            FROM Account_Message__c 
            LIMIT 1
        ];

        System.assertEquals(account.Id, accountMessage.Account__c, 'El mensaje no se relaciono con la cuenta esperada.');
        System.assertEquals(mensaje.Id, accountMessage.Mensaje__c, 'El mensaje no se relaciono con el mensaje esperado.');
        
        System.assertEquals('Saved Accounts: '+ account.Name +' (' + account.Id + ').', AccountMessageController.message
                            , 'El mensaje esperado no fue el recibido.');
        System.assertEquals('Mensaje test', AccountMessageController.mensaje.Name, 'El mensaje almacenado no es el ingresado.');
    }
}