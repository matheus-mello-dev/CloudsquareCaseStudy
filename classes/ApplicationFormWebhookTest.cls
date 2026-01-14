@IsTest
private class ApplicationFormWebhookTest {

    @IsTest
    static void testWebhook_createsLead() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/external/applications';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');

        req.requestBody = Blob.valueOf(
            '{' +
            '"companyName":"Webhook Company",' +
            '"federalTaxId":"321",' +
            '"contact":{' +
                '"firstName":"John",' +
                '"lastName":"Does",' +
                '"email":"email3@email.com",' +
                '"phone":"99999999"' +
            '},' +
            '"annualRevenue":500000' +
            '}'
        );

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ApplicationFormWebhook.handlePost();
        Test.stopTest();

        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"success":true'));
        System.assert(responseBody.contains('"recordType":"Lead"'));

        Lead l = [
            SELECT Application_Source__c
            FROM Lead
            WHERE Company = 'Webhook Company'
            LIMIT 1
        ];
        System.assertEquals('Webhook', l.Application_Source__c);
    }

        @IsTest
    static void testWebhook_createsOpportunity() {
        Account acc = new Account(
            Name = 'Existing Account',
            Federal_Tax_Id__c = '654321'
        );
        insert acc;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/external/applications';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');

        req.requestBody = Blob.valueOf(
            '{' +
            '"companyName":"Existing Account",' +
            '"federalTaxId":"654321",' +
            '"contact":{' +
                '"firstName":"Maria",' +
                '"lastName":"Santos",' +
                '"email":"email4@email.com",' +
                '"phone":"88888888"' +
            '},' +
            '"annualRevenue":750000' +
            '}'
        );

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ApplicationFormWebhook.handlePost();
        Test.stopTest();

        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"recordType":"Opportunity"'));

        Opportunity opp = [
            SELECT Application_Source__c
            FROM Opportunity
            WHERE AccountId = :acc.Id
            LIMIT 1
        ];
        System.assertEquals('Webhook', opp.Application_Source__c);
    }
}