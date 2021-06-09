public with sharing class LeadHelper {
	public static void findLeadsWithTheSameEmailAddress(List<Lead> leadsAProcesar, Map<ID, Lead> oldMap) {
        Map<String, Lead> leadByEmail = new Map<String, Lead>();
        for (Lead lead : leadsAProcesar) {
            if (emailIsChangingDuringAnUpdateAsADuplicate(oldMap, lead)) {
                if (newLeadIsADuplicate(leadByEmail, lead)) {
                    lead.Email.addError(System.Label.Another_Lead_Has_The_Same_Email_Address);
                } else {
                    leadByEmail.put(lead.Email, lead);
                }
            }
        }
        
        List<Lead> leads = [
            SELECT Email 
            FROM Lead 
            WHERE Email 
            IN :leadByEmail.KeySet()
        ];

        for(Lead lead : leads) {
            Lead newLead = leadByEmail.get(lead.Email);
            newLead.Email.addError(System.Label.Lead_Email_Already_Exists);
        }
    }

    private static Boolean emailIsChangingDuringAnUpdateAsADuplicate(Map<ID, Lead> oldMap, Lead lead) {
        return (lead.Email != null)
                && (System.Trigger.isInsert 
                    || (lead.Email != oldMap.get(lead.ID).Email));
    }

    private static Boolean newLeadIsADuplicate(Map<String, Lead> leadByEmail, Lead lead) {
        return leadByEmail.containsKey(lead.Email);
    }

    public static void createAssociatedTasks(List<Lead> leadsAProcesar) {
        List<Task> tasksToInsert = new List<Task>();
        for(Lead lead : leadsAProcesar) {
            Task task = new Task(
                Subject='Email', 
                WhoId=lead.Id, 
                Descripcion_Personalizada__c=lead.Descripcion_Personalizada__c,
                Texto_Auxiliar__c=lead.Texto_auxiliar__c,
                Creado_Con_Lead__c=true
            );
            tasksToInsert.add(task);
        }
        insert tasksToInsert;
    }

    public static void updateTaskFields(List<Lead> leadsAProcesar) {
        Map<ID, Lead> leadByID = new Map<ID, Lead>();
        for (Lead lead : leadsAProcesar) {
            leadByID.put(lead.ID, lead);
        }

        List<Task> tasks = [
            SELECT Descripcion_Personalizada__c, Texto_Auxiliar__c, Creado_Con_Lead__c, WhoId
            FROM Task 
            WHERE WhoId 
            IN :leadByID.keySet()
            AND Creado_Con_Lead__c = true
        ];

        for(Task task : tasks) {
            Lead lead = leadByID.get(task.WhoId);
            task.Descripcion_Personalizada__c = lead.Descripcion_Personalizada__c;
            task.Texto_Auxiliar__c = lead.Texto_Auxiliar__c;
        }
        update tasks;
    }
}