import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';

import CONTACT_OBJECT from '@salesforce/schema/Contact';
import CASE_OBJECT from '@salesforce/schema/Case';
import findContactsByEmailAndLastName from '@salesforce/apex/ContactController.findContactsByEmailAndLastName';

import CONTACT_QUESTION_TITLE from '@salesforce/label/c.Contact_Question_Title';
import CONTACT_INFO_TITLE from '@salesforce/label/c.Contact_Info_Title';
import FIRST_NAME_TITLE from '@salesforce/label/c.First_Name_Title';
import LAST_NAME_TITLE from '@salesforce/label/c.Last_Name_Title';
import CASE_INFO_TITLE from '@salesforce/label/c.Case_Info_Title';
import SUBJECT_TITLE from '@salesforce/label/c.Subject_Title';
import DESCRIPTION_TITLE from '@salesforce/label/c.Description_Title';
import SUBMIT_BUTTON from '@salesforce/label/c.Submit_Button';

export default class Question extends LightningElement {
    
    labels = {
        CONTACT_QUESTION_TITLE,
        CONTACT_INFO_TITLE,
        FIRST_NAME_TITLE,
        LAST_NAME_TITLE,
        CASE_INFO_TITLE,
        SUBJECT_TITLE,
        DESCRIPTION_TITLE,
        SUBMIT_BUTTON
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
                await this.createContact();
            }else{
                await this.updateContact(contactId);
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
        const contactRecord = this.processDataBeforeOperation();
        return await createRecord(contactRecord);
    }

    async updateContact(contactId) {
        const contactRecord = this.processDataBeforeOperation(contactId);
        return await updateRecord(contactRecord);
    }

    processDataBeforeOperation(contactId = null) {
        const contactFields = {
            FirstName: this.contact.firstName,
            LastName: this.contact.lastName,
            Email: this.contact.email,
        };

        if (contactId) {
            contactFields.Id = contactId;
            return { fields: contactFields };
        }

        return { apiName: CONTACT_OBJECT.objectApiName, fields: contactFields };
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