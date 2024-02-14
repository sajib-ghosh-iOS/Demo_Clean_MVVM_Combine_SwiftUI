//
//  ProductsSceneDIContainer.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 10/02/24.
//

import Foundation
import SwiftUI

final class ProductsSceneDIContainer: ProductFlowCoordinatorDependencies {

    struct Dependencies {
        let apiDataTransferService: DataTransferService
    }
    
    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - Use Cases
    /// Return
    func makeProductsListUseCase() -> ProductListUseCase {
        DefaultProductListUseCase(
            productsRepository: makeProductsRepository()
        )
    }
    
    
    // MARK: - Repositories
    func makeProductsRepository() -> ProductsRepository {
        DefaultProductsRepository(
            dataTransferService: dependencies.apiDataTransferService
        )
    }

    
    // MARK: - Product List
    func makeProductsListView() -> ProductListView {
        ProductListView.create(
            with: makeProductsListViewModel()
        )
    }
    
    func makeProductsListViewModel() -> ProductListViewModelWrapper {
        ProductListViewModelWrapper(viewModel: DefaultProductsListViewModel(productListUseCase: makeProductsListUseCase()))
    }
    
}
