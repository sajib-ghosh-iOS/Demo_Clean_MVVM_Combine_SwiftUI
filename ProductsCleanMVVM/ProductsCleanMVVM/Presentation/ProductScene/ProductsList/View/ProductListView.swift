//
//  ProductListView.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 08/02/24.
//

import SwiftUI

struct ProductListView : View {
    
    @ObservedObject private var viewModelWrapper: ProductListViewModelWrapper
    
    var body: some View {
        NavigationStack{
            if viewModelWrapper.isLoading {
                ///show loader
                ActivityIndicator(isAnimating: viewModelWrapper.isLoading){
                    $0.color = .red
                    $0.hidesWhenStopped = true
                }
            }else{
                ///Show list
                ProductListLayout(items: viewModelWrapper.items)
                    .navigationTitle(viewModelWrapper.title)
                .overlay {
                    ///Show error
                    if(viewModelWrapper.showError){
                        ErrorView(errorTitle: viewModelWrapper.errorTitle, errorDescription: viewModelWrapper.errorDescription) {
                            _ = viewModelWrapper.viewModel?.fetchProducts()
                        }
                    }else if(viewModelWrapper.isEmpty){
                        ErrorView(errorTitle: viewModelWrapper.emptyTitle, errorDescription: "") {
                            _ = viewModelWrapper.viewModel?.fetchProducts()
                        }
                    }
                }
            }
        }.onAppear(perform: {
            _ = viewModelWrapper.viewModel?.fetchProducts()

        })
        .preferredColorScheme(.light)
    }
    
    static func create(
        with viewModel: ProductListViewModelWrapper) -> ProductListView {
        let view = ProductListView(viewModelWrapper: viewModel)
        return view
    }
    
}

#Preview {
    ProductListView.create(with: ProductListViewModelWrapper(viewModel: nil))
}


