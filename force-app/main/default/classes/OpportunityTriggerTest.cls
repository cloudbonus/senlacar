@isTest
class OpportunityTriggerTest {
    
    @testSetup
    static void setupData() {
        String uniqueEmail = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        
        Contact testContact = new Contact(
            LastName = 'Petrov',
            Email = uniqueEmail
        );
        insert testContact;

        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        Id pricebookId = Test.getStandardPricebookId();

        Product2 testProduct = new Product2(
            Name = 'Test Product',
            IsActive = true
        );
        insert testProduct;

        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert testPricebookEntry;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity with Product',
            StageName = 'Proposal/Price Quote',
            CloseDate = Date.today(),
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            Pricebook2Id = pricebookId
        );
        insert testOpportunity;

        OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.00
        );
        insert testOpportunityLineItem;
    }
    
    @isTest
    static void testTriggerEnqueuesJob() {
        Opportunity testOpportunity = [select StageName from Opportunity where Name = 'Test Opportunity with Product' limit 1];
        
        Test.startTest();
        
        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;
        
        Test.stopTest();
        
        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status FROM AsyncApexJob WHERE JobType = 'Queueable' LIMIT 1];
        System.assert(!jobs.isEmpty(), 'expecting an asynchronous job to be enqueued');
        System.assertEquals('Completed', jobs[0].Status, 'expecting the job to complete successfully.');
    }
}