@isTest
private class ProductAmountBynBatchJobTest {
        
    private class ExchangeRateMock implements HttpCalloutMock {
        private Integer statusCode;
        
        public ExchangeRateMock(Integer statusCode) {
            this.statusCode = statusCode;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            if(statusCode == 200) {
                res.setBody('{"Cur_OfficialRate":2.5}');
            }
            return res;
        }
    }
    
    private class ExceptionMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Simulated exception');
        }
    }
    
    @TestSetup
    static void setup() {
        Id stdPricebookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = stdPricebookId,
            IsActive = true
        );
        
        update standardPricebook;
        
        Product2 product = new Product2(
            Name = 'Test Product',
            IsActive = true
        );
        
        insert product;
        
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = stdPricebookId,
            Product2Id = product.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        
        insert pbEntry;
        
    }
    
    
    @IsTest
    public static void testSchedule() {
        List<AsyncApexJob> jobsBefore = [SELECT Id, ApexClass.Name FROM AsyncApexJob];
        System.assertEquals(0, jobsBefore.size(), 'not expecting any asyncjobs');
        
        Test.startTest();
        String jobId = ProductAmountBynBatchJob.scheduleMe();
        Test.stopTest();
        
        List<AsyncApexJob> jobsScheduled = [SELECT Id, ApexClass.Name FROM AsyncApexJob WHERE JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('ProductAmountBynBatchJob', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');
    }
    
    
    @isTest
    static void testBatchWithValidRate() {
        Test.setMock(HttpCalloutMock.class, new ExchangeRateMock(200));
        
        Test.startTest();
        ProductAmountBynBatchUpdate batch = new ProductAmountBynBatchUpdate();
        Database.executeBatch(batch);
        Test.stopTest();
        
        Product2 updatedProd = [SELECT AmountByn__c FROM Product2 WHERE Name = 'Test Product'];
        System.assertNotEquals(null, updatedProd.AmountByn__c);
    }
    
    @isTest
    static void testBatchWithNullRate() {
        Test.setMock(HttpCalloutMock.class, new ExchangeRateMock(404));
        
        Test.startTest();
        ProductAmountBynBatchUpdate batch = new ProductAmountBynBatchUpdate();
        Database.executeBatch(batch);
        Test.stopTest();
        
        Product2 nonUpdatedProd = [SELECT AmountByn__c FROM Product2 WHERE Name = 'Test Product'];
        System.assertEquals(null, nonUpdatedProd.AmountByn__c);
    }
    
    @isTest
    static void testFetchRateException() {
        Test.setMock(HttpCalloutMock.class, new ExceptionMock());
        
        Test.startTest();
        ProductAmountBynBatchUpdate batch = new ProductAmountBynBatchUpdate();
        Database.executeBatch(batch);
        Test.stopTest();
        
        System.assertEquals(0, [SELECT COUNT() FROM Product2 WHERE AmountByn__c != null]);
    }
}