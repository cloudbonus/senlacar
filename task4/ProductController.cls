public with sharing class ProductController {
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {
        return [SELECT Id, Name, Image_Url__c, Lineup__c,
        toLabel(Equipment__c) equipmentLabel, Equipment__c, toLabel(Description), 
        (SELECT UnitPrice, CurrencyIsoCode, PriceByn__c FROM PricebookEntries LIMIT 1) 
        FROM Product2 
        WHERE IsActive = true 
        WITH SECURITY_ENFORCED];
    }
}