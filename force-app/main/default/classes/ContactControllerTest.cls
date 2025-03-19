@isTest
private class ContactControllerTest {

    @testSetup
    static void setupTestData() {
        Contact testContact = new Contact(
            FirstName = 'john',
            LastName = 'doe',
            Email = 'johndoe@testorg.com'
        );
        insert testContact;
    }

    @isTest
    static void testFindContactsByEmailAndLastNameWhenRecordFound() {
        Test.startTest();
        List<Contact> contacts = ContactController.findContactsByEmailAndLastName('johndoe@testorg.com', 'doe');
        Test.stopTest();
        
        System.assertEquals(1, contacts.size(), 'one contact should be returned');
        System.assertEquals('john', contacts[0].FirstName, 'first name should match');
        System.assertEquals('doe', contacts[0].LastName, 'last name should match');
    }

    @isTest
    static void testFindContactsByEmailAndLastNameWhenRecordNotFound() {
        Test.startTest();
        List<Contact> contacts = ContactController.findContactsByEmailAndLastName('nonexistent@testorg.com', 'smith');
        Test.stopTest();
        
        System.assertEquals(0, contacts.size(), 'an empty list should be returned');
    }
}