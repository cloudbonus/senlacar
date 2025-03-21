public with sharing class OpportunityTriggerHandler implements ITriggerHandler {
    public void afterUpdate(List<SObject> oldRecords, List<SObject> newRecords) {
        List<Opportunity> closedWonOpps = new List<Opportunity>();

        for (Integer i = 0; i < newRecords.size(); i++) {
            Opportunity oldOpp = (Opportunity) oldRecords[i];
            Opportunity newOpp = (Opportunity) newRecords[i];

            if (newOpp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won') {
                closedWonOpps.add(newOpp);
            }
        }

        if (!closedWonOpps.isEmpty()) {
            OpportunityEmailService.sendEmail(closedWonOpps);
        }
    }
}
