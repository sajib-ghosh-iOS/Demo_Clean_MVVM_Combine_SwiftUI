//
//  ProductDetailsViewModel.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 11/02/24.
//

import Foundation

protocol ProductDetailsViewModelInput {
}

protocol ProductDetailsViewModelOutput {
    var title: String { get }
    var description: String { get }
    var price: Int { get }
    var image: String { get }
    var screenTitle: String { get }
}

protocol ProductDetailsViewModel: ProductDetailsViewModelInput, ProductDetailsViewModelOutput { }

final class DefaultProductDetailsViewModel: ProductDetailsViewModel {
    
    
    private let mainQueue: DispatchQueueType

    // MARK: - OUTPUT
    let title: String
    let description: String
    let price: Int
    let image: String
    var screenTitle: String = "Product Details"
    
    init(
        product: ProductItemViewModel,
        mainQueue: DispatchQueueType = DispatchQueue.main
    ) {
        self.title = product.title
        self.description = product.description
        self.price = product.price
        self.image = product.image
        self.mainQueue = mainQueue
    }
}
