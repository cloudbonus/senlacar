import { LightningElement, api } from 'lwc';

import findLeadsByEmailAndLastName from '@salesforce/apex/LeadController.findLeadsByEmailAndLastName';

import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import lang from '@salesforce/i18n/lang'

import CLOSE_BUTTON from '@salesforce/label/c.Close_Button'
import DOWNLOAD_PDF_BUTTON from '@salesforce/label/c.Download_Pdf_Button'
import PRICE_TITLE from '@salesforce/label/c.Price_Title'
import SELECT_CONFIG_OPTION from '@salesforce/label/c.Select_Config_Option'
import CONFIG_SELECT_PRICE_PROMPT from '@salesforce/label/c.Config_Select_Price_Prompt'
import PRICE_NOT_SPECIFIED from '@salesforce/label/c.Price_Not_Specified'
import FIRST_NAME_TITLE from '@salesforce/label/c.First_Name_Title';
import LAST_NAME_TITLE from '@salesforce/label/c.Last_Name_Title';
import COMPANY_WEBSITE_TITLE from '@salesforce/label/c.Company_Website_Title';
import COMPANY_OR_INDIVIDUAL_TYPE_OPTION from '@salesforce/label/c.Company_Or_Individual_Type_Option';
import COMPANY_NAME_TITLE from '@salesforce/label/c.Company_Name_Title';

export default class CarDetail extends LightningElement {

    @api products;
    @api currentCurrency;

    selectedEquipment = null;
    selectedType = 'Individual';

    showCompanyFields = false;
    showTestDriveForm = false;
    isLoading = false;

    companyOptions = [
        { label: 'Individual', value: 'Individual' },
        { label: 'Company', value: 'Company' }
    ];

    labels = {
        FIRST_NAME_TITLE,
        LAST_NAME_TITLE,
        CLOSE_BUTTON,
        DOWNLOAD_PDF_BUTTON,
        PRICE_TITLE,
        SELECT_CONFIG_OPTION,
        CONFIG_SELECT_PRICE_PROMPT,
        PRICE_NOT_SPECIFIED,
        COMPANY_WEBSITE_TITLE,
        COMPANY_OR_INDIVIDUAL_TYPE_OPTION,
        COMPANY_NAME_TITLE
    };

    lead = {
        firstName: '',
        lastName: '',
        company: '',
        website: '', 
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

    get isCompanySelected() {
        return this.selectedType === 'Company';
    }

    get selectedProductPrice() {
        if (this.currentCurrency === 'usd') {
            return `${this.selectedProduct.PricebookEntries[0].UnitPrice} ${this.selectedProduct.PricebookEntries[0].CurrencyIsoCode}`;
        } else {
            return `${this.selectedProduct.PricebookEntries[0].PriceByn__c}`;
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
        this.lead.firstName = event.target.value;
    }

    handleLastNameChange(event) {
        this.lead.lastName = event.target.value;
    }

    handleTypeChange(event) {
        this.selectedType = event.detail.value;
        this.showCompanyFields = event.detail.value === 'Company';
    }

    handleCompanyChange(event) {
        this.lead.company = event.target.value;
    }

    handleWebsiteChange(event) {
        this.lead.website = event.target.value;
    }

    handleEmailChange(event) {
        this.lead.email = event.target.value;
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
            let leadId = await this.findExistingLead();

            if (!leadId) {
                await this.createLead();
            }else{
                await this.updateLead(leadId);
            }

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

    async findExistingLead() {
        try {
            const result = await findLeadsByEmailAndLastName({
                email: this.lead.email,
                lastName: this.lead.lastName
            });

            if (result.length > 0) {
                return result[0].Id;
            }

            return null;
        } catch (error) {
            console.error('Error finding lead:', error);
            return null;
        }
    }

    async createLead() {
        const leadRecord = this.processDataBeforeOperation();
        return await createRecord(leadRecord);
    }

    async updateLead(leadId) {
        const leadRecord = this.processDataBeforeOperation(leadId);
        return await updateRecord(leadRecord);
    }

    processDataBeforeOperation(leadId = null) {
        const carModel = this.productTemplate.Lineup__c;

        const leadFields = {
            FirstName: this.lead.firstName,
            LastName: this.lead.lastName,
            Company: this.selectedType === 'Company' ? this.lead.company : 'Individual',
            Email: this.lead.email,
            Website: this.lead.website,
            LeadSource: 'Web',
            Description: `Test Drive Request for: ${carModel}`,
            Status: 'Open - Not Contacted',
        };

        if (leadId) {
            leadFields.Id = leadId;
            return { fields: leadFields };
        }

        return { apiName: LEAD_OBJECT.objectApiName, fields: leadFields };
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
        this.selectedType = 'Individual';
        this.showCompanyFields = false;
        this.lead = {
            firstName: '',
            lastName: '',
            company: '',
            website: '',
            email: ''
        };

        this.template.querySelectorAll('lightning-input').forEach(input => {
            input.value = '';
        });
    }
}
