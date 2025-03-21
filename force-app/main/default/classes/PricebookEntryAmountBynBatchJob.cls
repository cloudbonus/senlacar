public with sharing class PricebookEntryAmountBynBatchJob implements Schedulable{
    public static String scheduler = '0 10 12 * * ?';  //Every Day at 12:10 PM 

    public static String scheduleMe() {
        PricebookEntryAmountBynBatchJob pricebookEntryAmountBynBatchJob = new PricebookEntryAmountBynBatchJob(); 
        return System.schedule('Custom pricebook entry amount byn batch Job', scheduler, pricebookEntryAmountBynBatchJob);
    }

    public void execute(SchedulableContext sc) {
        PricebookEntryAmountBynBatchUpdate pricebookEntryAmountBynBatchUpdate = new PricebookEntryAmountBynBatchUpdate();
        Database.executeBatch(pricebookEntryAmountBynBatchUpdate);           
    }
} 