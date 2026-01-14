@IsTest
private class ApplicationFormControllerTest {
    @IsTest
    static void testSubmitApplication_createsLead() {
        Map<String, Object> input = new Map<String, Object>{
            'companyName'   => 'Test Company',
            'taxId'         => '123456',
            'firstName'     => 'John',
            'lastName'      => 'Doe',
            'email'         => 'email@email.com',
            'phone'         => '123456789',
            'annualRevenue' => 100000
        };

        Test.startTest();
        ApplicationFormResult result =
            ApplicationFormController.submitApplication(input);
        Test.stopTest();

        System.assertEquals(true, result.success);
        System.assertEquals('Lead', result.recordType);
        System.assertNotEquals(null, result.recordId);

        Lead l = [
            SELECT Company, Application_Source__c
            FROM Lead
            WHERE Id = :result.recordId
        ];
        System.assertEquals('Test Company LWC', l.Company);
        System.assertEquals('Community', l.Application_Source__c);
    }

    @IsTest
    static void testSubmitApplication_createsOpportunity() {
        Account acc = new Account(
            Name = 'Existing Account',
            Federal_Tax_Id__c = '456789'
        );
        insert acc;

        Map<String, Object> input = new Map<String, Object>{
            'companyName'   => 'Existing Account',
            'taxId'         => '456789',
            'firstName'     => 'Maria',
            'lastName'      => 'Silva',
            'email'         => 'email2@email.com',
            'phone'         => '11999999999',
            'annualRevenue' => 250000
        };

        // Act
        Test.startTest();
        ApplicationFormResult result =
            ApplicationFormController.submitApplication(input);
        Test.stopTest();

        // Assert
        System.assertEquals(true, result.success);
        System.assertEquals('Opportunity', result.recordType);
        System.assertNotEquals(null, result.recordId);

        Opportunity opp = [
            SELECT Name, Application_Source__c, AccountId
            FROM Opportunity
            WHERE Id = :result.recordId
        ];

        System.assertEquals('Controller Existing Account', opp.Name);
        System.assertEquals('Community', opp.Application_Source__c);
        System.assertEquals(acc.Id, opp.AccountId);
    }

    @IsTest
    static void testSubmitApplication_missingCompany() {
        Map<String, Object> input = new Map<String, Object>{
            'lastName' => 'Doe'
        };

        Test.startTest();
        ApplicationFormResult result =
            ApplicationFormController.submitApplication(input);
        Test.stopTest();

        System.assertEquals(false, result.success);
        System.assertEquals('Company Name is required.', result.message);
    }
}
