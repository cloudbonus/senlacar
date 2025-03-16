public class OpportunityEmailJob implements Queueable {
    private Opportunity opp;

    public OpportunityEmailJob(Opportunity opp) {
        this.opp = opp;
    }

    public void execute(QueueableContext context) {
        OpportunityEmailService emailService = new OpportunityEmailService();
        emailService.sendEmail(opp);
    }
}