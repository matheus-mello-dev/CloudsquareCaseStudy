public with sharing class ApplicationFormController {
    @AuraEnabled
    public static ApplicationFormResult submitApplication(
        Map<String, Object> input
    ) {
        return ApplicationProcessingService.processApplication(input, 'Community');
    }
}
