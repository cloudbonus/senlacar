public with sharing class ProductAmountBynBatchUpdate implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, AmountByn__c, ' +
            '(SELECT UnitPrice FROM PricebookEntries WHERE Pricebook2.IsStandard = true LIMIT 1) ' +
            'FROM Product2';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Product2> scope) {
        Decimal usdRate = fetchUsdRate();
        if (usdRate == null) {
            System.debug('Failed to retrieve USD exchange rate.');
            return;
        }
        
        List<Product2> productsToUpdate = new List<Product2>();

        for (Product2 product : scope) {
            if (!product.PricebookEntries.isEmpty()) {
                Decimal priceUsd = product.PricebookEntries[0].UnitPrice;
                product.AmountByn__c = priceUsd * usdRate;
                productsToUpdate.add(product);
            } else {
                System.debug('No standard PricebookEntry found for Product2 ID: ' + product.Id);
            }
        }
    
        if (!productsToUpdate.isEmpty()) {
            update productsToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch update completed.');
    }
    
    private Decimal fetchUsdRate() {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.nbrb.by/exrates/rates/USD?parammode=2');
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                return (Decimal) result.get('Cur_OfficialRate');
            }
        } catch (Exception e) {
            System.debug('Error fetching USD exchange rate: ' + e.getMessage());
        }
        return null;
    }
    
    // private Decimal getPriceFromPriceBook(Id productId) {
        //     List<PricebookEntry> pricebookEntries = [
        //     SELECT UnitPrice
        //     FROM PricebookEntry
        //     WHERE Product2Id = :productId
        //     AND Pricebook2.IsStandard = true
        //     LIMIT 1
        // ];
        
        //     if (!pricebookEntries.isEmpty()) {
            //         return pricebookEntries[0].UnitPrice;
        //     } else {
            //         System.debug('No PricebookEntry found for Product2 ID: ' + productId);
            //         return null;
        //     }
    // }
}