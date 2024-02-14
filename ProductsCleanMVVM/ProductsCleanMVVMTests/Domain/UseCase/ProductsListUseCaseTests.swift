//
//  ProductsListUseCaseTests.swift
//  ProductsCleanMVVMTests
//
//  Created by Sajib Ghosh on 14/02/24.
//

import Combine
import XCTest
@testable import ProductsCleanMVVM

final class ProductsListUseCaseTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()
    var executeCallCount: Int = 0
    
    let productPages: [ProductsPage] = {
        let page1 = ProductsPage(skip: 0, limit: 10, total: 100, products: [
            Product.stub(id: 1,title: "Product 1", description: "Prdouct 1 description",price: 100)])
        let page2 = ProductsPage(skip: 0, limit: 10, total: 100, products: [
            Product.stub(id: 2,title: "Product 2", description: "Prdouct 2 description",price: 200)])
        return [page1,page2]
    }()
    
    enum ProductsRepositorySuccessTestError: Error {
        case failedFetching
    }
    
    class ProductsRepositoryMock: ProductsRepository {
        typealias ReturnType =  Future<ProductsPage,Error>
        var _returnData: ReturnType?
        var fetchCompletionCallsCount = 0
        func fetchProductsList(skip: Int, limit: Int) -> Future<ProductsPage, Error> {
            fetchCompletionCallsCount += 1
            return _returnData ?? Future<ProductsPage,Error>{_ in }
        }
    }
    
    func testProductsListUseCase_whenSuccessfullyFetchesProductsList(){
        // given
        var useCaseCompletionCallsCount = 0
        let productsRepositoryMock = ProductsRepositoryMock()
        productsRepositoryMock._returnData = Future<ProductsPage,Error> { promise in
            promise(.success(self.productPages[0]))
        }
        let useCase = DefaultProductListUseCase(productsRepository: productsRepositoryMock)
        // when
        let expectation = expectation(description: "")
        useCase.execute(requestValue: ProductListUseCaseRequestValue(skip: 0, limit: 1))
        .sink { completion in
            useCaseCompletionCallsCount += 1
            expectation.fulfill()
         } receiveValue: { page in
         }.store(in: &cancellables)

        // then
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(useCaseCompletionCallsCount, 1)
        XCTAssertEqual(productsRepositoryMock.fetchCompletionCallsCount, 1)
    }
    
    func testProductsListUseCase_whenFailedFetchingProductsList(){
        // given
        var useCaseCompletionCallsCount = 0
        let productsRepositoryMock = ProductsRepositoryMock()
        productsRepositoryMock._returnData = Future<ProductsPage,Error> { promise in
            promise(.failure(ProductsRepositorySuccessTestError.failedFetching))
        }
        let useCase = DefaultProductListUseCase(productsRepository: productsRepositoryMock)
        // when
        let expectation = expectation(description: "")
        var fetchedError: Error?
        useCase.execute(requestValue: ProductListUseCaseRequestValue(skip: 0, limit: 1))
        .sink { completion in
            useCaseCompletionCallsCount += 1
            if case let .failure(error) = completion {
                fetchedError = error
            }
            expectation.fulfill()
         } receiveValue: { page in
         }.store(in: &cancellables)

        // then
        waitForExpectations(timeout: 5.0)
        XCTAssertNotNil(fetchedError)
        XCTAssertEqual(useCaseCompletionCallsCount, 1)
        XCTAssertEqual(productsRepositoryMock.fetchCompletionCallsCount, 1)
    }
}
