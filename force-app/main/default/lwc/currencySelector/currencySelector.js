import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import CURRENCY_CHANNEL from '@salesforce/messageChannel/CurrencyMessageChannel__c';

export default class CurrencySelector extends LightningElement {
    
    @wire(MessageContext)
    messageContext;
    selectedCurrency = 'usd';
    currencyOptions = [
        { label: 'USD', value: 'usd' },
        { label: 'BYN', value: 'byn' }
    ];

    connectedCallback() {
        //const storedCurrency = localStorage.getItem('selectedCurrency');

        // if (storedCurrency) {
        //     this.selectedCurrency = storedCurrency;
        // }
        
        this.publishCurrency();
    }

    handleCurrencyChange(event) {
        this.selectedCurrency = event.detail.value;
        //localStorage.setItem('selectedCurrency', this.selectedCurrency);
        this.publishCurrency();
    }

    publishCurrency() {
        const message = { currency: this.selectedCurrency };
        publish(this.messageContext, CURRENCY_CHANNEL, message);
    }
}