import { LightningElement } from 'lwc';
import getProducts from '@salesforce/apex/ProductController.getProducts';

export default class CarList extends LightningElement {
    _products;
    _productsByLineup

    isModalOpen = false;
    selectedProduct;

    get products() {
        console.log(this._products);
        return this._products || [];
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

        this.selectedProduct = selectedLineup || null;

        if (this.selectedProduct) {
            this.isModalOpen = true;
        }
    }

    handleCloseModal() {
        this.isModalOpen = false;
        this.selectedProduct = null;
    }

    async connectedCallback() {
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
}
