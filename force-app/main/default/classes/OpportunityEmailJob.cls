public class OpportunityEmailJob implements Queueable {
    private List<Opportunity> opps;
    
    public OpportunityEmailJob(List<Opportunity> opps) {
        this.opps = opps;
    }
    
    public void execute(QueueableContext context) {
        OpportunityEmailService emailService = new OpportunityEmailService();
        for (Opportunity opp : opps) {
            emailService.sendEmail(opp);
        }
    }
}
