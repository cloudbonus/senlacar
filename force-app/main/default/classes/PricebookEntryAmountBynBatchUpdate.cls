public with sharing class PricebookEntryAmountBynBatchUpdate implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, UnitPrice, AmountByn__c ' +
                       'FROM PricebookEntry ' +
                       'WHERE IsActive = true ' +
                       'AND Product2.IsActive = true';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<PricebookEntry> scope) {
        Decimal usdRate = fetchUsdRate();
        if (usdRate == null) {
            System.debug('Failed to retrieve USD exchange rate.');
            return;
        }
        
        List<PricebookEntry> entriesToUpdate = new List<PricebookEntry>();

        for (PricebookEntry entry : scope) {
            Decimal priceUsd = entry.UnitPrice;
            entry.AmountByn__c = priceUsd * usdRate;
            entriesToUpdate.add(entry);
        }
    
        if (!entriesToUpdate.isEmpty()) {
            update entriesToUpdate;
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
}
