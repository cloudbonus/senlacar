public with sharing class EmailBatchJob implements Schedulable {

    public static String scheduler = '0 0 9 * * ?';  //Every Day at 9 AM 

    public static String scheduleMe() {
        EmailBatchJob emailBatchJob = new EmailBatchJob(); 
        return System.schedule('Custom email batch Job', scheduler, emailBatchJob);
    }

    public void execute(SchedulableContext sc) {
        EmailBatchNotifier emailBatchNotifier = new EmailBatchNotifier();
        Database.executeBatch(emailBatchNotifier);           
    }
}