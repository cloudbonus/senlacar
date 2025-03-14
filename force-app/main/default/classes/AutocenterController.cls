public with sharing class AutocenterController {
    
    @AuraEnabled(cacheable=true)
    public static List<Autocenter__c> getAllAutocenters(){
        return [
            SELECT Id, Name, Address__c, Total_Employees__c, Description__c, toLabel(RecordType.Name), RecordType.DeveloperName
            FROM Autocenter__c 
            WITH SECURITY_ENFORCED 
        ];
    }
}