public with sharing class EmailBatchNotifier implements Database.Batchable<SObject>, Database.Stateful {
    
    @TestVisible 
    private static Integer invocationCounter = 0;

    private List<Map<String, String>> emailDataList = new List<Map<String, String>>();

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
                Map<String, String> emailData = new Map<String, String>{
                    'email' => opp.Owner.Email,
                    'ownerName' => opp.Owner.Name,
                    'oppName' => opp.Name
                };
                emailDataList.add(emailData);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (Map<String, String> emailData : emailDataList) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{emailData.get('email')});
            email.setSubject('Opportunity is still in New stage');
            email.setPlainTextBody('Dear ' + emailData.get('ownerName') + 
                ', your opportunity "' + emailData.get('oppName') + '" is still in the New stage. Please take action.');
            emails.add(email);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
            invocationCounter = Limits.getEmailInvocations();
        }

        System.debug('Emails were sent');
    }
}
