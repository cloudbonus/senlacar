import { LightningElement, api } from 'lwc';

import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LEAD_OBJECT from '@salesforce/schema/Lead';

import close from '@salesforce/label/c.close'
import downloadPfd from '@salesforce/label/c.downloadPfd'
import price from '@salesforce/label/c.price'
import selectConfiguration from '@salesforce/label/c.selectConfiguration'
import configurationHint from '@salesforce/label/c.configurationHint'
import priceAbsence from '@salesforce/label/c.priceAbsence'
import lang from '@salesforce/i18n/lang'

export default class CarDetail extends LightningElement {

    @api products;
    selectedEquipment = null;

    showTestDriveForm = false;
    isLoading = false;

    label = {
        close,
        downloadPfd,
        price,
        configurationHint,
        priceAbsence,
        selectConfiguration
    };

    lead = {
        firstName: '',
        lastName: '',
        company: 'Individual',
        email: ''
    };

    _lang = lang;

    get productTemplate() {
        return this.products?.length ? this.products[0] : null;
    }

    get equipments() {
        return this.products?.map(prod => ({ label: prod.equipmentLabel, value: prod.Id }));
    }

    get selectedProduct() {
        return this.products?.find(prod => prod.Id === this.selectedEquipment) || this.productTemplate;
    }

    get selectedProductPrice() {
        if (this.currentCurrency === 'usd') {
            return `${this.selectedProduct.PricebookEntries[0].UnitPrice} ${this.selectedProduct.PricebookEntries[0].CurrencyIsoCode}`;
        } else {
            return `${this.selectedProduct.PriceByn__c}`;
        }
    }

    get isPriceAvailable() {
        return this.selectedProduct?.PricebookEntries?.length > 0;
    }

    handleEquipmentChange(event) {
        this.selectedEquipment = event.detail.value;
    }

    handleDownloadPdf() {
        const productId = this.selectedProduct.Id;

        const communityBaseURL = 'https://senlacar-dev-ed.develop.lightning.force.com';
        const vfPageName = `apex/ProductPdf?Id=${productId}&lang=${this._lang}&currency=${this.currentCurrency}`;
        const vfPageURL = `${communityBaseURL}/${vfPageName}`;

        window.open(vfPageURL);
    }

    handleFirstNameChange(event) {
        this.firstName = event.target.value;
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
    }

    handleCompanyChange(event) {
        this.company = event.target.value;
    }

    handleEmailChange(event) {
        this.email = event.target.value;
    }

    handleTestDrive() {
        this.showTestDriveForm = true;
    }

    handleCancel() {
        this.showTestDriveForm = false;
        this.resetForm();
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    async handleSubmit() {
        if (!this.validateForm()) {
            return;
        }

        this.isLoading = true;

        try {

            await this.createLead();

            this.showTestDriveForm = false;

            this.showToast('Success', 'Request Submitted Successfully', 'success');
            this.resetForm();
        } catch (error) {
            this.showToast('Error', error.body.message, 'error');
        }
        finally {
            this.isLoading = false;
        }
    }

    async createLead() {
        const carModel = this.productTemplate.Lineup__c;

        const leadFields = {
            FirstName: this.lead.firstName,
            LastName: this.lead.lastName,
            Company: this.lead.company,
            Email: this.lead.email,
            LeadSource: 'Web',
            Description: `Test Drive Request for: ${carModel}`,
            Status: 'Open - Not Contacted'
        };

        const leadRecord = { apiName: LEAD_OBJECT.objectApiName, fields: leadFields };
        return await createRecord(leadRecord);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }

    validateForm() {
        const inputs = this.template.querySelectorAll('lightning-input');
        let isValid = true;

        inputs.forEach(input => {
            if (input.required && !input.value) {
                input.reportValidity();
                isValid = false;
            }
        });

        return isValid;
    }

    resetForm() {
        lead = {
            firstName: '',
            lastName: '',
            company: 'Individual',
            email: ''
        };

        this.template.querySelector('lightning-input').forEach(input => {
            input.value = '';
        });
    }
}
