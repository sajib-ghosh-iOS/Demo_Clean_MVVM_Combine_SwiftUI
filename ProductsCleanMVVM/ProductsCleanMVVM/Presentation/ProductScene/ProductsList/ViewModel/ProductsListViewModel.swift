//
//  ProductsListViewModel.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 08/02/24.
//

import Foundation
import Combine

protocol ProductsListViewModelOutput {
    func fetchProducts() -> Future<ProductsPage,Error>
}

protocol ProductsListViewModelInput {
    var items: Box<[ProductItemViewModel]> {get}
    var loading: Box<Bool> { get }
    var error: Box<String> { get }
    var isEmpty: Bool { get }
    var screenTitle: String { get }
    var emptyDataTitle: String { get }
    var errorTitle: String { get }
}

typealias ProductsListViewModel = ProductsListViewModelInput & ProductsListViewModelOutput

final class DefaultProductsListViewModel: ProductsListViewModel {
    
    private let productListUseCase: ProductListUseCase
    private let mainQueue: DispatchQueueType
    
    private var pages: [ProductsPage] = []
    
    var skip: Int = 0
    var totalCount: Int = 1
    var limit: Int = 0 {
        didSet{
            if (limit + 10 < totalCount) {
                limit = limit + 10
            }else{
                limit = totalCount - limit
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - OUTPUT
    
    var items: Box<[ProductItemViewModel]> = Box([])
    var loading: Box<Bool> = Box(true)
    var error: Box<String> = Box("")
    var isEmpty: Bool { return items.value.isEmpty }
    var screenTitle: String = "Products"
    var emptyDataTitle: String = "No results"
    var errorTitle: String = "Error"
    
    // MARK: - Init
    
    init(
        productListUseCase: ProductListUseCase,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.productListUseCase = productListUseCase
        self.mainQueue = mainQueue
    }
}

// MARK: - INPUT. View event methods
extension DefaultProductsListViewModel {
    ///fetch products
    ///- Returns: product page if no error
    func fetchProducts() -> Future<ProductsPage,Error> {
        return fetch(loading: true)
    }
}
// MARK: - private

extension DefaultProductsListViewModel {
    
    private func resetPages() {
        skip = 0
        totalCount = 1
        pages.removeAll()
        items.value.removeAll()
    }
    /// Fetch product from productlistusecase
    ///- Returns: product page if no error
    private func fetch(loading: Bool) -> Future<ProductsPage,Error> {
        self.loading.value = loading
        return Future<ProductsPage,Error> { [weak self] promise in
            if let self = self {
                productListUseCase.execute(requestValue: .init(skip: skip, limit: limit))
                    .receive(on: RunLoop.main)
                    .sink { completion in
                    if case let .failure(error) = completion {
                        self.handle(error: error)
                        promise(.failure(error))
                    }
                } receiveValue: { page in
                    self.loading.value = false
                    self.appendPage(page)
                    promise(.success(page))
                }.store(in: &self.cancellables)
            }
        }
        
    }
    ///Append the items value after successfully receiving the pages
    private func appendPage(_ productsPage: ProductsPage) {
        skip = productsPage.skip
        limit = productsPage.limit
        totalCount = productsPage.total

        pages = pages
            .filter { $0.products != productsPage.products }
            + [productsPage]

        items.value = pages.products.map(ProductItemViewModel.init)
    }
    ///error handling for no network
    private func handle(error: Error) {
        self.error.value = error.isInternetConnectionError ?
            "No internet connection" : "Failed loading products"
    }
    
}

extension Array where Element == ProductsPage {
    var products: [Product] { flatMap { $0.products } }
}
