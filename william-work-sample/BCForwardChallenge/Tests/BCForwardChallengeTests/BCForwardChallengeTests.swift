import XCTest
@testable import BCForwardChallenge

class BCForwardChallengeTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPartitionsForPriceInCart() {
        let dl: Loadable = DataRequest(data: "Type,normal,Normal Price\nType,clearance,Clearance Price\nType,price_in_cart,Price In Cart\nProduct,59.99,39.98,10,true\nProduct,49.99,49.99,8,true\nProduct,79.99,29.98,5,true")
        let bl: Report = Report(dataRequest: dl)
        
        let products = dl.getProducts()
        let categories = bl.generateCategories()
        let expected: String = "Price In Cart: 3 products @ $29.98-$49.99\nClearance Price: 2 products @ $29.98-$39.98\nNormal Price: 1 product @ $49.99"
        
        let actual: String = bl.generateReport(products: products, categories: categories)
        
        let difference = zip(actual, expected).filter{ $0 != $1 }
        XCTAssertEqual(actual, expected, String(describing: difference))
    }
    
    func testFilterMissingData() {
        let dl: Loadable = DataRequest(data: "Type,normal,Normal Price\nType,clearance,Clearance Price\nType,price_in_cart,Price In Cart\nProduct,59.99,59.99,10,false\nProduct,49.99,49.99,8,false\nProduct,79.99,,5,false")
        let bl: Report = Report(dataRequest: dl)
        let products = dl.getProducts()
        let categories = bl.generateCategories()
        let expected: String = "Normal Price: 2 products @ $49.99-$59.99\nClearance Price: 0 products\nPrice In Cart: 0 products"
        
        let actual: String = bl.generateReport(products: products, categories: categories)
        
        XCTAssertEqual(actual, expected)
    }
    
    func testFilterLessThan3() {
        let dl: Loadable = DataRequest(data: "Type,normal,Normal Price\nType,clearance,Clearance Price\nType,price_in_cart,Price In Cart\nProduct,59.99,59.99,10,false\nProduct,49.99,49.99,2,false\nProduct,79.99,79.99,5,false")
        let bl: Report = Report(dataRequest: dl)
        let products = dl.getProducts()
        let categories = bl.generateCategories()
        let expected: String = "Normal Price: 2 products @ $59.99-$79.99\nClearance Price: 0 products\nPrice In Cart: 0 products"
        
        let actual: String = bl.generateReport(products: products, categories: categories)
        
        XCTAssertEqual(actual, expected)
    }
    
    func testOverallRequirement() {
        let dl: Loadable = DataRequest(data: "Type,normal,Normal Price\nType,clearance,Clearance Price\nType,price_in_cart,Price In Cart\nProduct,59.99,39.98,10,false\nProduct,49.99,49.99,8,false\nProduct,79.99,49.98,5,false")
        let bl: Report = Report(dataRequest: dl)
        
        let products = dl.getProducts()
        let categories = bl.generateCategories()
        let expected: String = "Clearance Price: 2 products @ $39.98-$49.98\nNormal Price: 1 product @ $49.99\nPrice In Cart: 0 products"
        
        let actual: String = bl.generateReport(products: products, categories: categories)
        
        let difference = zip(actual, expected).filter{ $0 != $1 }
        XCTAssertEqual(actual, expected, String(describing: difference))
    }
}
