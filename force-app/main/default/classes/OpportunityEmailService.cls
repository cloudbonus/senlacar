public with sharing class OpportunityEmailService {
    public static void sendEmail(List<Opportunity> opps) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        
        for (Opportunity opp : opps) {
            if (opp.ContactId != null) {
                contactIds.add(opp.ContactId);
                opportunityIds.add(opp.Id);
            }
        }
        
        if (contactIds.isEmpty()) {
            return;
        }
        
        Map<Id, Contact> contactsMap = new Map<Id, Contact>(
            [SELECT Id, Name, Email FROM Contact WHERE Id IN :contactIds]
            );
        
        Map<Id, List<String>> oppProductsMap = new Map<Id, List<String>>();
        
        for (OpportunityLineItem item : [
            SELECT OpportunityId, PricebookEntry.Product2.Name
            FROM OpportunityLineItem
            WHERE OpportunityId IN :opportunityIds
            WITH SECURITY_ENFORCED
        ]) {
            if (!oppProductsMap.containsKey(item.OpportunityId)) {
                oppProductsMap.put(item.OpportunityId, new List<String>());
            }
            oppProductsMap.get(item.OpportunityId).add(item.PricebookEntry.Product2.Name);
        }
        sendEmailsBatch(opps, contactsMap, oppProductsMap);
    }
    
    private static void sendEmailsBatch(
        List<Opportunity> opps,
    Map<Id, Contact> contactsMap,
    Map<Id, List<String>> oppProductsMap
    ) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Opportunity opp : opps) {
            Contact contact = contactsMap.get(opp.ContactId);
            if (contact == null || String.isEmpty(contact.Email)) {
                continue;
            }
            
            List<String> products = oppProductsMap.get(opp.Id);
            String productList = (products != null) ? String.join(products, '\n') : 'No products';
            
            String subject = 'Congratulations on Your Purchase!';
            String body = 'Dear ' + contact.Name + ',\n\n' +
                'Thank you for your purchase! Products:\n\n' + productList +
                '\n\nWe appreciate your business.';
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { contact.Email });
            email.setSubject(subject);
            email.setPlainTextBody(body);
            
            emails.add(email);
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}