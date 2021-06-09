public with sharing class accountsController {
    @AuraEnabled
    public static List<Account> getAccounts() {
        List<Account> accounts = [
            SELECT Id, Name
            FROM Account 
        ];

        return accounts;
    }

    @AuraEnabled
    public static List<Case> getRelatedCases(ID accountID) { 
        List<Case> cases = [
            SELECT Id, CaseNumber, CreatedDate, Closing_Reason__c, AccountId
            FROM Case
            WHERE AccountId = :accountID
        ];

        return cases;
    }
    
    @AuraEnabled
    public static List<Case> save(List<Case> cases) { 
        upsert cases;
        cases = [
            SELECT Id, CaseNumber, CreatedDate, Closing_Reason__c
            FROM Case
            WHERE AccountId = :cases.get(0).AccountId
        ];

        return cases;
    }    
}