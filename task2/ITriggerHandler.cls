public interface ITriggerHandler  {
    void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords); 
}