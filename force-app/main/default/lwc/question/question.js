import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';

import CONTACT_OBJECT from '@salesforce/schema/Contact';
import CASE_OBJECT from '@salesforce/schema/Case';
import findContactsByEmailAndLastName from '@salesforce/apex/ContactController.findContactsByEmailAndLastName';

import questionTitle from '@salesforce/label/c.question';
import contactInformation from '@salesforce/label/c.contactInformation';
import firstName from '@salesforce/label/c.firstName';
import lastName from '@salesforce/label/c.lastName';
import caseInformation from '@salesforce/label/c.caseInformation';
import subject from '@salesforce/label/c.subject';
import description from '@salesforce/label/c.description';
import submit from '@salesforce/label/c.submit';

export default class Question extends LightningElement {
    
    label = {
        questionTitle,
        contactInformation,
        firstName,
        lastName,
        caseInformation,
        subject,
        description,
        submit
    };

    contact = {
        firstName: '',
        lastName: '',
        email: '',
    };

    case = {
        subject: '',
        description: ''
    };

    isLoading = false;

    handleFirstNameChange(event) {
        this.contact.firstName = event.target.value;
    }

    handleLastNameChange(event) {
        this.contact.lastName = event.target.value;
    }

    handleEmailChange(event) {
        this.contact.email = event.target.value;
    }

    handleSubjectChange(event) {
        this.case.subject = event.target.value;
    }

    handleDescriptionChange(event) {
        this.case.description = event.target.value;
    }

    async handleSubmit() {
        if (!this.validateForm()) {
            return;
        }

        this.isLoading = true;

        try {
            let contactId = await this.findExistingContact();

            if (!contactId) {
                contactId = await this.createContact();
            }

            await this.createCase(contactId);

            this.showToast('Success', 'Case Submitted Successfully', 'success');
            this.resetForm();
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    async findExistingContact() {
        try {
            const result = await findContactsByEmailAndLastName({
                email: this.contact.email,
                lastName: this.contact.lastName
            });

            if (result.length > 0) {
                return result[0].Id;
            }
            
            return null;
        } catch (error) {
            console.error('Error finding contact:', error);
            return null;
        }
    }

    async createContact() {
        const contactFields = {
            FirstName: this.contact.firstName,
            LastName: this.contact.lastName,
            Email: this.contact.email,
        };

        const contactRecord = { apiName: CONTACT_OBJECT.objectApiName, fields: contactFields };
        const result = await createRecord(contactRecord);
        return result.id;
    }

    async createCase(contactId) {
        const caseFields = {
            Subject: this.case.subject,
            Description: this.case.description,
            ContactId: contactId,
            Status: 'New',
            Origin: 'Web'
        };

        const caseRecord = { apiName: CASE_OBJECT.objectApiName, fields: caseFields };
        return createRecord(caseRecord);
    }

    validateForm() {
        const inputs = this.template.querySelectorAll('lightning-input, lightning-textarea');
        let isValid = true;

        inputs.forEach(input => {
            if (input.required && !input.value) {
                input.reportValidity();
                isValid = false;
            }
        });

        return isValid;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }

    resetForm() {
        this.contact = {
            firstName: '',
            lastName: '',
            email: '',
        };

        this.case = {
            subject: '',
            description: ''
        };

        this.template.querySelectorAll('lightning-input, lightning-textarea').forEach(input => {
            input.value = '';
        });
    }
}