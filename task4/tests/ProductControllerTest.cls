@isTest
private class ProductControllerTest {

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
    static void testGetProductsReturnsActiveProducts() {
        Test.startTest();
        List<Product2> products = ProductController.getProducts();
        Test.stopTest();
        
        System.assertEquals(1, products.size(), 'one active product should be returned');
        System.assertEquals('test product', products[0].Name, 'product name should match');
    
        System.assertEquals(1, products[0].PricebookEntries.size(), 'product should have one PricebookEntry');
        System.assertEquals(100.00, products[0].PricebookEntries[0].UnitPrice, 'price should match');
        System.assertEquals('USD', products[0].PricebookEntries[0].CurrencyIsoCode, 'currency should match');
    }
}
