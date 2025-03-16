trigger OpportunityTrigger on Opportunity (after update) {
    List<Opportunity> closedWonOpps = new List<Opportunity>();
    
    for (Opportunity opp : Trigger.new) {
        if (opp.StageName == 'Closed Won' && Trigger.oldMap.get(opp.Id).StageName != 'Closed Won') {
            closedWonOpps.add(opp);
        }
    }
    
    for (Opportunity opp : closedWonOpps) {
        System.enqueueJob(new OpportunityEmailJob(opp));
    }
}