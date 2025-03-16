public with sharing class ProductAmountBynBatchJob implements Schedulable{
    public static String scheduler = '0 30 12 * * ?';  //Every Day at 12:10 PM 

    public static String scheduleMe() {
        ProductAmountBynBatchJob productAmountBynBatchJob = new ProductAmountBynBatchJob(); 
        return System.schedule('Custom product amount byn batch Job', scheduler, productAmountBynBatchJob);
    }

    public void execute(SchedulableContext sc) {
        ProductAmountBynBatchUpdate productAmountBynBatchUpdate = new ProductAmountBynBatchUpdate();
        Database.executeBatch(productAmountBynBatchUpdate);           
    }
}