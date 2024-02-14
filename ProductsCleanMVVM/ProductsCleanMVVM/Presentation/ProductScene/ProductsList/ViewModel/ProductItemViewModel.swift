//
//  ProductsListItemViewModel.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 08/02/24.
//

import Foundation


struct ProductItemViewModel: Hashable, Identifiable {
    
    var id : Int
    var title: String
    var description: String
    var price: Int
    var image: String
}

extension ProductItemViewModel {

     init(product: Product) {
        self.id = product.id 
        self.title = product.title ?? ""
        self.description = product.description ?? ""
        self.price = product.price ?? 0
        self.image = product.thumbnail ?? ""
    }
}
