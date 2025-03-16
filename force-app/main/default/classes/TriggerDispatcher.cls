public with sharing class TriggerDispatcher {
    public static void dispatch(ITriggerHandler handler, TriggerOperation op, List<SObject> newRecords, List<SObject> oldRecords) {
        if (op == TriggerOperation.AFTER_UPDATE) {
            handler.afterUpdate(oldRecords, newRecords);
        }
    }
}