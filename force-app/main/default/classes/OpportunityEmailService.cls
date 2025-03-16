public class OpportunityEmailService {
    public void sendEmail(Opportunity opp) {
        if (opp.ContactId != null) {
            
            Contact contact = [SELECT Id, Name, Email FROM Contact WHERE Id = :opp.ContactId LIMIT 1];
            
            if (contact.Email != null) {
                
                List<OpportunityLineItem> lineItems = [
                    SELECT PricebookEntry.Product2.Name
                    FROM OpportunityLineItem
                    WHERE OpportunityId = :opp.Id
                ];
                
                List<String> products = new List<String>();
                
                for (OpportunityLineItem item : lineItems) {
                    products.add(item.PricebookEntry.Product2.Name);
                }
                
                String subject = 'Congratulations on Your Purchase!';
                String body = 'Dear ' + contact.Name + ',\n\n' +
                    'Thank you for your purchase! Products:\n\n' + String.join(products, '\n') + 'We appreciate your business';
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { contact.Email });
                email.setSubject(subject);
                email.setPlainTextBody(body);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
        }
    }
}