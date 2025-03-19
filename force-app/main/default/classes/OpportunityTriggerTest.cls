@isTest
class OpportunityTriggerTest {
    
    @testSetup
    static void setupTestData() {
        String uniqueEmail = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        
        Contact testContact = new Contact(
            LastName = 'petrov',
            Email = uniqueEmail
        );
        insert testContact;

        Contact testContactNoEmail = new Contact(
            LastName = 'ivanov'
        );
        insert testContactNoEmail;

        Account testAccount = new Account(Name = 'test account');
        insert testAccount;

        Id pricebookId = Test.getStandardPricebookId();

        Product2 testProduct = new Product2(
            Name = 'test product',
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
            Name = 'test opportunity with contact',
            StageName = 'Proposal/Price Quote',
            CloseDate = Date.today(),
            AccountId = testAccount.Id,
            ContactId = testContact.Id,
            Pricebook2Id = pricebookId
        );
        insert testOpportunity;

        Opportunity testOpportunityNoEmail = new Opportunity(
            Name = 'test opportunity no email',
            StageName = 'Proposal/Price Quote',
            CloseDate = Date.today(),
            AccountId = testAccount.Id,
            ContactId = testContactNoEmail.Id,
            Pricebook2Id = pricebookId
        );
        insert testOpportunityNoEmail;

        Opportunity testOpportunityNoContact = new Opportunity(
            Name = 'test opportunity no contact',
            StageName = 'Proposal/Price Quote',
            CloseDate = Date.today(),
            AccountId = testAccount.Id,
            Pricebook2Id = pricebookId
        );
        insert testOpportunityNoContact;

        OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.00
        );
        insert testOpportunityLineItem;
    }

    @isTest
    static void testTriggerSendsEmail() {
        Opportunity testOpportunity = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Test Opportunity With Contact' LIMIT 1];

        Integer invocationCounter = 0;

        Test.startTest();
        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;
        invocationCounter = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocationCounter, 'expecting all emails to be sent');
    }

    @isTest
    static void testTriggerNoEmailSentWhenNoContact() {
        Opportunity testOpportunityNoContact = [SELECT Id, StageName FROM Opportunity WHERE Name = 'test opportunity no contact' LIMIT 1];

        Integer invocationCounter = 0;

        Test.startTest();
        testOpportunityNoContact.StageName = 'Closed Won';
        update testOpportunityNoContact;
        invocationCounter = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(0, invocationCounter, 'no email should be sent when there is no contact');
    }

    @isTest
    static void testTriggerNoEmailSentWhenContactHasNoEmail() {
        Opportunity testOpportunityNoEmail = [SELECT Id, StageName FROM Opportunity WHERE Name = 'test opportunity no email' LIMIT 1];

        Integer invocationCounter = 0;

        Test.startTest();
        testOpportunityNoEmail.StageName = 'Closed Won';
        update testOpportunityNoEmail;
        invocationCounter = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(0, invocationCounter, 'no email should be sent when contact has no email');
    }
}
