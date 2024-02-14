//
//  NetworkSessionManagerMock.swift
//  ProductsCleanMVVMTests
//
//  Created by Sajib Ghosh on 13/02/24.
//

import Foundation
import Combine
@testable import ProductsCleanMVVM

struct NetworkSessionManagerMock : NetworkSessionManager {
    
    
    let response: HTTPURLResponse?
    let data: Data?
    let error: Error?
    
    func request(_ request: URLRequest) -> Future<(Data?, URLResponse?), Error> {
        return Future<(Data?,URLResponse?),Error> { promise in
            if data != nil || response != nil {
                promise(.success((data,response)))
            }
            if let error {
                promise(.failure(error))
            }
        }
    }
    
}
