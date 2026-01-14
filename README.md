1. Overview

   This project implements a public application intake solution using Salesforce Experience Cloud, composed of:
      A public Lightning Web Component (LWC) for manual submissions
      A public Apex REST webhook for external system integrations
      A shared Apex service layer that centralizes business logic

   Depending on whether an existing Account is found, the application creates either:
      a Lead, or an Opportunity

3. Setup Instructions

   Apex Deployment
      Deploy the following Apex classes:
         ApplicationFormController
         ApplicationFormDTO
         ApplicationFormResult
         ApplicationFormWebhook
         ApplicationProcessingService
      Test classes:
         ApplicationFormControllerTest
         ApplicationFormWebhookTest

      Ensure the custom field Application_Source__c exists on:
         Lead
         Opportunity

      Ensure the custom field Federal_Tax_Id__c exists on:
         Account
         Lead

      Community Configuration
         Create or use an Experience Cloud site
         Enable public (guest) access
         Add the applicationForm LWC to a public page

      Grant Guest User access to:
         Apex classes
         Required objects and fields (Lead, Opportunity, Account)

      REST Endpoint
         The webhook is exposed publicly at:
            /services/apexrest/external/applications
         No authentication is required.

4. How It Works

      Community Form Flow
         User submits the public form
         LWC validates required fields
         Apex controller (ApplicationFormController) is invoked
         Data is passed to ApplicationProcessingService
            The service:
               Matches an existing Account
               Creates an Opportunity if found
               Otherwise creates a Lead
         A success or error message is returned to the UI
         All records created through the form are tagged with:
            Application_Source__c = 'Community'

      Webhook Flow
         Request Example:
            {
               "companyName": "Acme Corp",
               "federalTaxId": "123456789",
               "contact": {
                  "firstName": "José",
                  "lastName": "Silva",
                  "email": "email@email.com",
                  "phone": "+112233445566"
               },
               "annualRevenue": 500000
            }
         Processing
         The JSON body is parsed by ApplicationFormWebhook
         The Request is normalized into a Map<String, Object>
         The same ApplicationProcessingService is invoked
         Records are created following the same rules as the Community form
         Records created through the webhook are tagged with:
            Application_Source__c = 'Webhook'
         Response Example:
            {
               "success": true,
               "recordType": "Opportunity",
               "recordId": "006XXXXXXXXXXXX",
               "message": "Application processed successfully"
            }

6. Assumptions Made

   Guest access is allowed for both Community and Apex REST
   Matching logic prioritizes:
      Federal Tax ID
      Company Name
   Authentication and rate limiting are out of scope
   Attachments are not required
   Requests are processed one at a time (no bulk processing)

8. Testing

   Full test coverage is provided for:
      Community submissions
      Webhook submissions
      Lead and Opportunity creation
      Error scenarios
   No production data is accessed during tests

9. Architecture Highlights

   Single service layer for all business rules
   No duplicated logic
   Source tracking via Application_Source__c
   Guest-safe request handling using Map<String, Object>
