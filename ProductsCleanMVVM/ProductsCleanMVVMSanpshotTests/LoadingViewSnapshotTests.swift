//
//  LoadingViewSnapshotTests.swift
//  ProductsCleanMVVMSanpshotTests
//
//  Created by Sajib Ghosh on 15/02/24.
//

import XCTest
import FBSnapshotTestCase
import SwiftUI
@testable import ProductsCleanMVVM

final class LoadingViewSnapshotTests: FBSnapshotTestCase {

    lazy var loadingVC : UIHostingController<ActivityIndicator>? = {
        let loadingVC = ActivityIndicator(isAnimating: true)
        return UIHostingController(rootView: loadingVC)
    }()
    
    override func setUp() {
        super.setUp()
        //recordMode = true
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = loadingVC
        window.makeKeyAndVisible()
        loadingVC?.view.frame = UIScreen.main.bounds
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        loadingVC = nil
    }
    
    func test_LaunchFor_LoadingView() {
        FBSnapshotVerifyView(loadingVC?.view ?? UIView())
    }

}
