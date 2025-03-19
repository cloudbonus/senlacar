@isTest
private class AutocenterControllerTest {

    @IsTest
    static void testGetAllAutocentersWhenRecordsExist() {
        Autocenter__c testAutocenter = new Autocenter__c(
            Name = 'test autocenter',
            Description__c = 'test description'
        );
        insert testAutocenter;

        Test.startTest();
        List<Autocenter__c> result = AutocenterController.getAllAutocenters();
        Test.stopTest();

        System.assertEquals(1, result.size(), 'should return exactly one autocenter');
        
        Autocenter__c returnedAutocenter = result[0];

        System.assertEquals(testAutocenter.Name, returnedAutocenter.Name, 'name should match');
        System.assertEquals(testAutocenter.Description__c, returnedAutocenter.Description__c, 'description should match');
    }

    @IsTest
    static void testGetAllAutocentersWhenNoRecordsExist() {
        Test.startTest();
        List<Autocenter__c> result = AutocenterController.getAllAutocenters();
        Test.stopTest();

        System.assertEquals(0, result.size(), 'should return empty list when no autocenters exist');
    }
}