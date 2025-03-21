@isTest
private class ProductControllerWithTranslationTest {
    @testSetup
    static void setupTestData() {
        Id stdPricebookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = stdPricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Product2 product = new Product2(
            Name = 'test product',
            Equipment__c = 'Base',
            IsActive = true
        );
        insert product;
        
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = stdPricebookId,
            Product2Id = product.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
    }
    
    @isTest
    static void testGetProductReturnsCorrectProduct() {
        Test.startTest();
        Id productId = [SELECT Id FROM Product2 LIMIT 1].Id;
        ApexPages.currentPage().getParameters().put('id', productId);
        
        ProductControllerWithTranslationSupport controller = new ProductControllerWithTranslationSupport();
        Product2 product = controller.getProduct();
        Test.stopTest();
        
        System.assertNotEquals(null, product, 'product should not be null');
        System.assertEquals('Base', product.Equipment__c, 'product equipment should match');
        
        System.assertEquals(1, product.PricebookEntries.size(), 'product should have one PricebookEntry');
        System.assertEquals(100.00, product.PricebookEntries[0].UnitPrice, 'price should match');
        System.assertEquals('USD', product.PricebookEntries[0].CurrencyIsoCode, 'currency should match');
    }
}