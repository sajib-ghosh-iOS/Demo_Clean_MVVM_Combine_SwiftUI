//
//  ProductListViewModelWrapper.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 14/02/24.
//

import Foundation

final class ProductListViewModelWrapper: ObservableObject {
    var viewModel: ProductsListViewModel?
    @Published var items: [ProductItemViewModel] = []
    @Published var title = ""
    @Published var showError = false
    @Published var errorTitle = ""
    @Published var errorDescription = ""
    @Published var isEmpty = false
    @Published var emptyTitle = ""
    @Published var isLoading = false
    
    init(viewModel: ProductsListViewModel?) {
        self.viewModel = viewModel
        
        title = viewModel?.screenTitle ?? ""
        emptyTitle = viewModel?.emptyDataTitle ?? ""
        errorTitle = viewModel?.errorTitle ?? ""
        isEmpty = viewModel?.isEmpty ?? false
        
        viewModel?.items.bind(listener: { [weak self] items in
            self?.showError = false
            self?.isEmpty = items.isEmpty
            self?.items = items
        })
        
        viewModel?.error.bind { [weak self] error in
            if error != "" {
                self?.showError = true
                self?.isLoading = false
            }
            self?.errorDescription = error
        }
        
        viewModel?.loading.bind { [weak self] isLoading in
            self?.isLoading = isLoading
            if isLoading {
                self?.isEmpty = false
            }else{
                self?.isEmpty = self?.items.isEmpty ?? true
            }
        }
    }
}
