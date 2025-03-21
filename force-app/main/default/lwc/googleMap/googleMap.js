import { LightningElement } from 'lwc';
import getAllAutocenters from '@salesforce/apex/AutocenterController.getAllAutocenters';

import SHOW_BUTTON from '@salesforce/label/c.Show_Button'
import SHOW_ALL_BUTTON from '@salesforce/label/c.Show_All_Button'
import AUTOCENTER_TYPE_OPTION from '@salesforce/label/c.Autocenter_Type_Option'
import CITY_TITLE from '@salesforce/label/c.City_Title'
import COUNTRY_TITLE from '@salesforce/label/c.Country_Title'
import SELECT_CITY_OPTION from '@salesforce/label/c.Select_City_Option'
import SELECT_COUNTRY_OPTION from '@salesforce/label/c.Select_Country_Option'
import DEALER_SERVICE_NETWORK from '@salesforce/label/c.Dealer_Service_Network'

export default class GoogleMap extends LightningElement {
    
    labels = {
        SHOW_BUTTON,
        SHOW_ALL_BUTTON,
        AUTOCENTER_TYPE_OPTION,
        CITY_TITLE,
        COUNTRY_TITLE,
        SELECT_CITY_OPTION,
        SELECT_COUNTRY_OPTION,
        DEALER_SERVICE_NETWORK
    }

    selectedCountry = null;
    selectedCity = null;
    selectedRecordType = 'all';

    _countries = [];
    _countryToCities = {};
    _markers = [];
    _allMarkers = [];
    _recordTypeOptions = [];

    get markers() {
        return this._markers;
    }

    get countries() {
        return this._countries;
    }

    get cities() {
        return this._countryToCities[this.selectedCountry] || [];
    }

    get recordTypeOptions() {
        return this._recordTypeOptions;
    }

    get isMarkersEmpty() {
        return this._markers.length > 0;
    }

    get isButtonDisabled() {
        return !this.selectedCountry;
    }

    handleCountry(event) {
        this.selectedCountry = event.detail.value;
        this.selectedCity = null;
    }

    handleCity(event) {
        this.selectedCity = event.detail.value;
    }

    handleRecordTypeChange(event) {
        this.selectedRecordType = event.detail.value;
    }

    handleShow() {
        this.filterMarkers();
    }

    async connectedCallback() {
        await this.fetchAllAutocenters();
    }

    async fetchAllAutocenters() {
        try {
            const fetchedData = await getAllAutocenters();

            const countriesSet = new Set();
            const recordTypeSet = new Set();
            const countryToCitiesMap = {};
            const markersList = [];

            fetchedData.forEach(row => {
                const address = row.Address__c;
                const recordTypeName = row.RecordType.Name;
                const recordTypeDeveloperName = row.RecordType.DeveloperName;
                const totalEmployees = row.Total_Employees__c;
                const description = row.Description__c;

                if (!address) return;

                const country = address.country;
                const city = address.city;

                countriesSet.add(JSON.stringify({ label: country, value: country }));
                recordTypeSet.add(JSON.stringify({ label: recordTypeName, value: recordTypeDeveloperName }));

                if (city) {
                    if (!countryToCitiesMap[country]) {
                        countryToCitiesMap[country] = new Set();
                    }
                    countryToCitiesMap[country].add(JSON.stringify({ label: city, value: city }));
                }

                markersList.push({
                    location: {
                        City: city,
                        Street: address.street,
                        Country: country,
                        PostalCode: address.postalCode
                    },
                    title: row.Name,
                    recordType: recordTypeDeveloperName,
                    description: `${description} Employees: ${totalEmployees}\n`
                });
            });

            this._countries = Array.from(countriesSet).map(item => JSON.parse(item));
            this._recordTypeOptions = [{ label: this.labels.SHOW_BUTTON, value: 'all' }, ...Array.from(recordTypeSet).map(item => JSON.parse(item))];

            for (let key in countryToCitiesMap) {
                countryToCitiesMap[key] = Array.from(countryToCitiesMap[key]).map(item => JSON.parse(item));
            }

            this._countryToCities = countryToCitiesMap;
            this._allMarkers = markersList;

        } catch (error) {
            console.error('Error fetching autocenters:', error);
        }
    }

    filterMarkers() {
        this._markers = this._allMarkers.filter(marker => {
            const countryMatch = marker.location.Country === this.selectedCountry;
            const cityMatch = this.selectedCity ? marker.location.City === this.selectedCity : true;
            const recordTypeMatch = this.selectedRecordType !== 'all' ? marker.recordType === this.selectedRecordType : true;
            return countryMatch && cityMatch && recordTypeMatch;
        });
    }
}
