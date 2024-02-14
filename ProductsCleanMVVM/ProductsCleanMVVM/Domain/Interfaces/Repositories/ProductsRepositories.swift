//
//  ProductsRepositories.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 08/02/24.
//

import Foundation
import Combine

protocol ProductsRepository {
    func fetchProductsList(
        skip: Int,
        limit: Int) -> Future<ProductsPage,Error>
}
