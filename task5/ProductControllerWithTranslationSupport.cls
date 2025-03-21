public with sharing class ProductControllerWithTranslationSupport {
    private final Product2 product;
    
    public ProductControllerWithTranslationSupport() {
        this.product = [SELECT Id, Lineup__c, toLabel(Equipment__c), toLabel(Description),
                   (SELECT UnitPrice, CurrencyIsoCode, PriceByn__c FROM PricebookEntries LIMIT 1) 
                   FROM Product2 
                   WHERE Id = :ApexPages.currentPage().getParameters().get('id')
                   WITH SECURITY_ENFORCED];
    }
    
    public Product2 getProduct() {
        return this.product;
    }
}