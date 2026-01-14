public with sharing class ApplicationProcessingService {
    public static ApplicationFormResult processApplication(Map<String, Object> input, String source) {
        ApplicationFormResult result = new ApplicationFormResult();

        String companyName = (String) input.get('companyName');
        String taxId       = (String) input.get('taxId');
        String firstName   = (String) input.get('firstName');
        String lastName    = (String) input.get('lastName');
        String email       = (String) input.get('email');
        String phone       = (String) input.get('phone');
        Decimal revenue;
        Object rawRevenue = input.get('annualRevenue');

        if (rawRevenue != null && String.valueOf(rawRevenue).trim() != '') {
            revenue = Decimal.valueOf(String.valueOf(rawRevenue));
        }

        if (String.isBlank(companyName)) {
            result.success = false;
            result.message = 'Company Name is required.';
            return result;
        }

        if (String.isBlank(lastName)) {
            result.success = false;
            result.message = 'Last Name is required.';
            return result;
        }

        Account acc = findMatchingAccount(companyName, taxId);

        if (acc != null) {
            Opportunity opp = new Opportunity(
                Name = companyName,
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Amount = revenue,
                Application_Source__c = source
            );
            insert opp;

            result.recordType = 'Opportunity';
            result.recordId = opp.Id;
        } else {
            Lead lead = new Lead(
                Company = companyName,
                FirstName = firstName,
                LastName = lastName,
                Email = email,
                Phone = phone,
                Federal_Tax_Id__c = taxId,
                Application_Source__c = source
            );
            insert lead;

            result.recordType = 'Lead';
            result.recordId = lead.Id;
        }

        result.success = true;
        result.message = 'Application processed successfully.';
        return result;
    }

    private static Account findMatchingAccount(String name, String taxId) {
        if (!String.isBlank(taxId)) {
            List<Account> byTax = [
                SELECT Id FROM Account
                WHERE Federal_Tax_Id__c = :taxId
                LIMIT 1
            ];
            if (!byTax.isEmpty()) return byTax[0];
        }

        List<Account> byName = [
            SELECT Id FROM Account
            WHERE Name = :name
            LIMIT 1
        ];
        return byName.isEmpty() ? null : byName[0];
    }
}
