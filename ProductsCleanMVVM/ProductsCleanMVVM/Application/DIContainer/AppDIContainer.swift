//
//  AppDIContainer.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 10/02/24.
//

import Foundation
final class AppDIContainer {
    
    lazy var appConfiguration = AppConfiguration()
    
    // MARK: - Network
    lazy var apiDataTransferService: DataTransferService = {
        let config = ApiDataNetworkConfig(
            baseURL: URL(string: AppConfiguration.appBaseURL)!
        )
        let apiDataNetwork = DefaultNetworkService(config: config, sessionManager: DefaultNetworkSessionManager())
        return DefaultDataTransferService(with: apiDataNetwork)
    }()
    
    // MARK: - DIContainers of scenes
    func makeProductsSceneDIContainer() -> ProductsSceneDIContainer {
        let dependencies = ProductsSceneDIContainer.Dependencies(
            apiDataTransferService: apiDataTransferService
        )
        return ProductsSceneDIContainer(dependencies: dependencies)
    }
}
