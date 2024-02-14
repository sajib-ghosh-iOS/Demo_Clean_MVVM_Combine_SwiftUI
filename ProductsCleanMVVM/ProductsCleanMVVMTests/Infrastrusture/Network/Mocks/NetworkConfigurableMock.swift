//
//  NetworkConfigurableMock.swift
//  ProductsCleanMVVMTests
//
//  Created by Sajib Ghosh on 13/02/24.
//

import Foundation
@testable import ProductsCleanMVVM

class NetworkConfigurableMock: NetworkConfigurable {
    var baseURL: URL = URL(string: "https://mock.test.com")!
    var headers: [String : String] = [:]
    var queryParameters: [String : String] = [:]
}
