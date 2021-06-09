trigger LeadTrigger on Lead (
    before insert, before update,
	after insert, after update 
) {
	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
            LeadHelper.findLeadsWithTheSameEmailAddress(System.Trigger.new, System.Trigger.oldMap);
        }
        else if (Trigger.isUpdate) {
            LeadHelper.findLeadsWithTheSameEmailAddress(System.Trigger.new, System.Trigger.oldMap);
        }
    } 
    else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            LeadHelper.createAssociatedTasks(System.Trigger.new);
        } 
        else if (Trigger.isUpdate) {
            LeadHelper.updateTaskFields(System.Trigger.new);
        }
    }
}