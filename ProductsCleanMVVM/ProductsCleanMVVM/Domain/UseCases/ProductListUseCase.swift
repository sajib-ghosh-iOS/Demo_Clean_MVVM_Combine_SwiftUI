//
//  ProductListUseCase.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 08/02/24.
//

import Foundation
import Combine

protocol ProductListUseCase {
    func execute(
        requestValue: ProductListUseCaseRequestValue
    ) -> Future<ProductsPage,Error>
}

final class DefaultProductListUseCase: ProductListUseCase {

    private let productsRepository: ProductsRepository

    init(
        productsRepository: ProductsRepository
    ) {

        self.productsRepository = productsRepository
    }
    ///Fetch product list from repository
    /// - Returns: Product page if no error otherwise error
    func execute(
        requestValue: ProductListUseCaseRequestValue) -> Future<ProductsPage,Error> {

        return productsRepository.fetchProductsList(
            skip: requestValue.skip,
            limit: requestValue.limit)
    }
}

struct ProductListUseCaseRequestValue {
    let skip: Int
    let limit: Int
}
