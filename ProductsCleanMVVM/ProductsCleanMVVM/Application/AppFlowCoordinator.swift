//
//  AppFlowCoordinator.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 10/02/24.
//

import Foundation

final class AppFlowCoordinator {

    private let appDIContainer: AppDIContainer
    
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }

    func showInitialView() -> ProductListView {
        let productsSceneDIContainer = appDIContainer.makeProductsSceneDIContainer()
        return productsSceneDIContainer.makeProductsListView()
    }
}
