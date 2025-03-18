import { LightningElement, wire } from 'lwc';
import getProducts from '@salesforce/apex/ProductController.getProducts';
import { subscribe, MessageContext } from 'lightning/messageService';

import CURRENCY_CHANNEL from '@salesforce/messageChannel/CurrencyMessageChannel__c';
export default class CarList extends LightningElement {
    
    @wire(MessageContext)
    messageContext;

    currentCurrency = 'usd';

    isModalOpen = false;
    selectedProduct = null;

    _products = [];
    _productsByLineup = {};

    get products() {
        return this._products;
    }

    handleOpenModal(event) {
        const productId = event.target.dataset.id;
        let selectedLineup = null;

        for (const lineup in this._productsByLineup) {
            if (this._productsByLineup[lineup].some(prod => prod.Id === productId)) {
                selectedLineup = this._productsByLineup[lineup];
                break;
            }
        }

        if (selectedLineup) {
            this.selectedProduct = selectedLineup;
            this.isModalOpen = true;
        }
    }

    handleCloseModal() {
        this.isModalOpen = false;
        this.selectedProduct = null;
    }

    async connectedCallback() {
        const storedCurrency = localStorage.getItem('selectedCurrency');

        if (storedCurrency) {
            this.currentCurrency = storedCurrency;
        }

        this.subscribeToMessageChannel();
        await this.fetchAllProducts();
    }

    async fetchAllProducts() {
        try {
            const productsByLineup = {};
            const baseProducts = [];
            const fetchedData = await getProducts();

            fetchedData.forEach(row => {
                const lineup = row.Lineup__c;
                const equipment = row.Equipment__c;


                if (!productsByLineup[lineup]) {
                    productsByLineup[lineup] = [];
                }

                productsByLineup[lineup].push(row);

                if (equipment === 'Base') {
                    baseProducts.push(row);
                }
            });

            this._products = baseProducts;
            this._productsByLineup = productsByLineup;
        } catch (error) {
            console.error('Error fetching products:', error);
        }
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            CURRENCY_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        this.currentCurrency = message.currency;
    }
}
