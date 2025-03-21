public with sharing class LeadController {
    @AuraEnabled(cacheable=true)
    public static List<Lead> findLeadsByEmailAndLastName(String email, String lastName) {
        return [
            SELECT Id 
            FROM Lead 
            WHERE Email = :email AND LastName = :lastName 
            WITH SECURITY_ENFORCED
            LIMIT 1 
        ];
    }
}