//
//  DefaultProductsRepository.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 08/02/24.
//

import Foundation
import Combine

final class DefaultProductsRepository {

    private let dataTransferService: DataTransferService
    private let backgroundQueue: DataTransferDispatchQueue
    private var cancellables = Set<AnyCancellable>()
    init(
        dataTransferService: DataTransferService,
        backgroundQueue: DataTransferDispatchQueue = DispatchQueue.global(qos: .userInitiated)
    ) {
        self.dataTransferService = dataTransferService
        self.backgroundQueue = backgroundQueue
    }
}

extension DefaultProductsRepository: ProductsRepository {
    
    ///Fetch products from dataTransferService
    ///- Returns: Product page if no error otherwise error
    func fetchProductsList(skip: Int, limit: Int) -> Future<ProductsPage,Error> {
        
        let requestDTO = ProductsRequestDTO(skip: skip, limit: limit)
        let endpoint = APIEndpoints.getProducts(with: requestDTO)
        return Future<ProductsPage,Error> { [weak self] promise in
            if let self = self {
                self.dataTransferService.request(
                    with: endpoint,
                    on: backgroundQueue
                ).sink { completion in
                    if case let .failure(error) = completion {
                        promise(.failure(error))
                    }
                } receiveValue: { responseDTO in
                    promise(.success(responseDTO.toDomain()))
                }.store(in: &self.cancellables)
            }
        }
        
        
    }
    
}
