//
//  ProductListViewModelTests.swift
//  ProductsCleanMVVMTests
//
//  Created by Sajib Ghosh on 13/02/24.
//
import Combine
import XCTest
@testable import ProductsCleanMVVM

final class ProductListViewModelTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()
    
    private enum ProductListUseCaseError: Error {
        case someError
    }
    
    let productPages: [ProductsPage] = {
        let page1 = ProductsPage(skip: 0, limit: 10, total: 100, products: [
            Product.stub(id: 1,title: "Product 1", description: "Prdouct 1 description",price: 100)])
        let page2 = ProductsPage(skip: 0, limit: 10, total: 100, products: [
            Product.stub(id: 2,title: "Product 2", description: "Prdouct 2 description",price: 200)])
        return [page1,page2]
    }()
    
    class ProductsListUseCaseMock: ProductListUseCase {
        typealias ReturnType =  Future<ProductsPage,Error>
        var _returnData: ReturnType?
        var executeCallCount: Int = 0
        func execute(requestValue: ProductListUseCaseRequestValue) -> Future<ProductsPage, Error> {
            executeCallCount += 1
            return _returnData ?? Future<ProductsPage,Error>{_ in }
        }
    }
    
    func test_whenSearchProductsUseCaseRetrievesEmptyPage_thenViewModelIsEmpty() {
        // given
        let productsListUseCaseMock = ProductsListUseCaseMock()
        
        productsListUseCaseMock._returnData = Future<ProductsPage,Error> { promise in
            promise(.success(ProductsPage(skip: 0, limit: 0, total: 0, products: [])))
        }
        
        let viewModel = DefaultProductsListViewModel(productListUseCase: productsListUseCaseMock,mainQueue: DispatchQueueTypeMock())
        
        let expectation = expectation(description: "")
        // when
       viewModel.fetchProducts().sink { completion in
           expectation.fulfill()
        } receiveValue: { page in
        }.store(in: &cancellables)

        // then
        waitForExpectations(timeout: 5.0)
        XCTAssertTrue(viewModel.isEmpty)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
        
    }
    
    func test_whenSearchProductsUseCaseRetrievesFirstPage_thenViewModelContainsOnlyFirstPage() {
        // given
        let productsListUseCaseMock = ProductsListUseCaseMock()
        
        productsListUseCaseMock._returnData = Future<ProductsPage,Error> { promise in
            promise(.success(self.productPages[0]))
        }
        
        let viewModel = DefaultProductsListViewModel(productListUseCase: productsListUseCaseMock,mainQueue: DispatchQueueTypeMock())
        
        let expectation = expectation(description: "")
        
        // when
       viewModel.fetchProducts().sink { completion in
           expectation.fulfill()
        } receiveValue: { page in
        }.store(in: &cancellables)

        // then
        waitForExpectations(timeout: 5.0)
        let expectedItems = productPages[0]
            .products
            .map { ProductItemViewModel(product: $0) }
        XCTAssertEqual(viewModel.items.value, expectedItems)
        XCTAssertFalse(viewModel.isEmpty)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }
    
    func test_whenSearchProductsUseCaseRetrievesFirstAndSecondPage_thenViewModelContainsTwoPages() {
        let productsListUseCaseMock = ProductsListUseCaseMock()
        
        productsListUseCaseMock._returnData = Future<ProductsPage,Error> { promise in
            promise(.success(self.productPages[0]))
        }
        
        let viewModel = DefaultProductsListViewModel(productListUseCase: productsListUseCaseMock,mainQueue: DispatchQueueTypeMock())
        
        let expectation = expectation(description: "")
        
        // when
       viewModel.fetchProducts().sink { completion in
        } receiveValue: { page in
        }.store(in: &cancellables)
        
        productsListUseCaseMock._returnData = Future<ProductsPage,Error> { promise in
            promise(.success(self.productPages[1]))
        }
        
        // when
       viewModel.fetchProducts().sink { completion in
           expectation.fulfill()
        } receiveValue: { page in
        }.store(in: &cancellables)
        
        // then
        waitForExpectations(timeout: 5.0)
        let expectedItems = productPages
            .flatMap { $0.products }
            .map { ProductItemViewModel(product: $0) }
        XCTAssertEqual(viewModel.items.value, expectedItems)
        XCTAssertEqual(viewModel.items.value.count, 2)
        XCTAssertEqual(productsListUseCaseMock.executeCallCount, 2)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }
    
    func test_whenSearchProductsUseCaseReturnsError_thenViewModelContainsError() {
        // given
        let productsListUseCaseMock = ProductsListUseCaseMock()
        
        productsListUseCaseMock._returnData = Future<ProductsPage,Error> { promise in
            promise(.failure(ProductListUseCaseError.someError))
        }
        
        let viewModel = DefaultProductsListViewModel(productListUseCase: productsListUseCaseMock,mainQueue: DispatchQueueTypeMock())
        
        let expectation = expectation(description: "")
        
        // when
       viewModel.fetchProducts().sink { completion in
           expectation.fulfill()
        } receiveValue: { page in
        }.store(in: &cancellables)

        // then
        waitForExpectations(timeout: 5.0)
        XCTAssertNotNil(viewModel.error)
        XCTAssertTrue(viewModel.items.value.isEmpty)
        XCTAssertEqual(productsListUseCaseMock.executeCallCount, 1)
        addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) }
    }
}
