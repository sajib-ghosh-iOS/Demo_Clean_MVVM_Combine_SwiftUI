//
//  ProductsCleanMVVMSanpshotTests.swift
//  ProductsCleanMVVMSanpshotTests
//
//  Created by Sajib Ghosh on 14/02/24.
//

import XCTest
import FBSnapshotTestCase
@testable import ProductsCleanMVVM
import SwiftUI
import Combine

final class ProductListSnapshotTests: FBSnapshotTestCase {
    
    let productListVM = ProductsListViewModelMock()
    
    lazy var productListVC : UIHostingController<ProductListView>? = {
        let productListView = ProductListView.create(with: ProductListViewModelWrapper(viewModel: productListVM))
        return UIHostingController(rootView: productListView)
    }()
    
    private enum ProductListViewModelError: String {
        case someError = "Some error"
    }
    
    let productPages: [ProductsPage] = {
        let page1 = ProductsPage(skip: 0, limit: 10, total: 100, products: [
            Product.stub(id: 1,title: "Product 1", description: "Prdouct 1 description",price: 100)])
        let page2 = ProductsPage(skip: 0, limit: 10, total: 100, products: [
            Product.stub(id: 2,title: "Product 2", description: "Prdouct 2 description",price: 200)])
        return [page1,page2]
    }()
    
    class ProductsListViewModelMock: ProductsListViewModel {
        
        var items: Box<[ProductItemViewModel]> = Box([])
        var loading: Box<Bool> = Box(false)
        var error: Box<String> = Box("")
        var isEmpty: Bool { return items.value.isEmpty }
        var screenTitle: String = "Products"
        var emptyDataTitle: String = "No results"
        var errorTitle: String = "Error"
        
        private var pages: [ProductsPage] = []
        
        func fetchProducts() -> Future<ProductsPage, Error> {
            return Future<ProductsPage,Error>{_ in }
        }
        
        func appendPage(_ productsPage: ProductsPage) {

            pages = pages
                .filter { $0.products != productsPage.products }
                + [productsPage]

            items.value = pages.products.map(ProductItemViewModel.init)
        }
        
    }
    
    override func setUp() {
        super.setUp()
        //recordMode = true
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = productListVC
        window.makeKeyAndVisible()
        productListVC?.view.frame = UIScreen.main.bounds
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        productListVC = nil
    }

    func testLaunch() {
        FBSnapshotVerifyViewController(productListVC!)
    }
    func test_LaunchFor_ProductView_Success() {
        productListVM.appendPage(productPages[0])
        FBSnapshotVerifyView(productListVC?.view ?? UIView())
    }
    func test_LaunchFor_ProductView_Failure() {
        productListVM.error.value = ProductListViewModelError.someError.rawValue
        FBSnapshotVerifyView(productListVC?.view ?? UIView())
    }
    func test_LaunchFor_ProductView_Empty() {
        productListVM.items.value = []
        FBSnapshotVerifyView(productListVC?.view ?? UIView())
    }
}
