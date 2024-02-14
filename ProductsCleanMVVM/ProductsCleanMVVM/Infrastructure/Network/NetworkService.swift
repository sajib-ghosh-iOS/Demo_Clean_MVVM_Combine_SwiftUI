import Foundation
import Combine

enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
}

protocol NetworkCancellable {
    func cancel()
}


protocol NetworkService {
    func request(endpoint: Requestable) -> Future<Data?,NetworkError>
}

protocol NetworkSessionManager {
    func request(_ request: URLRequest) -> Future<(Data?,URLResponse?),Error>
}

protocol NetworkErrorLogger {
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
}

extension HTTPURLResponse {
     func isResponseOK() -> Bool {
      return (200...299).contains(self.statusCode)
     }
}
// MARK: - Implementation

final class DefaultNetworkService {
    
    private let config: NetworkConfigurable
    private let sessionManager: NetworkSessionManager
    private let logger: NetworkErrorLogger
    private var cancellables = Set<AnyCancellable>()
    init(
        config: NetworkConfigurable,
        sessionManager: NetworkSessionManager,
        logger: NetworkErrorLogger = DefaultNetworkErrorLogger()
    ) {
        self.sessionManager = sessionManager
        self.config = config
        self.logger = logger
    }
    /// Get data from sessionmanager and validate
    /// - Returns: Data and NetworkError
    private func request(
        request: URLRequest
    ) -> Future<Data?,NetworkError> {
        logger.log(request: request)
        return Future<Data?,NetworkError> { [weak self] promise in
            if let self = self {
                sessionManager.request(request).sink { completion in
                    if case let .failure(error) = completion {
                        var networkError: NetworkError
                        networkError = self.resolve(error: error)
                        self.logger.log(error: networkError)
                        promise(.failure(networkError))
                    }
                } receiveValue: { (data,response) in
                    self.logger.log(responseData: data, response: response)
                    
                    var networkError: NetworkError
                    if let response = response as? HTTPURLResponse, !response.isResponseOK() {
                        networkError = .error(statusCode: response.statusCode, data: data)
                        promise(.failure(networkError))
                    }
                    promise(.success(data))
                }.store(in: &self.cancellables)
            }
        }
    }
    
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
            case .notConnectedToInternet: return .notConnected
            case .cancelled: return .cancelled
            default: return .generic(error)
        }
    }
}

extension DefaultNetworkService: NetworkService {
    
    /// create url request and and request api
    /// - Returns: Data and NetworkError
    func request(
        endpoint: Requestable
    ) -> Future<Data?,NetworkError> {
        
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            return request(request: urlRequest)
        } catch {
            return Future<Data?,NetworkError> { promise in
                promise(.failure(NetworkError.urlGeneration))
            }
        }
    }
}

// MARK: - Default Network Session Manager

final class DefaultNetworkSessionManager: NetworkSessionManager {

    private var cancellables = Set<AnyCancellable>()
    
    ///Call api using URLSession
    /// - Returns : Data, URLResponse if no error, otherwise error
    func request(
        _ request: URLRequest) -> Future<(Data?,URLResponse?),Error> {
            return Future<(Data?,URLResponse?),Error> { [weak self] promise in
                if let self = self {
                    URLSession.shared.dataTaskPublisher(for: request)
                        .map(\.data,\.response)
                        .mapError({ error in
                        return error as Error
                    })
                        .sink { completion in
                            if case let .failure(error) = completion {
                                promise(.failure(error))
                            }
                        } receiveValue: {
                            promise(.success(($0.0, $0.1)))
                        }.store(in: &self.cancellables)
                }
            }
    }
}

// MARK: - Logger

final class DefaultNetworkErrorLogger: NetworkErrorLogger {
    init() { }
    
    /// logs request
    func log(request: URLRequest) {
        print("-------------")
        print("request: \(request.url!)")
        print("headers: \(request.allHTTPHeaderFields!)")
        print("method: \(request.httpMethod!)")
        if let httpBody = request.httpBody, let result = ((try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject]) as [String: AnyObject]??) {
            printIfDebug("body: \(String(describing: result))")
        } else if let httpBody = request.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            printIfDebug("body: \(String(describing: resultString))")
        }
    }
    /// logs Data and URLResponse
    func log(responseData data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            printIfDebug("responseData: \(String(describing: dataDict))")
        }
    }

    func log(error: Error) {
        printIfDebug("\(error)")
    }
}

// MARK: - NetworkError extension

extension NetworkError {
    var isNotFoundError: Bool { return hasStatusCode(404) }
    
    func hasStatusCode(_ codeError: Int) -> Bool {
        switch self {
        case let .error(code, _):
            return code == codeError
        default: return false
        }
    }
}

extension Dictionary where Key == String {
    func prettyPrint() -> String {
        var string: String = ""
        if let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            if let nstr = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                string = nstr as String
            }
        }
        return string
    }
}

func printIfDebug(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}
