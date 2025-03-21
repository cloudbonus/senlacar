import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import CURRENCY_CHANNEL from '@salesforce/messageChannel/CurrencyMessageChannel__c';

import CURRENCY_TITLE from '@salesforce/label/c.Currency_Title';
import SELECT_CURRENCY_OPTION from '@salesforce/label/c.Select_Currency_Option';
export default class CurrencySelector extends LightningElement {
    
    @wire(MessageContext)
    messageContext;

    labels = {
        CURRENCY_TITLE,
        SELECT_CURRENCY_OPTION
    };

    selectedCurrency = 'usd';

    currencyOptions = [
        { label: 'USD', value: 'usd' },
        { label: 'BYN', value: 'byn' }
    ];

    handleCurrencyChange(event) {
        this.selectedCurrency = event.detail.value;
        localStorage.setItem('selectedCurrency', this.selectedCurrency);
        this.publishCurrency();
    }

    publishCurrency() {
        const message = { currency: this.selectedCurrency };
        publish(this.messageContext, CURRENCY_CHANNEL, message);
    }

    connectedCallback() {
        const storedCurrency = localStorage.getItem('selectedCurrency');

        if (storedCurrency) {
            this.selectedCurrency = storedCurrency;
        }
        
        this.publishCurrency();
    }
}