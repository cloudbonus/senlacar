import { LightningElement, api } from 'lwc';

import close from '@salesforce/label/c.close'
import downloadPfd from '@salesforce/label/c.downloadPfd'
import price from '@salesforce/label/c.price'
import selectConfiguration from '@salesforce/label/c.selectConfiguration'
import configurationHint from '@salesforce/label/c.configurationHint'
import priceAbsence from '@salesforce/label/c.priceAbsence'
import lang from '@salesforce/i18n/lang'

export default class CarDetail extends LightningElement {
    label = {
        close,
        downloadPfd,
        price,
        configurationHint,
        priceAbsence,
        selectConfiguration
    };

    lang = lang;

    @api products;
    selectedEquipment = null;
    error;

    pdfString;

    get productTemplate() {
        return this.products?.[0];
    }

    get equipments() {
        return this.products?.map(prod => ({ label: prod.equipmentLabel, value: prod.Id }));
    }

    get selectedProduct() {
        return this.products?.find(prod => prod.Id === this.selectedEquipment) || this.productTemplate;
    }

    get selectedProductPrice() {
        return `${this.selectedProduct.PricebookEntries[0].UnitPrice} ${this.selectedProduct.PricebookEntries[0].CurrencyIsoCode}`;
    }

    get isPriceAvailable() {
        return this.selectedProduct?.PricebookEntries?.length > 0;
    }

    handleEquipmentChange(event) {
        this.selectedEquipment = event.detail.value;
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleDownloadPdf() {
        const productId = this.selectedProduct.Id;

        const communityBaseURL = 'https://senlacar-dev-ed.develop.lightning.force.com';
        const vfPageName = `apex/envelope?Id=${productId}&lang=${lang}`;
        const vfPageURL = `${communityBaseURL}/${vfPageName}`;

        window.open(vfPageURL);
    }
}
