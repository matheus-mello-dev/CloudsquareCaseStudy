import { LightningElement } from 'lwc';
import submitApplication from '@salesforce/apex/ApplicationFormController.submitApplication';

export default class ApplicationForm extends LightningElement {
    form = {
        companyName: '',
        taxId: '',
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        annualRevenue: null
    };

    isLoading = false;
    resultMessage;
    resultClass;

    handleChange(event) {
        const field = event.target.name;
        const value = event.target.value;
        this.form[field] = value;
    }

    handleSubmit() {
        const inputs = this.template.querySelectorAll('lightning-input');
        const formSent = {};
        let valid = true;

        inputs.forEach(input => {
            formSent[input.name] = input.value;
            if (!input.checkValidity()) {
                input.reportValidity();
                valid = false;
            }
        });

        if (!valid) {
            return;
        }

        this.isLoading = true;
        this.resultMessage = null;

        submitApplication({
            input: JSON.parse(JSON.stringify(formSent))
        })
            .then(result => {
                if (result.success) {
                    this.showMessage(
                        `Success! Record created as ${result.recordType}. Record Id: ${result.recordId}`,
                        'success'
                    );
                    this.resetForm();
                } else {
                    this.showMessage(result.message, 'error');
                }
            })
            .catch(() => {
                this.showMessage('Unexpected system error.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    showMessage(message, type) {
        this.resultMessage = message;
        this.resultClass =
            type === 'success'
                ? 'slds-text-color_success slds-m-top_medium'
                : 'slds-text-color_error slds-m-top_medium';
    }

    resetForm() {
        this.form = {
            companyName: '',
            taxId: '',
            firstName: '',
            lastName: '',
            email: '',
            phone: '',
            annualRevenue: null
        };
    }
}
