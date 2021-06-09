public with sharing class AccountMessageController {
    public SelectOption[] selectedAccounts { get; set; }
    public SelectOption[] allAccounts { get; set; }
    
    public String message { get; set; }

    public Mensaje__c mensaje { get; set; }
    public String mensajeTexto { get; set; }
    
    public AccountMessageController() {
        selectedAccounts = new List<SelectOption>();
        
        List<Account> accounts = [
            SELECT Name, Id 
            FROM Account
        ];    
        allAccounts = new List<SelectOption>();
        for(Account c : accounts) {
            allAccounts.add(new SelectOption(c.Id, c.Name));
        }

        mensaje = new Mensaje__c();
    }

    public PageReference save() {
        upsert mensaje;
        List<Account_Message__c> accountsMessages = new List<Account_Message__c>();

        List<Account> accounts = new List<Account>();
        for (SelectOption selectedAccount : selectedAccounts) {
            Account account = new Account(
                                ID = selectedAccount.getValue(), 
                                Name=selectedAccount.getLabel()
            );
            accounts.add(account);
        }

        for (Account account : accounts) {
            Account_Message__c accountMessage = new Account_Message__c(
                                                Account__c = account.Id, 
                                                Mensaje__c = mensaje.Id
            );
            accountsMessages.add(accountMessage);
        }
        upsert accountsMessages;

        mensajeTexto = 'Message: ' + mensaje.Name;

        message = 'Saved Accounts: ';
        Boolean first = true;
        for (SelectOption selectedAccount : selectedAccounts) {
            if (!first) {
                message += ', ';
            }
            message += selectedAccount.getLabel() + ' (' + selectedAccount.getValue() + ')';
            first = false;
        }
        message += '.';
        
        return null;       
    }
}