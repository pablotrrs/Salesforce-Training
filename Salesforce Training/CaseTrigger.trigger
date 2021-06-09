trigger CaseTrigger on Case (
    before insert, after insert,
	after update
) {
	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
            CaseHelper.checkAmountOfCasesWithMuestrasTypeInCurrentMonth(System.Trigger.new); 
        }
    } 
    else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CaseHelper.associateTasksWithCases(System.Trigger.new);
        }
        else if(Trigger.isUpdate) {
            CaseHelper.updateResultadoField(System.Trigger.new);
        }
    }
}