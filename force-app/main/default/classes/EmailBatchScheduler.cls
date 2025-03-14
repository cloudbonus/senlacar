public with sharing class EmailBatchScheduler implements Schedulable {

    public static String scheduler = '0 0 9 * * ?';  //Every Day at 9 AM 

    public static String scheduleMe() {
        EmailBatchScheduler emailBatchNotifier = new EmailBatchScheduler(); 
        return System.schedule('Custom email batch Job', scheduler, emailBatchNotifier);
    }

    public void execute(SchedulableContext sc) {
        EmailBatchNotifier emailBatchNotifier = new EmailBatchNotifier();
        Database.executeBatch(emailBatchNotifier);           
    }
}