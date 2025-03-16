trigger OpportunityTrigger on Opportunity (after update) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
    TriggerDispatcher.dispatch(handler, Trigger.operationType, Trigger.new, Trigger.old);
}
