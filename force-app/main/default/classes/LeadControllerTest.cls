@isTest
private class LeadControllerTest {
   
    @testSetup
    static void setupTestData() {
        Lead testLead = new Lead(
            FirstName = 'jane',
            LastName = 'doe',
            Email = 'janedoe@testorg.com',
            Company = 'test company'
        );
        insert testLead;
    }

    @isTest
    static void testFindLeadsByEmailAndLastNameWhenRecordFound() {
        Test.startTest();
        List<Lead> leads = LeadController.findLeadsByEmailAndLastName('janedoe@testorg.com', 'doe');
        Test.stopTest();
        
        System.assertEquals(1, leads.size(), 'one lead should be returned');
    }

    @isTest
    static void testFindLeadsByEmailAndLastNameWhenRecordNotFound() {
        Test.startTest();
        List<Lead> leads = LeadController.findLeadsByEmailAndLastName('nonexistent@testorg.com', 'smith');
        Test.stopTest();
        
        System.assertEquals(0, leads.size(), 'an empty list should be returned');
    }
}