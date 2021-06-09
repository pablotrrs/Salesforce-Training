public with sharing class CaseHelper {
    public static void associateTasksWithCases(List<Case> casosAProcesar) {
        List<Case> casos = new List<Case>();
        Set<ID> contactsIds = new Set<ID>();
        for(Case caso : casosAProcesar) {
            if (caso.ContactId != null) {
                casos.add(caso);
                contactsIds.add(caso.ContactId);
            }
        }

        List<Task> tasks = [
            SELECT Id, WhoId, WhatId, CreatedDate
            FROM Task
            WHERE WhoId IN :contactsIds
                AND WhatId = null
        ];

        Map<Id, List<Task>> tasksByContacts = new Map<Id, List<Task>>();
        for (Task task : tasks) {
            List<Task> contactTasks = new List<Task>();
            if (!tasksByContacts.containsKey(task.WhoId)) {
                contactTasks.add(task);
                tasksByContacts.put(task.WhoId, contactTasks);
            }
            else {
                contactTasks = tasksByContacts.get(task.WhoId);
                contactTasks.add(task);
                tasksByContacts.put(task.WhoId, contactTasks);
            }
        }

        List<Task> tasksToUpdate = new List<Task>();
        for (Case caso : casos) {
            for (Task task : tasksByContacts.get(caso.ContactId)) {
                if (wasTaskCreatedBetweenTheLastTwoMinutes(task, caso)) {
                    task.WhatId = caso.Id;
                    tasksToUpdate.add(task);
                }
            }
        }
        
        update tasksToUpdate;
    }

    private static Boolean wasTaskCreatedBetweenTheLastTwoMinutes(Task task, Case caso) {
        return caso.CreatedDate.minute() - task.CreatedDate.minute() <= 2;
    }

    public static void updateResultadoField(List<Case> casosAProcesar) {
        Set<ID> childCasesIds = new Set<ID>();
        List<Case> casos = new List<Case>();

        for(Case caso : casosAProcesar) {
            if(caso.Case__c != null) {
                casos.add(caso);
            }
        }

        for(Case caso : casos) {
            childCasesIds.add(caso.Case__c);
        }

        Map<ID, Case> childCasesByID = new Map<ID, Case>(
            [
                SELECT Id, Resultado__c
                FROM Case
                WHERE ID IN :childCasesIds
            ]
        );

        List<Case> casesToUpdate = new List<Case>();
        for(Case parentCase : casos) {
            Case childCase = childCasesByID.get(parentCase.Case__c);
            childCase.Resultado__c = parentCase.Resultado__c;
            casesToUpdate.add(childCase);
        }
        update casesToUpdate;
    }

    public static void checkAmountOfCasesWithMuestrasTypeInCurrentMonth(List<Case> casosAProcesar) {
        Set<ID> accountsIds = new Set<ID>();
        List<Case> casos = new List<Case>();

        for(Case caso : casosAProcesar) {
            if(caso.Type == 'Muestra') {
                casos.add(caso);
            }
        }
        for(Case caso : casos) {
            accountsIds.add(caso.AccountId);
        }

        Integer thisMonth = DateTime.now().month();
        Integer thisYear = DateTime.now().year();

        AggregateResult[] aggregateResult = [
            SELECT AccountId, COUNT(Id)
            FROM Case
            WHERE AccountId IN :accountsIds
            AND CALENDAR_MONTH(CreatedDate) = :thisMonth
            AND CALENDAR_YEAR(CreatedDate) = :thisYear
            GROUP BY AccountId  
            HAVING COUNT(Id) >= 2
        ];

        accountsIds = new Set<ID>();
        for (Integer i = 0; i < AggregateResult.size(); i++) {
            accountsIds.add((ID) AggregateResult.get(i).get('AccountId'));
        }

        Map<ID, List<Case>> casesByAccountID = new Map<ID, List<Case>>();
        for (Case caso : casos) {
            List<Case> casesValues = new List<Case>();
            if (casesByAccountID.containsKey(caso.AccountId)) {
                casesValues = casesByAccountID.get(caso.AccountId);
                casesValues.add(caso);
                casesByAccountID.put(caso.AccountId, casesValues);
            }
            else {
                casesValues.add(caso);
                casesByAccountID.put(caso.AccountId, casesValues);
            }
        }

        for (ID AccountId : casesByAccountID.keySet()) {
            Integer caseCounter = 0;
            for (Case caso : casesByAccountID.get(AccountId)) {
                if (accountsIds.contains(caso.AccountId)) {
                    caso.Status = 'Necesita aprobacion';
                }
                else if (!(accountsIds.contains(caso.AccountId))) {
                    if (caseCounter > 1) {
                        caso.Status = 'Necesita aprobacion';
                    }
                    caseCounter++;
                }
            }
        }
    }
}