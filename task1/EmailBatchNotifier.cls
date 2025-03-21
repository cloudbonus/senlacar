public with sharing class EmailBatchNotifier implements Database.Batchable<SObject>, Database.Stateful {

    private List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            select Id, Name, Owner.Email, Owner.Name 
            from Opportunity 
            where StageName = 'New' 
            and CreatedDate < LAST_N_DAYS:7
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        for (Opportunity opp : scope) {
            if (opp.Owner.Email != null) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{opp.Owner.Email});
                email.setSubject('Opportunity is still in New stage');
                email.setPlainTextBody('Dear ' + opp.Owner.Name + 
                    ', your opportunity "' + opp.Name + '" is still in the New stage. Please take action.');
                emails.add(email);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}
