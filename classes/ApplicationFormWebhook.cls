@RestResource(urlMapping='/external/applications')
global with sharing class ApplicationFormWebhook {

    @HttpPost
    global static void handlePost() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        try {
            String body = RestContext.request.requestBody.toString();
            System.debug('### WEBHOOK RAW BODY: ' + body);

            WebhookRequest payload = (WebhookRequest) JSON.deserialize(body, WebhookRequest.class);

            Map<String, Object> input = new Map<String, Object>{
                'companyName'   => payload.companyName,
                'taxId'         => payload.federalTaxId,
                'firstName'     => payload.contact.firstName,
                'lastName'      => payload.contact.lastName,
                'email'         => payload.contact.email,
                'phone'         => payload.contact.phone,
                'annualRevenue' => payload.annualRevenue
            };

            ApplicationFormResult result =
                ApplicationProcessingService.processApplication(input, 'Webhook');

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(result));

        } catch (Exception e) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(
                JSON.serialize(new Map<String, Object>{
                    'success' => false,
                    'message' => e.getMessage()
                })
            );
        }
    }

    global class WebhookRequest {
        public String companyName;
        public String federalTaxId;
        public ContactWrapper contact;
        public Decimal annualRevenue;
    }

    global class ContactWrapper {
        public String firstName;
        public String lastName;
        public String email;
        public String phone;
    }
}
