public with sharing class ContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> findContactsByEmailAndLastName(String email, String lastName) {
        return [
            SELECT Id, FirstName, LastName, Email
            FROM Contact
            WHERE Email = :email AND LastName = :lastName 
            WITH SECURITY_ENFORCED
            LIMIT 1 
        ];
    }
}