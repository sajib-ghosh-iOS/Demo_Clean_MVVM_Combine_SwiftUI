//
//  ProductsCleanMVVMApp.swift
//  ProductsCleanMVVM
//
//  Created by Sajib Ghosh on 08/02/24.
//

import SwiftUI

@main
struct ProductsCleanMVVMApp: App {
    var body: some Scene {
        WindowGroup {
            let appDIContainer = AppDIContainer()
            let flow = AppFlowCoordinator(appDIContainer: appDIContainer)
            flow.showInitialView()
        }
    }
}
