@isTest
class EmailBatchJobTest {
    
    @isTest static void testScheduleMe() {
        List<AsyncApexJob> jobsBefore = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob];
        System.assertEquals(0, jobsBefore.size(), 'not expecting any asyncjobs');
        
        Test.startTest();
        String jobId = EmailBatchJob.scheduleMe();
        Test.stopTest();
        
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals('EmailBatchJob', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');
    }
    
    @isTest
    static void testBatchExecution() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        
        Profile p = [select Id from Profile where Name='Standard User'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        List<Opportunity> testOpportunities = new List<Opportunity>();
        
        System.runAs(u) {
            for (Integer i = 0; i < 5; i++) {
                Opportunity opp = new Opportunity(
                    Name = 'test opportunity ' + i,
                    StageName = 'New',
                    CloseDate = Date.today().addDays(30),
                    OwnerId = u.Id
                );
                testOpportunities.add(opp);
            }
            insert testOpportunities;
            
            Datetime tenDaysAgo = Date.today().addDays(-10);
            
            for (Opportunity opp : testOpportunities) {
                Test.setCreatedDate(opp.Id, tenDaysAgo);
            }
        }

        Integer invocationCounter = 0;
        
        Test.startTest();
        EmailBatchNotifier batch = new EmailBatchNotifier();
        Database.executeBatch(batch);   
        invocationCounter = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assertEquals(1, invocationCounter, 'expecting all emails to be sent');
    }
}