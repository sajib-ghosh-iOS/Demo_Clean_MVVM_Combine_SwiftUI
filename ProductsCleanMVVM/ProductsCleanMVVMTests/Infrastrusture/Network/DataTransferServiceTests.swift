//
//  DataTransferServiceTests.swift
//  ProductsCleanMVVMTests
//
//  Created by Sajib Ghosh on 13/02/24.
//

import XCTest
@testable import ProductsCleanMVVM

private struct MockModel: Decodable {
    let name: String
}

final class DataTransferDispatchQueueMock: DataTransferDispatchQueue {
    func asyncExecute(work: @escaping () -> Void) {
        work()
    }
}


final class DataTransferServiceTests: XCTestCase {

    private enum DataTransferErrorMock: Error {
        case someError
    }
    
    func test_whenReceivedValidJsonInResponse_shouldDecodeResponseToDecodableObject() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let responseData = #"{"name": "Hello"}"#.data(using: .utf8)
        let networkService = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(
                response: nil,
                data: responseData,
                error: nil
            )
        )
        
        let sut = DefaultDataTransferService(with: networkService)
        let endPoint = Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get)
        //when
        _ = sut.request(
            with: endPoint,
            on: DataTransferDispatchQueueMock()
        )
        .sink(receiveCompletion: { completion in
            if case .failure(_) = completion {
                XCTFail("Should return proper response")
                return
            }
        }, receiveValue: { model in
            XCTAssertEqual(model.name, "Hello")
            completionCallsCount += 1
        })
        
        //then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    func test_whenInvalidResponse_shouldNotDecodeObject() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let responseData = #"{"age": 20}"#.data(using: .utf8)
        let networkService = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(
                response: HTTPURLResponse(),
                data: responseData,
                error: nil
            )
        )
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(
            with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get),
            on: DataTransferDispatchQueueMock()
        ).sink(receiveCompletion: { completion in
            if case .failure(_) = completion {
                completionCallsCount += 1
            }
        }, receiveValue: { model in
            XCTFail("Should not happen")
        })
        
        //then
        XCTAssertEqual(completionCallsCount, 1)
    }
    
    func test_whenBadRequestReceived_shouldRethrowNetworkError() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let responseData = #"{"invalidStructure": "Nothing"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 500,
                                       httpVersion: "1.1",
                                       headerFields: nil)
        let networkService = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(
                response: response,
                data: responseData,
                error: DataTransferErrorMock.someError
            )
        )
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(
            with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get),
            on: DataTransferDispatchQueueMock()
        ).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                if case DataTransferError.networkFailure(NetworkError.error(statusCode: 500, _)) = error {
                    completionCallsCount += 1
                }else {
                    XCTFail("Wrong error")
                }
            }
        }, receiveValue: { model in
            XCTFail("Should not happen")
        })
        
        //then
        XCTAssertEqual(completionCallsCount, 1)
    }

    func test_whenNoDataReceived_shouldThrowNoDataError() {
        //given
        let config = NetworkConfigurableMock()
        var completionCallsCount = 0
        
        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 200,
                                       httpVersion: "1.1",
                                       headerFields: [:])
        let networkService = DefaultNetworkService(
            config: config,
            sessionManager: NetworkSessionManagerMock(
                response: response,
                data: nil,
                error: nil
            )
        )
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(
            with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get),
            on: DataTransferDispatchQueueMock()
        ).sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                if case DataTransferError.noResponse = error {
                    completionCallsCount += 1
                } else {
                    XCTFail("Wrong error")
                }
            }
        }, receiveValue: { model in
            XCTFail("Should not happen")
        })
        
        //then
        XCTAssertEqual(completionCallsCount, 1)
    }
}

