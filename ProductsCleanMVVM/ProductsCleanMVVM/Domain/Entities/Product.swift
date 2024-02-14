//
//  Product.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 08/02/24.
//

import Foundation
struct Product: Equatable, Identifiable {
    typealias Identifier = Int
    let id: Identifier
    let title: String?
    let description: String?
    let price: Int?
    let discountPercentage: Double?
    let rating: Double?
    let stock: Int?
    let brand: String?
    let category: String?
    let thumbnail: String?
    let images: [String]?
}

struct ProductsPage: Equatable {
    let skip: Int
    let limit: Int
    let total: Int
    let products: [Product]
}
